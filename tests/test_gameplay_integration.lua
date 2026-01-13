#!/usr/bin/env lua5.3

-- Test Gameplay Integration
-- Comprehensive end-to-end tests for all gameplay steps
-- Tests the complete flow: Buy → Refuel → Repair → Charter → Load → Sail → Sell

local gamestate = require("game")
local broker_model = require("game.broker_model")
local ship_operations = require("game.ship_operations")
local routes_model = require("game.routes_model")
local world = require("game.world")
local turn = require("game.turn")

print("Testing Complete Gameplay Integration...")
print("")

-- Test 1: Initial game setup
print("=== Test 1: Initial Game Setup ===")
local game = gamestate.new()
assert(game.rubles == 5000000, "Should start with 5M Rubles")
assert(#game.fleet == 2, "Should start with 2 ships")
assert(game.heat == 0, "Should start with 0 heat")
print("✓ Game initialized correctly")
print("  - Starting Rubles: " .. game.rubles)
print("  - Starting Fleet: " .. #game.fleet .. " ships")
print("")

-- Test 2: Buy a ship from broker
print("=== Test 2: Ship Purchasing ===")
local available_ships = broker_model.get_available_ships(game)
assert(#available_ships == 6, "Should have 6 ships available for purchase")

local ship_to_buy = available_ships[1]  -- Buy GHOST-XX
local initial_rubles = game.rubles
local initial_fleet = #game.fleet
local success, msg = broker_model.buy_ship(game, ship_to_buy)

assert(success == true, "Should successfully purchase ship")
assert(#game.fleet == initial_fleet + 1, "Fleet should grow by 1")
assert(game.rubles == initial_rubles - ship_to_buy.price, "Rubles should be deducted")
print("✓ Successfully bought ship: " .. game.fleet[#game.fleet].name)
print("  - Cost: " .. ship_to_buy.price .. " Rubles")
print("  - Remaining: " .. game.rubles .. " Rubles")
print("  - Fleet size: " .. #game.fleet .. " ships")
print("")

-- Test 3: Refuel a ship
print("=== Test 3: Ship Refueling ===")
local ship = game.fleet[1]
ship.fuel = 50  -- Set low fuel for testing
local target_fuel = 100
local refuel_cost = ship_operations.calculate_refuel_cost(ship.fuel, target_fuel)
local rubles_before = game.rubles

ship_operations.refuel_ship(game, ship, target_fuel, refuel_cost)

assert(ship.fuel == target_fuel, "Ship should be refueled to target")
assert(game.rubles == rubles_before - refuel_cost, "Rubles should be deducted")
print("✓ Successfully refueled " .. ship.name)
print("  - From: 50% to: 100%")
print("  - Cost: " .. refuel_cost .. " Rubles")
print("  - Remaining: " .. game.rubles .. " Rubles")
print("")

-- Test 4: Repair a ship
print("=== Test 4: Ship Repair ===")
ship.hull = 60  -- Set damaged hull for testing
local target_hull = 100
local repair_cost = ship_operations.calculate_repair_cost(ship.hull, target_hull)
rubles_before = game.rubles

ship_operations.repair_ship(game, ship, target_hull, repair_cost)

assert(ship.hull == target_hull, "Ship should be repaired to target")
assert(game.rubles == rubles_before - repair_cost, "Rubles should be deducted")
print("✓ Successfully repaired " .. ship.name)
print("  - From: 60% to: 100%")
print("  - Cost: " .. repair_cost .. " Rubles")
print("  - Remaining: " .. game.rubles .. " Rubles")
print("")

-- Test 5: Load cargo onto ship
print("=== Test 5: Cargo Loading ===")
ship.cargo = nil  -- Clear any existing cargo
local port = world.get_port(ship.origin_id)
local cargo_amount = 500  -- Load full capacity
local cargo_cost = routes_model.calculate_cargo_cost(cargo_amount, port.oil_price)
rubles_before = game.rubles

routes_model.load_cargo(game, ship, cargo_amount, cargo_cost)

assert(ship.cargo ~= nil, "Ship should have cargo")
assert(ship.cargo.crude == cargo_amount, "Ship should have correct cargo amount")
assert(game.rubles == rubles_before - cargo_cost, "Rubles should be deducted")
print("✓ Successfully loaded cargo onto " .. ship.name)
print("  - Amount: " .. cargo_amount .. "k barrels")
print("  - Cost: " .. cargo_cost .. " Rubles")
print("  - Remaining: " .. game.rubles .. " Rubles")
print("")

-- Test 6: Charter route and depart
print("=== Test 6: Charter Route & Depart ===")
local destinations = world.get_destinations(ship.origin_id)
assert(#destinations > 0, "Should have available destinations")

local destination = destinations[1]
local route = destination.route
routes_model.depart_ship(ship, destination.port, route)

assert(ship.status == "at_sea", "Ship should be at sea")
assert(ship.destination_id == destination.port.id, "Ship should have destination")
assert(ship.days_remaining == route.days, "Ship should have days remaining")
assert(ship.cargo.crude == cargo_amount, "Ship should still have cargo")
print("✓ Successfully departed for " .. destination.port.name)
print("  - Route: " .. route.days .. " days")
print("  - Risk: " .. route.risk)
print("  - Cargo: " .. cargo_amount .. "k barrels")
print("")

-- Test 7: Simulate voyage (advance turns)
print("=== Test 7: Simulate Voyage ===")
local initial_days = ship.days_remaining
local turn_count = 0

while ship.status == "at_sea" and turn_count < 20 do
    turn.process(game)
    turn_count = turn_count + 1
end

assert(ship.status == "in_port", "Ship should arrive at port")
assert(ship.days_remaining == nil or ship.days_remaining == 0, "Ship should have no days remaining")
assert(ship.cargo.crude == cargo_amount, "Ship should still have cargo after voyage")
print("✓ Ship arrived at destination after " .. turn_count .. " turns")
print("  - Destination: " .. world.port_name(ship.destination_id))
print("  - Hull: " .. math.floor(ship.hull) .. "%")
print("  - Fuel: " .. math.floor(ship.fuel) .. "%")
print("")

-- Test 8: Sell cargo at destination
print("=== Test 8: Cargo Sale ===")
local dest_port = world.get_port(ship.destination_id)
local revenue = routes_model.calculate_cargo_revenue(cargo_amount, dest_port.oil_price)
rubles_before = game.rubles
local heat_before = game.heat

routes_model.sell_cargo(game, ship, revenue)

assert(ship.cargo == nil, "Ship should have no cargo after sale")
assert(game.rubles == rubles_before + revenue, "Rubles should increase")
assert(game.heat == heat_before + 1, "Heat should increase by 1")
print("✓ Successfully sold cargo at " .. dest_port.name)
print("  - Revenue: " .. revenue .. " Rubles")
print("  - Total Rubles: " .. game.rubles)
print("  - Heat: " .. game.heat .. "/" .. game.heat_max)
print("")

-- Test 9: Sell a ship
print("=== Test 9: Ship Sale ===")
rubles_before = game.rubles
local fleet_before = #game.fleet
success, msg = broker_model.sell_ship(game, #game.fleet)  -- Sell last ship

assert(success == true, "Should successfully sell ship")
assert(#game.fleet == fleet_before - 1, "Fleet should shrink by 1")
assert(game.rubles > rubles_before, "Rubles should increase")
print("✓ Successfully sold ship")
print("  - Sale proceeds added to account")
print("  - Final Rubles: " .. game.rubles)
print("  - Final Fleet: " .. #game.fleet .. " ships")
print("")

-- Test 10: Verify economic viability
print("=== Test 10: Economic Analysis ===")
local net_change = game.rubles - 5000000
print("✓ Complete gameplay loop executed successfully")
print("  - Starting capital: 5,000,000 Rubles")
print("  - Final capital: " .. game.rubles .. " Rubles")
if net_change > 0 then
    print("  - Net profit: +" .. net_change .. " Rubles")
else
    print("  - Net change: " .. net_change .. " Rubles")
end
print("  - Final heat: " .. game.heat .. "/" .. game.heat_max)
print("  - Turns played: " .. game.turn)
print("")

print("===================================")
print("All gameplay integration tests passed! ✓")
print("===================================")
print("")
print("Tested complete gameplay loop:")
print("  1. ✓ Initial game setup")
print("  2. ✓ Buy ship from broker")
print("  3. ✓ Refuel ship at port")
print("  4. ✓ Repair ship hull")
print("  5. ✓ Load cargo at export terminal")
print("  6. ✓ Charter route and depart")
print("  7. ✓ Simulate voyage (turn processing)")
print("  8. ✓ Sell cargo at destination")
print("  9. ✓ Sell ship back to broker")
print(" 10. ✓ Economic viability analysis")
print("")
print("All gameplay mechanics working end-to-end!")
print("===================================")

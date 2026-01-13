#!/usr/bin/env lua5.3

-- Test Edge Cases
-- Tests boundary conditions and edge cases in the game logic

local gamestate = require("game")
local broker_model = require("game.broker_model")
local ship_operations = require("game.ship_operations")
local routes_model = require("game.routes_model")
local world = require("game.world")

print("Testing Edge Cases...")
print("")

-- Test 1: Empty fleet scenarios
print("=== Test 1: Empty Fleet ===")
local game = gamestate.new()
game.fleet = {}  -- Empty the fleet

-- Get ships for refueling with empty fleet
local ships_for_refuel = ship_operations.get_ships_for_refuel(game)
assert(#ships_for_refuel == 0, "Should return empty list for empty fleet")
print("✓ Empty fleet returns no ships for refuel")

-- Get ships for repair with empty fleet
local ships_for_repair = ship_operations.get_ships_for_repair(game)
assert(#ships_for_repair == 0, "Should return empty list for empty fleet")
print("✓ Empty fleet returns no ships for repair")

-- Get ships for loading with empty fleet
local ships_for_loading = routes_model.get_ships_for_loading(game)
assert(#ships_for_loading == 0, "Should return empty list for empty fleet")
print("✓ Empty fleet returns no ships for loading")

-- Test 2: Invalid cargo amounts
print("")
print("=== Test 2: Invalid Cargo Amounts ===")
game = gamestate.new()
local ship = game.fleet[1]

-- Zero amount
local valid, err = routes_model.validate_cargo_load(ship, 0, 0, game.rubles)
assert(not valid, "Should reject zero cargo amount")
assert(err == "Invalid amount", "Should have correct error message")
print("✓ Rejects zero cargo amount")

-- Negative amount
valid, err = routes_model.validate_cargo_load(ship, -10, 0, game.rubles)
assert(not valid, "Should reject negative cargo amount")
print("✓ Rejects negative cargo amount")

-- Nil amount
valid, err = routes_model.validate_cargo_load(ship, nil, 0, game.rubles)
assert(not valid, "Should reject nil cargo amount")
print("✓ Rejects nil cargo amount")

-- Test 3: Insufficient funds scenarios
print("")
print("=== Test 3: Insufficient Funds ===")
game = gamestate.new()
game.rubles = 100  -- Very low funds
ship = game.fleet[1]
ship.fuel = 50

-- Refuel with insufficient funds
local target_fuel = 100
local refuel_cost = ship_operations.calculate_refuel_cost(ship.fuel, target_fuel)
valid, err = ship_operations.validate_refuel(ship, target_fuel, refuel_cost, game.rubles)
assert(not valid, "Should reject refuel with insufficient funds")
assert(err:find("Insufficient funds"), "Should have insufficient funds error message")
print("✓ Rejects refuel with insufficient funds")

-- Repair with insufficient funds
ship.hull = 50
local target_hull = 100
local repair_cost = ship_operations.calculate_repair_cost(ship.hull, target_hull)
valid, err = ship_operations.validate_repair(ship, target_hull, repair_cost, game.rubles)
assert(not valid, "Should reject repair with insufficient funds")
assert(err:find("Insufficient funds"), "Should have insufficient funds error message")
print("✓ Rejects repair with insufficient funds")

-- Load cargo with insufficient funds
local port = world.get_port(ship.origin_id)
local cargo_cost = routes_model.calculate_cargo_cost(100, port.oil_price)
valid, err = routes_model.validate_cargo_load(ship, 100, cargo_cost, game.rubles)
assert(not valid, "Should reject cargo load with insufficient funds")
assert(err:find("Insufficient funds"), "Should have insufficient funds error message")
print("✓ Rejects cargo load with insufficient funds")

-- Test 4: Boundary values for repair and refuel
print("")
print("=== Test 4: Boundary Values ===")
game = gamestate.new()
ship = game.fleet[1]

-- Repair from 100% to 100% (no-op case)
ship.hull = 100
target_hull = 100
repair_cost = ship_operations.calculate_repair_cost(ship.hull, target_hull)
assert(repair_cost == 0, "Repairing from 100% to 100% should cost 0")
print("✓ Repair cost is 0 when already at 100%")

-- Refuel from 100% to 100% (no-op case)
ship.fuel = 100
target_fuel = 100
refuel_cost = ship_operations.calculate_refuel_cost(ship.fuel, target_fuel)
assert(refuel_cost == 0, "Refueling from 100% to 100% should cost 0")
print("✓ Refuel cost is 0 when already at 100%")

-- Repair from 0% to 100% (maximum repair)
ship.hull = 0
target_hull = 100
repair_cost = ship_operations.calculate_repair_cost(ship.hull, target_hull)
assert(repair_cost == 100 * 10000, "Maximum repair should cost 1,000,000")
print("✓ Maximum repair (0% to 100%) costs correct amount")

-- Refuel from 0% to 100% (maximum refuel)
ship.fuel = 0
target_fuel = 100
refuel_cost = ship_operations.calculate_refuel_cost(ship.fuel, target_fuel)
assert(refuel_cost == 100 * 5000, "Maximum refuel should cost 500,000")
print("✓ Maximum refuel (0% to 100%) costs correct amount")

-- Test 5: Invalid command inputs
print("")
print("=== Test 5: Invalid Ship Indices ===")
game = gamestate.new()

-- Negative index for selling ship
local success, msg = broker_model.sell_ship(game, -1)
assert(not success, "Should reject negative ship index")
print("✓ Rejects negative ship index for sale")

-- Zero index for selling ship
success, msg = broker_model.sell_ship(game, 0)
assert(not success, "Should reject zero ship index")
print("✓ Rejects zero ship index for sale")

-- Out of bounds index for selling ship
success, msg = broker_model.sell_ship(game, #game.fleet + 10)
assert(not success, "Should reject out of bounds ship index")
print("✓ Rejects out of bounds ship index for sale")

-- Test 6: Heat level boundaries
print("")
print("=== Test 6: Heat Level Boundaries ===")
game = gamestate.new()

-- Heat at 0
game.heat = 0
local heat_desc = gamestate.get_heat_description(game)
assert(type(heat_desc) == "string", "Should return string for heat description")
print("✓ Heat description works at 0")

-- Heat at maximum
game.heat = game.heat_max
heat_desc = gamestate.get_heat_description(game)
assert(type(heat_desc) == "string", "Should return string for heat description at max")
print("✓ Heat description works at maximum")

-- Heat color at different levels
game.heat = 0
local color = gamestate.get_heat_color(game)
assert(type(color) == "string", "Should return color for heat level 0")

game.heat = 3
color = gamestate.get_heat_color(game)
assert(type(color) == "string", "Should return color for heat level 3")

game.heat = 7
color = gamestate.get_heat_color(game)
assert(type(color) == "string", "Should return color for heat level 7")

game.heat = 10
color = gamestate.get_heat_color(game)
assert(type(color) == "string", "Should return color for heat level 10")
print("✓ Heat color works at all threshold levels")

-- Test 7: Upgrade availability edge cases
print("")
print("=== Test 7: Upgrade Availability ===")
game = gamestate.new()
ship = game.fleet[1]

-- Ship with hull at 100% should not be able to get hull repair
ship.hull = 100
local available_upgrades = gamestate.get_available_upgrades(game, ship)
local has_hull_repair = false
for _, upgrade in ipairs(available_upgrades) do
    if upgrade.name == "Hull Repair" then
        has_hull_repair = true
        break
    end
end
assert(not has_hull_repair, "Hull repair should not be available when hull is at 100%")
print("✓ Hull repair not available when hull is at 100%")

-- Ship with damaged hull should be able to get hull repair
ship.hull = 50
available_upgrades = gamestate.get_available_upgrades(game, ship)
has_hull_repair = false
for _, upgrade in ipairs(available_upgrades) do
    if upgrade.name == "Hull Repair" then
        has_hull_repair = true
        break
    end
end
assert(has_hull_repair, "Hull repair should be available when hull is damaged")
print("✓ Hull repair available when hull is damaged")

-- Test 8: Cargo capacity edge cases
print("")
print("=== Test 8: Cargo Capacity ===")
game = gamestate.new()
ship = game.fleet[1]
ship.capacity = 500

-- Loading cargo exactly at capacity should be valid
local amount = ship.capacity
local cost = routes_model.calculate_cargo_cost(amount, 60)
valid, err = routes_model.validate_cargo_load(ship, amount, cost, 999999999)
assert(valid, "Should accept cargo amount equal to capacity")
print("✓ Accepts cargo amount equal to capacity")

-- Loading cargo over capacity should be rejected
amount = ship.capacity + 100
cost = routes_model.calculate_cargo_cost(amount, 60)
valid, err = routes_model.validate_cargo_load(ship, amount, cost, 999999999)
assert(not valid, "Should reject cargo amount over capacity")
assert(err:find("Cannot load"), "Should have capacity error message")
print("✓ Rejects cargo amount over capacity")

print("")
print("===================================")
print("All edge case tests passed! ✓")
print("===================================")
print("")
print("Tested edge cases:")
print("  1. ✓ Empty fleet scenarios")
print("  2. ✓ Invalid cargo amounts (zero, negative, nil)")
print("  3. ✓ Insufficient funds for all operations")
print("  4. ✓ Boundary values for repair and refuel")
print("  5. ✓ Invalid ship indices")
print("  6. ✓ Heat level boundaries and colors")
print("  7. ✓ Upgrade availability conditions")
print("  8. ✓ Cargo capacity limits")
print("")

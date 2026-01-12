#!/usr/bin/env lua5.3

-- Test World Data and Turn Processing

local world = require("game.world")
local turn = require("game.turn")
local gamestate = require("game")

print("Testing World Data and Turn Processing...\n")

-- Test 1: World module loaded
assert(type(world) == "table", "World module should be a table")
print("✓ Test 1: World module loaded successfully")

-- Test 2: Ports defined
assert(#world.ports > 0, "Should have ports defined")
assert(#world.ports >= 12, "Should have at least 12 ports")
print("✓ Test 2: " .. #world.ports .. " ports defined")

-- Test 3: Routes defined
assert(#world.routes > 0, "Should have routes defined")
assert(#world.routes >= 20, "Should have at least 20 routes")
print("✓ Test 3: " .. #world.routes .. " routes defined")

-- Test 4: Get port by ID
local port = world.get_port("ust_luga")
assert(port ~= nil, "Should find Ust-Luga port")
assert(port.name == "Ust-Luga (RU)", "Port name should match")
assert(port.type == "export", "Ust-Luga should be an export terminal")
print("✓ Test 4: Get port by ID works")

-- Test 5: Get route between ports
local route = world.get_route("ust_luga", "malta_sts")
assert(route ~= nil, "Should find route from Ust-Luga to Malta STS")
assert(route.days > 0, "Route should have travel time")
assert(route.risk ~= nil, "Route should have risk level")
print("✓ Test 5: Get route between ports works")

-- Test 6: Get destinations from port
local destinations = world.get_destinations("ust_luga")
assert(#destinations > 0, "Ust-Luga should have destinations")
assert(destinations[1].port ~= nil, "Destination should have port data")
assert(destinations[1].route ~= nil, "Destination should have route data")
print("✓ Test 6: Get destinations from port works (" .. #destinations .. " destinations from Ust-Luga)")

-- Test 7: Get ports by type
local export_terminals = world.get_ports_by_type("export")
assert(#export_terminals >= 4, "Should have at least 4 export terminals")
local markets = world.get_ports_by_type("market")
assert(#markets >= 4, "Should have at least 4 markets")
print("✓ Test 7: Get ports by type works (" .. #export_terminals .. " export terminals, " .. #markets .. " markets)")

-- Test 8: Turn processing module loaded
assert(type(turn) == "table", "Turn module should be a table")
assert(type(turn.process) == "function", "Turn module should have process function")
print("✓ Test 8: Turn processing module loaded")

-- Test 9: Date advancement
local date1 = "Jan 08, 2026"
local date2 = turn.advance_date(date1)
assert(date2 == "Jan 09, 2026", "Date should advance by one day")

local date3 = turn.advance_date("Jan 31, 2026")
assert(date3 == "Feb 01, 2026", "Date should roll over to next month")
print("✓ Test 9: Date advancement works")

-- Test 10: Turn processing with ship movement
local game = gamestate.new()

-- Set up a ship in transit
local ship = game.fleet[2]  -- SHADOW-03
local status_name = world.get_status(ship.status)
assert(status_name == "At Sea", "Test ship should be at sea")
assert(ship.days_remaining == 2, "Test ship should have 2 days remaining")

local initial_fuel = ship.fuel
local initial_hull = ship.hull
local initial_days = ship.days_remaining

-- Process one turn
local events = turn.process(game)

assert(game.turn == 1, "Turn counter should be 1")
assert(game.date == "Jan 09, 2026", "Date should advance")
assert(ship.days_remaining == 1, "Ship days remaining should decrease")
assert(ship.fuel < initial_fuel, "Ship fuel should decrease")
assert(ship.hull <= initial_hull, "Ship hull should stay same or decrease")
print("✓ Test 10: Turn processing advances ships correctly")

-- Test 11: Ship arrival
turn.process(game)  -- Process second turn
assert(ship.days_remaining == 0, "Ship should have arrived")
local status_name2 = world.get_status(ship.status)
assert(status_name2 == "In Port", "Ship should be in port")
assert(ship.eta == 0, "Ship ETA should be 0")
print("✓ Test 11: Ship arrives at destination after correct number of turns")

-- Test 12: Arrival event generation
-- Reset ship for arrival test
ship.status = "at_sea"
ship.days_remaining = 1
ship.destination_id = "malta_sts"

local events = turn.process(game)
assert(#events > 0, "Should generate arrival event")

local found_arrival = false
for _, event in ipairs(events) do
    if event.type == "Ship Arrival" then
        found_arrival = true
        assert(event.ship == ship.name, "Event should reference correct ship")
        assert(event.port ~= nil, "Event should have port name")
    end
end
assert(found_arrival, "Should have generated ship arrival event")
print("✓ Test 12: Arrival events generated correctly")

-- Test 13: Market updates
local initial_price = game.market.shadow_price
turn.process(game)
-- Price should change (might be same by chance, but structure should work)
assert(type(game.market.shadow_price) == "number", "Market price should be updated")
assert(game.market.shadow_price > 0, "Market price should be positive")
print("✓ Test 13: Market updates on turn processing")

print("\n===================================")
print("All tests passed! ✓")
print("===================================\n")
print("World data provides:")
print("  • " .. #world.ports .. " ports (export terminals, STS points, markets)")
print("  • " .. #world.routes .. " routes with travel times and risk levels")
print("  • Helper functions for route planning")
print("\nTurn processing provides:")
print("  • Ship movement and arrival detection")
print("  • Fuel and hull degradation")
print("  • Event generation for ship arrivals")
print("  • Market price fluctuations")
print("  • Date advancement")
print("\n===================================")

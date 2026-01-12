#!/usr/bin/env lua5.3
-- Test Threat System

local world = require("game.world")
local routes_model = require("game.routes_model")

print("Testing Threat System...")

-- Test 1: Threat definitions exist
assert(type(world.threats) == "table", "world.threats should be a table")
assert(world.threats.nato_patrol ~= nil, "nato_patrol threat should be defined")
assert(world.threats.satellite_surveillance ~= nil, "satellite_surveillance threat should be defined")
assert(world.threats.port_inspection ~= nil, "port_inspection threat should be defined")
print("✓ Test 1: Threat definitions exist")

-- Test 2: Get threat by ID works
local threat = world.get_threat("nato_patrol")
assert(type(threat) == "table", "get_threat should return a table")
assert(threat.name == "NATO Patrol", "Threat should have correct name")
assert(type(threat.risk_contribution) == "number", "Threat should have risk_contribution")
print("✓ Test 2: Get threat by ID works")

-- Test 3: Calculate risk from empty/nil threats
local risk = world.calculate_risk_from_threats(nil)
assert(risk == "none", "Nil threats should give 'none' risk")

risk = world.calculate_risk_from_threats({})
assert(risk == "none", "Empty threats should give 'none' risk")
print("✓ Test 3: Calculate risk from empty/nil threats works")

-- Test 4: Calculate risk from low-level threats
local low_threats = {
    ais_scrutiny = true
}
risk = world.calculate_risk_from_threats(low_threats)
assert(risk == "low", "Single low threat should give 'low' risk, got: " .. risk)
print("✓ Test 4: Calculate low risk from threats")

-- Test 5: Calculate risk from medium-level threats
local medium_threats = {
    nato_patrol = true,
    satellite_surveillance = true
}
risk = world.calculate_risk_from_threats(medium_threats)
assert(risk == "low" or risk == "medium", "Two single-contribution threats should give 'low' or 'medium' risk, got: " .. risk)
print("✓ Test 5: Calculate medium risk from threats")

-- Test 6: Calculate risk from high-level threats
local high_threats = {
    nato_patrol = true,
    satellite_surveillance = true,
    port_inspection = true,
    sanctions_enforcement = true
}
risk = world.calculate_risk_from_threats(high_threats)
assert(risk == "high", "Many threats should give 'high' risk, got: " .. risk)
print("✓ Test 6: Calculate high risk from threats")

-- Test 7: Format threats as list
local threat_list = world.format_threats(nil)
assert(threat_list == "None", "Nil threats should format as 'None'")

threat_list = world.format_threats({nato_patrol = true})
assert(threat_list:match("NATO Patrol"), "Threat list should include threat name")
print("✓ Test 7: Format threats as list")

-- Test 8: Format risk with threats
local formatted = world.format_risk_with_threats("medium", {nato_patrol = true, satellite_surveillance = true})
assert(formatted:match("MED"), "Formatted risk should include risk level")
assert(formatted:match("NATO Patrol") or formatted:match("Satellite"), "Formatted risk should include threat names")
print("✓ Test 8: Format risk with threats")

-- Test 9: Depart ship sets threats based on route risk
local ship = {
    name = "TEST-01",
    status = "docked",
    origin_id = "ust_luga"
}
local destination = {id = "malta_sts", name = "STS off Malta"}
local low_route = {from = "ust_luga", to = "malta_sts", days = 7, risk = "low"}

routes_model.depart_ship(ship, destination, low_route)
assert(ship.threats ~= nil, "Ship should have threats after departure")
assert(type(ship.threats) == "table", "Ship threats should be a table")
print("✓ Test 9: Depart ship sets threats based on route risk")

-- Test 10: Different route risks set different threats
local ship_low = {name = "LOW", status = "docked"}
local ship_medium = {name = "MED", status = "docked"}
local ship_high = {name = "HIGH", status = "docked"}

local low_route = {from = "a", to = "b", days = 1, risk = "low"}
local medium_route = {from = "a", to = "b", days = 1, risk = "medium"}
local high_route = {from = "a", to = "b", days = 1, risk = "high"}

routes_model.depart_ship(ship_low, {id = "b"}, low_route)
routes_model.depart_ship(ship_medium, {id = "b"}, medium_route)
routes_model.depart_ship(ship_high, {id = "b"}, high_route)

-- Count threats for each
local function count_threats(threats)
    if not threats then return 0 end
    local count = 0
    for _, v in pairs(threats) do
        if v then count = count + 1 end
    end
    return count
end

local low_count = count_threats(ship_low.threats)
local medium_count = count_threats(ship_medium.threats)
local high_count = count_threats(ship_high.threats)

assert(low_count < medium_count, "Low risk should have fewer threats than medium")
assert(medium_count < high_count, "Medium risk should have fewer threats than high")
print("✓ Test 10: Different route risks set different threat counts")

print("\n===================================")
print("All tests passed! ✓")
print("===================================")
print("\nThe threat system provides:")
print("  • Threat definitions with risk contributions")
print("  • Risk calculation from multiple threats")
print("  • Threat formatting and display")
print("  • Automatic threat assignment on ship departure")
print("===================================")

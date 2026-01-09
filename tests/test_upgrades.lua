#!/usr/bin/env lua5.3
-- Test for vessel upgrade functionality

local gamestate = require("game")

print("Testing Vessel Upgrade System...")
print("")

-- Test 1: Module has upgrade functions
print("Testing upgrade functions exist...")
assert(type(gamestate.can_apply_upgrade) == "function", 
       "gamestate.can_apply_upgrade should be a function")
assert(type(gamestate.apply_upgrade) == "function", 
       "gamestate.apply_upgrade should be a function")
assert(type(gamestate.get_available_upgrades) == "function", 
       "gamestate.get_available_upgrades should be a function")
print("✓ Test 1: All upgrade functions exist")

-- Test 2: Game state has upgrades
print("\nTesting game state has upgrades...")
local game = gamestate.new()
assert(type(game.upgrades) == "table", "game.upgrades should be a table")
assert(#game.upgrades > 0, "game.upgrades should have at least one upgrade")
print("✓ Test 2: Game state has " .. #game.upgrades .. " upgrades defined")

-- Test 3: Test hull repair upgrade applicability
print("\nTesting hull repair upgrade...")
local ship = {
    name = "TEST-01",
    age = 10,
    hull = 50,
    fuel = 80,
    status = "Docked"
}

local hull_upgrade = {
    name = "Hull Repair",
    description = "Restore hull to 100%",
    cost = 500000,
    effect = "hull",
    value = 100
}

local can_apply, reason = gamestate.can_apply_upgrade(ship, hull_upgrade)
assert(can_apply == true, "Hull repair should be applicable to damaged ship")
print("✓ Test 3a: Hull repair is applicable to damaged ship")

-- Apply the upgrade
gamestate.apply_upgrade(ship, hull_upgrade)
assert(ship.hull == 100, "Hull should be 100 after hull repair")
print("✓ Test 3b: Hull repair sets hull to 100%")

-- Test that hull repair is not applicable when hull is at 100%
can_apply, reason = gamestate.can_apply_upgrade(ship, hull_upgrade)
assert(can_apply == false, "Hull repair should not be applicable when hull is at 100%")
assert(reason ~= nil, "Should provide a reason when upgrade is not applicable")
print("✓ Test 3c: Hull repair is not applicable when hull is at 100%")

-- Test 4: Test equipment upgrade
print("\nTesting equipment upgrade...")
local equipment_upgrade = {
    name = "AIS Spoofer",
    description = "Permanent AIS spoofing capability",
    cost = 1000000,
    effect = "equipment",
    value = "AIS_SPOOF"
}

ship.hull = 50  -- Reset hull for fresh ship
ship.equipment = nil  -- Reset equipment

can_apply, reason = gamestate.can_apply_upgrade(ship, equipment_upgrade)
assert(can_apply == true, "Equipment upgrade should be applicable to ship without it")
print("✓ Test 4a: Equipment upgrade is applicable to ship without it")

-- Apply the upgrade
gamestate.apply_upgrade(ship, equipment_upgrade)
assert(ship.equipment ~= nil, "Ship should have equipment table after upgrade")
assert(ship.equipment["AIS_SPOOF"] == true, "Ship should have AIS_SPOOF equipment")
print("✓ Test 4b: Equipment upgrade adds equipment to ship")

-- Test that equipment upgrade is not applicable when ship already has it
can_apply, reason = gamestate.can_apply_upgrade(ship, equipment_upgrade)
assert(can_apply == false, "Equipment upgrade should not be applicable when ship already has it")
print("✓ Test 4c: Equipment upgrade is not applicable when ship already has it")

-- Test 5: Test get_available_upgrades
print("\nTesting get_available_upgrades...")
local test_ship = {
    name = "TEST-02",
    age = 15,
    hull = 60,
    fuel = 70,
    status = "Docked"
}

local available = gamestate.get_available_upgrades(game, test_ship)
assert(type(available) == "table", "get_available_upgrades should return a table")
assert(#available > 0, "Should have at least one available upgrade for a new ship")
print("✓ Test 5: get_available_upgrades returns " .. #available .. " upgrades for new ship")

-- Test 6: Verify upgrades in game state have required fields
print("\nTesting upgrade data structure...")
for i, upgrade in ipairs(game.upgrades) do
    assert(type(upgrade.name) == "string", "Upgrade " .. i .. " should have a name")
    assert(type(upgrade.description) == "string", "Upgrade " .. i .. " should have a description")
    assert(type(upgrade.cost) == "number", "Upgrade " .. i .. " should have a cost")
    assert(type(upgrade.effect) == "string", "Upgrade " .. i .. " should have an effect")
    assert(upgrade.value ~= nil, "Upgrade " .. i .. " should have a value")
end
print("✓ Test 6: All upgrades have required fields (name, description, cost, effect, value)")

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The vessel upgrade system provides:")
print("  • can_apply_upgrade - check if upgrade is applicable to a ship")
print("  • apply_upgrade - apply upgrade to a ship")
print("  • get_available_upgrades - get list of applicable upgrades for a ship")
print("  • " .. #game.upgrades .. " upgrade types defined in game state")
print("")

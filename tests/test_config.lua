#!/usr/bin/env lua5.3

-- Test Configuration Module
-- Tests the new config.lua module

local config = require("config")

print("Testing Configuration Module...")
print("")

-- Test 1: Config module loads correctly
print("=== Test 1: Module Load ===")
assert(type(config) == "table", "config should be a table")
print("✓ Config module loaded successfully")

-- Test 2: UI configuration exists
print("")
print("=== Test 2: UI Configuration ===")
assert(type(config.ui) == "table", "config.ui should be a table")
assert(type(config.ui.default_width) == "number", "config.ui.default_width should be a number")
assert(config.ui.default_width == 120, "Default width should be 120")
assert(config.ui.percentage_decimals == 2, "Percentage decimals should be 2")
print("✓ UI configuration loaded correctly")
print("  - default_width: " .. config.ui.default_width)
print("  - percentage_decimals: " .. config.ui.percentage_decimals)

-- Test 3: Game configuration exists
print("")
print("=== Test 3: Game Configuration ===")
assert(type(config.game) == "table", "config.game should be a table")
assert(config.game.initial_rubles == 5000000, "Initial rubles should be 5M")
assert(config.game.heat_max == 10, "Max heat should be 10")
assert(config.game.fleet_max_size == 50, "Fleet max size should be 50")
print("✓ Game configuration loaded correctly")
print("  - initial_rubles: " .. config.game.initial_rubles)
print("  - heat_max: " .. config.game.heat_max)
print("  - fleet_max_size: " .. config.game.fleet_max_size)

-- Test 4: Cost configuration exists
print("")
print("=== Test 4: Cost Configuration ===")
assert(type(config.costs) == "table", "config.costs should be a table")
assert(config.costs.repair_cost_per_point == 10000, "Repair cost per point should be 10000")
assert(config.costs.refuel_cost_per_point == 5000, "Refuel cost per point should be 5000")
print("✓ Cost configuration loaded correctly")
print("  - repair_cost_per_point: " .. config.costs.repair_cost_per_point)
print("  - refuel_cost_per_point: " .. config.costs.refuel_cost_per_point)

-- Test 5: Color configuration exists
print("")
print("=== Test 5: Color Configuration ===")
assert(type(config.colors) == "table", "config.colors should be a table")
assert(type(config.colors.fg_red) == "string", "config.colors.fg_red should be a string")
assert(type(config.colors.reset) == "string", "config.colors.reset should be a string")
print("✓ Color configuration loaded correctly")

-- Test 6: Config.get() function works
print("")
print("=== Test 6: Config Get Function ===")
assert(type(config.get) == "function", "config.get should be a function")

local default_width = config.get("ui.default_width")
assert(default_width == 120, "config.get('ui.default_width') should return 120")

local initial_rubles = config.get("game.initial_rubles")
assert(initial_rubles == 5000000, "config.get('game.initial_rubles') should return 5000000")

local invalid = config.get("invalid.path.here")
assert(invalid == nil, "config.get with invalid path should return nil")

print("✓ Config.get() function works correctly")

-- Test 7: Config.set() function works
print("")
print("=== Test 7: Config Set Function ===")
assert(type(config.set) == "function", "config.set should be a function")

-- Save original value
local original_width = config.ui.default_width

-- Set new value
config.set("ui.default_width", 100)
assert(config.ui.default_width == 100, "config.set should update the value")
assert(config.get("ui.default_width") == 100, "config.get should return updated value")

-- Restore original value
config.set("ui.default_width", original_width)
assert(config.ui.default_width == original_width, "Value should be restored")

print("✓ Config.set() function works correctly")

-- Test 8: Config can be used for testing with different values
print("")
print("=== Test 8: Config for Testing ===")
local original_heat_max = config.game.heat_max

-- Temporarily change for testing
config.set("game.heat_max", 5)
assert(config.game.heat_max == 5, "Should be able to modify config for testing")

-- Restore
config.set("game.heat_max", original_heat_max)
assert(config.game.heat_max == original_heat_max, "Should be able to restore original value")

print("✓ Config can be modified for testing scenarios")

print("")
print("===================================")
print("All configuration tests passed! ✓")
print("===================================")
print("")
print("The config module provides:")
print("  • Centralized configuration values")
print("  • config.get(path) - Get config by dot-separated path")
print("  • config.set(path, value) - Set config for testing")
print("  • ui, game, costs, and colors configuration sections")
print("")

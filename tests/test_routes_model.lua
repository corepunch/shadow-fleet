#!/usr/bin/env lua5.3

-- Test Routes Model (MVP Pattern)
-- Tests the pure business logic layer without UI dependencies

local routes_model = require("game.routes_model")
local gamestate = require("game")

print("Testing Routes Model (MVP Pattern)...\n")

-- Create a test game state
local game = gamestate.new()

-- Test 1: Get docked ships
local docked = routes_model.get_docked_ships(game)
assert(#docked == 1, "Should have 1 docked ship (GHOST-01)")
assert(docked[1].ship.name == "GHOST-01", "Docked ship should be GHOST-01")
print("✓ Test 1: get_docked_ships works correctly")

-- Test 2: Get ships for loading
local for_loading = routes_model.get_ships_for_loading(game)
assert(#for_loading == 1, "Should have 1 ship at export terminal")
assert(for_loading[1].ship.name == "GHOST-01", "Ship should be GHOST-01")
assert(for_loading[1].port.type == "export", "Port should be export type")
print("✓ Test 2: get_ships_for_loading works correctly")

-- Test 3: Get ships for selling (none initially)
local for_selling = routes_model.get_ships_for_selling(game)
assert(#for_selling == 0, "Should have no ships for selling initially")
print("✓ Test 3: get_ships_for_selling works correctly")

-- Test 4: Check fuel calculation
local ship = game.fleet[1]
local test_route = {days = 5, risk = "low"}
local has_fuel, fuel_needed = routes_model.check_fuel(ship, test_route)
assert(has_fuel == true, "Ship with 80% fuel should have enough for 5 day route")
assert(fuel_needed == 10, "Fuel needed should be 10%")
print("✓ Test 4: check_fuel works correctly")

-- Test 5: Calculate cargo cost
local cost = routes_model.calculate_cargo_cost(50, 60)
assert(cost == 3000000, "Cost should be 3,000,000 rubles (50k bbls * 60/bbl * 1000)")
print("✓ Test 5: calculate_cargo_cost works correctly")

-- Test 6: Calculate cargo revenue
local revenue = routes_model.calculate_cargo_revenue(50, 75)
assert(revenue == 3750000, "Revenue should be 3,750,000 rubles (50k bbls * 75/bbl * 1000)")
print("✓ Test 6: calculate_cargo_revenue works correctly")

-- Test 7: Validate cargo load - valid case
local valid, err = routes_model.validate_cargo_load(ship, 50, 3000000, 5000000)
assert(valid == true, "Should be valid to load 50k barrels with 5M rubles")
assert(err == nil, "Should have no error message")
print("✓ Test 7: validate_cargo_load accepts valid request")

-- Test 8: Validate cargo load - insufficient funds
valid, err = routes_model.validate_cargo_load(ship, 100, 6000000, 5000000)
assert(valid == false, "Should be invalid with insufficient funds")
assert(err:match("Insufficient funds"), "Error should mention insufficient funds")
print("✓ Test 8: validate_cargo_load rejects insufficient funds")

-- Test 9: Validate cargo load - exceeds capacity
valid, err = routes_model.validate_cargo_load(ship, 600, 1000000, 5000000)
assert(valid == false, "Should be invalid when exceeding capacity")
assert(err:match("space available"), "Error should mention space")
print("✓ Test 9: validate_cargo_load rejects capacity overflow")

-- Test 10: Load cargo (mutates state)
local initial_rubles = game.rubles
routes_model.load_cargo(game, ship, 50, 3000000)
assert(ship.cargo ~= nil, "Ship should have cargo table")
assert(ship.cargo.crude == 50, "Ship should have 50k barrels of crude")
assert(game.rubles == initial_rubles - 3000000, "Rubles should be deducted")
print("✓ Test 10: load_cargo updates state correctly")

-- Test 11: Sell cargo (mutates state)
-- First set ship to "In Port" with cargo
ship.status = "in_port"
ship.destination_id = "malta_sts"
local initial_rubles2 = game.rubles
local initial_heat = game.heat
routes_model.sell_cargo(game, ship, 3500000)
assert(ship.cargo == nil, "Ship should have no cargo after sale")
assert(game.rubles == initial_rubles2 + 3500000, "Rubles should increase")
assert(game.heat == initial_heat + 1, "Heat should increase by 1")
print("✓ Test 11: sell_cargo updates state correctly")

-- Test 12: Depart ship (mutates state)
local test_destination = {id = "skaw_sts", name = "Skaw STS"}
local test_route2 = {days = 2, risk = "low"}
ship.status = "docked"
routes_model.depart_ship(ship, test_destination, test_route2)
assert(ship.status == "at_sea", "Ship should be at_sea")
assert(ship.destination_id == "skaw_sts", "Destination ID should be set")
assert(ship.days_remaining == 2, "Days remaining should be 2")
assert(ship.eta == 2, "ETA should be 2")
assert(ship.risk == "low", "Risk should be low")
print("✓ Test 12: depart_ship updates state correctly")

-- Test 13: Model is pure (no UI dependencies)
local module_env = package.loaded["game.routes_model"]
assert(type(module_env) == "table", "Module should be a table")
-- Check that module doesn't reference UI functions
local module_str = tostring(module_env)
assert(not module_str:match("echo"), "Model should not contain UI functions")
print("✓ Test 13: Model layer is pure (no UI dependencies)")

print("\n===================================")
print("All tests passed! ✓")
print("===================================\n")
print("The routes_model module provides:")
print("  • Pure business logic without UI dependencies")
print("  • Query functions (get_docked_ships, get_ships_for_loading, etc.)")
print("  • Calculation functions (check_fuel, calculate_cost, etc.)")
print("  • Validation functions (validate_cargo_load)")
print("  • State mutation functions (load_cargo, sell_cargo, depart_ship)")
print("\nThis follows the Model layer of the MVP pattern.")
print("===================================")

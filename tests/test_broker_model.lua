#!/usr/bin/env lua5.3

-- Test Ship Broker Model
-- Validates ship buying and selling logic

local broker_model = require("game.broker_model")
local gamestate = require("game")

print("Testing Ship Broker Model...")

-- Test 1: Get available ships
local game = gamestate.new()
local available = broker_model.get_available_ships(game)
assert(type(available) == "table", "get_available_ships should return a table")
assert(#available > 0, "Should have available ships for purchase")
print("✓ Test 1: get_available_ships returns " .. #available .. " ships")

-- Test 2: Buy a ship with sufficient funds
local initial_rubles = game.rubles
local initial_fleet_size = #game.fleet
local ship_to_buy = available[1]
local success, message = broker_model.buy_ship(game, ship_to_buy)
assert(success == true, "Should successfully buy ship with sufficient funds")
assert(#game.fleet == initial_fleet_size + 1, "Fleet should grow by 1")
assert(game.rubles == initial_rubles - ship_to_buy.price, "Rubles should decrease by ship price")
print("✓ Test 2: buy_ship successfully purchases ship and deducts cost")

-- Test 3: Try to buy a ship without sufficient funds
game.rubles = 100  -- Set very low funds
ship_to_buy = available[2]
success, message = broker_model.buy_ship(game, ship_to_buy)
assert(success == false, "Should fail to buy ship without sufficient funds")
assert(message:find("Insufficient funds"), "Error message should mention insufficient funds")
print("✓ Test 3: buy_ship fails with insufficient funds")

-- Test 4: Sell a ship
game = gamestate.new()  -- Reset game
local fleet_size_before = #game.fleet
local rubles_before = game.rubles
success, message = broker_model.sell_ship(game, 1)
assert(success == true, "Should successfully sell ship")
assert(#game.fleet == fleet_size_before - 1, "Fleet should shrink by 1")
assert(game.rubles > rubles_before, "Rubles should increase after selling")
print("✓ Test 4: sell_ship successfully sells ship and adds funds")

-- Test 5: Try to sell ship at sea
game = gamestate.new()
game.fleet[2].status = "at_sea"  -- SHADOW-03 is at sea
success, message = broker_model.sell_ship(game, 2)
assert(success == false, "Should not be able to sell ship at sea")
assert(message:find("at sea"), "Error message should mention ship is at sea")
print("✓ Test 5: sell_ship fails for ships at sea")

print("\n=== Ship Broker Model Tests ===")
print("All tests passed! ✓")
print("\nFunctions tested:")
print("  • get_available_ships - get list of ships available for purchase")
print("  • buy_ship - purchase a ship and add to fleet")
print("  • sell_ship - sell a ship from fleet")

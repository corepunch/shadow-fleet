#!/usr/bin/env lua5.3

-- Test Broker Presenter
-- Tests UI layer for ship buying and selling

local broker_presenter = require("presenters.broker")
local gamestate = require("game")

print("Testing Broker Presenter...")
print("")

-- Test 1: Broker presenter module loads
assert(type(broker_presenter) == "table", "broker_presenter should be a table")
assert(type(broker_presenter.buy_ship) == "function", "buy_ship should be a function")
assert(type(broker_presenter.sell_ship) == "function", "sell_ship should be a function")
print("✓ Test 1: Broker presenter module loaded successfully")

-- Test 2: buy_ship function exists and has correct signature
local game = gamestate.new()

-- Create mock echo function
local echo_buffer = {}
local function mock_echo(text)
    table.insert(echo_buffer, text)
end

-- Create mock read_char that simulates user canceling (B for back)
local function mock_read_char_cancel()
    return "B"
end

-- Create mock read_line that returns nil (cancel)
local function mock_read_line_cancel()
    return nil
end

-- Test that buy_ship can be called without crashing
local success, err = pcall(function()
    broker_presenter.buy_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)
end)
assert(success, "buy_ship should not crash when called: " .. tostring(err or ""))
print("✓ Test 2: buy_ship function can be called")

-- Test 3: Verify echo output contains expected elements
echo_buffer = {}
broker_presenter.buy_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)

local output = table.concat(echo_buffer, "")
assert(output:match("BUY SHIP"), "Output should contain BUY SHIP header")
assert(output:match("Rubles"), "Output should mention Rubles")
assert(output:match("GHOST"), "Output should list GHOST ships")
print("✓ Test 3: buy_ship displays expected UI elements")

-- Test 4: sell_ship function exists and works
echo_buffer = {}
success, err = pcall(function()
    broker_presenter.sell_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)
end)
assert(success, "sell_ship should not crash when called: " .. tostring(err or ""))
print("✓ Test 4: sell_ship function can be called")

-- Test 5: Verify sell_ship output
echo_buffer = {}
broker_presenter.sell_ship(game, mock_echo, mock_read_char_cancel, mock_read_line_cancel)

output = table.concat(echo_buffer, "")
assert(output:match("SELL SHIP"), "Output should contain SELL SHIP header")
assert(output:match("GHOST%-01") or output:match("SHADOW%-03"), "Output should list fleet ships")
print("✓ Test 5: sell_ship displays expected UI elements")

-- Test 6: Test with empty fleet
local game_empty = gamestate.new()
game_empty.fleet = {}
echo_buffer = {}

broker_presenter.sell_ship(game_empty, mock_echo, mock_read_char_cancel, mock_read_line_cancel)

output = table.concat(echo_buffer, "")
assert(output:match("No ships"), "Should show message about no ships")
print("✓ Test 6: sell_ship handles empty fleet gracefully")

-- Test 7: Test simulated purchase with confirmation
local function mock_read_char_sequence()
    local sequence = {"1", "Y"}  -- Select ship 1, confirm
    local index = 0
    return function()
        index = index + 1
        return sequence[index]
    end
end

local read_char_sim = mock_read_char_sequence()
local function mock_read_line_sim()
    return nil
end

game = gamestate.new()
local initial_fleet = #game.fleet
echo_buffer = {}

-- Note: This will fail on confirmation because we don't mock all inputs,
-- but it tests that the flow progresses correctly
pcall(function()
    broker_presenter.buy_ship(game, mock_echo, read_char_sim, mock_read_line_sim)
end)

-- Should have attempted to show confirmation
output = table.concat(echo_buffer, "")
assert(output:match("Purchase") or output:match("Confirm"), "Should show purchase confirmation")
print("✓ Test 7: buy_ship flows to confirmation step")

print("")
print("===================================")
print("All broker presenter tests passed! ✓")
print("===================================")
print("")
print("Tested presenter functionality:")
print("  • buy_ship - ship purchase UI flow")
print("  • sell_ship - ship sale UI flow")
print("  • Empty fleet handling")
print("  • User input flow (selection, confirmation)")
print("  • Output formatting and display")
print("")

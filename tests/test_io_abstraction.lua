#!/usr/bin/env lua5.3

-- Test I/O Abstraction Modules
-- Tests the new ui/output.lua and ui/input.lua modules

local ui_output = require("ui.output")
local ui_input = require("ui.input")

print("Testing I/O Abstraction Modules...")
print("")

-- Test 1: Output module loads correctly
print("=== Test 1: Output Module ===")
assert(type(ui_output) == "table", "ui_output should be a table")
assert(type(ui_output.write) == "function", "ui_output.write should be a function")
assert(type(ui_output.set_output_fn) == "function", "ui_output.set_output_fn should be a function")
assert(type(ui_output.reset) == "function", "ui_output.reset should be a function")
print("✓ Output module loaded with required functions")

-- Test 2: Input module loads correctly
print("")
print("=== Test 2: Input Module ===")
assert(type(ui_input) == "table", "ui_input should be a table")
assert(type(ui_input.read_char) == "function", "ui_input.read_char should be a function")
assert(type(ui_input.read_line) == "function", "ui_input.read_line should be a function")
assert(type(ui_input.set_read_char_fn) == "function", "ui_input.set_read_char_fn should be a function")
assert(type(ui_input.set_read_line_fn) == "function", "ui_input.set_read_line_fn should be a function")
assert(type(ui_input.reset) == "function", "ui_input.reset should be a function")
print("✓ Input module loaded with required functions")

-- Test 3: Output can be mocked
print("")
print("=== Test 3: Mock Output ===")
local captured = {}
local mock_output = function(text)
    table.insert(captured, text)
end

ui_output.set_output_fn(mock_output)
ui_output.write("Test output 1")
ui_output.write("Test output 2")

assert(#captured == 2, "Should have captured 2 outputs")
assert(captured[1] == "Test output 1", "First output should match")
assert(captured[2] == "Test output 2", "Second output should match")
print("✓ Output mocking works correctly")

-- Test 4: Output can be reset
print("")
print("=== Test 4: Reset Output ===")
ui_output.reset()
local default_fn = ui_output.get_output_fn()
assert(type(default_fn) == "function", "Should have default output function after reset")
print("✓ Output reset works correctly")

-- Test 5: Input can be mocked
print("")
print("=== Test 5: Mock Input ===")
local char_index = 0
local chars = {"A", "B", "C"}
local mock_read_char = function()
    char_index = char_index + 1
    return chars[char_index]
end

ui_input.set_read_char_fn(mock_read_char)
local char1 = ui_input.read_char()
local char2 = ui_input.read_char()
local char3 = ui_input.read_char()

assert(char1 == "A", "First character should be A")
assert(char2 == "B", "Second character should be B")
assert(char3 == "C", "Third character should be C")
print("✓ Input mocking for read_char works correctly")

-- Test 6: Input lines can be mocked
print("")
print("=== Test 6: Mock Input Lines ===")
local line_index = 0
local lines = {"Line 1", "Line 2"}
local mock_read_line = function()
    line_index = line_index + 1
    return lines[line_index]
end

ui_input.set_read_line_fn(mock_read_line)
local line1 = ui_input.read_line()
local line2 = ui_input.read_line()

assert(line1 == "Line 1", "First line should match")
assert(line2 == "Line 2", "Second line should match")
print("✓ Input mocking for read_line works correctly")

-- Test 7: Input can be reset
print("")
print("=== Test 7: Reset Input ===")
ui_input.reset()
local default_read_char = ui_input.get_read_char_fn()
local default_read_line = ui_input.get_read_line_fn()
assert(type(default_read_char) == "function", "Should have default read_char after reset")
assert(type(default_read_line) == "function", "Should have default read_line after reset")
print("✓ Input reset works correctly")

print("")
print("===================================")
print("All I/O abstraction tests passed! ✓")
print("===================================")
print("")
print("The I/O abstraction modules provide:")
print("  • ui/output.lua - Output abstraction with mocking support")
print("  • ui/input.lua - Input abstraction with mocking support")
print("  • Easy mocking for automated testing")
print("  • Clean reset to default behavior")
print("")

#!/usr/bin/env lua5.3

-- Test Mock I/O Utilities
-- Tests the mock I/O utilities for testing

local mock_io = require("tests.mocks.io")

print("Testing Mock I/O Utilities...")
print("")

-- Test 1: Mock output creation
print("=== Test 1: Mock Output Creation ===")
local mock_output, captured = mock_io.create_output()
assert(type(mock_output) == "function", "Mock output should be a function")
assert(type(captured) == "table", "Captured should be a table")
assert(#captured == 0, "Captured should start empty")
print("✓ Mock output created successfully")

-- Test 2: Mock output captures text
print("")
print("=== Test 2: Capture Output ===")
mock_output("Hello")
mock_output(" World")
assert(#captured == 2, "Should have captured 2 outputs")
assert(captured[1] == "Hello", "First capture should be 'Hello'")
assert(captured[2] == " World", "Second capture should be ' World'")
print("✓ Output capture works correctly")

-- Test 3: Mock output handles formatted strings
print("")
print("=== Test 3: Formatted Output ===")
local mock_fmt, captured_fmt = mock_io.create_output()
mock_fmt("Number: %d", 42)
mock_fmt("String: %s", "test")
assert(#captured_fmt == 2, "Should have captured 2 formatted outputs")
assert(captured_fmt[1] == "Number: 42", "First format should work")
assert(captured_fmt[2] == "String: test", "Second format should work")
print("✓ Formatted output works correctly")

-- Test 4: Mock read_char
print("")
print("=== Test 4: Mock Read Char ===")
local mock_read_char = mock_io.create_read_char({"A", "B", "C"})
assert(type(mock_read_char) == "function", "Mock read_char should be a function")
assert(mock_read_char() == "A", "Should return first char")
assert(mock_read_char() == "B", "Should return second char")
assert(mock_read_char() == "C", "Should return third char")
assert(mock_read_char() == nil, "Should return nil after exhausting inputs")
print("✓ Mock read_char works correctly")

-- Test 5: Mock read_line
print("")
print("=== Test 5: Mock Read Line ===")
local mock_read_line = mock_io.create_read_line({"Line 1", "Line 2"})
assert(type(mock_read_line) == "function", "Mock read_line should be a function")
assert(mock_read_line() == "Line 1", "Should return first line")
assert(mock_read_line() == "Line 2", "Should return second line")
assert(mock_read_line() == nil, "Should return nil after exhausting inputs")
print("✓ Mock read_line works correctly")

-- Test 6: Create complete environment
print("")
print("=== Test 6: Complete Mock Environment ===")
local env = mock_io.create_environment({"X", "Y"}, {"Input line"})
assert(type(env.output_fn) == "function", "Should have output_fn")
assert(type(env.read_char) == "function", "Should have read_char")
assert(type(env.read_line) == "function", "Should have read_line")
assert(type(env.captured) == "table", "Should have captured array")

env.output_fn("Test")
assert(env.read_char() == "X", "Should read char from environment")
assert(env.read_line() == "Input line", "Should read line from environment")
assert(#env.captured == 1, "Should have captured output")
print("✓ Complete mock environment works correctly")

-- Test 7: Assert output contains
print("")
print("=== Test 7: Assert Output Contains ===")
local _, test_captured = mock_io.create_output()
table.insert(test_captured, "This is a test message")
table.insert(test_captured, "Another message")

-- This should pass
mock_io.assert_output_contains(test_captured, "test message")
mock_io.assert_output_contains(test_captured, "Another")

-- This should fail
local success, err = pcall(function()
    mock_io.assert_output_contains(test_captured, "not present")
end)
assert(not success, "Should fail when string not found")

print("✓ Assert output contains works correctly")

-- Test 8: Assert output not contains
print("")
print("=== Test 8: Assert Output Not Contains ===")
-- This should pass
mock_io.assert_output_not_contains(test_captured, "not present")

-- This should fail
success, err = pcall(function()
    mock_io.assert_output_not_contains(test_captured, "test message")
end)
assert(not success, "Should fail when string is found")

print("✓ Assert output not contains works correctly")

-- Test 9: Get full output
print("")
print("=== Test 9: Get Full Output ===")
local full = mock_io.get_full_output(test_captured)
assert(type(full) == "string", "Full output should be a string")
assert(full:find("This is a test message", 1, true), "Should contain first message")
assert(full:find("Another message", 1, true), "Should contain second message")
print("✓ Get full output works correctly")

-- Test 10: Clear output
print("")
print("=== Test 10: Clear Output ===")
assert(#test_captured > 0, "Captured should have content before clear")
mock_io.clear_output(test_captured)
assert(#test_captured == 0, "Captured should be empty after clear")
print("✓ Clear output works correctly")

print("")
print("===================================")
print("All mock I/O tests passed! ✓")
print("===================================")
print("")
print("The mock I/O utilities provide:")
print("  • create_output() - Mock output with capture")
print("  • create_read_char(inputs) - Mock character input")
print("  • create_read_line(inputs) - Mock line input")
print("  • create_environment() - Complete mock I/O setup")
print("  • assert_output_contains() - Verify output content")
print("  • assert_output_not_contains() - Verify output absence")
print("  • get_full_output() - Get concatenated output")
print("  • clear_output() - Reset captured output")
print("")

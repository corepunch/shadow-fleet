#!/usr/bin/env lua5.3
-- Simple test to verify widgets.lua module works correctly

local widgets = require("widgets")

print("Testing Widgets Module...")
print("")

-- Test 1: Module loads correctly
print("✓ Test 1: Module loaded successfully")
assert(type(widgets) == "table", "widgets should be a table")

-- Test 2: Check all widget functions exist
local required_functions = {
    "separator", "title", "status_bar", "section_header",
    "labeled_value", "percentage_bar", "heat_meter", "menu_item",
    "format_number"
}

for _, func_name in ipairs(required_functions) do
    assert(type(widgets[func_name]) == "function", 
           "widgets." .. func_name .. " should be a function")
end
print("✓ Test 2: All required widget functions exist")

-- Test 3: Test format_number utility function
local test_cases = {
    {input = 1000, expected = "1,000"},
    {input = 1000000, expected = "1,000,000"},
    {input = 123456789, expected = "123,456,789"},
    {input = 100, expected = "100"},
    {input = 42, expected = "42"},
}

for _, test in ipairs(test_cases) do
    local result = widgets.format_number(test.input)
    assert(result == test.expected, 
           string.format("format_number(%d) should return '%s' but got '%s'", 
                        test.input, test.expected, result))
end
print("✓ Test 3: format_number utility function works correctly")

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The widgets module provides:")
print("  • separator - horizontal separator line")
print("  • title - centered title text")
print("  • status_bar - status bar with left/middle/right text")
print("  • section_header - bold section header")
print("  • labeled_value - label with colored value")
print("  • percentage_bar - color-coded percentage display")
print("  • heat_meter - visual heat level meter")
print("  • menu_item - numbered menu item")
print("  • format_number - number formatting utility")
print("")
print("Usage: local widgets = require('widgets')")

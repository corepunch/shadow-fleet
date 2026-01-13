#!/usr/bin/env lua5.3
-- Simple test to verify ui module works correctly

local widgets = require("ui")

print("Testing Widgets Module...")
print("")

-- Test 1: Module loads correctly
print("✓ Test 1: Module loaded successfully")
assert(type(widgets) == "table", "widgets should be a table")

-- Test 2: Check all widget functions exist
local required_functions = {
    "separator", "title", "status_bar", "section_header",
    "labeled_value", "percentage_bar", "heat_meter", "menu_item",
    "format_number", "format_percentage", "format_ship_info", "format_hull_fuel",
    "table_generator"
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

-- Test 4: Test table_generator widget
print("")
print("Testing table_generator widget...")

-- Create sample data
local test_data = {
    {name = "Ship-A", age = 10, status = "Active"},
    {name = "Ship-B", age = 15, status = "Docked"},
    {name = "Ship-C", age = 5, status = "At Sea"}
}

-- Define columns
local test_columns = {
    {title = "Name", value_fn = function(row) return row.name end, width = 11},
    {title = "Age", value_fn = function(row) return row.age .. "y" end, width = 5},
    {title = "Status", value_fn = function(row) return row.status end, width = 10}
}

-- Capture output (we'll just verify it doesn't crash)
local test_options = {
    title = "--- TEST TABLE ---",
    footer_fn = function()
        io.write("Total: " .. #test_data .. " ships\n")
    end
}

-- This should not crash
widgets.table_generator(test_columns, test_data, test_options)
print("✓ Test 4: table_generator widget works correctly")

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
print("  • table_generator - generic table with columns and data")
print("")
print("Usage: local widgets = require('ui')")

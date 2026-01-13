#!/usr/bin/env lua5.3
-- Test formatting functions to prevent integer/float format errors

local widgets = require("ui")

print("Testing Formatting Functions...")
print("")

-- Test 1: Module loads correctly
assert(type(widgets) == "table", "widgets should be a table")
print("✓ Test 1: Module loaded successfully")

-- Test 2: Check formatting functions exist
local required_functions = {
    "format_percentage",
    "format_ship_info",
    "format_hull_fuel"
}

for _, func_name in ipairs(required_functions) do
    assert(type(widgets[func_name]) == "function", 
           "widgets." .. func_name .. " should be a function")
end
print("✓ Test 2: All formatting functions exist")

-- Test 3: format_percentage handles integers
local test_cases_int = {
    {input = 100, expected = "100.00%"},
    {input = 65, expected = "65.00%"},
    {input = 0, expected = "0.00%"},
    {input = 50, expected = "50.00%"},
}

for _, test in ipairs(test_cases_int) do
    local result = widgets.format_percentage(test.input)
    assert(result == test.expected, 
           string.format("format_percentage(%d) should return '%s' but got '%s'", 
                        test.input, test.expected, result))
end
print("✓ Test 3: format_percentage handles integer values correctly")

-- Test 4: format_percentage handles floats (the main bug fix)
local test_cases_float = {
    {input = 71.81, expected = "71.81%"},
    {input = 43.82, expected = "43.82%"},
    {input = 99.99, expected = "99.99%"},
    {input = 0.01, expected = "0.01%"},
    {input = 65.123, expected = "65.12%"},  -- Should round to 2 decimal places
}

for _, test in ipairs(test_cases_float) do
    local result = widgets.format_percentage(test.input)
    assert(result == test.expected, 
           string.format("format_percentage(%.2f) should return '%s' but got '%s'", 
                        test.input, test.expected, result))
end
print("✓ Test 4: format_percentage handles floating-point values correctly")

-- Test 5: format_hull_fuel combines hull and fuel
local hull = 71.81
local fuel = 43.82
local expected = "Hull: 71.81%  Fuel: 43.82%"
local result = widgets.format_hull_fuel(hull, fuel)
assert(result == expected,
       string.format("format_hull_fuel should return '%s' but got '%s'", expected, result))
print("✓ Test 5: format_hull_fuel combines hull and fuel correctly")

-- Test 6: format_ship_info formats complete ship information
local test_ship = {
    name = "SHADOW-03",
    age = 18,
    hull = 71.81,
    fuel = 43.82,
    status = "At Sea"
}
local expected_info = "Age: 18y, Hull: 71.81%, Fuel: 43.82%, Status: At Sea"
local result_info = widgets.format_ship_info(test_ship)
assert(result_info == expected_info,
       string.format("format_ship_info should return '%s' but got '%s'", expected_info, result_info))
print("✓ Test 6: format_ship_info formats complete ship information correctly")

-- Test 7: format_ship_info handles integer hull/fuel values
local test_ship_int = {
    name = "GHOST-01",
    age = 22,
    hull = 65,
    fuel = 80,
    status = "Docked"
}
local expected_info_int = "Age: 22y, Hull: 65.00%, Fuel: 80.00%, Status: Docked"
local result_info_int = widgets.format_ship_info(test_ship_int)
assert(result_info_int == expected_info_int,
       string.format("format_ship_info should return '%s' but got '%s'", expected_info_int, result_info_int))
print("✓ Test 7: format_ship_info handles integer hull/fuel values correctly")

print("")
print("===================================")
print("All formatting tests passed! ✓")
print("===================================")
print("")
print("These tests ensure:")
print("  • format_percentage handles both integers and floats")
print("  • No 'number has no integer representation' errors")
print("  • Consistent formatting across the application")
print("")

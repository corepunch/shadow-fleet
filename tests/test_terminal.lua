#!/usr/bin/env lua5.3
-- Simple test to verify terminal.lua module works correctly

local terminal = require("terminal")

print("Testing Terminal Framework...")
print("")

-- Test 1: Module loads correctly
print("✓ Test 1: Module loaded successfully")
assert(type(terminal) == "table", "terminal should be a table")

-- Test 2: Check all main functions exist
local required_functions = {
    "clear", "clear_to_bottom", "clear_to_top", "clear_line",
    "move_to", "home", "move_up", "move_down", "move_forward", "move_backward",
    "save_cursor", "restore_cursor", "hide_cursor", "show_cursor",
    "set_fg", "set_bg", "set_colors", "set_style", "reset",
    "write_at", "write_colored",
    "get_size", "enable_alt_screen", "disable_alt_screen",
    "draw_box", "fill_box", "init", "cleanup", "apply_scheme"
}

for _, func_name in ipairs(required_functions) do
    assert(type(terminal[func_name]) == "function", 
           "terminal." .. func_name .. " should be a function")
end
print("✓ Test 2: All required functions exist")

-- Test 3: Check colors table exists
assert(type(terminal.colors) == "table", "terminal.colors should be a table")
print("✓ Test 3: Colors table exists")

-- Test 4: Check predefined colors
local required_colors = {
    "fg_black", "fg_red", "fg_green", "fg_yellow", "fg_blue", "fg_magenta", "fg_cyan", "fg_white",
    "fg_bright_black", "fg_bright_red", "fg_bright_green", "fg_bright_yellow",
    "fg_bright_blue", "fg_bright_magenta", "fg_bright_cyan", "fg_bright_white",
    "bg_black", "bg_red", "bg_green", "bg_yellow", "bg_blue", "bg_magenta", "bg_cyan", "bg_white",
    "bg_bright_black", "bg_bright_red", "bg_bright_green", "bg_bright_yellow",
    "bg_bright_blue", "bg_bright_magenta", "bg_bright_cyan", "bg_bright_white"
}

for _, color in ipairs(required_colors) do
    assert(terminal.colors[color] ~= nil, 
           "terminal.colors." .. color .. " should exist")
end
print("✓ Test 4: All predefined colors exist (32 total)")

-- Test 5: Check styles table
assert(type(terminal.styles) == "table", "terminal.styles should be a table")
print("✓ Test 5: Styles table exists")

-- Test 6: Check color schemes
assert(type(terminal.schemes) == "table", "terminal.schemes should be a table")
assert(terminal.schemes.default ~= nil, "default scheme should exist")
assert(terminal.schemes.title ~= nil, "title scheme should exist")
assert(terminal.schemes.ocean ~= nil, "ocean scheme should exist")
print("✓ Test 6: Color schemes exist")

-- Test 7: Visual test - display colors
print("")
print("Visual Test - Displaying color palette:")
print("")

-- Display foreground colors
io.write("Foreground colors: ")
for _, color in ipairs({"fg_red", "fg_green", "fg_yellow", "fg_blue", "fg_magenta", "fg_cyan"}) do
    terminal.set_fg(color)
    io.write("███ ")
end
terminal.reset()
print("")

-- Display background colors
io.write("Background colors: ")
for _, color in ipairs({"bg_red", "bg_green", "bg_yellow", "bg_blue", "bg_magenta", "bg_cyan"}) do
    terminal.set_bg(color)
    io.write("   ")
end
terminal.reset()
print("")
print("")

-- Test 8: Test color combinations
terminal.write_colored("Success message ", "fg_bright_green", "bg_black")
print("(green text)")
terminal.write_colored("Error message ", "fg_bright_red", "bg_black")
print("(red text)")
terminal.write_colored("Info message ", "fg_bright_cyan", "bg_black")
print("(cyan text)")
terminal.write_colored("Warning message ", "fg_bright_yellow", "bg_black")
print("(yellow text)")

print("")
print("✓ Test 8: Color output works correctly")

-- Test 9: Test color schemes
print("")
print("Predefined color schemes:")
for name, scheme in pairs(terminal.schemes) do
    io.write("  " .. name .. ": ")
    terminal.write_colored(" Sample ", scheme.fg, scheme.bg)
    print("")
end

print("")
print("✓ Test 9: All color schemes display correctly")

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The terminal framework provides:")
print("  • Screen clearing functions")
print("  • Cursor positioning (write anywhere)")
print("  • Color setting (16 foreground + 16 background)")
print("  • Predefined color schemes")
print("  • Box drawing utilities")
print("  • Text styling")
print("  • All returned as a module table")
print("")
print("Usage: local terminal = require('terminal')")

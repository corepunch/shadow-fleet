#!/usr/bin/env lua5.3
-- Test for the menu formatting functionality

print("Testing Menu Formatting...")
print("")

-- Test that the menu module exists and provides the needed functions
print("✓ Test 1: Checking that menu module is available")

-- Test that menu module can be loaded
local menu = require("menu")
assert(type(menu) == "table", "menu should be a table")
assert(type(menu.print_from_keymap) == "function", "menu should have print_from_keymap function")
assert(type(menu.generate_items) == "function", "menu should have generate_items function")
assert(type(menu.draw_boxed) == "function", "menu should have draw_boxed function")

print("✓ Menu module loaded with required functions")

-- Read the main.lua file and verify it uses the menu module
local file = io.open("main.lua", "r")
assert(file, "Could not open main.lua")
local content = file:read("*all")
file:close()

assert(content:match('require%("menu"%)'), "main.lua should require menu module")
print("✓ main.lua requires menu module")

-- Test that keymap and commands are used
assert(content:match('require%("keymap"%)'), "main.lua should require keymap module")
assert(content:match('require%("commands"%)'), "main.lua should require commands module")

print("✓ All required modules are loaded")

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The menu formatting system provides:")
print("  • menu.print_from_keymap(title, keymap, echo_fn) function")
print("  • menu.generate_items(keymap) for extracting menu items")
print("  • menu.draw_boxed(title, items, echo_fn) for rendering")
print("  • Keymap-based hotkey mapping")
print("  • Command registry for actions")
print("")

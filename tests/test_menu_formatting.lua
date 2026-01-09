#!/usr/bin/env lua5.3
-- Test for the new menu formatting functionality

print("Testing Menu Formatting...")
print("")

-- Test that the main.lua file can be loaded and contains the new function
print("✓ Test 1: Checking that main.lua contains menu functions")

-- Read the main.lua file and verify it contains required functions
local file = io.open("main.lua", "r")
assert(file, "Could not open main.lua")
local content = file:read("*all")
file:close()

assert(content:match("local function print_menu_from_keymap") or content:match("function print_menu_from_keymap"), 
       "main.lua should contain print_menu_from_keymap function")
assert(content:match("╔"), "main.lua should use double-lined box drawing characters (╔)")
assert(content:match("╗"), "main.lua should use double-lined box drawing characters (╗)")
assert(content:match("║"), "main.lua should use double-lined box drawing characters (║)")
assert(content:match("╚"), "main.lua should use double-lined box drawing characters (╚)")
assert(content:match("╝"), "main.lua should use double-lined box drawing characters (╝)")
assert(content:match("═"), "main.lua should use double-lined box drawing characters (═)")

print("✓ All box-drawing characters found")

-- Test that print_main_menu uses the new approach
assert(content:match('print_menu_from_keymap%("QUICK ACTIONS"'), "print_main_menu should call print_menu_from_keymap with QUICK ACTIONS title")
print("✓ print_main_menu now uses print_menu_from_keymap function")

-- Test that keymap and command_labels are used
assert(content:match('require%("keymap"%)'), "main.lua should require keymap module")
assert(content:match('require%("command_labels"%)'), "main.lua should require command_labels module")
assert(content:match('require%("commands"%)'), "main.lua should require commands module")

print("✓ All required modules are loaded")

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The menu formatting system provides:")
print("  • print_menu_from_keymap(title, keymap) function")
print("  • Double-lined box-drawing characters (╔╗║╚╝═)")
print("  • Keymap-based hotkey mapping")
print("  • Command registry for actions")
print("")

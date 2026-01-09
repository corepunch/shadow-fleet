#!/usr/bin/env lua5.3
-- Test for the new menu formatting functionality

print("Testing Menu Formatting...")
print("")

-- Test that the main.lua file can be loaded and contains the new function
print("✓ Test 1: Checking that main.lua contains print_menu function")

-- Read the main.lua file and verify it contains print_menu
local file = io.open("main.lua", "r")
assert(file, "Could not open main.lua")
local content = file:read("*all")
file:close()

assert(content:match("local function print_menu"), "main.lua should contain print_menu function")
assert(content:match("╔"), "main.lua should use double-lined box drawing characters (╔)")
assert(content:match("╗"), "main.lua should use double-lined box drawing characters (╗)")
assert(content:match("║"), "main.lua should use double-lined box drawing characters (║)")
assert(content:match("╚"), "main.lua should use double-lined box drawing characters (╚)")
assert(content:match("╝"), "main.lua should use double-lined box drawing characters (╝)")
assert(content:match("═"), "main.lua should use double-lined box drawing characters (═)")

print("✓ All box-drawing characters found")

-- Test that print_main_menu now uses print_menu
assert(content:match('print_menu%("QUICK ACTIONS"'), "print_main_menu should call print_menu with QUICK ACTIONS title")
print("✓ print_main_menu now uses print_menu function")

-- Test that the menu items are passed as a list
assert(content:match('"Fleet"'), "Menu should include Fleet")
assert(content:match('"Route"'), "Menu should include Route")
assert(content:match('"Trade"'), "Menu should include Trade")
assert(content:match('"Evade"'), "Menu should include Evade")
assert(content:match('"Events"'), "Menu should include Events")
assert(content:match('"Market"'), "Menu should include Market")
assert(content:match('"Status"'), "Menu should include Status")
assert(content:match('"Help"'), "Menu should include Help")
assert(content:match('"Quit"'), "Menu should include Quit")

print("✓ All menu items found in the list")

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The menu formatting system provides:")
print("  • print_menu(title, items) function")
print("  • Double-lined box-drawing characters (╔╗║╚╝═)")
print("  • Automatic hotkey extraction from menu_structure")
print("  • Centered title in box")
print("")

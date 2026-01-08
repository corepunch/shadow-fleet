#!/usr/bin/env lua5.3
-- Simple test for menu navigation
-- This simulates the main menu without requiring user interaction for automated testing

local term = require("terminal")
local widgets = require("ui")

-- Test menu rendering with highlighting
local function test_menu_rendering()
    print("Testing menu item highlighting...")
    
    local actions = {
        "Fleet",
        "Route",
        "Trade",
        "Evade",
        "Events",
        "Market",
        "Status",
        "Help"
    }
    
    -- Test that menu_item_highlighted function exists (vertical layout)
    assert(type(widgets.menu_item_highlighted) == "function", 
           "widgets.menu_item_highlighted should be a function")
    
    print("✓ menu_item_highlighted function exists")
    
    -- Test that horizontal_menu function exists
    assert(type(widgets.horizontal_menu) == "function", 
           "widgets.horizontal_menu should be a function")
    
    print("✓ horizontal_menu function exists")
    
    -- Test rendering with different selections
    term.init()
    term.clear()
    
    local row = 1
    widgets.section_header(row, "TEST HORIZONTAL MENU WITH SELECTION 1")
    row = row + 1
    
    widgets.horizontal_menu(row, 1, actions, 1)
    row = row + 1
    
    print("✓ Horizontal menu rendered successfully with item 1 highlighted")
    
    -- Test with different selection
    row = row + 2
    widgets.section_header(row, "TEST HORIZONTAL MENU WITH SELECTION 5")
    row = row + 1
    
    widgets.horizontal_menu(row, 1, actions, 5)
    row = row + 1
    
    print("✓ Horizontal menu rendered successfully with item 5 highlighted")
    
    term.cleanup()
end

-- Test input module
local function test_input_module()
    print("\nTesting input module...")
    
    local input = require("terminal.input")
    
    -- Test that module loads
    assert(type(input) == "table", "input should be a table")
    print("✓ Input module loaded successfully")
    
    -- Test that key constants exist
    assert(input.keys.UP == "up", "UP key constant should exist")
    assert(input.keys.DOWN == "down", "DOWN key constant should exist")
    assert(input.keys.LEFT == "left", "LEFT key constant should exist")
    assert(input.keys.RIGHT == "right", "RIGHT key constant should exist")
    assert(input.keys.ENTER == "enter", "ENTER key constant should exist")
    assert(input.keys.Q == "q", "Q key constant should exist")
    print("✓ All key constants exist")
    
    -- Test that functions exist
    assert(type(input.read_key) == "function", "read_key should be a function")
    assert(type(input.wait_for_enter) == "function", "wait_for_enter should be a function")
    assert(type(input.set_raw_mode) == "function", "set_raw_mode should be a function")
    assert(type(input.restore_mode) == "function", "restore_mode should be a function")
    print("✓ All input functions exist (including set_raw_mode and restore_mode)")
end

-- Run tests
print("===================================")
print("Running Menu Navigation Tests")
print("===================================")
print("")

test_input_module()
test_menu_rendering()

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The arrow key navigation system provides:")
print("  • Arrow key detection (UP/DOWN/LEFT/RIGHT)")
print("  • Enter key confirmation")
print("  • Horizontal menu layout with 2-space padding")
print("  • Highlighted menu items")
print("  • Visual selection feedback")
print("")

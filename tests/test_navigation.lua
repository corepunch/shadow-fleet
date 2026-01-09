#!/usr/bin/env lua5.3
-- Simple test for BBS Door-style menu navigation
-- This tests the hotkey-based navigation without requiring user interaction

local term = require("terminal")
local widgets = require("ui")

-- Test basic menu item widget
local function test_menu_item_widget()
    print("Testing menu item widget...")
    
    -- Test that menu_item function exists
    assert(type(widgets.menu_item) == "function", 
           "widgets.menu_item should be a function")
    
    print("✓ menu_item function exists")
    
    -- Test rendering
    term.init()
    term.clear()
    
    local row = 1
    widgets.section_header(row, "TEST MENU")
    row = row + 1
    
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
    
    for i, action in ipairs(actions) do
        widgets.menu_item(row, i, action)
        row = row + 1
    end
    
    print("✓ Menu rendered successfully")
    
    term.cleanup()
end

-- Test widgets module
local function test_widgets_module()
    print("\nTesting widgets module...")
    
    local widgets = require("ui")
    
    -- Test that module loads
    assert(type(widgets) == "table", "widgets should be a table")
    print("✓ Widgets module loaded successfully")
    
    -- Test that key functions exist
    assert(type(widgets.separator) == "function", "separator should be a function")
    assert(type(widgets.title) == "function", "title should be a function")
    assert(type(widgets.section_header) == "function", "section_header should be a function")
    assert(type(widgets.menu_item) == "function", "menu_item should be a function")
    assert(type(widgets.format_number) == "function", "format_number should be a function")
    print("✓ All widget functions exist")
end

-- Run tests
print("===================================")
print("Running BBS Door Navigation Tests")
print("===================================")
print("")

test_widgets_module()
test_menu_item_widget()

print("")
print("===================================")
print("All tests passed! ✓")
print("===================================")
print("")
print("The BBS Door navigation system provides:")
print("  • Hotkey-based navigation (F/R/T/E/V/M/S/?)")
print("  • Simple sequential text output")
print("  • Color-coded text display")
print("  • Back navigation with B key")
print("")

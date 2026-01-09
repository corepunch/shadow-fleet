#!/usr/bin/env lua5.3

-- Test Theme Functionality
-- Tests that themes can be set and affect terminal behavior

local terminal = require("terminal")

print("Testing Terminal Theme Functionality...")
print("")

-- Test 1: Default theme should be dark
assert(terminal.current_theme == "dark", "Default theme should be 'dark'")
print("✓ Test 1: Default theme is dark")

-- Test 2: Theme switching works
terminal.set_theme("light")
assert(terminal.current_theme == "light", "Theme should switch to light")
print("✓ Test 2: Can switch to light theme")

terminal.set_theme("dark")
assert(terminal.current_theme == "dark", "Theme should switch back to dark")
print("✓ Test 3: Can switch back to dark theme")

-- Test 4: Invalid theme throws error
local success, err = pcall(function()
    terminal.set_theme("invalid")
end)
assert(not success, "Setting invalid theme should throw error")
print("✓ Test 4: Invalid theme throws error")

-- Test 5: get_theme_bg returns correct values
terminal.set_theme("dark")
assert(terminal.get_theme_bg() == "bg_black", "Dark theme should have black background")
terminal.set_theme("light")
assert(terminal.get_theme_bg() == "bg_white", "Light theme should have white background")
print("✓ Test 5: Theme background colors are correct")

-- Test 6: get_theme_fg returns correct values
terminal.set_theme("dark")
assert(terminal.get_theme_fg() == "fg_white", "Dark theme should have white foreground")
terminal.set_theme("light")
assert(terminal.get_theme_fg() == "fg_black", "Light theme should have black foreground")
print("✓ Test 6: Theme foreground colors are correct")

-- Test 7: get_scheme returns correct schemes
terminal.set_theme("dark")
local dark_default = terminal.get_scheme("default")
assert(dark_default.fg == "fg_white", "Dark default scheme should have white foreground")
assert(dark_default.bg == "bg_black", "Dark default scheme should have black background")
print("✓ Test 7: get_scheme returns dark theme schemes")

terminal.set_theme("light")
local light_default = terminal.get_scheme("default")
assert(light_default.fg == "fg_black", "Light default scheme should have black foreground")
assert(light_default.bg == "bg_white", "Light default scheme should have white background")
print("✓ Test 8: get_scheme returns light theme schemes")

-- Test 9: init() accepts theme parameter
terminal.init("light")
assert(terminal.current_theme == "light", "init() should set theme to light")
print("✓ Test 9: init() accepts theme parameter")

-- Reset terminal
terminal.cleanup()

-- Test 10: Visual test - display both themes
print("")
print("Visual Test - Comparing Dark and Light Themes:")
print("")

-- Show dark theme
terminal.set_theme("dark")
terminal.init("dark")
print("Dark Theme:")
print("  Default text (should be white on black)")
terminal.apply_scheme("error")
io.write("  Error text ")
terminal.reset()
print("")
terminal.apply_scheme("success")
io.write("  Success text ")
terminal.reset()
print("")
terminal.apply_scheme("warning")
io.write("  Warning text ")
terminal.reset()
print("")
terminal.cleanup()

print("")

-- Show light theme
terminal.set_theme("light")
terminal.init("light")
print("Light Theme:")
print("  Default text (should be black on white)")
terminal.apply_scheme("error")
io.write("  Error text ")
terminal.reset()
print("")
terminal.apply_scheme("success")
io.write("  Success text ")
terminal.reset()
print("")
terminal.apply_scheme("warning")
io.write("  Warning text ")
terminal.reset()
print("")
terminal.cleanup()

print("")
print("✓ Test 10: Visual theme comparison complete")

print("")
print("===================================")
print("All theme tests passed! ✓")
print("===================================")
print("")
print("Theme features:")
print("  • Dark theme (white on black)")
print("  • Light theme (black on white)")
print("  • Theme-aware color schemes")
print("  • Command-line theme selection")
print("  • Dynamic theme switching")
print("")

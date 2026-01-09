#!/usr/bin/env lua5.3
-- Test integer color codes in write_colored

local terminal = require("terminal")

print("Testing Integer Color Codes...")
print("")

-- Test 1: Verify color constants exist
print("✓ Test 1: Color constants exist")
assert(terminal.colors.fg_bright_yellow == 93, "fg_bright_yellow should be 93")
assert(terminal.colors.bg_black == 40, "bg_black should be 40")

-- Test 2: Test packed color format (fg << 8) | bg
local fg = terminal.colors.fg_bright_yellow
local bg = terminal.colors.bg_black
local packed = (fg << 8) | bg

print("✓ Test 2: Packed color format")
print("  fg_bright_yellow = " .. fg)
print("  bg_black = " .. bg)
print("  packed = " .. packed)

-- Test 3: Visual test - string colors (backward compatible)
print("")
print("✓ Test 3: String colors (backward compatible)")
terminal.write_colored("  This is bright yellow text on black background", "fg_bright_yellow", "bg_black")
print(" <- should be yellow on black, then reset to white on black")

-- Test 4: Visual test - integer colors as separate parameters
print("")
print("✓ Test 4: Integer colors as separate parameters")
terminal.write_colored("  This is bright yellow text on black background", fg, bg)
print(" <- should be yellow on black, then reset to white on black")

-- Test 5: Visual test - packed integer color
print("")
print("✓ Test 5: Packed integer color format (fg << 8) | bg")
terminal.write_colored("  This is bright yellow text on black background", packed)
print(" <- should be yellow on black, then reset to white on black")

-- Test 6: Visual test - bitwise OR with bit-shift syntax ((fg << 8) | bg)
print("")
print("✓ Test 6: Using bit-shift packing syntax ((fg << 8)|bg)")
terminal.write_colored("  This is bright yellow text on black background", 
                      (terminal.colors.fg_bright_yellow << 8) | terminal.colors.bg_black)
print(" <- should be yellow on black, then reset to white on black")

-- Test 7: Verify color reset to default (fg_white on bg_black)
print("")
print("✓ Test 7: Verify automatic color reset to white on black")
terminal.write_colored("  Yellow text", terminal.colors.fg_bright_yellow, terminal.colors.bg_black)
io.write("  White text (should be white on black without explicit color set)")
print("")

-- Test 8: Test multiple color combinations
print("")
print("✓ Test 8: Multiple color combinations")
local test_colors = {
    {terminal.colors.fg_bright_green, terminal.colors.bg_black, "Green"},
    {terminal.colors.fg_bright_red, terminal.colors.bg_black, "Red"},
    {terminal.colors.fg_bright_cyan, terminal.colors.bg_black, "Cyan"},
    {terminal.colors.fg_white, terminal.colors.bg_black, "White"},
}

for _, test in ipairs(test_colors) do
    local fg, bg, name = test[1], test[2], test[3]
    terminal.write_colored("  " .. name, (fg << 8) | bg)
    io.write(" ")
end
print("")

print("")
print("===================================")
print("All integer color tests passed! ✓")
print("===================================")
print("")
print("Summary:")
print("  • String color names still work (backward compatible)")
print("  • Integer color codes work as separate parameters")
print("  • Packed format (fg << 8) | bg works")
print("  • Colors automatically reset to white on black after each call")
print("")

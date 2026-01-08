#!/usr/bin/env lua5.3
-- Terminal Framework Demo
-- Demonstrates the capabilities of the terminal framework

local terminal = require("terminal")

-- Helper function to pause and wait for user input
local function pause(message)
    message = message or "Press Enter to continue..."
    terminal.move_to(25, 1)
    terminal.write_colored(message, "fg_bright_yellow", "bg_black")
    io.read()
end

-- Demo 1: Basic screen operations
local function demo_basic()
    terminal.init()
    
    terminal.write_at(1, 1, "=== TERMINAL FRAMEWORK DEMO ===", "fg_bright_white", "bg_blue")
    terminal.write_at(3, 1, "Demo 1: Basic Operations")
    
    terminal.write_at(5, 1, "Clearing screen...")
    pause()
    
    terminal.clear()
    terminal.write_at(1, 1, "Screen cleared!", "fg_green")
    terminal.write_at(3, 1, "Moving cursor to different positions...")
    
    terminal.write_at(5, 10, "X", "fg_red")
    terminal.write_at(7, 20, "X", "fg_green")
    terminal.write_at(9, 30, "X", "fg_blue")
    terminal.write_at(11, 40, "X", "fg_yellow")
    
    pause()
end

-- Demo 2: Colors
local function demo_colors()
    terminal.clear()
    terminal.write_at(1, 1, "=== COLOR DEMO ===", "fg_bright_white", "bg_blue")
    
    local row = 3
    terminal.write_at(row, 1, "Foreground Colors:")
    row = row + 1
    
    local colors = {
        "fg_black", "fg_red", "fg_green", "fg_yellow",
        "fg_blue", "fg_magenta", "fg_cyan", "fg_white"
    }
    
    for i, color in ipairs(colors) do
        terminal.write_at(row, 1, "  " .. color .. ": ", "fg_white")
        terminal.write_colored("████", color)
        row = row + 1
    end
    
    row = row + 1
    terminal.write_at(row, 1, "Bright Foreground Colors:")
    row = row + 1
    
    local bright_colors = {
        "fg_bright_black", "fg_bright_red", "fg_bright_green", "fg_bright_yellow",
        "fg_bright_blue", "fg_bright_magenta", "fg_bright_cyan", "fg_bright_white"
    }
    
    for i, color in ipairs(bright_colors) do
        terminal.write_at(row, 1, "  " .. color .. ": ", "fg_white")
        terminal.write_colored("████", color)
        row = row + 1
    end
    
    pause()
end

-- Demo 3: Background colors
local function demo_backgrounds()
    terminal.clear()
    terminal.write_at(1, 1, "=== BACKGROUND COLOR DEMO ===", "fg_bright_white", "bg_blue")
    
    local row = 3
    terminal.write_at(row, 1, "Background Colors with White Text:")
    row = row + 1
    
    local bg_colors = {
        "bg_black", "bg_red", "bg_green", "bg_yellow",
        "bg_blue", "bg_magenta", "bg_cyan", "bg_white"
    }
    
    for i, bg in ipairs(bg_colors) do
        terminal.write_at(row, 1, "  ")
        terminal.write_colored(" " .. bg .. " ", "fg_white", bg)
        row = row + 1
    end
    
    pause()
end

-- Demo 4: Color combinations
local function demo_combinations()
    terminal.clear()
    terminal.write_at(1, 1, "=== COLOR COMBINATION DEMO ===", "fg_bright_white", "bg_blue")
    
    local row = 3
    terminal.write_at(row, 1, "Predefined Color Schemes:")
    row = row + 2
    
    for name, scheme in pairs(terminal.schemes) do
        terminal.write_at(row, 3, name .. ": ", "fg_white")
        terminal.write_colored("  Sample Text  ", scheme.fg, scheme.bg)
        row = row + 1
    end
    
    pause()
end

-- Demo 5: Drawing boxes
local function demo_boxes()
    terminal.clear()
    terminal.write_at(1, 1, "=== BOX DRAWING DEMO ===", "fg_bright_white", "bg_blue")
    
    terminal.draw_box(3, 3, 30, 8, "fg_green", "bg_black")
    terminal.write_at(4, 5, "Simple Box", "fg_green")
    
    terminal.draw_box(3, 40, 35, 8, "fg_cyan", "bg_black")
    terminal.write_at(4, 42, "Another Box with Text", "fg_cyan")
    
    terminal.fill_box(12, 3, 30, 5, " ", "fg_white", "bg_blue")
    terminal.write_at(14, 10, "Filled Box", "fg_white", "bg_blue")
    
    terminal.fill_box(12, 40, 35, 5, "░", "fg_yellow", "bg_black")
    terminal.write_at(14, 48, "Pattern Fill", "fg_yellow", "bg_black")
    
    pause()
end

-- Demo 6: Game UI Example
local function demo_game_ui()
    terminal.clear()
    
    -- Title bar
    terminal.fill_box(1, 1, 80, 1, " ", "fg_bright_yellow", "bg_blue")
    terminal.write_at(1, 30, "SHADOW FLEET", "fg_bright_yellow", "bg_blue")
    
    -- Main game area
    terminal.draw_box(3, 2, 78, 18, "fg_cyan", "bg_black")
    terminal.write_at(4, 4, "Game Area", "fg_cyan")
    
    -- Ships
    terminal.write_at(8, 10, "⚓ Tanker 'Aurora'", "fg_green")
    terminal.write_at(10, 20, "⚓ Cargo Ship 'Neva'", "fg_green")
    terminal.write_at(12, 15, "⚓ Oil Tanker 'Volga'", "fg_yellow")
    
    -- Ocean effect
    for i = 14, 18 do
        terminal.write_at(i, 5, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", "fg_blue")
    end
    
    -- Status bar
    terminal.fill_box(21, 1, 80, 1, " ", "fg_white", "bg_blue")
    terminal.write_at(21, 2, "Status: Active", "fg_white", "bg_blue")
    terminal.write_at(21, 30, "Ships: 3", "fg_white", "bg_blue")
    terminal.write_at(21, 50, "Sanctions: High Risk", "fg_yellow", "bg_blue")
    
    -- Info panel
    terminal.draw_box(3, 82, 40, 10, "fg_yellow", "bg_black")
    terminal.write_at(4, 84, "Mission Briefing", "fg_bright_yellow")
    terminal.write_at(6, 84, "Evade international", "fg_white")
    terminal.write_at(7, 84, "sanctions while", "fg_white")
    terminal.write_at(8, 84, "transporting cargo", "fg_white")
    
    -- Menu
    terminal.write_at(23, 2, "[M]ove [A]ttack [D]efend [Q]uit", "fg_bright_white")
    
    pause("Press Enter to finish demo...")
end

-- Main demo sequence
local function main()
    -- Save original terminal state
    print("Starting Terminal Framework Demo...")
    print("This demo will showcase the capabilities of the terminal framework.")
    print("")
    io.write("Press Enter to start...")
    io.read()
    
    demo_basic()
    demo_colors()
    demo_backgrounds()
    demo_combinations()
    demo_boxes()
    demo_game_ui()
    
    -- Cleanup and exit
    terminal.cleanup()
    print("\nDemo completed!")
    print("Terminal framework provides:")
    print("  ✓ Screen clearing and cursor positioning")
    print("  ✓ Foreground and background colors (16 colors)")
    print("  ✓ Predefined color schemes")
    print("  ✓ Box drawing utilities")
    print("  ✓ Text styling (bold, underline, etc.)")
    print("  ✓ All functions returned as a module table")
    print("\nUse: local terminal = require('terminal')")
end

main()

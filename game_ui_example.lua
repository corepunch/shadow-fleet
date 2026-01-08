#!/usr/bin/env lua5.3
-- Shadow Fleet Game UI Example
-- Demonstrates how to use the terminal framework for a game interface

local terminal = require("terminal")

-- Game state
local game = {
    ships = {
        {name = "Tanker Aurora", x = 10, y = 8, fuel = 85, status = "active"},
        {name = "Cargo Neva", x = 25, y = 12, fuel = 60, status = "active"},
        {name = "Oil Volga", x = 15, y = 15, fuel = 45, status = "warning"},
    },
    sanctions_level = 78,
    day = 15,
    money = 125000,
    selected = 1
}

-- Draw the title bar
local function draw_title_bar()
    terminal.fill_box(1, 1, 120, 1, " ", "fg_bright_yellow", "bg_blue")
    terminal.write_at(1, 48, "═══ SHADOW FLEET ═══", "fg_bright_yellow", "bg_blue")
    terminal.write_at(1, 2, "Day: " .. game.day, "fg_white", "bg_blue")
    terminal.write_at(1, 105, "$" .. game.money, "fg_bright_green", "bg_blue")
end

-- Draw the main map area
local function draw_map()
    terminal.draw_box(3, 2, 80, 20, "fg_cyan", "bg_black")
    terminal.write_at(3, 4, "[ BALTIC SEA ]", "fg_bright_cyan", "bg_black")
    
    -- Draw ocean waves
    local wave_rows = {6, 9, 12, 15, 18}
    for _, row in ipairs(wave_rows) do
        terminal.write_at(row, 5, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", "fg_blue")
    end
    
    -- Draw ships
    for i, ship in ipairs(game.ships) do
        local color = ship.status == "active" and "fg_bright_green" or "fg_bright_yellow"
        if i == game.selected then
            terminal.write_at(ship.y, ship.x, "► ⚓", "fg_bright_white", "bg_blue")
        else
            terminal.write_at(ship.y, ship.x, "  ⚓", color)
        end
    end
    
    -- Draw ports
    terminal.write_at(5, 70, "⌂ Port", "fg_bright_white")
    terminal.write_at(10, 75, "⌂ Port", "fg_bright_white")
    terminal.write_at(20, 65, "⌂ Port", "fg_bright_white")
end

-- Draw the info panel
local function draw_info_panel()
    terminal.draw_box(3, 84, 38, 20, "fg_yellow", "bg_black")
    terminal.write_at(3, 86, "[ FLEET STATUS ]", "fg_bright_yellow")
    
    local row = 5
    for i, ship in ipairs(game.ships) do
        -- Ship name
        if i == game.selected then
            terminal.write_at(row, 86, "►", "fg_bright_white")
        end
        terminal.write_at(row, 88, ship.name, i == game.selected and "fg_bright_white" or "fg_white")
        row = row + 1
        
        -- Fuel bar
        terminal.write_at(row, 88, "Fuel: ", "fg_cyan")
        local fuel_bars = math.floor(ship.fuel / 10)
        local bar_color = ship.fuel > 50 and "fg_green" or "fg_red"
        terminal.write_colored(string.rep("█", fuel_bars), bar_color)
        terminal.write_colored(" " .. ship.fuel .. "%", "fg_white")
        row = row + 1
        
        -- Status
        local status_color = ship.status == "active" and "fg_bright_green" or "fg_bright_yellow"
        terminal.write_at(row, 88, "Status: ", "fg_cyan")
        terminal.write_colored(string.upper(ship.status), status_color)
        row = row + 2
    end
end

-- Draw sanctions meter
local function draw_sanctions()
    terminal.draw_box(24, 2, 80, 5, "fg_red", "bg_black")
    terminal.write_at(24, 4, "[ SANCTIONS RISK ]", "fg_bright_red")
    
    terminal.write_at(26, 4, "International Pressure: ", "fg_white")
    local bars = math.floor(game.sanctions_level / 2)
    local bar_color = game.sanctions_level > 75 and "fg_bright_red" or 
                     game.sanctions_level > 50 and "fg_bright_yellow" or "fg_green"
    terminal.write_colored(string.rep("█", bars), bar_color, "bg_black")
    terminal.write_colored(" " .. game.sanctions_level .. "%", "fg_white")
    
    if game.sanctions_level > 75 then
        terminal.write_at(27, 4, "⚠ CRITICAL - Detection imminent!", "fg_bright_red", "bg_black")
    elseif game.sanctions_level > 50 then
        terminal.write_at(27, 4, "⚠ HIGH - Proceed with caution", "fg_bright_yellow", "bg_black")
    else
        terminal.write_at(27, 4, "✓ LOW - Operations normal", "fg_green", "bg_black")
    end
end

-- Draw message log
local function draw_messages()
    terminal.draw_box(24, 84, 38, 5, "fg_magenta", "bg_black")
    terminal.write_at(24, 86, "[ MESSAGES ]", "fg_bright_magenta")
    terminal.write_at(26, 86, "• Cargo loaded", "fg_white")
    terminal.write_at(27, 86, "• Route calculated", "fg_cyan")
end

-- Draw command bar
local function draw_commands()
    terminal.fill_box(30, 1, 120, 1, " ", "fg_black", "bg_white")
    terminal.write_at(30, 2, "[↑↓] Select Ship", "fg_black", "bg_white")
    terminal.write_at(30, 25, "[M] Move", "fg_black", "bg_white")
    terminal.write_at(30, 40, "[R] Refuel", "fg_black", "bg_white")
    terminal.write_at(30, 55, "[T] Trade", "fg_black", "bg_white")
    terminal.write_at(30, 70, "[H] Hide", "fg_black", "bg_white")
    terminal.write_at(30, 85, "[Q] Quit", "fg_black", "bg_white")
end

-- Main game loop (simplified - just drawing UI)
local function main()
    terminal.init()
    
    -- Draw all UI elements
    draw_title_bar()
    draw_map()
    draw_info_panel()
    draw_sanctions()
    draw_messages()
    draw_commands()
    
    -- Show cursor and wait
    terminal.show_cursor()
    terminal.move_to(32, 1)
    
    -- Print summary
    io.write("\n")
    print("═══════════════════════════════════════════════════════════")
    print("Shadow Fleet Game UI Example")
    print("═══════════════════════════════════════════════════════════")
    print("This demonstrates the terminal framework capabilities:")
    print("  ✓ Complex multi-panel UI layout")
    print("  ✓ Color-coded information (fuel, status, risk)")
    print("  ✓ Dynamic content rendering")
    print("  ✓ Box drawing for panels and borders")
    print("  ✓ Color schemes for different UI elements")
    print("  ✓ Precise cursor positioning")
    print("")
    print("The framework makes it easy to build rich terminal UIs!")
    print("═══════════════════════════════════════════════════════════")
end

main()

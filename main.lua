#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- BBS Door style interface with hotkey navigation

local term = require("terminal")
local gamestate = require("game")
local widgets = require("ui")

-- Initialize game state
local game = gamestate.new()

-- Raw mode flag
local raw_mode_active = false

-- Set terminal to raw mode for single-character input
local function set_raw_mode()
    if not raw_mode_active then
        os.execute("stty raw -echo 2>/dev/null")
        raw_mode_active = true
    end
end

-- Restore terminal to normal mode
local function restore_normal_mode()
    if raw_mode_active then
        os.execute("stty sane 2>/dev/null")
        raw_mode_active = false
    end
end

-- Read a single character without waiting for Enter
local function read_char()
    set_raw_mode()
    local char = io.read(1)
    return char
end

-- Helper function to fix line endings for raw terminal mode
-- Converts \n to \r\n, avoiding double conversion of existing \r\n sequences
local function fix_line_endings(text)
    local result = text:gsub("\r?\n", "\r\n")
    return result
end

-- Shorthand for color constants
local fg_bright_yellow = term.colors.fg_bright_yellow
local fg_bright_green = term.colors.fg_bright_green
local fg_bright_red = term.colors.fg_bright_red
local fg_bright_white = term.colors.fg_bright_white
local fg_bright_cyan = term.colors.fg_bright_cyan
local fg_white = term.colors.fg_white
local fg_yellow = term.colors.fg_yellow
local bg_black = term.colors.bg_black

-- Helper function to write colored text at cursor position
-- In raw mode, we need \r\n instead of just \n for proper line breaks
-- Accepts either:
--   1. String color names: write_colored(text, "fg_bright_yellow", "bg_black")
--   2. Two integer color codes: write_colored(text, fg_bright_yellow, bg_black)
--   3. Single packed integer (fg << 8) | bg: write_colored(text, fg_bright_yellow|bg_black)
local function write_colored(text, fg_color, bg_color)
    io.flush()  -- Ensure output is visible before setting colors
    
    -- If fg_color is an integer and bg_color is nil, check if it's a packed color code
    if type(fg_color) == "number" and bg_color == nil then
        -- If the value is > 255, it's likely a packed color code (fg << 8) | bg
        if fg_color > 255 then
            local packed = fg_color
            fg_color = packed >> 8
            bg_color = packed & 0xFF
        else
            -- Single color code, default bg to black
            bg_color = term.colors.bg_black
        end
        term.set_colors(fg_color, bg_color)
    elseif bg_color then
        term.set_colors(fg_color, bg_color)
    else
        term.set_fg(fg_color)
    end
    
    io.write(fix_line_endings(text))
    -- Restore default colors: light-grey (fg_white) on black
    term.set_colors(term.colors.fg_white, term.colors.bg_black)
    io.flush()  -- Ensure colored text is displayed immediately
end

-- Helper function to write plain text with proper line endings in raw mode
local function write_text(text)
    io.write(fix_line_endings(text))
    io.flush()
end

-- Print a separator line
local function print_separator()
    write_colored(string.rep("=", 80) .. "\n", "fg_white")
end

-- Print header
local function print_header()
    print_separator()
    write_colored("PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE\n", "fg_bright_red")
    print_separator()
end

-- Print status line
local function print_status()
    local heat_desc = gamestate.get_heat_description(game)
    write_colored("[", "fg_white")
    write_colored("Dark Terminal v0.1", "fg_cyan")
    write_colored("] - ", "fg_white")
    write_colored("Rogue Operator Mode", "fg_yellow")
    write_colored(" | Heat: ", "fg_white")
    write_colored(heat_desc, gamestate.get_heat_color(game))
    write_text("\n")
    
    write_colored(game.location, "fg_bright_cyan")
    write_colored(" - " .. game.date .. " | Rubles: ", "fg_white")
    write_colored(widgets.format_number(game.rubles), "fg_bright_yellow")
    write_colored(" | Oil Stock: ", "fg_white")
    write_colored(game.oil_stock .. "k bbls", "fg_bright_white")
    write_text("\n\n")
end

-- Print fleet status
local function print_fleet_status()
    write_colored("--- FLEET STATUS ---\n", "fg_bright_white")
    
    -- Table header
    write_colored(string.format("%-11s %-3s %-5s %-5s %-10s %-17s %-21s %-23s %-7s %-4s\n",
        "Name", "Age", "Hull", "Fuel", "Status", "Cargo", "Origin", "Destination", "ETA", "Risk"), "fg_white")
    
    write_colored(string.rep("-", 80) .. "\n", "fg_white")
    
    -- Table rows
    for i, ship in ipairs(game.fleet) do
        write_colored(string.format("%-11s ", ship.name), "fg_bright_cyan")
        write_colored(string.format("%-3s ", ship.age .. "y"), "fg_white")
        
        local hull_color = ship.hull >= 70 and "fg_green" or (ship.hull >= 50 and "fg_yellow" or "fg_red")
        write_colored(string.format("%-5s ", ship.hull .. "%"), hull_color)
        
        local fuel_color = ship.fuel >= 70 and "fg_green" or (ship.fuel >= 30 and "fg_yellow" or "fg_red")
        write_colored(string.format("%-5s ", ship.fuel .. "%"), fuel_color)
        
        write_colored(string.format("%-10s ", ship.status), "fg_white")
        write_colored(string.format("%-17s ", ship.cargo), "fg_bright_white")
        write_colored(string.format("%-21s ", ship.origin or "-"), "fg_bright_white")
        write_colored(string.format("%-23s ", ship.destination or "-"), "fg_white")
        write_colored(string.format("%-7s ", ship.eta or "-"), "fg_yellow")
        
        local risk_color = ship.risk == "None" and "fg_green" or 
                          (ship.risk:match("LOW") or ship.risk:match("MED")) and "fg_yellow" or "fg_bright_yellow"
        write_colored(string.format("%-4s", ship.risk), risk_color)
        write_text("\n")
    end
    
    write_text("\n")
    local stats = gamestate.get_fleet_stats(game)
    write_colored("Total Fleet: ", "fg_white")
    write_colored(stats.total .. "/" .. stats.max, "fg_bright_white")
    write_colored(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses, "fg_white")
    write_text("\n\n")
end

-- Print market snapshot
local function print_market_snapshot()
    write_colored("--- MARKET SNAPSHOT ---\n", "fg_bright_white")
    
    write_colored("Crude Price Cap: ", "fg_white")
    write_colored("$" .. game.market.crude_price_cap .. "/bbl", fg_bright_yellow|bg_black)
    write_colored(" | Shadow Markup: ", "fg_white")
    write_colored("+" .. game.market.shadow_markup_percent .. "%", "fg_bright_green")
    write_colored(" (", "fg_white")
    write_colored("$" .. game.market.shadow_price .. "/bbl", fg_bright_yellow|bg_black)
    write_colored(" to India/China)", "fg_white")
    write_text("\n")
    
    write_colored("Demand: ", "fg_white")
    write_colored(game.market.demand, "fg_bright_green")
    write_colored(" (Baltic Exports: ", "fg_white")
    write_colored(game.market.baltic_exports .. "M bbls/day", "fg_bright_white")
    write_colored(") | Sanctions Alert: ", "fg_white")
    write_colored(game.market.sanctions_alert, "fg_red")
    write_text("\n")
    
    write_colored('News Ticker: "', "fg_white")
    write_colored(game.market.news, "fg_yellow")
    write_colored('"', "fg_white")
    write_text("\n\n")
end

-- Print active events
local function print_active_events()
    write_colored("--- ACTIVE EVENTS ---\n", "fg_bright_white")
    
    for _, event in ipairs(game.events) do
        write_colored("- ", "fg_white")
        local event_color = event.type == "Pending" and "fg_yellow" or "fg_green"
        write_colored(event.type, event_color)
        write_colored(": " .. event.description, "fg_white")
        write_text("\n")
    end
    write_text("\n")
end

-- Print heat meter
local function print_heat_meter()
    write_colored("--- HEAT METER ---\n", "fg_bright_white")
    
    local heat = game.heat
    local max_heat = game.heat_max
    
    write_colored("[", "fg_white")
    for i = 1, max_heat do
        if i <= heat then
            write_colored("|", "fg_red")
        else
            write_colored("|", "fg_white")
        end
    end
    write_colored("] " .. heat .. "/" .. max_heat, gamestate.get_heat_color(game))
    write_colored(" - ", "fg_white")
    write_colored(gamestate.get_heat_message(game), heat > 7 and "fg_bright_red" or "fg_white")
    write_text("\n\n")
end

-- Print main menu
local function print_main_menu()
    write_colored("--- QUICK ACTIONS ---\n", "fg_bright_white")
    write_colored("(F) Fleet\n", "fg_white")
    write_colored("(R) Route\n", "fg_white")
    write_colored("(T) Trade\n", "fg_white")
    write_colored("(E) Evade\n", "fg_white")
    write_colored("(V) Events\n", "fg_white")
    write_colored("(M) Market\n", "fg_white")
    write_colored("(S) Status\n", "fg_white")
    write_colored("(?) Help\n", "fg_white")
    write_colored("(Q) Quit\n\n", "fg_white")
    write_colored("Enter command: ", "fg_bright_green")
end

-- Print submenu based on choice
local function print_submenu(menu_name, options)
    write_colored("\n--- " .. menu_name:upper() .. " MENU ---\n", "fg_bright_white")
    for key, option in pairs(options) do
        write_colored("(" .. key:upper() .. ") " .. option .. "\n", "fg_white")
    end
    write_colored("(B) Back\n\n", "fg_white")
    write_colored("Enter command: ", "fg_bright_green")
end

-- Main dashboard display
local function render_dashboard()
    -- Don't clear screen - append to terminal content
    write_text("\n")  -- Add spacing between screens
    print_header()
    print_status()
    print_market_snapshot()
    print_active_events()
    print_heat_meter()
    print_main_menu()
end

-- Menu structure with submenus
local menu_structure = {
    F = {
        name = "Fleet",
        submenus = {
            V = "View",
            Y = "Buy",
            U = "Upgrade",
            S = "Scrap"
        }
    },
    R = {
        name = "Route",
        submenus = {
            P = "Plot Ghost Path",
            L = "Load Cargo"
        }
    },
    T = {
        name = "Trade",
        submenus = {
            S = "Sell",
            L = "Launder Oil"
        }
    },
    E = {
        name = "Evade",
        submenus = {
            A = "Spoof AIS",
            F = "Flag Swap",
            I = "Bribe"
        }
    },
    V = {
        name = "Events",
        submenus = {
            R = "Resolve Pending Dilemmas"
        }
    },
    M = {
        name = "Market",
        submenus = {
            C = "Check Prices",
            P = "Speculate",
            A = "Auction Dive"
        }
    },
    S = {
        name = "Status",
        submenus = {
            R = "Quick Recap",
            N = "News Refresh"
        }
    },
    ["?"] = {
        name = "Help",
        submenus = {
            C = "Command Details"
        }
    }
}

-- Handle submenu action
local function handle_submenu_action(menu_name, action)
    write_text("\n")
    write_colored("Action '" .. action .. "' in " .. menu_name .. " not yet implemented.\n", "fg_yellow")
    write_colored("Press any key to continue...", "fg_white")
    read_char()  -- Single character input
    write_text("\n")
end

-- Handle submenu navigation
local function handle_submenu(menu_key)
    local menu = menu_structure[menu_key]
    if not menu then return end
    
    -- Don't clear screen - append to terminal content
    write_text("\n")
    
    -- Special case for Fleet menu - show fleet status
    if menu_key == "F" then
        print_header()
        print_status()
        print_fleet_status()
        print_submenu(menu.name, menu.submenus)
    else
        print_submenu(menu.name, menu.submenus)
    end
    
    while true do
        local choice = read_char()  -- Single character input
        
        -- Handle EOF (nil input)
        if not choice then
            return
        end
        
        choice = choice:upper()
        
        if choice == "B" or choice == "Q" then
            write_text("\n")  -- Add newline after input
            return  -- Back to main menu or quit
        elseif menu.submenus[choice] then
            write_text("\n")  -- Add newline after input
            handle_submenu_action(menu.name, menu.submenus[choice])
            -- Redraw submenu after action (without clearing)
            write_text("\n")
            if menu_key == "F" then
                print_header()
                print_status()
                print_fleet_status()
                print_submenu(menu.name, menu.submenus)
            else
                print_submenu(menu.name, menu.submenus)
            end
        else
            -- Invalid option - don't show error, just ignore
        end
    end
end

-- Main game loop
local function main()
    term.init()
    
    -- Use pcall to ensure terminal is restored on error
    local function game_loop()
        -- Clear screen only on initial startup
        term.clear()
        
        while true do
            render_dashboard()
            local choice = read_char()  -- Single character input
            
            -- Handle EOF (nil input)
            if not choice then
                write_text("\n")
                write_colored("Thank you for playing Shadow Fleet!\n", "fg_bright_yellow")
                break
            end
            
            choice = choice:upper()
            
            if choice == "Q" then
                write_text("\n")
                write_colored("Thank you for playing Shadow Fleet!\n", "fg_bright_yellow")
                break
            elseif menu_structure[choice] then
                write_text("\n")  -- Add newline after input
                handle_submenu(choice)
            else
                -- Invalid option - just ignore
            end
        end
    end
    
    local function error_handler(err)
        restore_normal_mode()
        return debug.traceback(err, 2)
    end
    
    local success, err = xpcall(game_loop, error_handler)
    
    -- Always restore terminal mode
    restore_normal_mode()
    term.cleanup()
    
    if not success then
        print("\nError occurred: " .. tostring(err))
    end
end

-- Run the game
main()

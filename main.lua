#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- BBS Door style interface with hotkey navigation

local term = require("terminal")
local gamestate = require("game")
local widgets = require("ui")

-- Parse command line arguments
local theme = "light"  -- default theme
for i = 1, #arg do
    if arg[i] == "--theme" or arg[i] == "-t" then
        if arg[i + 1] then
            theme = arg[i + 1]
        end
    elseif arg[i] == "--help" or arg[i] == "-h" then
        print("Shadow Fleet - Text-based Strategy Game")
        print("")
        print("Usage: lua5.3 main.lua [OPTIONS]")
        print("")
        print("Options:")
        print("  -t, --theme THEME    Set color theme (dark or light). Default: dark")
        print("  -h, --help           Show this help message")
        print("")
        os.exit(0)
    end
end

-- Validate theme
if theme ~= "dark" and theme ~= "light" then
    print("Error: Invalid theme '" .. theme .. "'. Must be 'dark' or 'light'.")
    os.exit(1)
end

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
local fg_cyan = term.colors.fg_cyan
local fg_white = term.colors.fg_white
local fg_yellow = term.colors.fg_yellow
local fg_green = term.colors.fg_green
local fg_red = term.colors.fg_red

-- Helper function to get theme background
local function get_bg()
    return term.colors[term.get_theme_bg()]
end

-- Helper function to get theme foreground
local function get_fg()
    return term.colors[term.get_theme_fg()]
end

-- Helper function to write colored text with optional formatting
-- In raw mode, we need \r\n instead of just \n for proper line breaks
-- Usage: echo(color, format_string, ...)
-- Example: echo(fg_bright_green, "Enter command: ")
-- Example: echo(fg_white, "Ship: %s Age: %d", ship.name, ship.age)
local function echo(fg_color, ...)
    local args = {...}
    local text
    
    -- If we have arguments, format them
    if #args > 0 then
        -- First argument is the format string
        if #args == 1 then
            text = args[1]
        else
            text = string.format(args[1], select(2, ...))
        end
    else
        text = ""
    end
    
    -- Fix line endings for raw terminal mode
    local fixed_text = fix_line_endings(text)
    
    -- Ensure output is visible before setting colors
    io.flush()
    
    -- Set color (always with theme background)
    term.set_colors(fg_color, get_bg())
    
    io.write(fixed_text)
    
    -- Restore default colors based on theme
    term.set_colors(get_fg(), get_bg())
    io.flush()
end

-- Helper function to write plain text with proper line endings in raw mode
local function write_text(text)
    io.write(fix_line_endings(text))
    io.flush()
end

-- Print a separator line
local function print_separator()
    echo(get_fg(), string.rep("=", 80) .. "\n")
end

-- Print header
local function print_header()
    print_separator()
    echo(fg_bright_red, "PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE\n")
    print_separator()
end

-- Print status line
local function print_status()
    local heat_desc = gamestate.get_heat_description(game)
    echo(get_fg(), "[")
    echo(fg_cyan, "Dark Terminal v0.1")
    echo(get_fg(), "] - ")
    echo(fg_yellow, "Rogue Operator Mode")
    echo(get_fg(), " | Heat: ")
    echo(gamestate.get_heat_color(game), heat_desc)
    write_text("\n")
    
    echo(fg_bright_cyan, game.location)
    echo(get_fg(), " - " .. game.date .. " | Rubles: ")
    echo(fg_bright_yellow, widgets.format_number(game.rubles))
    echo(get_fg(), " | Oil Stock: ")
    echo(fg_bright_white, game.oil_stock .. "k bbls")
    write_text("\n\n")
end

-- Print fleet status
local function print_fleet_status()
    echo(fg_bright_white, "--- FLEET STATUS ---\n")
    
    -- Table header
    echo(get_fg(), "%-11s %-3s %-5s %-5s %-10s %-17s %-21s %-23s %-7s %-4s\n",
        "Name", "Age", "Hull", "Fuel", "Status", "Cargo", "Origin", "Destination", "ETA", "Risk")
    
    echo(get_fg(), string.rep("-", 80) .. "\n")
    
    -- Table rows
    for i, ship in ipairs(game.fleet) do
        echo(fg_bright_cyan, "%-11s ", ship.name)
        echo(get_fg(), "%-3s ", ship.age .. "y")
        
        local hull_color = ship.hull >= 70 and fg_green or (ship.hull >= 50 and fg_yellow or fg_red)
        echo(hull_color, "%-5s ", ship.hull .. "%")
        
        local fuel_color = ship.fuel >= 70 and fg_green or (ship.fuel >= 30 and fg_yellow or fg_red)
        echo(fuel_color, "%-5s ", ship.fuel .. "%")
        
        echo(get_fg(), "%-10s ", ship.status)
        echo(fg_bright_white, "%-17s ", ship.cargo)
        echo(fg_bright_white, "%-21s ", ship.origin or "-")
        echo(get_fg(), "%-23s ", ship.destination or "-")
        echo(fg_yellow, "%-7s ", ship.eta or "-")
        
        local risk_color = ship.risk == "None" and fg_green or 
                          (ship.risk:match("LOW") or ship.risk:match("MED")) and fg_yellow or fg_bright_yellow
        echo(risk_color, "%-4s", ship.risk)
        write_text("\n")
    end
    
    write_text("\n")
    local stats = gamestate.get_fleet_stats(game)
    echo(get_fg(), "Total Fleet: ")
    echo(fg_bright_white, stats.total .. "/" .. stats.max)
    echo(get_fg(), " | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses)
    write_text("\n\n")
end

-- Print market snapshot
local function print_market_snapshot()
    echo(fg_bright_white, "--- MARKET SNAPSHOT ---\n")
    
    echo(get_fg(), "Crude Price Cap: ")
    echo(fg_bright_yellow, "$" .. game.market.crude_price_cap .. "/bbl")
    echo(get_fg(), " | Shadow Markup: ")
    echo(fg_bright_green, "+" .. game.market.shadow_markup_percent .. "%")
    echo(get_fg(), " (")
    echo(fg_bright_yellow, "$" .. game.market.shadow_price .. "/bbl")
    echo(get_fg(), " to India/China)")
    write_text("\n")
    
    echo(get_fg(), "Demand: ")
    echo(fg_bright_green, game.market.demand)
    echo(get_fg(), " (Baltic Exports: ")
    echo(fg_bright_white, game.market.baltic_exports .. "M bbls/day")
    echo(get_fg(), ") | Sanctions Alert: ")
    echo(fg_red, game.market.sanctions_alert)
    write_text("\n")
    
    echo(get_fg(), 'News Ticker: "')
    echo(fg_yellow, game.market.news)
    echo(get_fg(), '"')
    write_text("\n\n")
end

-- Print active events
local function print_active_events()
    echo(fg_bright_white, "--- ACTIVE EVENTS ---\n")
    
    for _, event in ipairs(game.events) do
        echo(get_fg(), "- ")
        local event_color = event.type == "Pending" and fg_yellow or fg_green
        echo(event_color, event.type)
        echo(get_fg(), ": " .. event.description)
        write_text("\n")
    end
    write_text("\n")
end

-- Print heat meter
local function print_heat_meter()
    echo(fg_bright_white, "--- HEAT METER ---\n")
    
    local heat = game.heat
    local max_heat = game.heat_max
    
    echo(get_fg(), "[")
    for i = 1, max_heat do
        if i <= heat then
            echo(fg_red, "|")
        else
            echo(get_fg(), "|")
        end
    end
    echo(gamestate.get_heat_color(game), "] " .. heat .. "/" .. max_heat)
    echo(get_fg(), " - ")
    echo(heat > 7 and fg_bright_red or get_fg(), gamestate.get_heat_message(game))
    write_text("\n\n")
end

-- Print main menu
local function print_main_menu()
    echo(fg_bright_white, "--- QUICK ACTIONS ---\n")
    echo(get_fg(), "(F) Fleet\n")
    echo(get_fg(), "(R) Route\n")
    echo(get_fg(), "(T) Trade\n")
    echo(get_fg(), "(E) Evade\n")
    echo(get_fg(), "(V) Events\n")
    echo(get_fg(), "(M) Market\n")
    echo(get_fg(), "(S) Status\n")
    echo(get_fg(), "(?) Help\n")
    echo(get_fg(), "(Q) Quit\n\n")
    echo(fg_bright_green, "Enter command: ")
end

-- Print submenu based on choice
local function print_submenu(menu_name, options)
    echo(fg_bright_white, "\n--- " .. menu_name:upper() .. " MENU ---\n")
    for key, option in pairs(options) do
        echo(get_fg(), "(" .. key:upper() .. ") " .. option .. "\n")
    end
    echo(get_fg(), "(B) Back\n\n")
    echo(fg_bright_green, "Enter command: ")
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
    echo(fg_yellow, "Action '" .. action .. "' in " .. menu_name .. " not yet implemented.\n")
    echo(fg_white, "Press any key to continue...")
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
    term.init(theme)
    
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
                echo(fg_bright_yellow, "Thank you for playing Shadow Fleet!\n")
                break
            end
            
            choice = choice:upper()
            
            if choice == "Q" then
                write_text("\n")
                echo(fg_bright_yellow, "Thank you for playing Shadow Fleet!\n")
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

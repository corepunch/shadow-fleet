#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- BBS Door style interface with hotkey navigation

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

-- Helper function to write text with optional formatting
-- In raw mode, we need \r\n instead of just \n for proper line breaks
-- Usage: echo(format_string, ...)
-- Example: echo("Enter command: ")
-- Example: echo("Ship: %s Age: %d", ship.name, ship.age)
local function echo(...)
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
    
    io.write(fixed_text)
    io.flush()
end

-- Print a separator line
local function print_separator()
    echo(string.rep("=", 80) .. "\n")
end

-- Print header
local function print_header()
    print_separator()
    echo("PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE\n")
    print_separator()
end

-- Print status line
local function print_status()
    local heat_desc = gamestate.get_heat_description(game)
    echo("[")
    echo("Dark Terminal v0.1")
    echo("] - ")
    echo("Rogue Operator Mode")
    echo(" | Heat: ")
    echo(heat_desc)
    echo("\n")
    
    echo(game.location)
    echo(" - " .. game.date .. " | Rubles: ")
    echo(widgets.format_number(game.rubles))
    echo(" | Oil Stock: ")
    echo(game.oil_stock .. "k bbls")
    echo("\n\n")
end

-- Print fleet status
local function print_fleet_status()
    echo("--- FLEET STATUS ---\n")
    
    -- Table header
    echo("%-11s %-3s %-5s %-5s %-10s %-17s %-21s %-23s %-7s %-4s\n",
        "Name", "Age", "Hull", "Fuel", "Status", "Cargo", "Origin", "Destination", "ETA", "Risk")
    
    echo(string.rep("-", 80) .. "\n")
    
    -- Table rows
    for i, ship in ipairs(game.fleet) do
        echo("%-11s ", ship.name)
        echo("%-3s ", ship.age .. "y")
        echo("%-5s ", ship.hull .. "%")
        echo("%-5s ", ship.fuel .. "%")
        echo("%-10s ", ship.status)
        echo("%-17s ", ship.cargo)
        echo("%-21s ", ship.origin or "-")
        echo("%-23s ", ship.destination or "-")
        echo("%-7s ", ship.eta or "-")
        echo("%-4s", ship.risk)
        echo("\n")
    end
    
    echo("\n")
    local stats = gamestate.get_fleet_stats(game)
    echo("Total Fleet: ")
    echo(stats.total .. "/" .. stats.max)
    echo(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses)
    echo("\n\n")
end

-- Print market snapshot
local function print_market_snapshot()
    echo("--- MARKET SNAPSHOT ---\n")
    
    echo("Crude Price Cap: ")
    echo("$" .. game.market.crude_price_cap .. "/bbl")
    echo(" | Shadow Markup: ")
    echo("+" .. game.market.shadow_markup_percent .. "%")
    echo(" (")
    echo("$" .. game.market.shadow_price .. "/bbl")
    echo(" to India/China)")
    echo("\n")
    
    echo("Demand: ")
    echo(game.market.demand)
    echo(" (Baltic Exports: ")
    echo(game.market.baltic_exports .. "M bbls/day")
    echo(") | Sanctions Alert: ")
    echo(game.market.sanctions_alert)
    echo("\n")
    
    echo('News Ticker: "')
    echo(game.market.news)
    echo('"')
    echo("\n\n")
end

-- Print active events
local function print_active_events()
    echo("--- ACTIVE EVENTS ---\n")
    
    for _, event in ipairs(game.events) do
        echo("- ")
        echo(event.type)
        echo(": " .. event.description)
        echo("\n")
    end
    echo("\n")
end

-- Print heat meter
local function print_heat_meter()
    echo("--- HEAT METER ---\n")
    
    local heat = game.heat
    local max_heat = game.heat_max
    
    echo("[")
    for i = 1, max_heat do
        if i <= heat then
            echo("|")
        else
            echo("|")
        end
    end
    echo("] " .. heat .. "/" .. max_heat)
    echo(" - ")
    echo(gamestate.get_heat_message(game))
    echo("\n\n")
end

-- Print main menu
local function print_main_menu()
    echo("--- QUICK ACTIONS ---\n")
    echo("(F) Fleet\n")
    echo("(R) Route\n")
    echo("(T) Trade\n")
    echo("(E) Evade\n")
    echo("(V) Events\n")
    echo("(M) Market\n")
    echo("(S) Status\n")
    echo("(?) Help\n")
    echo("(Q) Quit\n\n")
    echo("Enter command: ")
end

-- Print submenu based on choice
local function print_submenu(menu_name, options)
    echo("\n--- " .. menu_name:upper() .. " MENU ---\n")
    for key, option in pairs(options) do
        echo("(" .. key:upper() .. ") " .. option .. "\n")
    end
    echo("(B) Back\n\n")
    echo("Enter command: ")
end

-- Main dashboard display
local function render_dashboard()
    -- Don't clear screen - append to terminal content
    echo("\n")  -- Add spacing between screens
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
    echo("\n")
    echo("Action '" .. action .. "' in " .. menu_name .. " not yet implemented.\n")
    echo("Press any key to continue...")
    read_char()  -- Single character input
    echo("\n")
end

-- Handle submenu navigation
local function handle_submenu(menu_key)
    local menu = menu_structure[menu_key]
    if not menu then return end
    
    -- Don't clear screen - append to terminal content
    echo("\n")
    
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
            echo("\n")  -- Add newline after input
            return  -- Back to main menu or quit
        elseif menu.submenus[choice] then
            echo("\n")  -- Add newline after input
            handle_submenu_action(menu.name, menu.submenus[choice])
            -- Redraw submenu after action (without clearing)
            echo("\n")
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
    -- Use pcall to ensure terminal is restored on error
    local function game_loop()
        while true do
            render_dashboard()
            local choice = read_char()  -- Single character input
            
            -- Handle EOF (nil input)
            if not choice then
                echo("\n")
                echo("Thank you for playing Shadow Fleet!\n")
                break
            end
            
            choice = choice:upper()
            
            if choice == "Q" then
                echo("\n")
                echo("Thank you for playing Shadow Fleet!\n")
                break
            elseif menu_structure[choice] then
                echo("\n")  -- Add newline after input
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
    
    if not success then
        print("\nError occurred: " .. tostring(err))
    end
end

-- Run the game
main()

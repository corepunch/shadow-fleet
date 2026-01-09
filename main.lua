#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- BBS Door style interface with hotkey navigation

local term = require("terminal")
local gamestate = require("game")
local widgets = require("ui")

-- Initialize game state
local game = gamestate.new()

-- Helper function to write colored text at cursor position
local function write_colored(text, fg_color, bg_color)
    if bg_color then
        term.set_colors(fg_color, bg_color)
    else
        term.set_fg(fg_color)
    end
    io.write(text)
    term.reset()
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
    io.write("\n")
    
    write_colored(game.location, "fg_bright_cyan")
    write_colored(" - " .. game.date .. " | Rubles: ", "fg_white")
    write_colored(widgets.format_number(game.rubles), "fg_bright_yellow")
    write_colored(" | Oil Stock: ", "fg_white")
    write_colored(game.oil_stock .. "k bbls", "fg_bright_white")
    io.write("\n\n")
end

-- Print fleet status
local function print_fleet_status()
    write_colored("--- FLEET STATUS ---\n", "fg_bright_white")
    
    -- Table header
    io.write(string.format("%-11s %-3s %-5s %-5s %-10s %-17s %-21s %-23s %-7s %-4s\n",
        "Name", "Age", "Hull", "Fuel", "Status", "Cargo", "Origin", "Destination", "ETA", "Risk"))
    
    io.write(string.rep("-", 80) .. "\n")
    
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
        io.write("\n")
    end
    
    io.write("\n")
    local stats = gamestate.get_fleet_stats(game)
    write_colored("Total Fleet: ", "fg_white")
    write_colored(stats.total .. "/" .. stats.max, "fg_bright_white")
    write_colored(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses, "fg_white")
    io.write("\n\n")
end

-- Print market snapshot
local function print_market_snapshot()
    write_colored("--- MARKET SNAPSHOT ---\n", "fg_bright_white")
    
    write_colored("Crude Price Cap: ", "fg_white")
    write_colored("$" .. game.market.crude_price_cap .. "/bbl", "fg_bright_yellow")
    write_colored(" | Shadow Markup: ", "fg_white")
    write_colored("+" .. game.market.shadow_markup_percent .. "%", "fg_bright_green")
    write_colored(" (", "fg_white")
    write_colored("$" .. game.market.shadow_price .. "/bbl", "fg_bright_yellow")
    write_colored(" to India/China)", "fg_white")
    io.write("\n")
    
    write_colored("Demand: ", "fg_white")
    write_colored(game.market.demand, "fg_bright_green")
    write_colored(" (Baltic Exports: ", "fg_white")
    write_colored(game.market.baltic_exports .. "M bbls/day", "fg_bright_white")
    write_colored(") | Sanctions Alert: ", "fg_white")
    write_colored(game.market.sanctions_alert, "fg_red")
    io.write("\n")
    
    write_colored('News Ticker: "', "fg_white")
    write_colored(game.market.news, "fg_yellow")
    write_colored('"', "fg_white")
    io.write("\n\n")
end

-- Print active events
local function print_active_events()
    write_colored("--- ACTIVE EVENTS ---\n", "fg_bright_white")
    
    for _, event in ipairs(game.events) do
        write_colored("- ", "fg_white")
        local event_color = event.type == "Pending" and "fg_yellow" or "fg_green"
        write_colored(event.type, event_color)
        write_colored(": " .. event.description, "fg_white")
        io.write("\n")
    end
    io.write("\n")
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
    io.write("\n\n")
end

-- Print main menu
local function print_main_menu()
    write_colored("--- QUICK ACTIONS ---\n", "fg_bright_white")
    write_colored("(F) Fleet  (R) Route  (T) Trade  (E) Evade\n", "fg_white")
    write_colored("(V) Events  (M) Market  (S) Status  (?) Help\n", "fg_white")
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
    term.clear()
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
    io.write("\n")
    write_colored("Action '" .. action .. "' in " .. menu_name .. " not yet implemented.\n", "fg_yellow")
    write_colored("Press Enter to continue...", "fg_white")
    io.read()
end

-- Handle submenu navigation
local function handle_submenu(menu_key)
    local menu = menu_structure[menu_key]
    if not menu then return end
    
    -- Special case for Fleet menu - show fleet status
    if menu_key == "F" then
        term.clear()
        print_header()
        print_status()
        print_fleet_status()
        print_submenu(menu.name, menu.submenus)
    else
        print_submenu(menu.name, menu.submenus)
    end
    
    while true do
        local choice = io.read()
        
        -- Handle EOF (nil input)
        if not choice then
            return
        end
        
        choice = choice:upper()
        
        if choice == "B" or choice == "Q" then
            return  -- Back to main menu or quit
        elseif menu.submenus[choice] then
            handle_submenu_action(menu.name, menu.submenus[choice])
            -- Redraw submenu after action
            if menu_key == "F" then
                term.clear()
                print_header()
                print_status()
                print_fleet_status()
                print_submenu(menu.name, menu.submenus)
            else
                print_submenu(menu.name, menu.submenus)
            end
        else
            write_colored("Invalid option. Try again: ", "fg_red")
        end
    end
end

-- Main game loop
local function main()
    term.init()
    
    while true do
        render_dashboard()
        local choice = io.read()
        
        -- Handle EOF (nil input)
        if not choice then
            term.clear()
            print("Thank you for playing Shadow Fleet!")
            break
        end
        
        choice = choice:upper()
        
        if choice == "Q" then
            term.clear()
            print("Thank you for playing Shadow Fleet!")
            break
        elseif menu_structure[choice] then
            handle_submenu(choice)
        else
            write_colored("\nInvalid option. Press Enter to continue...", "fg_red")
            io.read()
        end
    end
    
    term.cleanup()
end

-- Run the game
main()

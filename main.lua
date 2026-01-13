#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- BBS Door style interface with hotkey navigation

local gamestate = require("game")
local widgets = require("ui")
local commands = require("commands")
local keymap = require("keymap")
local commands_init = require("commands_init")
local terminal = require("terminal")
local menu = require("menu")
local display = require("display")
local command_labels = require("command_labels")
local routes_presenter = require("presenters.routes")

-- Initialize game state
local game = gamestate.new()

-- Wrapper for echo function to use throughout
local echo = terminal.echo
local read_char = terminal.read_char
local read_line = terminal.read_line

-- Main dashboard display
local function render_dashboard()
    echo("\n")  -- Add spacing between screens
    display.header(echo)
    display.status(game, echo)
    display.fleet_status(game, echo)  -- Always show fleet status
    menu.print_from_keymap("MAIN MENU", keymap.main, echo)
end

-- Echo command label after user input
-- Always outputs a newline to maintain consistent spacing,
-- even when no label is found (e.g., for invalid commands)
local function echo_command_label(command_id)
    local label = command_labels[command_id]
    if label then
        echo(label .. "\n")
    else
        echo("\n")
    end
end

-- Handle vessel upgrade flow
local function handle_vessel_upgrade()
    echo("\n")
    
    if #game.fleet == 0 then
        echo("No vessels in fleet to upgrade.\nPress any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Display vessel selection menu
    display.header(echo)
    display.status(game, echo)
    echo("--- SELECT VESSEL TO UPGRADE ---\n\n")
    
    -- List all vessels with numbers
    local vessel_parts = {}
    for i, ship in ipairs(game.fleet) do
        table.insert(vessel_parts, string.format(
            "(%d) %-11s - Age: %dy, Hull: %.2f%%, Fuel: %.2f%%, Status: %s\n",
            i, ship.name, ship.age, ship.hull, ship.fuel, ship.status))
    end
    table.insert(vessel_parts, "\n(B) Back\n\nEnter vessel number: ")
    echo(table.concat(vessel_parts))
    
    local choice = read_char()
    echo("\n")
    
    if not choice or choice:upper() == "B" then
        return
    end
    
    local vessel_idx = tonumber(choice)
    if not vessel_idx or vessel_idx < 1 or vessel_idx > #game.fleet then
        echo("Invalid vessel number.\nPress any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    local selected_ship = game.fleet[vessel_idx]
    local available_upgrades = gamestate.get_available_upgrades(game, selected_ship)
    
    if #available_upgrades == 0 then
        echo("\nNo upgrades available for " .. selected_ship.name .. ".\nPress any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Display upgrade selection menu
    echo("\n")
    display.header(echo)
    display.status(game, echo)
    echo(string.format("--- UPGRADE %s ---\n\nCurrent: Age %dy, Hull %.2f%%, Fuel %.2f%%\n\nAvailable Upgrades:\n\n",
        selected_ship.name, selected_ship.age, selected_ship.hull, selected_ship.fuel))
    
    local upgrade_parts = {}
    for i, upgrade in ipairs(available_upgrades) do
        table.insert(upgrade_parts, string.format("(%d) %-25s - %s\n    %s\n\n",
            i, upgrade.name, widgets.format_number(upgrade.cost) .. " Rubles", upgrade.description))
    end
    table.insert(upgrade_parts, "(B) Back\n\nYour Rubles: ")
    table.insert(upgrade_parts, widgets.format_number(game.rubles))
    table.insert(upgrade_parts, "\n\nEnter upgrade number: ")
    echo(table.concat(upgrade_parts))
    
    choice = read_char()
    echo("\n")
    
    if not choice or choice:upper() == "B" then
        return
    end
    
    local upgrade_idx = tonumber(choice)
    if not upgrade_idx or upgrade_idx < 1 or upgrade_idx > #available_upgrades then
        echo("Invalid upgrade number.\nPress any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    local selected_upgrade = available_upgrades[upgrade_idx]
    
    if game.rubles < selected_upgrade.cost then
        echo("\nInsufficient funds. You need " .. widgets.format_number(selected_upgrade.cost) .. " Rubles.\nPress any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Confirm purchase
    echo(string.format("\nPurchase %s for %s Rubles?\n(Y) Yes  (N) No\n\nConfirm: ",
        selected_upgrade.name, widgets.format_number(selected_upgrade.cost)))
    
    choice = read_char()
    echo("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo("Purchase cancelled.\nPress any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Apply the upgrade
    gamestate.apply_upgrade(selected_ship, selected_upgrade)
    game.rubles = game.rubles - selected_upgrade.cost
    
    echo(string.format("\nUpgrade successful! %s installed on %s.\nRemaining Rubles: %s\nPress any key to continue...",
        selected_upgrade.name, selected_ship.name, widgets.format_number(game.rubles)))
    read_char()
    echo("\n")
end

-- Handle submenu action
local function handle_submenu_action(menu_name, action)
    -- Legacy upgrade handler (not currently in menu)
    if menu_name == "Ship Broker" and action == "Upgrade" then
        handle_vessel_upgrade()
        return
    end
    
    echo("\nAction '" .. action .. "' in " .. menu_name .. " not yet implemented.\nPress any key to continue...")
    read_char()
    echo("\n")
end

-- Handle ship action screen (triggered by events like arrival)
local function handle_ship_action_screen(ship, port_name)
    while true do
        echo("\n")
        display.header(echo)
        display.status(game, echo)
        
        echo(string.format("--- SHIP ACTION: %s AT %s ---\n\n", ship.name, port_name))
        echo(string.format("Hull: %.2f%%  Fuel: %.2f%%  Cargo: %s\n\n",
            ship.hull, ship.fuel, 
            ship.cargo and ship.cargo.crude and (ship.cargo.crude .. "k bbls Crude") or "Empty"))
        
        echo("--- ACTIONS ---\n")
        echo("(R) Repair\n")
        echo("(F) Refuel\n")
        echo("(C) Charter (Plot Route)\n")
        echo("(L) Load Cargo\n")
        echo("(U) Unload Cargo\n")
        echo("(D) Depart\n")
        echo("(X) Done\n\n")
        echo("Enter command: ")
        
        local choice = read_char()
        
        if not choice then
            return
        end
        
        choice = choice:upper()
        echo("\n")
        
        if choice == "R" then
            handle_submenu_action("Ship Action", "Repair")
        elseif choice == "F" then
            handle_submenu_action("Ship Action", "Refuel")
        elseif choice == "C" then
            routes_presenter.plot_route(game, echo, read_char, read_line)
        elseif choice == "L" then
            routes_presenter.load_cargo(game, echo, read_char, read_line)
        elseif choice == "U" then
            routes_presenter.sell_cargo(game, echo, read_char, read_line)
        elseif choice == "D" then
            -- Depart: plot route and automatically exit action screen
            -- Note: Currently uses the same route plotting UI as Charter (C)
            -- The difference is that Depart exits the action screen after plotting
            routes_presenter.plot_route(game, echo, read_char, read_line)
            return  -- Exit after plotting route
        elseif choice == "X" then
            return  -- Exit action screen
        end
    end
end

-- Get the keymap for a given context
local function get_context_keymap(context)
    return keymap[context] or keymap.main
end

-- Get the display name for a context
local function get_context_name(context)
    if context == "main" then
        return "Main Menu"
    else
        return context:sub(1,1):upper() .. context:sub(2)
    end
end

-- Render context screen based on context type
local function render_context_screen(context)
    local menu_title = get_context_name(context):upper() .. " MENU"
    
    if context == "broker" or context == "port" then
        -- Ship Broker and Stop Action menus - show fleet status
        display.header(echo)
        display.status(game, echo)
        display.fleet_status(game, echo)
        menu.print_from_keymap(menu_title, get_context_keymap(context), echo)
    elseif context == "office" then
        -- Office menu - show status and overview
        display.header(echo)
        display.status(game, echo)
        display.market_snapshot(game, echo)
        display.active_events(game, echo)
        menu.print_from_keymap(menu_title, get_context_keymap(context), echo)
    else
        -- Other menus - just show the menu
        menu.print_from_keymap(menu_title, get_context_keymap(context), echo)
    end
end

-- Handle context display and input
local function handle_context(context)
    echo("\n")
    render_context_screen(context)
    
    local context_keymap = get_context_keymap(context)
    
    while true do
        local choice = read_char()
        
        if not choice then
            return "main"
        end
        
        choice = choice:upper()
        local command_id = context_keymap[choice]
        
        if command_id then
            -- Echo the command label
            echo_command_label(command_id)
            
            local result = commands.run(command_id, game, context)
            
            if result then
                if result.change_context then
                    return result.change_context
                elseif result.quit then
                    return "quit"
                elseif result.message then
                    echo(result.message .. "\nPress any key to continue...")
                    read_char()
                    echo("\n")
                end
            end
            
            -- Redraw submenu after action (unless we're switching context)
            if not result or not result.change_context then
                echo("\n")
                render_context_screen(context)
            end
        end
    end
end

-- Main game loop
local function main()
    commands_init.register_all(handle_vessel_upgrade, handle_submenu_action, handle_ship_action_screen, echo, read_char, read_line)
    
    local current_context = "main"
    
    local function game_loop()
        while true do
            if current_context == "main" then
                render_dashboard()
                local choice = read_char()
                
                if not choice then
                    echo("\nThank you for playing Shadow Fleet!\n")
                    break
                end
                
                choice = choice:upper()
                local command_id = keymap.main[choice]
                
                if command_id then
                    -- Echo the command label
                    echo_command_label(command_id)
                    
                    local result = commands.run(command_id, game, current_context)
                    
                    if result then
                        if result.change_context then
                            current_context = result.change_context
                        elseif result.quit then
                            echo("Thank you for playing Shadow Fleet!\n")
                            break
                        elseif result.message then
                            echo(result.message .. "\nPress any key to continue...")
                            read_char()
                            echo("\n")
                        end
                    end
                end
            else
                local new_context = handle_context(current_context)
                
                if new_context == "quit" then
                    echo("\nThank you for playing Shadow Fleet!\n")
                    break
                else
                    current_context = new_context
                end
            end
        end
    end
    
    local function error_handler(err)
        terminal.restore_normal_mode()
        return debug.traceback(err, 2)
    end
    
    local success, err = xpcall(game_loop, error_handler)
    terminal.restore_normal_mode()
    
    if not success then
        print("\nError occurred: " .. tostring(err))
    end
end

main()

#!/usr/bin/env lua5.3

-- Shadow Fleet - Text-based Strategy Game
-- BBS Door style interface with hotkey navigation

local gamestate = require("game")
local widgets = require("ui")
local commands = require("commands")
local keymap = require("keymap")
local command_labels = require("command_labels")
local commands_init = require("commands_init")

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
    -- Define column structure
    local columns = {
        {title = "Name", value_fn = function(ship) return ship.name end, width = 11},
        {title = "Age", value_fn = function(ship) return ship.age .. "y" end, width = 4},
        {title = "Hull", value_fn = function(ship) return ship.hull .. "%" end, width = 5},
        {title = "Fuel", value_fn = function(ship) return ship.fuel .. "%" end, width = 5},
        {title = "Status", value_fn = function(ship) return ship.status end, width = 10},
        {title = "Cargo", value_fn = function(ship) return ship.cargo end, width = 17},
        {title = "Origin", value_fn = function(ship) return ship.origin or "-" end, width = 21},
        {title = "Destination", value_fn = function(ship) return ship.destination or "-" end, width = 23},
        {title = "ETA", value_fn = function(ship) return ship.eta or "-" end, width = 7},
        {title = "Risk", value_fn = function(ship) return ship.risk end, width = 4}
    }
    
    -- Define footer function
    local footer_fn = function()
        local stats = gamestate.get_fleet_stats(game)
        echo("Total Fleet: ")
        echo(stats.total .. "/" .. stats.max)
        echo(" | Avg Age: " .. stats.avg_age .. "y | Uninsured Losses: " .. stats.uninsured_losses)
        echo("\n\n")
    end
    
    -- Use the generic table generator with echo for output
    widgets.table_generator(columns, game.fleet, {
        title = "--- FLEET STATUS ---",
        footer_fn = footer_fn,
        output_fn = echo
    })
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
            echo("█")  -- Filled heat bar (solid block)
        else
            echo("░")  -- Empty heat bar (25% dithered)
        end
    end
    echo("] " .. heat .. "/" .. max_heat)
    echo(" - ")
    echo(gamestate.get_heat_message(game))
    echo("\n\n")
end

-- Helper function to generate formatted menu items from a keymap
-- @param context_keymap table - The keymap for a specific context (e.g., keymap.main)
-- @return table - Array of formatted menu items like "(F) Fleet"
local function generate_menu_items(context_keymap)
    local items = {}
    
    -- Collect all hotkey-command pairs
    for hotkey, command_id in pairs(context_keymap) do
        local label = command_labels[command_id]
        if label then
            table.insert(items, {
                hotkey = hotkey,
                label = label,
                formatted = "(" .. hotkey .. ") " .. label
            })
        end
    end
    
    -- Sort by hotkey for consistent display
    -- Put special keys at the end (like ? and Q)
    table.sort(items, function(a, b)
        -- Special handling for common navigation keys
        if a.hotkey == "B" then return false end  -- Back goes last
        if b.hotkey == "B" then return true end
        if a.hotkey == "Q" then return false end  -- Quit goes near last
        if b.hotkey == "Q" then return true end
        if a.hotkey == "?" then return false end  -- Help goes near last
        if b.hotkey == "?" then return true end
        return a.hotkey < b.hotkey
    end)
    
    -- Extract just the formatted strings
    local formatted = {}
    for _, item in ipairs(items) do
        table.insert(formatted, item.formatted)
    end
    
    return formatted
end

-- Generic function to draw a menu with title and items
-- items: array of strings with format "(X) Item Name" or just "Item Name"
local function draw_boxed_menu(title, formatted_items)
    -- Calculate width based on longest item
    local max_width = #title
    for _, line_text in ipairs(formatted_items) do
        if #line_text > max_width then
            max_width = #line_text
        end
    end
    
    -- Title line
    echo(title)
    echo("\n")
    
    -- Separator line between title and items
    echo(string.rep("═", max_width))
    echo("\n")
    
    -- Menu items
    for _, line_text in ipairs(formatted_items) do
        echo(line_text)
        echo("\n")
    end
    
    echo("\n")
    echo("Enter command: ")
end

-- Generic function to print a menu from a keymap
-- @param title string - Menu title
-- @param context_keymap table - The keymap for this context
local function print_menu_from_keymap(title, context_keymap)
    local formatted_items = generate_menu_items(context_keymap)
    draw_boxed_menu(title, formatted_items)
end

-- Print main menu
local function print_main_menu()
    print_menu_from_keymap("QUICK ACTIONS", keymap.main)
end

-- Print submenu for a given context
-- @param menu_name string - Display name for the menu
-- @param context_keymap table - The keymap for this context
local function print_submenu(menu_name, context_keymap)
    echo("\n")
    print_menu_from_keymap(menu_name:upper() .. " MENU", context_keymap)
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

-- Handle vessel upgrade flow
local function handle_vessel_upgrade()
    echo("\n")
    
    -- Check if there are any ships
    if #game.fleet == 0 then
        echo("No vessels in fleet to upgrade.\n")
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Display vessel selection menu
    print_header()
    print_status()
    echo("--- SELECT VESSEL TO UPGRADE ---\n\n")
    
    -- List all vessels with numbers
    for i, ship in ipairs(game.fleet) do
        echo(string.format("(%d) %-11s - Age: %dy, Hull: %d%%, Fuel: %d%%, Status: %s\n",
            i, ship.name, ship.age, ship.hull, ship.fuel, ship.status))
    end
    
    echo("\n(B) Back\n\n")
    echo("Enter vessel number: ")
    
    local choice = read_char()
    echo("\n")
    
    -- Handle EOF or back
    if not choice or choice:upper() == "B" then
        return
    end
    
    -- Convert to number
    local vessel_idx = tonumber(choice)
    if not vessel_idx or vessel_idx < 1 or vessel_idx > #game.fleet then
        echo("Invalid vessel number.\n")
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    local selected_ship = game.fleet[vessel_idx]
    
    -- Get available upgrades for this ship
    local available_upgrades = gamestate.get_available_upgrades(game, selected_ship)
    
    if #available_upgrades == 0 then
        echo("\n")
        echo("No upgrades available for " .. selected_ship.name .. ".\n")
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Display upgrade selection menu
    echo("\n")
    print_header()
    print_status()
    echo("--- UPGRADE " .. selected_ship.name .. " ---\n\n")
    echo(string.format("Current: Age %dy, Hull %d%%, Fuel %d%%\n\n",
        selected_ship.age, selected_ship.hull, selected_ship.fuel))
    
    echo("Available Upgrades:\n\n")
    for i, upgrade in ipairs(available_upgrades) do
        echo(string.format("(%d) %-25s - %s\n",
            i, upgrade.name, widgets.format_number(upgrade.cost) .. " Rubles"))
        echo("    " .. upgrade.description .. "\n\n")
    end
    
    echo("(B) Back\n\n")
    echo("Your Rubles: " .. widgets.format_number(game.rubles) .. "\n\n")
    echo("Enter upgrade number: ")
    
    choice = read_char()
    echo("\n")
    
    -- Handle EOF or back
    if not choice or choice:upper() == "B" then
        return
    end
    
    -- Convert to number
    local upgrade_idx = tonumber(choice)
    if not upgrade_idx or upgrade_idx < 1 or upgrade_idx > #available_upgrades then
        echo("Invalid upgrade number.\n")
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    local selected_upgrade = available_upgrades[upgrade_idx]
    
    -- Check if player has enough money
    if game.rubles < selected_upgrade.cost then
        echo("\n")
        echo("Insufficient funds. You need " .. widgets.format_number(selected_upgrade.cost) .. " Rubles.\n")
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Confirm purchase
    echo("\n")
    echo("Purchase " .. selected_upgrade.name .. " for " .. widgets.format_number(selected_upgrade.cost) .. " Rubles?\n")
    echo("(Y) Yes  (N) No\n\n")
    echo("Confirm: ")
    
    choice = read_char()
    echo("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo("Purchase cancelled.\n")
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        return
    end
    
    -- Apply the upgrade
    gamestate.apply_upgrade(selected_ship, selected_upgrade)
    game.rubles = game.rubles - selected_upgrade.cost
    
    echo("\n")
    echo("Upgrade successful! " .. selected_upgrade.name .. " installed on " .. selected_ship.name .. ".\n")
    echo("Remaining Rubles: " .. widgets.format_number(game.rubles) .. "\n")
    echo("Press any key to continue...")
    read_char()
    echo("\n")
end

-- Handle submenu action
local function handle_submenu_action(menu_name, action)
    -- Special handling for Fleet > Upgrade
    if menu_name == "Fleet" and action == "Upgrade" then
        handle_vessel_upgrade()
        return
    end
    
    echo("\n")
    echo("Action '" .. action .. "' in " .. menu_name .. " not yet implemented.\n")
    echo("Press any key to continue...")
    read_char()  -- Single character input
    echo("\n")
end

-- Get the keymap for a given context
local function get_context_keymap(context)
    return keymap[context] or keymap.main  -- Default to main menu if context not found
end

-- Get the display name for a context
local function get_context_name(context)
    -- Capitalize first letter of context name
    if context == "main" then
        return "Main Menu"
    else
        return context:sub(1,1):upper() .. context:sub(2)
    end
end

-- Handle context display and input
-- Returns the new context or nil to return to main
local function handle_context(context)
    -- Don't clear screen - append to terminal content
    echo("\n")
    
    -- Special case for Fleet menu - show fleet status
    if context == "fleet" then
        print_header()
        print_status()
        print_fleet_status()
        print_submenu(get_context_name(context), get_context_keymap(context))
    else
        print_submenu(get_context_name(context), get_context_keymap(context))
    end
    
    local context_keymap = get_context_keymap(context)
    
    while true do
        local choice = read_char()  -- Single character input
        
        -- Handle EOF (nil input)
        if not choice then
            return "main"
        end
        
        choice = choice:upper()
        
        -- Look up command in keymap
        local command_id = context_keymap[choice]
        
        if command_id then
            echo("\n")  -- Add newline after input
            
            -- Run the command
            local result = commands.run(command_id, game, context)
            
            -- Handle command result
            if result then
                if result.change_context then
                    -- Switch to new context
                    return result.change_context
                elseif result.quit then
                    -- Quit the game
                    return "quit"
                elseif result.message then
                    -- Display message to user
                    echo(result.message .. "\n")
                    echo("Press any key to continue...")
                    read_char()
                    echo("\n")
                end
            end
            
            -- Redraw submenu after action (unless we're switching context)
            if not result or not result.change_context then
                echo("\n")
                if context == "fleet" then
                    print_header()
                    print_status()
                    print_fleet_status()
                    print_submenu(get_context_name(context), get_context_keymap(context))
                else
                    print_submenu(get_context_name(context), get_context_keymap(context))
                end
            end
        else
            -- Invalid option - don't show error, just ignore
        end
    end
end

-- Main game loop
local function main()
    -- Initialize command registry
    commands_init.register_all(handle_vessel_upgrade, handle_submenu_action)
    
    -- Current context (main menu or submenu name)
    local current_context = "main"
    
    -- Use pcall to ensure terminal is restored on error
    local function game_loop()
        while true do
            if current_context == "main" then
                -- Render main dashboard
                render_dashboard()
                local choice = read_char()  -- Single character input
                
                -- Handle EOF (nil input)
                if not choice then
                    echo("\n")
                    echo("Thank you for playing Shadow Fleet!\n")
                    break
                end
                
                choice = choice:upper()
                
                -- Look up command in main keymap
                local command_id = keymap.main[choice]
                
                if command_id then
                    echo("\n")  -- Add newline after input
                    
                    -- Run the command
                    local result = commands.run(command_id, game, current_context)
                    
                    -- Handle command result
                    if result then
                        if result.change_context then
                            -- Switch to submenu context
                            current_context = result.change_context
                        elseif result.quit then
                            -- Quit the game
                            echo("Thank you for playing Shadow Fleet!\n")
                            break
                        elseif result.message then
                            -- Display message to user
                            echo(result.message .. "\n")
                            echo("Press any key to continue...")
                            read_char()
                            echo("\n")
                        end
                    end
                else
                    -- Invalid option - just ignore
                end
            else
                -- Handle submenu context
                local new_context = handle_context(current_context)
                
                if new_context == "quit" then
                    echo("\n")
                    echo("Thank you for playing Shadow Fleet!\n")
                    break
                else
                    current_context = new_context
                end
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

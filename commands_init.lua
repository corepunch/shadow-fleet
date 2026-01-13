-- Commands Initialization Module
-- Registers all command handlers for the game
--
-- This module sets up the command registry by registering handlers for
-- all menu actions and subcommands. Handlers return result tables that
-- control context switching and user feedback.
--
-- Usage:
--   local commands_init = require("commands_init")
--   commands_init.register_all(handle_vessel_upgrade, handle_submenu_action, echo, read_char, read_line)

local commands = require("commands")
local routes_presenter = require("presenters.routes")
local broker_presenter = require("presenters.broker")
local ship_operations_presenter = require("presenters.ship_operations")
local turn_processor = require("game.turn")

local commands_init = {}

-- Register all game commands
-- @param handle_vessel_upgrade function - The vessel upgrade handler from main.lua
-- @param handle_submenu_action function - The generic submenu action handler from main.lua
-- @param handle_ship_action_screen function - The ship action screen handler from main.lua
-- @param echo function - The echo/output function
-- @param read_char function - The character read function
-- @param read_line function - The line read function
function commands_init.register_all(handle_vessel_upgrade, handle_submenu_action, handle_ship_action_screen, echo, read_char, read_line)
    
    -- Main Menu Commands (Context Switching)
    local menu_contexts = {
        {"menu.open_port", "port"},
        {"menu.open_navigate", "navigate"},
        {"menu.open_office", "office"},
        {"menu.open_broker", "broker"},
        {"menu.open_evade", "evade"},
        {"help.open", "help"}
    }
    
    for _, cmd in ipairs(menu_contexts) do
        local command_id, context = cmd[1], cmd[2]
        commands.register(command_id, function()
            return { change_context = context }
        end)
    end
    
    -- Application Commands
    commands.register("app.quit", function()
        return { quit = true }
    end)
    
    -- Turn Commands
    commands.register("turn.end", function(game)
        echo("\n")
        echo("--- END TURN ---\n\n")
        echo("Processing turn...\n\n")
        
        local events = turn_processor.process(game)
        
        echo(string.format("Turn %d complete. Date: %s\n\n", game.turn, game.date))
        
        -- Display any events that occurred
        if #events > 0 then
            echo("--- TURN EVENTS ---\n\n")
            for _, event in ipairs(events) do
                echo(string.format("* %s: %s\n", event.type, event.description))
            end
            echo("\n")
        end
        
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        
        -- Handle ship arrival events by showing action screen
        for _, event in ipairs(events) do
            if event.type == "Ship Arrival" then
                -- Find the ship that arrived
                local arrived_ship = nil
                for _, ship in ipairs(game.fleet) do
                    if ship.name == event.ship then
                        arrived_ship = ship
                        break
                    end
                end
                
                if arrived_ship then
                    handle_ship_action_screen(arrived_ship, event.port)
                end
            end
        end
        
        return nil
    end)
    
    -- Navigation Commands
    commands.register("menu.back", function()
        return { change_context = "main" }
    end)
    
    -- Ship Broker Commands
    commands.register("broker.view", function()
        return nil  -- View is implicit when entering broker menu
    end)
    
    commands.register("broker.buy", function(game)
        broker_presenter.buy_ship(game, echo, read_char, read_line)
        return nil
    end)
    
    commands.register("broker.sell", function(game)
        broker_presenter.sell_ship(game, echo, read_char, read_line)
        return nil
    end)
    
    -- Port Commands (Stop Action menu)
    commands.register("port.repair", function(game)
        ship_operations_presenter.repair_ship(game, echo, read_char, read_line)
        return nil
    end)
    
    commands.register("port.refuel", function(game)
        ship_operations_presenter.refuel_ship(game, echo, read_char, read_line)
        return nil
    end)
    
    commands.register("port.charter", function()
        handle_submenu_action("Stop Action", "Charter")
        return nil
    end)
    
    commands.register("port.load", function(game)
        routes_presenter.load_cargo(game, echo, read_char, read_line)
        return nil
    end)
    
    commands.register("port.unload", function(game)
        routes_presenter.sell_cargo(game, echo, read_char, read_line)
        return nil
    end)
    
    commands.register("port.layup", function()
        handle_submenu_action("Stop Action", "Lay Up")
        return nil
    end)
    
    -- Navigate Commands (Globe menu)
    commands.register("navigate.view", function()
        handle_submenu_action("Globe", "View Map")
        return nil
    end)
    
    commands.register("navigate.sail", function(game)
        routes_presenter.plot_route(game, echo, read_char, read_line)
        return nil
    end)
    
    -- Evade Commands
    local evade_actions = {
        {"evade.spoof_ais", "Spoof AIS"},
        {"evade.flag_swap", "Flag Swap"},
        {"evade.bribe", "Bribe"}
    }
    
    for _, cmd in ipairs(evade_actions) do
        local command_id, action = cmd[1], cmd[2]
        commands.register(command_id, function()
            handle_submenu_action("Evade", action)
            return nil
        end)
    end
    
    -- Events Commands
    commands.register("events.resolve", function()
        handle_submenu_action("Events", "Resolve Pending Dilemmas")
        return nil
    end)
    
    -- Market Commands
    local market_actions = {
        {"market.check_prices", "Check Prices"},
        {"market.speculate", "Speculate"},
        {"market.auction", "Auction Dive"}
    }
    
    for _, cmd in ipairs(market_actions) do
        local command_id, action = cmd[1], cmd[2]
        commands.register(command_id, function()
            handle_submenu_action("Market", action)
            return nil
        end)
    end
    
    -- Office Commands
    commands.register("office.statistics", function()
        handle_submenu_action("Office", "Statistics")
        return nil
    end)
    
    commands.register("office.fleet", function()
        handle_submenu_action("Office", "Fleet Overview")
        return nil
    end)
    
    commands.register("office.news", function()
        handle_submenu_action("Office", "News")
        return nil
    end)
    
    commands.register("office.market", function()
        handle_submenu_action("Office", "Market Prices")
        return nil
    end)
    
    -- Help Commands
    commands.register("help.details", function()
        handle_submenu_action("Help", "Command Details")
        return nil
    end)
end

return commands_init

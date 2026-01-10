-- Commands Initialization Module
-- Registers all command handlers for the game
--
-- This module sets up the command registry by registering handlers for
-- all menu actions and subcommands. Handlers return result tables that
-- control context switching and user feedback.
--
-- Usage:
--   local commands_init = require("commands_init")
--   commands_init.register_all(handle_vessel_upgrade, handle_submenu_action, echo, read_char)

local commands = require("commands")
local routes = require("game.routes")
local turn_processor = require("game.turn")

local commands_init = {}

-- Register all game commands
-- @param handle_vessel_upgrade function - The vessel upgrade handler from main.lua
-- @param handle_submenu_action function - The generic submenu action handler from main.lua
-- @param echo function - The echo/output function
-- @param read_char function - The character read function
function commands_init.register_all(handle_vessel_upgrade, handle_submenu_action, echo, read_char)
    
    -- Main Menu Commands (Context Switching)
    local menu_contexts = {
        {"menu.open_fleet", "fleet"},
        {"menu.open_route", "route"},
        {"menu.open_trade", "trade"},
        {"menu.open_evade", "evade"},
        {"menu.open_events", "events"},
        {"menu.open_market", "market"},
        {"menu.open_status", "status"},
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
                -- Add event to game events list for later resolution
                table.insert(game.events, event)
            end
            echo("\n")
        end
        
        echo("Press any key to continue...")
        read_char()
        echo("\n")
        return nil
    end)
    
    -- Navigation Commands
    commands.register("menu.back", function()
        return { change_context = "main" }
    end)
    
    -- Fleet Commands
    commands.register("fleet.view", function()
        return nil  -- View is implicit when entering fleet menu
    end)
    
    commands.register("fleet.buy", function()
        handle_submenu_action("Fleet", "Buy")
        return nil
    end)
    
    commands.register("fleet.upgrade", function()
        handle_vessel_upgrade()
        return nil
    end)
    
    commands.register("fleet.scrap", function()
        handle_submenu_action("Fleet", "Scrap")
        return nil
    end)
    
    -- Route Commands
    commands.register("route.plot", function(game)
        routes.plot_route(game, echo, read_char)
        return nil
    end)
    
    commands.register("route.load", function(game)
        routes.load_cargo(game, echo, read_char)
        return nil
    end)
    
    -- Trade Commands
    commands.register("trade.sell", function(game)
        routes.sell_cargo(game, echo, read_char)
        return nil
    end)
    
    commands.register("trade.launder", function()
        handle_submenu_action("Trade", "Launder Oil")
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
    
    -- Status Commands
    commands.register("status.recap", function()
        handle_submenu_action("Status", "Quick Recap")
        return nil
    end)
    
    commands.register("status.news", function()
        handle_submenu_action("Status", "News Refresh")
        return nil
    end)
    
    -- Help Commands
    commands.register("help.details", function()
        handle_submenu_action("Help", "Command Details")
        return nil
    end)
end

return commands_init

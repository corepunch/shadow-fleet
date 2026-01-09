-- Commands Initialization Module
-- Registers all command handlers for the game
--
-- This module sets up the command registry by registering handlers for
-- all menu actions and subcommands. Handlers return result tables that
-- control context switching and user feedback.
--
-- Usage:
--   local commands_init = require("commands_init")
--   commands_init.register_all(handle_vessel_upgrade, handle_submenu_action)

local commands = require("commands")

local commands_init = {}

-- Register all game commands
-- @param handle_vessel_upgrade function - The vessel upgrade handler from main.lua
-- @param handle_submenu_action function - The generic submenu action handler from main.lua
function commands_init.register_all(handle_vessel_upgrade, handle_submenu_action)
    
    -- ========================================
    -- Main Menu Commands (Context Switching)
    -- ========================================
    
    commands.register("menu.open_fleet", function(game, ctx, params)
        return { change_context = "fleet" }
    end)
    
    commands.register("menu.open_route", function(game, ctx, params)
        return { change_context = "route" }
    end)
    
    commands.register("menu.open_trade", function(game, ctx, params)
        return { change_context = "trade" }
    end)
    
    commands.register("menu.open_evade", function(game, ctx, params)
        return { change_context = "evade" }
    end)
    
    commands.register("menu.open_events", function(game, ctx, params)
        return { change_context = "events" }
    end)
    
    commands.register("menu.open_market", function(game, ctx, params)
        return { change_context = "market" }
    end)
    
    commands.register("menu.open_status", function(game, ctx, params)
        return { change_context = "status" }
    end)
    
    commands.register("help.open", function(game, ctx, params)
        return { change_context = "help" }
    end)
    
    -- ========================================
    -- Application Commands
    -- ========================================
    
    commands.register("app.quit", function(game, ctx, params)
        return { quit = true }
    end)
    
    -- ========================================
    -- Navigation Commands
    -- ========================================
    
    commands.register("menu.back", function(game, ctx, params)
        return { change_context = "main" }
    end)
    
    -- ========================================
    -- Fleet Commands
    -- ========================================
    
    commands.register("fleet.view", function(game, ctx, params)
        -- View is implicit when entering fleet menu - just stay in fleet context
        return nil
    end)
    
    commands.register("fleet.buy", function(game, ctx, params)
        handle_submenu_action("Fleet", "Buy")
        return nil
    end)
    
    commands.register("fleet.upgrade", function(game, ctx, params)
        handle_vessel_upgrade()
        return nil
    end)
    
    commands.register("fleet.scrap", function(game, ctx, params)
        handle_submenu_action("Fleet", "Scrap")
        return nil
    end)
    
    -- ========================================
    -- Route Commands
    -- ========================================
    
    commands.register("route.plot", function(game, ctx, params)
        handle_submenu_action("Route", "Plot Ghost Path")
        return nil
    end)
    
    commands.register("route.load", function(game, ctx, params)
        handle_submenu_action("Route", "Load Cargo")
        return nil
    end)
    
    -- ========================================
    -- Trade Commands
    -- ========================================
    
    commands.register("trade.sell", function(game, ctx, params)
        handle_submenu_action("Trade", "Sell")
        return nil
    end)
    
    commands.register("trade.launder", function(game, ctx, params)
        handle_submenu_action("Trade", "Launder Oil")
        return nil
    end)
    
    -- ========================================
    -- Evade Commands
    -- ========================================
    
    commands.register("evade.spoof_ais", function(game, ctx, params)
        handle_submenu_action("Evade", "Spoof AIS")
        return nil
    end)
    
    commands.register("evade.flag_swap", function(game, ctx, params)
        handle_submenu_action("Evade", "Flag Swap")
        return nil
    end)
    
    commands.register("evade.bribe", function(game, ctx, params)
        handle_submenu_action("Evade", "Bribe")
        return nil
    end)
    
    -- ========================================
    -- Events Commands
    -- ========================================
    
    commands.register("events.resolve", function(game, ctx, params)
        handle_submenu_action("Events", "Resolve Pending Dilemmas")
        return nil
    end)
    
    -- ========================================
    -- Market Commands
    -- ========================================
    
    commands.register("market.check_prices", function(game, ctx, params)
        handle_submenu_action("Market", "Check Prices")
        return nil
    end)
    
    commands.register("market.speculate", function(game, ctx, params)
        handle_submenu_action("Market", "Speculate")
        return nil
    end)
    
    commands.register("market.auction", function(game, ctx, params)
        handle_submenu_action("Market", "Auction Dive")
        return nil
    end)
    
    -- ========================================
    -- Status Commands
    -- ========================================
    
    commands.register("status.recap", function(game, ctx, params)
        handle_submenu_action("Status", "Quick Recap")
        return nil
    end)
    
    commands.register("status.news", function(game, ctx, params)
        handle_submenu_action("Status", "News Refresh")
        return nil
    end)
    
    -- ========================================
    -- Help Commands
    -- ========================================
    
    commands.register("help.details", function(game, ctx, params)
        handle_submenu_action("Help", "Command Details")
        return nil
    end)
    
end

return commands_init

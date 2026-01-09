-- Command Labels Module
-- Maps command IDs to display labels for menus
--
-- This module separates display labels from command IDs and hotkeys,
-- making it easier to change menu text without affecting command logic.
--
-- Usage:
--   local command_labels = require("command_labels")
--   local label = command_labels["menu.open_fleet"]  -- Returns "Fleet"

local command_labels = {
    -- Main menu command labels
    ["menu.open_fleet"] = "Fleet",
    ["menu.open_route"] = "Route",
    ["menu.open_trade"] = "Trade",
    ["menu.open_evade"] = "Evade",
    ["menu.open_events"] = "Events",
    ["menu.open_market"] = "Market",
    ["menu.open_status"] = "Status",
    ["help.open"] = "Help",
    ["app.quit"] = "Quit",
    
    -- Fleet submenu labels
    ["fleet.view"] = "View",
    ["fleet.buy"] = "Buy",
    ["fleet.upgrade"] = "Upgrade",
    ["fleet.scrap"] = "Scrap",
    
    -- Route submenu labels
    ["route.plot"] = "Plot Ghost Path",
    ["route.load"] = "Load Cargo",
    
    -- Trade submenu labels
    ["trade.sell"] = "Sell",
    ["trade.launder"] = "Launder Oil",
    
    -- Evade submenu labels
    ["evade.spoof_ais"] = "Spoof AIS",
    ["evade.flag_swap"] = "Flag Swap",
    ["evade.bribe"] = "Bribe",
    
    -- Events submenu labels
    ["events.resolve"] = "Resolve Pending Dilemmas",
    
    -- Market submenu labels
    ["market.check_prices"] = "Check Prices",
    ["market.speculate"] = "Speculate",
    ["market.auction"] = "Auction Dive",
    
    -- Status submenu labels
    ["status.recap"] = "Quick Recap",
    ["status.news"] = "News Refresh",
    
    -- Help submenu labels
    ["help.details"] = "Command Details",
    
    -- Common labels
    ["menu.back"] = "Back"
}

return command_labels

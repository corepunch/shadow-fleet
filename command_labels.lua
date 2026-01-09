-- Command Labels Module
-- Maps command IDs to display labels for menus
--
-- This module separates display labels from command IDs and hotkeys,
-- making it easier to change menu text without affecting command logic.
--
-- Usage:
--   local command_labels = require("command_labels")
--   local label = command_labels["menu.open_fleet"]  -- Returns "Fleet"

local command_labels = {}

-- Main menu command labels
command_labels["menu.open_fleet"] = "Fleet"
command_labels["menu.open_route"] = "Route"
command_labels["menu.open_trade"] = "Trade"
command_labels["menu.open_evade"] = "Evade"
command_labels["menu.open_events"] = "Events"
command_labels["menu.open_market"] = "Market"
command_labels["menu.open_status"] = "Status"
command_labels["help.open"] = "Help"
command_labels["app.quit"] = "Quit"

-- Fleet submenu labels
command_labels["fleet.view"] = "View"
command_labels["fleet.buy"] = "Buy"
command_labels["fleet.upgrade"] = "Upgrade"
command_labels["fleet.scrap"] = "Scrap"

-- Route submenu labels
command_labels["route.plot"] = "Plot Ghost Path"
command_labels["route.load"] = "Load Cargo"

-- Trade submenu labels
command_labels["trade.sell"] = "Sell"
command_labels["trade.launder"] = "Launder Oil"

-- Evade submenu labels
command_labels["evade.spoof_ais"] = "Spoof AIS"
command_labels["evade.flag_swap"] = "Flag Swap"
command_labels["evade.bribe"] = "Bribe"

-- Events submenu labels
command_labels["events.resolve"] = "Resolve Pending Dilemmas"

-- Market submenu labels
command_labels["market.check_prices"] = "Check Prices"
command_labels["market.speculate"] = "Speculate"
command_labels["market.auction"] = "Auction Dive"

-- Status submenu labels
command_labels["status.recap"] = "Quick Recap"
command_labels["status.news"] = "News Refresh"

-- Help submenu labels
command_labels["help.details"] = "Command Details"

-- Common labels
command_labels["menu.back"] = "Back"

return command_labels

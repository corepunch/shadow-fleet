-- Command Labels Module
-- Maps command IDs to display labels for menus
--
-- This module separates display labels from command IDs and hotkeys,
-- making it easier to change menu text without affecting command logic.
--
-- Usage:
--   local command_labels = require("command_labels")
--   local label = command_labels["menu.open_fleet"]  -- Returns "Shipyard"

local command_labels = {
    -- Main menu command labels (aligned with Ports of Call)
    ["menu.open_fleet"] = "Shipyard",
    ["menu.open_port"] = "Harbor",
    ["menu.open_navigate"] = "Sea",
    ["menu.open_evade"] = "Evade",
    ["menu.open_events"] = "Events",
    ["menu.open_market"] = "Freight",
    ["menu.open_status"] = "Office",
    ["turn.end"] = "end Turn",
    ["help.open"] = "Help",
    ["app.quit"] = "Quit",
    
    -- Shipyard submenu labels (aligned with Ports of Call)
    ["fleet.view"] = "View",
    ["fleet.buy"] = "Buy",
    ["fleet.upgrade"] = "Repair",
    ["fleet.scrap"] = "Sell",
    
    -- Harbor submenu labels (aligned with Ports of Call)
    ["port.load"] = "Load",
    ["port.sell"] = "Unload",
    ["port.launder"] = "Launder",
    
    -- Sea submenu labels (aligned with Ports of Call)
    ["navigate.plot"] = "Sail",
    
    -- Evade submenu labels
    ["evade.spoof_ais"] = "Spoof AIS",
    ["evade.flag_swap"] = "Flag Swap",
    ["evade.bribe"] = "Bribe",
    
    -- Events submenu labels
    ["events.resolve"] = "Resolve Pending Dilemmas",
    
    -- Freight submenu labels (aligned with Ports of Call)
    ["market.check_prices"] = "Prices",
    ["market.speculate"] = "Speculate",
    ["market.auction"] = "Auction",
    
    -- Office submenu labels (aligned with Ports of Call)
    ["status.recap"] = "Statistics",
    ["status.news"] = "News",
    
    -- Help submenu labels
    ["help.details"] = "Command Details",
    
    -- Common labels
    ["menu.back"] = "Back"
}

return command_labels

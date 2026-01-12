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
    ["menu.open_port"] = "Stop Action",
    ["menu.open_navigate"] = "Globe",
    ["menu.open_office"] = "Office",
    ["menu.open_broker"] = "Ship Broker",
    ["menu.open_evade"] = "Evade",
    ["turn.end"] = "end Turn",
    ["help.open"] = "Help",
    ["app.quit"] = "Quit",
    
    -- Ship Broker submenu labels (aligned with Ports of Call)
    ["broker.view"] = "View Ships",
    ["broker.buy"] = "Buy",
    ["broker.sell"] = "Sell",
    
    -- Stop Action submenu labels (aligned with Ports of Call)
    ["port.repair"] = "Repair",
    ["port.refuel"] = "Refuel",
    ["port.charter"] = "Charter",
    ["port.load"] = "Load",
    ["port.unload"] = "Unload",
    ["port.layup"] = "Lay Up",
    
    -- Globe submenu labels (aligned with Ports of Call)
    ["navigate.view"] = "View Map",
    ["navigate.sail"] = "Sail",
    
    -- Office submenu labels (aligned with Ports of Call)
    ["office.statistics"] = "Statistics",
    ["office.fleet"] = "Fleet Overview",
    ["office.news"] = "News",
    ["office.market"] = "Market Prices",
    
    -- Evade submenu labels
    ["evade.spoof_ais"] = "Spoof AIS",
    ["evade.flag_swap"] = "Flag Swap",
    ["evade.bribe"] = "Bribe",
    
    -- Events submenu labels
    ["events.resolve"] = "Resolve Pending Dilemmas",
    
    -- Market submenu labels (kept for potential future use)
    ["market.check_prices"] = "Prices",
    ["market.speculate"] = "Speculate",
    ["market.auction"] = "Auction",
    
    -- Help submenu labels
    ["help.details"] = "Command Details",
    
    -- Common labels
    ["menu.back"] = "Back"
}

return command_labels

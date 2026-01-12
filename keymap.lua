-- Keymap Module
-- Maps hotkeys to command IDs for each context
--
-- This module separates key bindings from command handlers, enabling
-- rebindable hotkeys without modifying game logic. Each context
-- (main menu, fleet submenu, etc.) has its own keymap.
--
-- Usage:
--   local keymap = require("keymap")
--   local command_id = keymap.main["S"]  -- Returns "menu.open_fleet" (Shipyard)

local keymap = {}

-- Main menu keymap (aligned with Ports of Call conventions)
keymap.main = {
    S = "menu.open_port",         -- S for Stop Action (port operations)
    G = "menu.open_navigate",     -- G for Globe (navigation)
    O = "menu.open_office",       -- O for Office (statistics/info)
    B = "menu.open_broker",       -- B for Ship Broker (buy/sell ships)
    E = "menu.open_evade",        -- E for Evade (shadow fleet specific)
    T = "turn.end",               -- T for end Turn
    ["?"] = "help.open",          -- ? for Help
    Q = "app.quit"                -- Q for Quit
}

-- Ship Broker submenu keymap (aligned with Ports of Call conventions)
keymap.broker = {
    V = "broker.view",     -- V for View ships
    B = "broker.buy",      -- B for Buy
    S = "broker.sell",     -- S for Sell
    X = "menu.back"        -- X for eXit/back
}

-- Stop Action submenu keymap (aligned with Ports of Call conventions - port operations)
keymap.port = {
    R = "port.repair",     -- R for Repair
    F = "port.refuel",     -- F for Refuel
    C = "port.charter",    -- C for Charter (route setup)
    L = "port.load",       -- L for Load (execute loading)
    U = "port.unload",     -- U for Unload (sell cargo)
    Y = "port.layup",      -- Y for laY up (mothball ship)
    X = "menu.back"        -- X for eXit/back
}

-- Globe submenu keymap (aligned with Ports of Call conventions - navigation)
keymap.navigate = {
    V = "navigate.view",   -- V for View routes/map
    S = "navigate.sail",   -- S for Sail (plot route)
    X = "menu.back"        -- X for eXit/back
}

-- Evade submenu keymap
keymap.evade = {
    A = "evade.spoof_ais",
    F = "evade.flag_swap",
    I = "evade.bribe",
    X = "menu.back"
}

-- Events submenu keymap
keymap.events = {
    R = "events.resolve",
    X = "menu.back"
}

-- Freight submenu keymap (aligned with Ports of Call conventions)
keymap.market = {
    P = "market.check_prices",  -- P for Prices
    S = "market.speculate",     -- S for Speculate
    A = "market.auction",       -- A for Auction
    X = "menu.back"             -- X for eXit/back
}

-- Office submenu keymap (aligned with Ports of Call conventions)
keymap.office = {
    S = "office.statistics",  -- S for Statistics
    F = "office.fleet",       -- F for Fleet overview
    N = "office.news",        -- N for News
    M = "office.market",      -- M for Market prices
    X = "menu.back"           -- X for eXit/back
}

-- Help submenu keymap
keymap.help = {
    C = "help.details",
    X = "menu.back"
}

return keymap

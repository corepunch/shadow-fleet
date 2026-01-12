-- Keymap Module
-- Maps hotkeys to command IDs for each context
--
-- This module separates key bindings from command handlers, enabling
-- rebindable hotkeys without modifying game logic. Each context
-- (main menu, fleet submenu, etc.) has its own keymap.
--
-- Usage:
--   local keymap = require("keymap")
--   local command_id = keymap.main["S"]  -- Returns "menu.open_fleet"

local keymap = {}

-- Main menu keymap (aligned with Ports of Call conventions)
keymap.main = {
    S = "menu.open_fleet",       -- S for Shipyard
    H = "menu.open_port",         -- H for Harbor
    A = "menu.open_navigate",     -- A for sAil/Sea
    E = "menu.open_evade",        -- E for Evade
    V = "menu.open_events",       -- V for eVents
    F = "menu.open_market",       -- F for Freight
    O = "menu.open_status",       -- O for Office
    T = "turn.end",               -- T for end Turn
    ["?"] = "help.open",          -- ? for Help
    Q = "app.quit"                -- Q for Quit
}

-- Shipyard submenu keymap (aligned with Ports of Call conventions)
keymap.fleet = {
    V = "fleet.view",      -- V for View
    B = "fleet.buy",       -- B for Buy
    R = "fleet.upgrade",   -- R for Repair
    S = "fleet.scrap",     -- S for Sell
    X = "menu.back"        -- X for eXit/back (B is now Buy)
}

-- Harbor submenu keymap (aligned with Ports of Call conventions)
keymap.port = {
    L = "port.load",       -- L for Load
    U = "port.sell",       -- U for Unload
    N = "port.launder",    -- N for lauNder (keeping unique letter)
    B = "menu.back"        -- B for Back
}

-- Sea submenu keymap (aligned with Ports of Call conventions)
keymap.navigate = {
    S = "navigate.plot",   -- S for Sail
    B = "menu.back"        -- B for Back
}

-- Evade submenu keymap
keymap.evade = {
    A = "evade.spoof_ais",
    F = "evade.flag_swap",
    I = "evade.bribe",
    B = "menu.back"
}

-- Events submenu keymap
keymap.events = {
    R = "events.resolve",
    B = "menu.back"
}

-- Freight submenu keymap (aligned with Ports of Call conventions)
keymap.market = {
    P = "market.check_prices",  -- P for Prices
    S = "market.speculate",     -- S for Speculate
    A = "market.auction",       -- A for Auction
    B = "menu.back"             -- B for Back
}

-- Office submenu keymap (aligned with Ports of Call conventions)
keymap.status = {
    S = "status.recap",    -- S for Statistics
    N = "status.news",     -- N for News
    B = "menu.back"        -- B for Back
}

-- Help submenu keymap
keymap.help = {
    C = "help.details",
    B = "menu.back"
}

return keymap

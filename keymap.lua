-- Keymap Module
-- Maps hotkeys to command IDs for each context
--
-- This module separates key bindings from command handlers, enabling
-- rebindable hotkeys without modifying game logic. Each context
-- (main menu, fleet submenu, etc.) has its own keymap.
--
-- Usage:
--   local keymap = require("keymap")
--   local command_id = keymap.main["F"]  -- Returns "menu.open_fleet"

local keymap = {}

-- Main menu keymap
keymap.main = {
    F = "menu.open_fleet",
    R = "menu.open_route",
    T = "menu.open_trade",
    E = "menu.open_evade",
    V = "menu.open_events",
    M = "menu.open_market",
    S = "menu.open_status",
    N = "turn.end",
    ["?"] = "help.open",
    Q = "app.quit"
}

-- Fleet submenu keymap
keymap.fleet = {
    V = "fleet.view",
    Y = "fleet.buy",
    U = "fleet.upgrade",
    S = "fleet.scrap",
    B = "menu.back"
}

-- Route submenu keymap
keymap.route = {
    P = "route.plot",
    L = "route.load",
    B = "menu.back"
}

-- Trade submenu keymap
keymap.trade = {
    S = "trade.sell",
    L = "trade.launder",
    B = "menu.back"
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

-- Market submenu keymap
keymap.market = {
    C = "market.check_prices",
    P = "market.speculate",
    A = "market.auction",
    B = "menu.back"
}

-- Status submenu keymap
keymap.status = {
    R = "status.recap",
    N = "status.news",
    B = "menu.back"
}

-- Help submenu keymap
keymap.help = {
    C = "help.details",
    B = "menu.back"
}

return keymap

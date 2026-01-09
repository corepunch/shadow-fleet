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

local M = {}

-- Main menu keymap
M.main = {
    F = "menu.open_fleet",
    R = "menu.open_route",
    T = "menu.open_trade",
    E = "menu.open_evade",
    V = "menu.open_events",
    M = "menu.open_market",
    S = "menu.open_status",
    ["?"] = "help.open",
    Q = "app.quit"
}

-- Fleet submenu keymap
M.fleet = {
    V = "fleet.view",
    Y = "fleet.buy",
    U = "fleet.upgrade",
    S = "fleet.scrap",
    B = "menu.back"
}

-- Route submenu keymap
M.route = {
    P = "route.plot",
    L = "route.load",
    B = "menu.back"
}

-- Trade submenu keymap
M.trade = {
    S = "trade.sell",
    L = "trade.launder",
    B = "menu.back"
}

-- Evade submenu keymap
M.evade = {
    A = "evade.spoof_ais",
    F = "evade.flag_swap",
    I = "evade.bribe",
    B = "menu.back"
}

-- Events submenu keymap
M.events = {
    R = "events.resolve",
    B = "menu.back"
}

-- Market submenu keymap
M.market = {
    C = "market.check_prices",
    P = "market.speculate",
    A = "market.auction",
    B = "menu.back"
}

-- Status submenu keymap
M.status = {
    R = "status.recap",
    N = "status.news",
    B = "menu.back"
}

-- Help submenu keymap
M.help = {
    C = "help.details",
    B = "menu.back"
}

return M

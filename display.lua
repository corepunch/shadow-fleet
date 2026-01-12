--- Display Module
--- Handles dashboard and status rendering for Shadow Fleet
---
--- This module provides high-level display functions for rendering
--- game state information including header, status, market data, events, etc.
---
--- @module display

local gamestate = require("game")
local widgets = require("ui")
local world = require("game.world")

local display = {}

-- Time calculation constants
local DAYS_PER_WEEK = 7
local WEEKS_PER_YEAR = 52

--- Print separator line
function display.separator(echo_fn)
    echo_fn(string.rep("=", 80) .. "\n")
end

--- Print game header
function display.header(echo_fn)
    display.separator(echo_fn)
    echo_fn("PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE\n")
    display.separator(echo_fn)
end

--- Print status line with player info
--- @param game table Game state
--- @param echo_fn function Output function
function display.status(game, echo_fn)
    local heat_desc = gamestate.get_heat_description(game)
    
    -- Calculate weeks and years from turn number (1 turn = 1 day)
    local total_days = game.turn
    local weeks = math.floor(total_days / DAYS_PER_WEEK)
    local years = math.floor(weeks / WEEKS_PER_YEAR)
    local remaining_weeks = weeks % WEEKS_PER_YEAR
    
    local parts = {
        widgets.format_number(game.rubles), " / ", tostring(remaining_weeks), " Weeks / ", tostring(years), " Yrs.\n",
        "[", "Dark Terminal v0.1", "] - ", "Rogue Operator Mode",
        " | Heat: ", heat_desc, "\n",
        game.location, " - ", game.date, " | Oil Stock: ",
        game.oil_stock, "k bbls\n\n"
    }
    
    echo_fn(table.concat(parts))
end

--- Print fleet status table
--- @param game table Game state
--- @param echo_fn function Output function
function display.fleet_status(game, echo_fn)
    local columns = {
        {title = "Name", value_fn = function(ship) return ship.name end, width = 11},
        {title = "Age", value_fn = function(ship) return ship.age .. "y" end, width = 4},
        {title = "Hull", value_fn = function(ship) return ship.hull .. "%" end, width = 5},
        {title = "Fuel", value_fn = function(ship) return ship.fuel .. "%" end, width = 5},
        {title = "Status", value_fn = function(ship) return world.get_status(ship.status) or "" end, width = 10},
        {title = "Cargo", value_fn = function(ship) return world.format_cargo(ship.cargo) end, width = 17},
        {title = "Origin", value_fn = function(ship) return world.port_name(ship.origin_id) end, width = 21},
        {title = "Destination", value_fn = function(ship) return world.port_name(ship.destination_id) end, width = 23},
        {title = "ETA", value_fn = function(ship) return world.format_eta(ship.eta) or "" end, width = 7},
        {title = "Risk", value_fn = function(ship) return world.format_risk_with_threats(ship.risk, ship.threats) or "" end, width = 40}
    }
    
    local footer_fn = function()
        local stats = gamestate.get_fleet_stats(game)
        echo_fn(string.format("Total Fleet: %d/%d | Avg Age: %dy | Uninsured Losses: %d\n\n",
            stats.total, stats.max, stats.avg_age, stats.uninsured_losses))
    end
    
    widgets.table_generator(columns, game.fleet, {
        title = "--- FLEET STATUS ---",
        footer_fn = footer_fn,
        output_fn = echo_fn
    })
end

--- Print market snapshot
--- @param game table Game state
--- @param echo_fn function Output function
function display.market_snapshot(game, echo_fn)
    local parts = {
        "--- MARKET SNAPSHOT ---\n",
        "Crude Price Cap: $", tostring(game.market.crude_price_cap), "/bbl",
        " | Shadow Markup: +", tostring(game.market.shadow_markup_percent), "%",
        " ($", tostring(game.market.shadow_price), "/bbl to India/China)\n",
        "Demand: ", game.market.demand,
        " (Baltic Exports: ", tostring(game.market.baltic_exports), "M bbls/day)",
        " | Sanctions Alert: ", game.market.sanctions_alert, "\n",
        'News Ticker: "', game.market.news, '"\n\n'
    }
    
    echo_fn(table.concat(parts))
end

--- Print active events list
--- @param game table Game state
--- @param echo_fn function Output function
function display.active_events(game, echo_fn)
    local parts = {"--- ACTIVE EVENTS ---\n"}
    
    for _, event in ipairs(game.events) do
        table.insert(parts, "- ")
        table.insert(parts, event.type)
        table.insert(parts, ": ")
        table.insert(parts, event.description)
        table.insert(parts, "\n")
    end
    table.insert(parts, "\n")
    
    echo_fn(table.concat(parts))
end

--- Print heat meter visualization
--- @param game table Game state
--- @param echo_fn function Output function
function display.heat_meter(game, echo_fn)
    local parts = {"--- HEAT METER ---\n["}
    
    for i = 1, game.heat_max do
        if i <= game.heat then
            table.insert(parts, "█")
        else
            table.insert(parts, "░")
        end
    end
    
    table.insert(parts, "] ")
    table.insert(parts, tostring(game.heat))
    table.insert(parts, "/")
    table.insert(parts, tostring(game.heat_max))
    table.insert(parts, " - ")
    table.insert(parts, gamestate.get_heat_message(game))
    table.insert(parts, "\n\n")
    
    echo_fn(table.concat(parts))
end

return display

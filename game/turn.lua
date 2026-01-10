--- Shadow Fleet - Turn Processing
--- Handles game turn advancement and time-based mechanics
---
--- This module processes turn progression including ship movement,
--- event generation, and state updates.
---
--- @module game.turn

local world = require("game.world")

local turn = {}

--- Process turn advancement
--- @param game table Game state to update
--- @return table Array of events generated this turn
function turn.process(game)
    local events = {}
    
    -- Advance turn counter
    game.turn = (game.turn or 0) + 1
    
    -- Advance date by one day
    game.date = turn.advance_date(game.date)
    
    -- Process each ship
    for _, ship in ipairs(game.fleet) do
        local ship_events = turn.process_ship(ship, game)
        for _, event in ipairs(ship_events) do
            table.insert(events, event)
        end
    end
    
    -- Update market (small random fluctuations)
    turn.update_market(game)
    
    -- Natural heat decay (if no risky actions)
    if game.heat > 0 then
        game.heat = math.max(0, game.heat - 1)
    end
    
    return events
end

--- Process a single ship's movement
--- @param ship table Ship to process
--- @param game table Game state
--- @return table Array of events for this ship
function turn.process_ship(ship, game)
    local events = {}
    
    -- Only process ships at sea
    if ship.status ~= "At Sea" then
        return events
    end
    
    -- Reduce days remaining
    if ship.days_remaining and ship.days_remaining > 0 then
        ship.days_remaining = ship.days_remaining - 1
        
        -- Update ETA display
        if ship.days_remaining == 0 then
            ship.eta = "Arrived"
        elseif ship.days_remaining == 1 then
            ship.eta = "1 day"
        else
            ship.eta = ship.days_remaining .. " days"
        end
        
        -- Consume fuel (roughly 1% per day, more for older ships)
        local fuel_consumption = 1 + (ship.age / 100)
        ship.fuel = math.max(0, ship.fuel - fuel_consumption)
        
        -- Hull degradation (very slow, accelerated by age)
        local hull_degradation = 0.1 + (ship.age / 200)
        ship.hull = math.max(0, ship.hull - hull_degradation)
        
        -- Check if ship arrived
        if ship.days_remaining == 0 then
            ship.status = "In Port"
            
            -- Get destination port info
            local port = world.get_port(ship.destination_id)
            local port_name = port and port.name or ship.destination
            
            -- Generate arrival event
            table.insert(events, {
                type = "Ship Arrival",
                ship = ship.name,
                port = port_name,
                description = string.format("%s has arrived at %s", ship.name, port_name),
                actions = {"Sell Cargo", "Load Cargo", "Depart Empty"}
            })
        end
    end
    
    return events
end

--- Advance game date by one day
--- @param current_date string Current date (e.g., "Jan 08, 2026")
--- @return string New date
function turn.advance_date(current_date)
    -- Simple date advancement (simplified, doesn't handle month/year rollover perfectly)
    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    
    -- Parse current date
    local month_str, day_str, year_str = current_date:match("(%a+) (%d+), (%d+)")
    if not month_str then
        return current_date  -- Fallback if parsing fails
    end
    
    local day = tonumber(day_str)
    local year = tonumber(year_str)
    
    -- Find month index
    local month_idx = 1
    for i, m in ipairs(months) do
        if m == month_str then
            month_idx = i
            break
        end
    end
    
    -- Advance day
    day = day + 1
    
    -- Handle month rollover
    if day > days_in_month[month_idx] then
        day = 1
        month_idx = month_idx + 1
        
        -- Handle year rollover
        if month_idx > 12 then
            month_idx = 1
            year = year + 1
        end
    end
    
    return string.format("%s %02d, %d", months[month_idx], day, year)
end

--- Update market prices and conditions
--- @param game table Game state to update
function turn.update_market(game)
    -- Small random price fluctuations (-3% to +3%)
    local change = (math.random() - 0.5) * 0.06
    game.market.shadow_price = math.floor(game.market.shadow_price * (1 + change))
    
    -- Ensure price doesn't go below price cap
    if game.market.shadow_price < game.market.crude_price_cap then
        game.market.shadow_price = game.market.crude_price_cap + 5
    end
    
    -- Update demand randomly (stays in reasonable range)
    local demands = {"LOW", "MEDIUM", "HIGH"}
    if math.random() < 0.2 then  -- 20% chance to change
        game.market.demand = demands[math.random(#demands)]
    end
    
    -- Baltic exports slight variation
    game.market.baltic_exports = math.max(3.0, math.min(5.0, 
        game.market.baltic_exports + (math.random() - 0.5) * 0.3))
end

return turn

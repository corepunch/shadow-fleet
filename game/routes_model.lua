--- Shadow Fleet - Route Operations (Model Layer)
--- Pure business logic for route and cargo operations
---
--- This module contains ONLY game logic without any UI dependencies.
--- It should be testable without terminal/UI components.
---
--- @module game.routes_model

local world = require("game.world")

local routes_model = {}

--- Get all docked ships that can depart
--- @param game table Game state
--- @return table Array of {index, ship} for docked ships
function routes_model.get_docked_ships(game)
    local docked_ships = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "Docked" or ship.status == "In Port" then
            table.insert(docked_ships, {index = i, ship = ship})
        end
    end
    return docked_ships
end

--- Get ships available for cargo loading (at export terminals)
--- @param game table Game state
--- @return table Array of {index, ship, port} for ships at export terminals
function routes_model.get_ships_for_loading(game)
    local available_ships = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "Docked" or ship.status == "In Port" then
            local port = world.get_port(ship.origin_id)
            if port and port.type == "export" then
                table.insert(available_ships, {index = i, ship = ship, port = port})
            end
        end
    end
    return available_ships
end

--- Get ships with cargo at sellable locations (markets or STS)
--- @param game table Game state
--- @return table Array of {index, ship, port} for ships with cargo at markets
function routes_model.get_ships_for_selling(game)
    local ships_with_cargo = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "In Port" and ship.cargo_amount and ship.cargo_amount > 0 then
            local port = world.get_port(ship.destination_id)
            if port and (port.type == "market" or port.type == "sts") then
                table.insert(ships_with_cargo, {index = i, ship = ship, port = port})
            end
        end
    end
    return ships_with_cargo
end

--- Check if a ship has enough fuel for a route
--- @param ship table Ship data
--- @param route table Route data
--- @return boolean, number Has enough fuel, estimated fuel needed
function routes_model.check_fuel(ship, route)
    local fuel_needed = route.days * 2  -- Rough estimate: 2% per day
    return ship.fuel >= fuel_needed, fuel_needed
end

--- Calculate cargo loading cost
--- @param amount number Amount in thousands of barrels
--- @param price_per_barrel number Price per barrel
--- @return number Total cost in rubles
function routes_model.calculate_cargo_cost(amount, price_per_barrel)
    return amount * 1000 * price_per_barrel
end

--- Calculate cargo sale revenue
--- @param amount number Amount in thousands of barrels
--- @param price_per_barrel number Price per barrel
--- @return number Total revenue in rubles
function routes_model.calculate_cargo_revenue(amount, price_per_barrel)
    return amount * 1000 * price_per_barrel
end

--- Validate cargo loading request
--- @param ship table Ship data
--- @param amount number Amount to load (in thousands of barrels)
--- @param cost number Cost of cargo
--- @param rubles number Available rubles
--- @return boolean, string Is valid, error message if invalid
function routes_model.validate_cargo_load(ship, amount, cost, rubles)
    if not amount or amount <= 0 then
        return false, "Invalid amount"
    end
    
    local cargo_space = ship.capacity - (ship.cargo_amount or 0)
    if amount > cargo_space then
        return false, string.format("Cannot load %dk bbls - only %dk space available", amount, cargo_space)
    end
    
    if rubles < cost then
        return false, string.format("Insufficient funds. Cost: %d Rubles, You have: %d Rubles", cost, rubles)
    end
    
    return true, nil
end

--- Execute cargo loading (mutates game state)
--- @param game table Game state
--- @param ship table Ship to load
--- @param amount number Amount in thousands of barrels
--- @param cost number Cost to deduct
function routes_model.load_cargo(game, ship, amount, cost)
    ship.cargo_amount = (ship.cargo_amount or 0) + amount
    ship.cargo_type = "Crude"
    ship.cargo = string.format("%dk bbls Crude", ship.cargo_amount)
    game.rubles = game.rubles - cost
end

--- Execute cargo sale (mutates game state)
--- @param game table Game state
--- @param ship table Ship to unload
--- @param revenue number Revenue to add
function routes_model.sell_cargo(game, ship, revenue)
    game.rubles = game.rubles + revenue
    ship.cargo_amount = 0
    ship.cargo_type = nil
    ship.cargo = "Empty"
    
    -- Small heat increase for selling
    game.heat = math.min(game.heat_max, game.heat + 1)
end

--- Execute ship departure (mutates game state)
--- @param ship table Ship to send
--- @param destination table Destination port
--- @param route table Route data
function routes_model.depart_ship(ship, destination, route)
    ship.status = "At Sea"
    ship.destination = destination.name
    ship.destination_id = destination.id
    ship.days_remaining = route.days
    if route.days == 1 then
        ship.eta = "1 day"
    else
        ship.eta = route.days .. " days"
    end
    ship.risk = route.risk:upper()
end

return routes_model

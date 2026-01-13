--- Shadow Fleet - Ship Operations Model
--- Business logic for ship maintenance operations
---
--- This module contains pure game logic for refueling and repairing ships.
---
--- @module game.ship_operations

local world = require("game.world")

local ship_operations = {}

-- Pricing constants
local FUEL_COST_PER_PERCENT = 5000  -- 5,000 Rubles per 1% fuel
local REPAIR_COST_PER_PERCENT = 10000  -- 10,000 Rubles per 1% hull

--- Get ships available for refueling (docked or in port)
--- @param game table Game state
--- @return table Array of {index, ship, port} for ships that can refuel
function ship_operations.get_ships_for_refuel(game)
    local available_ships = {}
    for i, ship in ipairs(game.fleet) do
        local status_name = world.get_status(ship.status)
        if status_name == "Docked" or status_name == "In Port" then
            local port = world.get_port(ship.origin_id or ship.destination_id)
            table.insert(available_ships, {index = i, ship = ship, port = port})
        end
    end
    return available_ships
end

--- Get ships available for repair (docked or in port)
--- @param game table Game state
--- @return table Array of {index, ship, port} for ships that can be repaired
function ship_operations.get_ships_for_repair(game)
    local available_ships = {}
    for i, ship in ipairs(game.fleet) do
        local status_name = world.get_status(ship.status)
        if status_name == "Docked" or status_name == "In Port" then
            local port = world.get_port(ship.origin_id or ship.destination_id)
            table.insert(available_ships, {index = i, ship = ship, port = port})
        end
    end
    return available_ships
end

--- Calculate refueling cost
--- @param current_fuel number Current fuel percentage
--- @param target_fuel number Target fuel percentage
--- @return number Cost in rubles
function ship_operations.calculate_refuel_cost(current_fuel, target_fuel)
    local fuel_needed = math.max(0, target_fuel - current_fuel)
    return math.floor(fuel_needed * FUEL_COST_PER_PERCENT)
end

--- Calculate repair cost
--- @param current_hull number Current hull percentage
--- @param target_hull number Target hull percentage
--- @return number Cost in rubles
function ship_operations.calculate_repair_cost(current_hull, target_hull)
    local repair_needed = math.max(0, target_hull - current_hull)
    return math.floor(repair_needed * REPAIR_COST_PER_PERCENT)
end

--- Validate refuel request
--- @param ship table Ship data
--- @param target_fuel number Target fuel percentage
--- @param cost number Cost of refueling
--- @param rubles number Available rubles
--- @return boolean, string Is valid, error message if invalid
function ship_operations.validate_refuel(ship, target_fuel, cost, rubles)
    if not target_fuel or target_fuel < 0 or target_fuel > 100 then
        return false, "Invalid fuel amount (must be 0-100%)"
    end
    
    if target_fuel <= ship.fuel then
        return false, "Target fuel must be greater than current fuel level"
    end
    
    if rubles < cost then
        return false, string.format("Insufficient funds. Cost: %d Rubles, You have: %d Rubles", cost, rubles)
    end
    
    return true, nil
end

--- Validate repair request
--- @param ship table Ship data
--- @param target_hull number Target hull percentage
--- @param cost number Cost of repair
--- @param rubles number Available rubles
--- @return boolean, string Is valid, error message if invalid
function ship_operations.validate_repair(ship, target_hull, cost, rubles)
    if not target_hull or target_hull < 0 or target_hull > 100 then
        return false, "Invalid hull amount (must be 0-100%)"
    end
    
    if target_hull <= ship.hull then
        return false, "Target hull must be greater than current hull condition"
    end
    
    if rubles < cost then
        return false, string.format("Insufficient funds. Cost: %d Rubles, You have: %d Rubles", cost, rubles)
    end
    
    return true, nil
end

--- Execute refueling (mutates game state)
--- @param game table Game state
--- @param ship table Ship to refuel
--- @param target_fuel number Target fuel percentage
--- @param cost number Cost to deduct
function ship_operations.refuel_ship(game, ship, target_fuel, cost)
    ship.fuel = target_fuel
    game.rubles = game.rubles - cost
end

--- Execute repair (mutates game state)
--- @param game table Game state
--- @param ship table Ship to repair
--- @param target_hull number Target hull percentage
--- @param cost number Cost to deduct
function ship_operations.repair_ship(game, ship, target_hull, cost)
    ship.hull = target_hull
    game.rubles = game.rubles - cost
end

return ship_operations

--- Shadow Fleet - Ship Broker Model
--- Business logic for buying and selling ships
---
--- This module contains pure game logic for ship trading operations.
---
--- @module game.broker_model

local broker_model = {}

--- Available ships for purchase
--- Each ship has different characteristics: age, capacity, hull condition, price
broker_model.available_ships = {
    {
        name = "GHOST-",
        base_price = 3000000,
        age = 15,
        hull = 85,
        fuel = 100,
        capacity = 500,
        description = "Reliable mid-age tanker, good condition"
    },
    {
        name = "PHANTOM-",
        base_price = 2000000,
        age = 20,
        hull = 70,
        fuel = 100,
        capacity = 500,
        description = "Older vessel, economical purchase"
    },
    {
        name = "SHADOW-",
        base_price = 4500000,
        age = 12,
        hull = 90,
        fuel = 100,
        capacity = 500,
        description = "Newer vessel with excellent hull"
    },
    {
        name = "SPECTER-",
        base_price = 1500000,
        age = 25,
        hull = 60,
        fuel = 100,
        capacity = 500,
        description = "Budget option, requires maintenance"
    },
    {
        name = "WRAITH-",
        base_price = 5500000,
        age = 8,
        hull = 95,
        fuel = 100,
        capacity = 750,
        description = "Premium large-capacity tanker"
    },
    {
        name = "SPIRIT-",
        base_price = 2500000,
        age = 18,
        hull = 75,
        fuel = 100,
        capacity = 500,
        description = "Standard workhorse tanker"
    }
}

--- Get next available ship number for a given prefix
--- @param game table Game state
--- @param prefix string Ship name prefix (e.g., "GHOST-")
--- @return number Next available number
local function get_next_ship_number(game, prefix)
    local max_num = 0
    for _, ship in ipairs(game.fleet) do
        if ship.name:sub(1, #prefix) == prefix then
            local num_str = ship.name:sub(#prefix + 1)
            local num = tonumber(num_str)
            if num and num > max_num then
                max_num = num
            end
        end
    end
    return max_num + 1
end

--- Get list of available ships for purchase
--- @param game table Game state
--- @return table Array of ship templates with prices
function broker_model.get_available_ships(game)
    -- Return a copy of available ships to prevent modification
    local ships = {}
    for i, template in ipairs(broker_model.available_ships) do
        local ship_copy = {
            index = i,
            name = template.name,
            price = template.base_price,
            age = template.age,
            hull = template.hull,
            fuel = template.fuel,
            capacity = template.capacity,
            description = template.description
        }
        table.insert(ships, ship_copy)
    end
    return ships
end

--- Purchase a ship
--- @param game table Game state
--- @param ship_template table Ship template from available_ships
--- @return boolean, string Success and message
function broker_model.buy_ship(game, ship_template)
    -- Check if player has enough money
    if game.rubles < ship_template.price then
        return false, string.format("Insufficient funds. Need %d Rubles, have %d Rubles",
            ship_template.price, game.rubles)
    end
    
    -- Generate unique ship name
    local ship_number = get_next_ship_number(game, ship_template.name)
    local ship_name = string.format("%s%02d", ship_template.name, ship_number)
    
    -- Create new ship
    local new_ship = {
        name = ship_name,
        age = ship_template.age,
        hull = ship_template.hull,
        fuel = ship_template.fuel,
        capacity = ship_template.capacity,
        status = "docked",
        origin_id = "ust_luga",  -- Default starting port
        cargo = nil,
        destination_id = nil,
        days_remaining = nil,
        eta = nil,
        risk = "none",
        threats = nil
    }
    
    -- Add to fleet
    table.insert(game.fleet, new_ship)
    
    -- Deduct cost
    game.rubles = game.rubles - ship_template.price
    
    return true, string.format("Purchased %s for %d Rubles", ship_name, ship_template.price)
end

--- Sell a ship
--- @param game table Game state
--- @param ship_index number Index of ship in fleet
--- @return boolean, string Success and message
function broker_model.sell_ship(game, ship_index)
    if ship_index < 1 or ship_index > #game.fleet then
        return false, "Invalid ship selection"
    end
    
    local ship = game.fleet[ship_index]
    
    -- Can't sell ships at sea
    if ship.status == "at_sea" then
        return false, "Cannot sell ship while at sea"
    end
    
    -- Calculate sale value based on hull condition and age
    -- Base value decreases with age and poor condition
    local base_value = 2000000
    local age_factor = math.max(0.3, 1 - (ship.age / 40))  -- 30% minimum
    local hull_factor = ship.hull / 100
    local sale_price = math.floor(base_value * age_factor * hull_factor)
    
    -- Add to player funds
    game.rubles = game.rubles + sale_price
    
    -- Remove from fleet
    local ship_name = ship.name
    table.remove(game.fleet, ship_index)
    
    return true, string.format("Sold %s for %d Rubles", ship_name, sale_price)
end

return broker_model

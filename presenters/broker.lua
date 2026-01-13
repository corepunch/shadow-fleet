--- Shadow Fleet - Ship Broker Presenter
--- UI interaction layer for ship buying and selling
---
--- This module handles user interaction and delegates to the model layer
--- for business logic. It follows the Presenter pattern.
---
--- @module presenters.broker

local broker_model = require("game.broker_model")
local widgets = require("ui")
local world = require("game.world")

local broker_presenter = {}

--- Present ship buying interface
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function for single character
--- @param read_line function Input function for line input
--- @return boolean Success
function broker_presenter.buy_ship(game, echo_fn, read_char, read_line)
    echo_fn("\n")
    echo_fn("--- BUY SHIP ---\n\n")
    
    -- Get available ships from model
    local available_ships = broker_model.get_available_ships(game)
    
    echo_fn(string.format("Your Rubles: %s\n\n", widgets.format_number(game.rubles)))
    echo_fn("Available ships for purchase:\n\n")
    
    -- Display ship options
    for i, ship in ipairs(available_ships) do
        echo_fn(string.format("(%d) %-12s - Age: %2dy, Hull: %3d%%, Capacity: %3dk bbls - %s Rubles\n",
            i, ship.name .. "XX", ship.age, ship.hull, ship.capacity, widgets.format_number(ship.price)))
        echo_fn(string.format("    %s\n", ship.description))
    end
    
    echo_fn("\n(B) Back\n\nEnter ship number to purchase: ")
    
    local choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() == "B" then
        return false
    end
    
    local ship_idx = tonumber(choice)
    if not ship_idx or ship_idx < 1 or ship_idx > #available_ships then
        echo_fn("Invalid ship number.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    local selected_ship = available_ships[ship_idx]
    
    -- Check if player has enough money
    if game.rubles < selected_ship.price then
        echo_fn(string.format("Insufficient funds. You need %s Rubles but have %s Rubles.\nPress any key to continue...",
            widgets.format_number(selected_ship.price), widgets.format_number(game.rubles)))
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present confirmation
    echo_fn(string.format("\nPurchase %sXX (Age %dy, Hull %d%%, Capacity %dk bbls) for %s Rubles?\n",
        selected_ship.name, selected_ship.age, selected_ship.hull, selected_ship.capacity,
        widgets.format_number(selected_ship.price)))
    echo_fn("(Y) Yes  (N) No\n\nConfirm: ")
    
    choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo_fn("Purchase cancelled.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Execute purchase using model
    local success, message = broker_model.buy_ship(game, selected_ship)
    
    if success then
        echo_fn(string.format("\n%s\nRemaining Rubles: %s\nPress any key to continue...",
            message, widgets.format_number(game.rubles)))
    else
        echo_fn(string.format("\n%s\nPress any key to continue...", message))
    end
    
    read_char()
    echo_fn("\n")
    
    return success
end

--- Present ship selling interface
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function for single character
--- @param read_line function Input function for line input
--- @return boolean Success
function broker_presenter.sell_ship(game, echo_fn, read_char, read_line)
    echo_fn("\n")
    echo_fn("--- SELL SHIP ---\n\n")
    
    if #game.fleet == 0 then
        echo_fn("No ships in fleet to sell.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    echo_fn("Select ship to sell:\n\n")
    
    -- Display ships
    for i, ship in ipairs(game.fleet) do
        local status = world.get_status(ship.status)
        local location = world.port_name(ship.origin_id) or "Unknown"
        echo_fn(string.format("(%d) %-11s - Age: %2dy, Hull: %3d%%, Status: %s, Location: %s\n",
            i, ship.name, ship.age, math.floor(ship.hull), status, location))
    end
    
    echo_fn("\n(B) Back\n\nEnter ship number to sell: ")
    
    local choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() == "B" then
        return false
    end
    
    local ship_idx = tonumber(choice)
    if not ship_idx or ship_idx < 1 or ship_idx > #game.fleet then
        echo_fn("Invalid ship number.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    local ship = game.fleet[ship_idx]
    
    -- Check if ship is at sea
    if ship.status == "at_sea" then
        echo_fn("Cannot sell ship while at sea.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Calculate sale value preview
    local base_value = 2000000
    local age_factor = math.max(0.3, 1 - (ship.age / 40))
    local hull_factor = ship.hull / 100
    local sale_price = math.floor(base_value * age_factor * hull_factor)
    
    -- Present confirmation
    echo_fn(string.format("\nSell %s (Age %dy, Hull %d%%) for %s Rubles?\n",
        ship.name, ship.age, math.floor(ship.hull), widgets.format_number(sale_price)))
    echo_fn("(Y) Yes  (N) No\n\nConfirm: ")
    
    choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo_fn("Sale cancelled.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Execute sale using model
    local success, message = broker_model.sell_ship(game, ship_idx)
    
    if success then
        echo_fn(string.format("\n%s\nYour Rubles: %s\nPress any key to continue...",
            message, widgets.format_number(game.rubles)))
    else
        echo_fn(string.format("\n%s\nPress any key to continue...", message))
    end
    
    read_char()
    echo_fn("\n")
    
    return success
end

return broker_presenter

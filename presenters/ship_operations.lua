--- Shadow Fleet - Ship Operations Presenter
--- UI interaction layer for ship maintenance operations
---
--- This module handles user interaction for refueling and repairing ships.
--- It follows the Presenter pattern.
---
--- @module presenters.ship_operations

local ship_operations = require("game.ship_operations")
local widgets = require("ui")
local world = require("game.world")

local ship_operations_presenter = {}

--- Present ship refueling interface
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function for single character
--- @param read_line function Input function for line input
--- @param preselected_ship table Optional preselected ship (for action screens)
--- @return boolean Success
function ship_operations_presenter.refuel_ship(game, echo_fn, read_char, read_line, preselected_ship)
    echo_fn("\n")
    echo_fn("--- REFUEL SHIP ---\n\n")
    
    local selected_ship = preselected_ship
    
    if not selected_ship then
        -- Get available ships from model
        local available_ships = ship_operations.get_ships_for_refuel(game)
        
        if #available_ships == 0 then
            echo_fn("No ships available at port to refuel.\nPress any key to continue...")
            read_char()
            echo_fn("\n")
            return false
        end
        
        -- Present ship selection
        echo_fn("Select ship to refuel:\n\n")
        for i, entry in ipairs(available_ships) do
            local location = world.port_name(entry.ship.origin_id or entry.ship.destination_id)
            echo_fn(string.format("(%d) %s - %s, Fuel: %d%%\n",
                i, entry.ship.name, location, math.floor(entry.ship.fuel)))
        end
        echo_fn("\n(B) Back\n\nEnter ship number: ")
        
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
        
        selected_ship = available_ships[ship_idx].ship
    end
    
    -- Show current fuel level
    echo_fn(string.format("\n--- REFUEL %s ---\n\n", selected_ship.name))
    echo_fn(string.format("Current fuel: %d%%\n", math.floor(selected_ship.fuel)))
    echo_fn(string.format("Cost per %%: %s Rubles\n", widgets.format_number(5000)))
    echo_fn(string.format("Your Rubles: %s\n\n", widgets.format_number(game.rubles)))
    
    echo_fn("Enter target fuel percentage (0-100): ")
    local input = read_line(true)
    echo_fn("\n")
    
    if not input then
        return false
    end
    
    local target_fuel = tonumber(input)
    
    -- Calculate cost using model
    local cost = ship_operations.calculate_refuel_cost(selected_ship.fuel, target_fuel or 0)
    
    -- Validate using model
    local valid, error_msg = ship_operations.validate_refuel(selected_ship, target_fuel, cost, game.rubles)
    if not valid then
        echo_fn(string.format("\n%s\nPress any key to continue...", error_msg))
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present confirmation
    local fuel_gain = target_fuel - selected_ship.fuel
    echo_fn(string.format("\nRefuel %s from %d%% to %d%% (+%d%%) for %s Rubles?\n",
        selected_ship.name, math.floor(selected_ship.fuel), target_fuel, math.floor(fuel_gain),
        widgets.format_number(cost)))
    echo_fn("(Y) Yes  (N) No\n\nConfirm: ")
    
    local choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo_fn("Refueling cancelled.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Execute refueling using model
    ship_operations.refuel_ship(game, selected_ship, target_fuel, cost)
    
    echo_fn(string.format("\nRefueled %s to %d%%. Cost: %s Rubles\nRemaining: %s Rubles\nPress any key to continue...",
        selected_ship.name, target_fuel, widgets.format_number(cost), widgets.format_number(game.rubles)))
    read_char()
    echo_fn("\n")
    
    return true
end

--- Present ship repair interface
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function for single character
--- @param read_line function Input function for line input
--- @param preselected_ship table Optional preselected ship (for action screens)
--- @return boolean Success
function ship_operations_presenter.repair_ship(game, echo_fn, read_char, read_line, preselected_ship)
    echo_fn("\n")
    echo_fn("--- REPAIR SHIP ---\n\n")
    
    local selected_ship = preselected_ship
    
    if not selected_ship then
        -- Get available ships from model
        local available_ships = ship_operations.get_ships_for_repair(game)
        
        if #available_ships == 0 then
            echo_fn("No ships available at port to repair.\nPress any key to continue...")
            read_char()
            echo_fn("\n")
            return false
        end
        
        -- Present ship selection
        echo_fn("Select ship to repair:\n\n")
        for i, entry in ipairs(available_ships) do
            local location = world.port_name(entry.ship.origin_id or entry.ship.destination_id)
            echo_fn(string.format("(%d) %s - %s, Hull: %d%%\n",
                i, entry.ship.name, location, math.floor(entry.ship.hull)))
        end
        echo_fn("\n(B) Back\n\nEnter ship number: ")
        
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
        
        selected_ship = available_ships[ship_idx].ship
    end
    
    -- Show current hull condition
    echo_fn(string.format("\n--- REPAIR %s ---\n\n", selected_ship.name))
    echo_fn(string.format("Current hull: %d%%\n", math.floor(selected_ship.hull)))
    echo_fn(string.format("Cost per %%: %s Rubles\n", widgets.format_number(10000)))
    echo_fn(string.format("Your Rubles: %s\n\n", widgets.format_number(game.rubles)))
    
    echo_fn("Enter target hull percentage (0-100): ")
    local input = read_line(true)
    echo_fn("\n")
    
    if not input then
        return false
    end
    
    local target_hull = tonumber(input)
    
    -- Calculate cost using model
    local cost = ship_operations.calculate_repair_cost(selected_ship.hull, target_hull or 0)
    
    -- Validate using model
    local valid, error_msg = ship_operations.validate_repair(selected_ship, target_hull, cost, game.rubles)
    if not valid then
        echo_fn(string.format("\n%s\nPress any key to continue...", error_msg))
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present confirmation
    local hull_gain = target_hull - selected_ship.hull
    echo_fn(string.format("\nRepair %s from %d%% to %d%% (+%d%%) for %s Rubles?\n",
        selected_ship.name, math.floor(selected_ship.hull), target_hull, math.floor(hull_gain),
        widgets.format_number(cost)))
    echo_fn("(Y) Yes  (N) No\n\nConfirm: ")
    
    local choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo_fn("Repair cancelled.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Execute repair using model
    ship_operations.repair_ship(game, selected_ship, target_hull, cost)
    
    echo_fn(string.format("\nRepaired %s to %d%%. Cost: %s Rubles\nRemaining: %s Rubles\nPress any key to continue...",
        selected_ship.name, target_hull, widgets.format_number(cost), widgets.format_number(game.rubles)))
    read_char()
    echo_fn("\n")
    
    return true
end

return ship_operations_presenter

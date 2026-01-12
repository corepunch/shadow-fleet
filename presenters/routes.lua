--- Shadow Fleet - Route Operations Presenter
--- UI interaction layer for route and cargo operations
---
--- This module handles user interaction and delegates to the model layer
--- for business logic. It follows the Presenter pattern.
---
--- @module presenters.routes

local world = require("game.world")
local routes_model = require("game.routes_model")
local widgets = require("ui")

local routes_presenter = {}

--- Present route plotting interface
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function for single character
--- @param read_line function Input function for line input
--- @return boolean Success
function routes_presenter.plot_route(game, echo_fn, read_char, read_line)
    echo_fn("\n")
    echo_fn("--- PLOT ROUTE ---\n\n")
    
    -- Get available ships from model
    local docked_ships = routes_model.get_docked_ships(game)
    
    if #docked_ships == 0 then
        echo_fn("No ships available at port to depart.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present ship selection
    echo_fn("Select ship to depart:\n\n")
    for i, entry in ipairs(docked_ships) do
        local origin_name = world.port_name(entry.ship.origin_id)
        echo_fn(string.format("(%d) %s - %s, Fuel: %d%%, Cargo: %s\n",
            i, entry.ship.name, origin_name, entry.ship.fuel,
            entry.ship.cargo or "Empty"))
    end
    echo_fn("\n(B) Back\n\nEnter ship number: ")
    
    local choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() == "B" then
        return false
    end
    
    local ship_idx = tonumber(choice)
    if not ship_idx or ship_idx < 1 or ship_idx > #docked_ships then
        echo_fn("Invalid ship number.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    local selected_entry = docked_ships[ship_idx]
    local ship = selected_entry.ship
    
    -- Get ship's current port from model
    local current_port_id = ship.origin_id
    
    if not current_port_id then
        echo_fn("Error: Cannot determine ship's current port.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    local current_port = world.get_port(current_port_id)
    local current_port_name = world.port_name(current_port_id)
    
    -- Get available destinations from model
    local destinations = world.get_destinations(current_port_id)
    
    if #destinations == 0 then
        echo_fn("No routes available from " .. current_port_name .. ".\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present destination selection
    echo_fn("\n--- SELECT DESTINATION ---\n\n")
    echo_fn(string.format("Ship: %s at %s\n\n", ship.name, current_port_name))
    echo_fn("Available destinations:\n\n")
    
    for i, dest in ipairs(destinations) do
        echo_fn(string.format("(%d) %s - %d days, Risk: %s\n",
            i, dest.port.name, dest.route.days, dest.route.risk:upper()))
    end
    echo_fn("\n(B) Back\n\nEnter destination number: ")
    
    choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() == "B" then
        return false
    end
    
    local dest_idx = tonumber(choice)
    if not dest_idx or dest_idx < 1 or dest_idx > #destinations then
        echo_fn("Invalid destination number.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    local destination = destinations[dest_idx]
    
    -- Check fuel using model
    local has_fuel, fuel_needed = routes_model.check_fuel(ship, destination.route)
    if not has_fuel then
        echo_fn(string.format("WARNING: Low fuel! Ship has %d%% fuel, route needs ~%d%%.\n", 
            ship.fuel, fuel_needed))
        echo_fn("Continue anyway? (Y/N): ")
        choice = read_char()
        echo_fn("\n")
        if not choice or choice:upper() ~= "Y" then
            return false
        end
    end
    
    -- Present departure summary and confirmation
    echo_fn(string.format("\nDeparture Summary:\n"))
    echo_fn(string.format("Ship: %s\n", ship.name))
    echo_fn(string.format("From: %s\n", current_port_name))
    echo_fn(string.format("To: %s\n", destination.port.name))
    echo_fn(string.format("Distance: %d days\n", destination.route.days))
    echo_fn(string.format("Risk: %s\n", destination.route.risk:upper()))
    echo_fn(string.format("Cargo: %s\n\n", ship.cargo or "Empty"))
    echo_fn("Confirm departure? (Y/N): ")
    
    choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo_fn("Departure cancelled.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Execute departure using model
    routes_model.depart_ship(ship, destination.port, destination.route)
    
    echo_fn(string.format("\n%s has departed for %s. ETA: %s\nPress any key to continue...",
        ship.name, destination.port.name, ship.eta))
    read_char()
    echo_fn("\n")
    
    return true
end

--- Present cargo loading interface
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function for single character
--- @param read_line function Input function for line input
--- @return boolean Success
function routes_presenter.load_cargo(game, echo_fn, read_char, read_line)
    echo_fn("\n")
    echo_fn("--- LOAD CARGO ---\n\n")
    
    -- Get available ships from model
    local available_ships = routes_model.get_ships_for_loading(game)
    
    if #available_ships == 0 then
        echo_fn("No ships available at export terminals to load cargo.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present ship selection
    echo_fn("Select ship to load:\n\n")
    for i, entry in ipairs(available_ships) do
        local cargo_space = entry.ship.capacity - (entry.ship.cargo_amount or 0)
        local origin_name = world.port_name(entry.ship.origin_id)
        echo_fn(string.format("(%d) %s - %s, Capacity: %dk bbls (%dk available)\n",
            i, entry.ship.name, origin_name, entry.ship.capacity, cargo_space))
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
    
    local selected_entry = available_ships[ship_idx]
    local ship = selected_entry.ship
    local port = selected_entry.port
    
    -- Calculate available space
    local cargo_space = ship.capacity - (ship.cargo_amount or 0)
    
    if cargo_space <= 0 then
        echo_fn("Ship is already at full capacity.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present cargo options
    local origin_name = world.port_name(ship.origin_id)
    echo_fn("\n--- CARGO OPTIONS ---\n\n")
    echo_fn(string.format("Ship: %s\n", ship.name))
    echo_fn(string.format("Location: %s\n", origin_name))
    echo_fn(string.format("Available space: %dk barrels\n", cargo_space))
    echo_fn(string.format("Oil price: $%d/bbl\n\n", port.oil_price))
    
    echo_fn("Enter cargo amount (in thousands of barrels): ")
    local input = read_line(true)  -- Echo input as user types
    echo_fn("\n")
    
    if not input then
        return false
    end
    
    local amount = tonumber(input)
    
    -- Calculate cost using model
    local cost = routes_model.calculate_cargo_cost(amount, port.oil_price)
    
    -- Validate using model
    local valid, error_msg = routes_model.validate_cargo_load(ship, amount, cost, game.rubles)
    if not valid then
        echo_fn(string.format("\n%s\nPress any key to continue...", error_msg))
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present confirmation
    echo_fn(string.format("\nLoad %dk barrels of crude oil for %s Rubles?\n", 
        amount, widgets.format_number(cost)))
    echo_fn("(Y) Yes  (N) No\n\nConfirm: ")
    
    choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo_fn("Cargo loading cancelled.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Execute loading using model
    routes_model.load_cargo(game, ship, amount, cost)
    
    echo_fn(string.format("\nLoaded %dk barrels onto %s.\nCost: %s Rubles\nRemaining: %s Rubles\nPress any key to continue...",
        amount, ship.name, widgets.format_number(cost), widgets.format_number(game.rubles)))
    read_char()
    echo_fn("\n")
    
    return true
end

--- Present cargo selling interface
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function for single character
--- @param read_line function Input function for line input
--- @return boolean Success
function routes_presenter.sell_cargo(game, echo_fn, read_char, read_line)
    echo_fn("\n")
    echo_fn("--- SELL CARGO ---\n\n")
    
    -- Get ships with cargo from model
    local ships_with_cargo = routes_model.get_ships_for_selling(game)
    
    if #ships_with_cargo == 0 then
        echo_fn("No ships with cargo at markets to sell.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Present ship selection
    echo_fn("Select ship to sell cargo from:\n\n")
    for i, entry in ipairs(ships_with_cargo) do
        local dest_name = world.port_name(entry.ship.destination_id)
        echo_fn(string.format("(%d) %s - %s, Cargo: %s\n",
            i, entry.ship.name, dest_name, entry.ship.cargo))
    end
    echo_fn("\n(B) Back\n\nEnter ship number: ")
    
    local choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() == "B" then
        return false
    end
    
    local ship_idx = tonumber(choice)
    if not ship_idx or ship_idx < 1 or ship_idx > #ships_with_cargo then
        echo_fn("Invalid ship number.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    local selected_entry = ships_with_cargo[ship_idx]
    local ship = selected_entry.ship
    local port = selected_entry.port
    
    -- Calculate sale revenue using model
    local revenue = routes_model.calculate_cargo_revenue(ship.cargo_amount, port.oil_price)
    
    -- Present sale summary
    local dest_name = world.port_name(ship.destination_id)
    echo_fn("\n--- CARGO SALE ---\n\n")
    echo_fn(string.format("Ship: %s\n", ship.name))
    echo_fn(string.format("Location: %s\n", dest_name))
    echo_fn(string.format("Cargo: %dk barrels of %s\n", ship.cargo_amount, ship.cargo_type))
    echo_fn(string.format("Market price: $%d/bbl\n", port.oil_price))
    echo_fn(string.format("Total revenue: %s Rubles\n\n", widgets.format_number(revenue)))
    
    echo_fn("Sell cargo? (Y/N): ")
    
    choice = read_char()
    echo_fn("\n")
    
    if not choice or choice:upper() ~= "Y" then
        echo_fn("Sale cancelled.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Execute sale using model
    routes_model.sell_cargo(game, ship, revenue)
    
    echo_fn(string.format("\nSold cargo for %s Rubles!\nYour rubles: %s\nHeat increased to %d/10\nPress any key to continue...",
        widgets.format_number(revenue), widgets.format_number(game.rubles), game.heat))
    read_char()
    echo_fn("\n")
    
    return true
end

return routes_presenter

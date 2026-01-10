--- Shadow Fleet - Route and Cargo Operations
--- Handles route plotting and cargo management
---
--- This module provides functions for plotting routes between ports,
--- loading and unloading cargo, and managing ship logistics.
---
--- @module game.routes

local world = require("game.world")
local widgets = require("ui")

local routes = {}

--- Plot a route for a ship
--- Interactive function to select ship and destination
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function
--- @return boolean Success
function routes.plot_route(game, echo_fn, read_char)
    echo_fn("\n")
    echo_fn("--- PLOT ROUTE ---\n\n")
    
    -- List docked ships only
    local docked_ships = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "Docked" or ship.status == "In Port" then
            table.insert(docked_ships, {index = i, ship = ship})
        end
    end
    
    if #docked_ships == 0 then
        echo_fn("No ships available at port to depart.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Select ship
    echo_fn("Select ship to depart:\n\n")
    for i, entry in ipairs(docked_ships) do
        echo_fn(string.format("(%d) %s - %s, Fuel: %d%%, Cargo: %s\n",
            i, entry.ship.name, entry.ship.origin, entry.ship.fuel,
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
    
    -- Get ship's current port
    local current_port_id = ship.origin_id
    if not current_port_id then
        -- Try to find port ID from name
        current_port_id = world.find_port_id(ship.origin)
    end
    
    if not current_port_id then
        echo_fn("Error: Cannot determine ship's current port.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Get available destinations
    local destinations = world.get_destinations(current_port_id)
    
    if #destinations == 0 then
        echo_fn("No routes available from " .. ship.origin .. ".\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Display destinations
    echo_fn("\n--- SELECT DESTINATION ---\n\n")
    echo_fn(string.format("Ship: %s at %s\n\n", ship.name, ship.origin))
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
    
    -- Check fuel
    local fuel_needed = destination.route.days * 2  -- Rough estimate: 2% per day
    if ship.fuel < fuel_needed then
        echo_fn(string.format("WARNING: Low fuel! Ship has %d%% fuel, route needs ~%d%%.\n", 
            ship.fuel, fuel_needed))
        echo_fn("Continue anyway? (Y/N): ")
        choice = read_char()
        echo_fn("\n")
        if not choice or choice:upper() ~= "Y" then
            return false
        end
    end
    
    -- Confirm departure
    echo_fn(string.format("\nDeparture Summary:\n"))
    echo_fn(string.format("Ship: %s\n", ship.name))
    echo_fn(string.format("From: %s\n", ship.origin))
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
    
    -- Set ship on route
    ship.status = "At Sea"
    ship.destination = destination.port.name
    ship.destination_id = destination.port.id
    ship.days_remaining = destination.route.days
    if destination.route.days == 1 then
        ship.eta = "1 day"
    else
        ship.eta = destination.route.days .. " days"
    end
    ship.risk = destination.route.risk:upper()
    
    echo_fn(string.format("\n%s has departed for %s. ETA: %s\nPress any key to continue...",
        ship.name, destination.port.name, ship.eta))
    read_char()
    echo_fn("\n")
    
    return true
end

--- Load cargo onto a ship
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function
--- @return boolean Success
function routes.load_cargo(game, echo_fn, read_char)
    echo_fn("\n")
    echo_fn("--- LOAD CARGO ---\n\n")
    
    -- List ships at export terminals
    local available_ships = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "Docked" or ship.status == "In Port" then
            -- Check if at an export terminal
            local port = world.get_port(ship.origin_id)
            if port and port.type == "export" then
                table.insert(available_ships, {index = i, ship = ship, port = port})
            end
        end
    end
    
    if #available_ships == 0 then
        echo_fn("No ships available at export terminals to load cargo.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Select ship
    echo_fn("Select ship to load:\n\n")
    for i, entry in ipairs(available_ships) do
        local cargo_space = entry.ship.capacity - (entry.ship.cargo_amount or 0)
        echo_fn(string.format("(%d) %s - %s, Capacity: %dk bbls (%dk available)\n",
            i, entry.ship.name, entry.ship.origin, entry.ship.capacity, cargo_space))
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
    
    -- Show cargo options
    echo_fn("\n--- CARGO OPTIONS ---\n\n")
    echo_fn(string.format("Ship: %s\n", ship.name))
    echo_fn(string.format("Location: %s\n", ship.origin))
    echo_fn(string.format("Available space: %dk barrels\n", cargo_space))
    echo_fn(string.format("Oil price: $%d/bbl\n\n", port.oil_price))
    
    echo_fn("Enter cargo amount (in thousands of barrels): ")
    local input = io.read()
    
    if not input then
        return false
    end
    
    local amount = tonumber(input)
    if not amount or amount <= 0 then
        echo_fn("\nInvalid amount.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    if amount > cargo_space then
        echo_fn(string.format("\nCannot load %dk bbls - only %dk space available.\nPress any key to continue...",
            amount, cargo_space))
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Calculate cost
    local cost = amount * 1000 * port.oil_price  -- amount is in thousands
    
    if game.rubles < cost then
        echo_fn(string.format("\nInsufficient funds. Cost: %s Rubles, You have: %s Rubles\nPress any key to continue...",
            widgets.format_number(cost), widgets.format_number(game.rubles)))
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Confirm purchase
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
    
    -- Load cargo
    ship.cargo_amount = (ship.cargo_amount or 0) + amount
    ship.cargo_type = "Crude"
    ship.cargo = string.format("%dk bbls Crude", ship.cargo_amount)
    game.rubles = game.rubles - cost
    
    echo_fn(string.format("\nLoaded %dk barrels onto %s.\nCost: %s Rubles\nRemaining: %s Rubles\nPress any key to continue...",
        amount, ship.name, widgets.format_number(cost), widgets.format_number(game.rubles)))
    read_char()
    echo_fn("\n")
    
    return true
end

--- Sell cargo at current port
--- @param game table Game state
--- @param echo_fn function Output function
--- @param read_char function Input function
--- @return boolean Success
function routes.sell_cargo(game, echo_fn, read_char)
    echo_fn("\n")
    echo_fn("--- SELL CARGO ---\n\n")
    
    -- List ships with cargo at markets
    local ships_with_cargo = {}
    for i, ship in ipairs(game.fleet) do
        if ship.status == "In Port" and ship.cargo_amount and ship.cargo_amount > 0 then
            local port = world.get_port(ship.destination_id)
            if port and (port.type == "market" or port.type == "sts") then
                table.insert(ships_with_cargo, {index = i, ship = ship, port = port})
            end
        end
    end
    
    if #ships_with_cargo == 0 then
        echo_fn("No ships with cargo at markets to sell.\nPress any key to continue...")
        read_char()
        echo_fn("\n")
        return false
    end
    
    -- Select ship
    echo_fn("Select ship to sell cargo from:\n\n")
    for i, entry in ipairs(ships_with_cargo) do
        echo_fn(string.format("(%d) %s - %s, Cargo: %s\n",
            i, entry.ship.name, entry.ship.destination, entry.ship.cargo))
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
    
    -- Calculate sale price
    local revenue = ship.cargo_amount * 1000 * port.oil_price
    
    echo_fn("\n--- CARGO SALE ---\n\n")
    echo_fn(string.format("Ship: %s\n", ship.name))
    echo_fn(string.format("Location: %s\n", ship.destination))
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
    
    -- Sell cargo
    game.rubles = game.rubles + revenue
    ship.cargo_amount = 0
    ship.cargo_type = nil
    ship.cargo = "Empty"
    
    -- Small heat increase for selling
    game.heat = math.min(game.heat_max, game.heat + 1)
    
    echo_fn(string.format("\nSold cargo for %s Rubles!\nYour rubles: %s\nHeat increased to %d/10\nPress any key to continue...",
        widgets.format_number(revenue), widgets.format_number(game.rubles), game.heat))
    read_char()
    echo_fn("\n")
    
    return true
end

return routes

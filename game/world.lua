--- Shadow Fleet - World Data
--- Port and route information
---
--- This module defines the game world including ports, routes, and travel times.
--- Based on real-world shadow fleet operations and major oil trading routes.
---
--- @module game.world

local world = {}

--- Cargo type definitions
world.cargo = {
    crude = {
        name = "Crude",
        unit = "bbl"
    }
}

--- Risk level definitions
world.risks = {
    none = {
        name = "None",
        level = 0
    },
    low = {
        name = "LOW",
        level = 1
    },
    medium = {
        name = "MED",
        level = 2,
        description = "AIS Spoof Active"
    },
    high = {
        name = "HIGH",
        level = 3
    }
}

--- Ship status definitions
world.status = {
    docked = "Docked",
    in_port = "In Port",
    at_sea = "At Sea"
}

--- Port definitions
--- Each port has a name, region, and type (export terminal, STS point, or market)
world.ports = {
    -- Russian Export Terminals
    {
        id = "ust_luga",
        name = "Ust-Luga (RU)",
        region = "Baltic",
        type = "export",
        oil_price = 60  -- Base price at Russian terminals
    },
    {
        id = "primorsk",
        name = "Primorsk (RU)",
        region = "Baltic",
        type = "export",
        oil_price = 60
    },
    {
        id = "novorossiysk",
        name = "Novorossiysk (RU)",
        region = "Black Sea",
        type = "export",
        oil_price = 60
    },
    {
        id = "kozmino",
        name = "Kozmino (RU)",
        region = "Pacific",
        type = "export",
        oil_price = 60
    },
    
    -- STS (Ship-to-Ship) Transfer Points
    {
        id = "malta_sts",
        name = "STS off Malta",
        region = "Mediterranean",
        type = "sts",
        oil_price = 70  -- Higher prices at transfer points
    },
    {
        id = "laconia_sts",
        name = "Laconian Gulf STS",
        region = "Mediterranean",
        type = "sts",
        oil_price = 70
    },
    {
        id = "ceuta_sts",
        name = "Ceuta STS",
        region = "Gibraltar",
        type = "sts",
        oil_price = 72
    },
    {
        id = "skaw_sts",
        name = "Skaw STS",
        region = "North Sea",
        type = "sts",
        oil_price = 68
    },
    
    -- Destination Markets
    {
        id = "india_ports",
        name = "India (Various Ports)",
        region = "Indian Ocean",
        type = "market",
        oil_price = 75  -- Highest prices at markets
    },
    {
        id = "china_ports",
        name = "China (Various Ports)",
        region = "East Asia",
        type = "market",
        oil_price = 76
    },
    {
        id = "turkey",
        name = "Turkey",
        region = "Mediterranean",
        type = "market",
        oil_price = 73
    },
    {
        id = "singapore",
        name = "Singapore",
        region = "Southeast Asia",
        type = "market",
        oil_price = 74
    }
}

--- Route definitions
--- Each route connects two ports and specifies travel time in days and risk level
world.routes = {
    -- From Ust-Luga
    {from = "ust_luga", to = "malta_sts", days = 7, risk = "medium"},
    {from = "ust_luga", to = "skaw_sts", days = 2, risk = "low"},
    {from = "ust_luga", to = "turkey", days = 10, risk = "high"},
    
    -- From Primorsk
    {from = "primorsk", to = "malta_sts", days = 8, risk = "medium"},
    {from = "primorsk", to = "skaw_sts", days = 2, risk = "low"},
    
    -- From Novorossiysk
    {from = "novorossiysk", to = "malta_sts", days = 3, risk = "low"},
    {from = "novorossiysk", to = "laconia_sts", days = 2, risk = "low"},
    {from = "novorossiysk", to = "turkey", days = 1, risk = "low"},
    
    -- From Kozmino
    {from = "kozmino", to = "china_ports", days = 5, risk = "low"},
    {from = "kozmino", to = "singapore", days = 12, risk = "medium"},
    {from = "kozmino", to = "india_ports", days = 18, risk = "high"},
    
    -- From STS points to markets
    {from = "malta_sts", to = "india_ports", days = 12, risk = "medium"},
    {from = "malta_sts", to = "turkey", days = 2, risk = "low"},
    {from = "malta_sts", to = "china_ports", days = 25, risk = "high"},
    
    {from = "laconia_sts", to = "india_ports", days = 11, risk = "medium"},
    {from = "laconia_sts", to = "turkey", days = 1, risk = "low"},
    
    {from = "ceuta_sts", to = "india_ports", days = 15, risk = "medium"},
    {from = "ceuta_sts", to = "turkey", days = 5, risk = "medium"},
    
    {from = "skaw_sts", to = "india_ports", days = 20, risk = "high"},
    {from = "skaw_sts", to = "china_ports", days = 30, risk = "high"},
    
    {from = "singapore", to = "china_ports", days = 6, risk = "low"},
    {from = "singapore", to = "india_ports", days = 8, risk = "low"},
    
    -- Return routes (markets to export terminals)
    {from = "india_ports", to = "ust_luga", days = 25, risk = "medium"},
    {from = "india_ports", to = "novorossiysk", days = 15, risk = "medium"},
    {from = "india_ports", to = "kozmino", days = 18, risk = "medium"},
    
    {from = "china_ports", to = "kozmino", days = 5, risk = "low"},
    {from = "china_ports", to = "ust_luga", days = 35, risk = "high"},
    
    {from = "turkey", to = "novorossiysk", days = 1, risk = "low"},
    {from = "turkey", to = "ust_luga", days = 10, risk = "medium"}
}

--- Get port by ID
--- @param port_id string Port identifier
--- @return table|nil Port data or nil if not found
function world.get_port(port_id)
    for _, port in ipairs(world.ports) do
        if port.id == port_id then
            return port
        end
    end
    return nil
end

--- Get route between two ports
--- @param from_id string Origin port ID
--- @param to_id string Destination port ID
--- @return table|nil Route data or nil if no route exists
function world.get_route(from_id, to_id)
    for _, route in ipairs(world.routes) do
        if route.from == from_id and route.to == to_id then
            return route
        end
    end
    return nil
end

--- Get all available destinations from a port
--- @param from_id string Origin port ID
--- @return table Array of {port, route} tables
function world.get_destinations(from_id)
    local destinations = {}
    for _, route in ipairs(world.routes) do
        if route.from == from_id then
            local dest_port = world.get_port(route.to)
            if dest_port then
                table.insert(destinations, {
                    port = dest_port,
                    route = route
                })
            end
        end
    end
    return destinations
end

--- Get all ports of a specific type
--- @param port_type string Port type ("export", "sts", "market")
--- @return table Array of port data
function world.get_ports_by_type(port_type)
    local ports = {}
    for _, port in ipairs(world.ports) do
        if port.type == port_type then
            table.insert(ports, port)
        end
    end
    return ports
end

--- Convert port ID to display name
--- Helper for backward compatibility with existing ship data
--- @param port_id_or_name string Port ID or legacy name
--- @return string Display name
function world.port_name(port_id_or_name)
    -- If it's already a display name format (contains parentheses), return as-is
    if port_id_or_name and port_id_or_name:match("%(") then
        return port_id_or_name
    end
    
    -- Otherwise look up by ID
    local port = world.get_port(port_id_or_name)
    return port and port.name or port_id_or_name
end

--- Find port ID from legacy name
--- @param name string Display name like "Ust-Luga (RU)"
--- @return string|nil Port ID or nil
function world.find_port_id(name)
    for _, port in ipairs(world.ports) do
        if port.name == name then
            return port.id
        end
    end
    return nil
end

--- Get risk level data by ID
--- @param risk_id string Risk identifier
--- @return table|nil Risk data or nil if not found
function world.get_risk(risk_id)
    return world.risks[risk_id]
end

--- Format risk display string
--- @param risk_id string Risk identifier
--- @return string Formatted risk string
function world.format_risk(risk_id)
    local risk = world.get_risk(risk_id)
    if not risk then
        return "Unknown"
    end
    if risk.description then
        return string.format("%s (%s)", risk.name, risk.description)
    end
    return risk.name
end

--- Get cargo type data by ID
--- @param cargo_id string Cargo type identifier
--- @return table|nil Cargo data or nil if not found
function world.get_cargo_type(cargo_id)
    return world.cargo[cargo_id]
end

--- Format cargo display string
--- @param cargo_table table Cargo table like {crude = 500}
--- @return string Formatted cargo string like "500k bbls Crude"
function world.format_cargo(cargo_table)
    if not cargo_table or type(cargo_table) ~= "table" then
        return "Empty"
    end
    
    local parts = {}
    for cargo_id, amount in pairs(cargo_table) do
        local cargo_type = world.get_cargo_type(cargo_id)
        if cargo_type then
            table.insert(parts, string.format("%dk %ss %s", amount, cargo_type.unit, cargo_type.name))
        end
    end
    
    if #parts == 0 then
        return "Empty"
    end
    
    return table.concat(parts, ", ")
end

--- Get total cargo amount from cargo table
--- @param cargo_table table Cargo table like {crude = 500}
--- @return number Total amount in thousands
function world.get_cargo_amount(cargo_table)
    if not cargo_table or type(cargo_table) ~= "table" then
        return 0
    end
    
    local total = 0
    for _, amount in pairs(cargo_table) do
        total = total + amount
    end
    return total
end

--- Get status display name by ID
--- @param status_id string Status identifier
--- @return string Status display name
function world.get_status(status_id)
    return world.status[status_id] or status_id
end

--- Format ETA display string
--- @param days number Days remaining
--- @return string Formatted ETA string
function world.format_eta(days)
    if not days then
        return nil
    end
    if days == 0 then
        return "Arrived"
    elseif days == 1 then
        return "1 day"
    else
        return days .. " days"
    end
end

return world

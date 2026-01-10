--- Shadow Fleet - World Data
--- Port and route information
---
--- This module defines the game world including ports, routes, and travel times.
--- Based on real-world shadow fleet operations and major oil trading routes.
---
--- @module game.world

local world = {}

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

return world

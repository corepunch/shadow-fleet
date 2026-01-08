-- Shadow Fleet - Game State
-- Central game state management

local gamestate = {}

-- Initialize game state with default values
function gamestate.new()
    return {
        -- Player resources
        location = "Moscow Safehouse",
        date = "Jan 08, 2026",
        rubles = 5000000,
        oil_stock = 0,
        
        -- Heat level (0-10, represents scrutiny from authorities)
        heat = 0,
        heat_max = 10,
        
        -- Fleet data
        fleet = {
            {
                name = "GHOST-01",
                age = 22,
                hull = 65,
                fuel = 80,
                status = "Docked",
                origin = "Ust-Luga (RU)",
                cargo = "Empty",
                destination = nil,
                risk = "None"
            },
            {
                name = "SHADOW-03",
                age = 18,
                hull = 72,
                fuel = 45,
                status = "At Sea",
                origin = "Ust-Luga",
                cargo = "500k bbls Crude",
                destination = "STS off Malta",
                eta = "2 days",
                risk = "MED (AIS Spoof Active)"
            }
        },
        
        -- Market data
        market = {
            crude_price_cap = 60,
            shadow_markup_percent = 25,
            shadow_price = 75,
            demand = "HIGH",
            baltic_exports = 4.1,
            sanctions_alert = "EU Patrols Up 15%",
            news = "NATO eyes 92 new blacklisted hulls. Stay dark, comrades."
        },
        
        -- Active events
        events = {
            {
                type = "Pending",
                description = "Crew Mutiny Risk on GHOST-01 (Resolve? Y/N)"
            },
            {
                type = "Opportunity",
                description = "Shady Auction - Buy \"RUST-07\" (Age 28y, 1M bbls cap) for 2M Rubles?"
            }
        }
    }
end

-- Calculate fleet statistics
function gamestate.get_fleet_stats(game)
    local total_ships = #game.fleet
    local total_age = 0
    for _, ship in ipairs(game.fleet) do
        total_age = total_age + ship.age
    end
    local avg_age = total_ships > 0 and math.floor(total_age / total_ships) or 0
    
    return {
        total = total_ships,
        max = 50,
        avg_age = avg_age,
        uninsured_losses = 0
    }
end

-- Get heat level description
function gamestate.get_heat_description(game)
    if game.heat == 0 then
        return "LOW (0/10)"
    elseif game.heat <= 3 then
        return "MEDIUM (" .. game.heat .. "/10)"
    elseif game.heat <= 7 then
        return "HIGH (" .. game.heat .. "/10)"
    else
        return "CRITICAL (" .. game.heat .. "/10)"
    end
end

-- Get heat meter color based on level
function gamestate.get_heat_color(game)
    if game.heat == 0 then
        return "fg_green"
    elseif game.heat <= 3 then
        return "fg_yellow"
    elseif game.heat <= 7 then
        return "fg_bright_yellow"
    else
        return "fg_red"
    end
end

-- Get heat meter message
function gamestate.get_heat_message(game)
    if game.heat == 0 then
        return "No eyes on you yet. One slip, and drones swarm."
    elseif game.heat <= 3 then
        return "Low profile. Keep it that way."
    elseif game.heat <= 7 then
        return "Authorities are watching. Lay low."
    else
        return "DANGER! Active pursuit in progress!"
    end
end

return gamestate

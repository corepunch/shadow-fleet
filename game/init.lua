--- Shadow Fleet - Game State
--- Central game state management
---
--- This module handles game state initialization and provides helper functions
--- for querying and modifying game state, including fleet stats, heat levels,
--- and upgrade management.
---
--- @module game

local M = {}

--- Initialize game state with default values
--- @return table New game state
function M.new()
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
        },
        
        -- Available vessel upgrades
        upgrades = {
            {
                name = "Hull Repair",
                description = "Restore hull to 100%",
                cost = 500000,
                effect = "hull",
                value = 100
            },
            {
                name = "Fuel Tank Expansion",
                description = "Increase fuel capacity by 20%",
                cost = 750000,
                effect = "fuel_capacity",
                value = 20
            },
            {
                name = "AIS Spoofer",
                description = "Permanent AIS spoofing capability",
                cost = 1000000,
                effect = "equipment",
                value = "AIS_SPOOF"
            },
            {
                name = "Hull Reinforcement",
                description = "Reduce hull degradation by 50%",
                cost = 1200000,
                effect = "equipment",
                value = "HULL_REINFORCE"
            },
            {
                name = "Advanced Radar",
                description = "Better detection avoidance",
                cost = 800000,
                effect = "equipment",
                value = "ADV_RADAR"
            }
        }
    }
end

-- Heat level thresholds
local HEAT_LOW = 0
local HEAT_MEDIUM = 3
local HEAT_HIGH = 7

--- Calculate fleet statistics
--- @param game table Game state
--- @return table Statistics including total ships, max capacity, average age, and losses
function M.get_fleet_stats(game)
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

--- Get heat level description
--- @param game table Game state
--- @return string Human-readable heat level description
function M.get_heat_description(game)
    local heat = game.heat
    if heat == HEAT_LOW then
        return "LOW (0/10)"
    elseif heat <= HEAT_MEDIUM then
        return string.format("MEDIUM (%d/10)", heat)
    elseif heat <= HEAT_HIGH then
        return string.format("HIGH (%d/10)", heat)
    else
        return string.format("CRITICAL (%d/10)", heat)
    end
end

--- Get heat meter color based on level
--- @param game table Game state
--- @return string Color name for UI rendering
function M.get_heat_color(game)
    local heat = game.heat
    if heat == HEAT_LOW then
        return "fg_green"
    elseif heat <= HEAT_MEDIUM then
        return "fg_yellow"
    elseif heat <= HEAT_HIGH then
        return "fg_bright_yellow"
    else
        return "fg_red"
    end
end

--- Get heat meter message
--- @param game table Game state
--- @return string Contextual message about current heat level
function M.get_heat_message(game)
    local heat = game.heat
    if heat == HEAT_LOW then
        return "No eyes on you yet. One slip, and drones swarm."
    elseif heat <= HEAT_MEDIUM then
        return "Low profile. Keep it that way."
    elseif heat <= HEAT_HIGH then
        return "Authorities are watching. Lay low."
    else
        return "DANGER! Active pursuit in progress!"
    end
end

--- Check if an upgrade is applicable to a ship
--- @param ship table Ship to check
--- @param upgrade table Upgrade definition
--- @return boolean, string Can apply and optional error message
function M.can_apply_upgrade(ship, upgrade)
    -- Hull repair only if hull is damaged
    if upgrade.effect == "hull" and ship.hull >= 100 then
        return false, "Hull is already at 100%"
    end
    
    -- Check if ship already has this equipment
    if upgrade.effect == "equipment" then
        ship.equipment = ship.equipment or {}
        if ship.equipment[upgrade.value] then
            return false, "Ship already has this upgrade"
        end
    end
    
    return true, nil
end

--- Apply an upgrade to a ship
--- @param ship table Ship to upgrade
--- @param upgrade table Upgrade definition to apply
function M.apply_upgrade(ship, upgrade)
    if upgrade.effect == "hull" then
        ship.hull = upgrade.value
    elseif upgrade.effect == "fuel_capacity" then
        ship.fuel_capacity = (ship.fuel_capacity or 100) + upgrade.value
    elseif upgrade.effect == "equipment" then
        ship.equipment = ship.equipment or {}
        ship.equipment[upgrade.value] = true
    end
end

--- Get available upgrades for a ship
--- @param game table Game state
--- @param ship table Ship to get upgrades for
--- @return table Array of applicable upgrade definitions
function M.get_available_upgrades(game, ship)
    local available = {}
    for _, upgrade in ipairs(game.upgrades) do
        local can_apply = M.can_apply_upgrade(ship, upgrade)
        if can_apply then
            table.insert(available, upgrade)
        end
    end
    return available
end

return M

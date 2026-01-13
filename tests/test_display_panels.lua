#!/usr/bin/env lua5.3

-- Test Display Panels (Condensed Fleet Status and Detailed Ship/Port Panels)

local widgets = require("ui")
local display = require("display")
local gamestate = require("game")
local world = require("game.world")

print("Testing Display Panels...")
print()

-- Test 1: Check that new widget functions exist
print("Test 1: Checking new widget functions exist...")
assert(type(widgets.ship_detail_panel) == "function", "ship_detail_panel should exist")
assert(type(widgets.port_detail_panel) == "function", "port_detail_panel should exist")
print("✓ Test 1: New widget functions exist")
print()

-- Test 2: Check that new display functions exist
print("Test 2: Checking new display functions exist...")
assert(type(display.ship_details) == "function", "display.ship_details should exist")
assert(type(display.port_details) == "function", "display.port_details should exist")
print("✓ Test 2: New display functions exist")
print()

-- Test 3: Test condensed fleet status width
print("Test 3: Testing condensed fleet status width...")
local game = gamestate.new()
local output = {}
local echo_fn = function(str) table.insert(output, str) end

display.fleet_status(game, echo_fn)

-- Check that the output doesn't exceed 80 characters per line
local full_output = table.concat(output)
for line in full_output:gmatch("[^\n]+") do
    assert(#line <= 80, string.format("Line exceeds 80 chars (%d): %s", #line, line))
end
print("✓ Test 3: Condensed fleet status fits in 80 characters")
print()

-- Test 4: Test ship detail panel
print("Test 4: Testing ship detail panel...")
local ship = game.fleet[1]
output = {}
widgets.ship_detail_panel(ship, echo_fn)

local panel_output = table.concat(output)
assert(panel_output:find("Firma:"), "Should contain Firma field")
assert(panel_output:find("Schiff:"), "Should contain Schiff field")
assert(panel_output:find("Zustand:"), "Should contain Zustand (hull) field")
assert(panel_output:find("Bunker:"), "Should contain Bunker (fuel) field")
assert(panel_output:find("Alter:"), "Should contain Alter (age) field")
print("✓ Test 4: Ship detail panel contains expected fields")
print()

-- Test 5: Test port detail panel
print("Test 5: Testing port detail panel...")
output = {}
widgets.port_detail_panel("ust_luga", echo_fn)

panel_output = table.concat(output)
assert(panel_output:find("Ust%-Luga"), "Should contain port name")
assert(panel_output:find("Region:"), "Should contain Region field")
assert(panel_output:find("Typ:"), "Should contain Typ (type) field")
assert(panel_output:find("Ölpreis:"), "Should contain Ölpreis (oil price) field")
print("✓ Test 5: Port detail panel contains expected fields")
print()

-- Test 6: Test display.ship_details
print("Test 6: Testing display.ship_details...")
output = {}
display.ship_details(ship, echo_fn)

local details_output = table.concat(output)
assert(details_output:find("SHIP DETAILS"), "Should contain header")
assert(details_output:find("Firma:"), "Should contain ship data")
print("✓ Test 6: display.ship_details works correctly")
print()

-- Test 7: Test display.port_details
print("Test 7: Testing display.port_details...")
output = {}
display.port_details("malta_sts", echo_fn)

details_output = table.concat(output)
assert(details_output:find("PORT DETAILS"), "Should contain header")
assert(details_output:find("Malta"), "Should contain port name")
print("✓ Test 7: display.port_details works correctly")
print()

-- Test 8: Verify fleet status shows essential columns only
print("Test 8: Verifying condensed fleet status shows essential columns...")
output = {}
display.fleet_status(game, echo_fn)

full_output = table.concat(output)
-- Should have Name, Age, Hull, Fuel, Status, Destination, ETA columns
assert(full_output:find("Name"), "Should have Name column")
assert(full_output:find("Age"), "Should have Age column")
assert(full_output:find("Hull"), "Should have Hull column")
assert(full_output:find("Fuel"), "Should have Fuel column")
assert(full_output:find("Status"), "Should have Status column")
assert(full_output:find("Destination"), "Should have Destination column")
assert(full_output:find("ETA"), "Should have ETA column")

-- Should NOT have Origin, Cargo, Risk columns in header
assert(not full_output:find("Origin"), "Should not have Origin column")
assert(not full_output:find("Cargo"), "Should not have Cargo column")
assert(not full_output:find("Risk"), "Should not have Risk column")
print("✓ Test 8: Condensed fleet status shows essential columns only")
print()

print("===================================")
print("All display panel tests passed! ✓")
print("===================================")
print()
print("These tests ensure:")
print("  • Condensed fleet status fits in 80 characters")
print("  • Ship detail panels show comprehensive information")
print("  • Port detail panels show port information")
print("  • Essential columns only in main fleet view")
print("  • Detailed data available in event/action screens")

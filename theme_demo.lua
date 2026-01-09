#!/usr/bin/env lua5.3

-- Demo script to showcase both themes
local term = require("terminal")

-- Function to render a sample screen
local function render_sample(theme_name)
    term.set_theme(theme_name)
    term.init(theme_name)
    
    print("")
    print("╔════════════════════════════════════════════════════════════════════════════╗")
    print("║                     Shadow Fleet - " .. string.upper(theme_name) .. " THEME DEMO                        ║")
    print("╚════════════════════════════════════════════════════════════════════════════╝")
    print("")
    
    -- Apply default scheme and show text
    term.apply_scheme("default")
    print("Default text in " .. theme_name .. " theme")
    term.reset()
    print("")
    
    -- Show various color schemes
    term.apply_scheme("success")
    io.write("SUCCESS: ")
    term.reset()
    print("Operation completed successfully")
    
    term.apply_scheme("error")
    io.write("ERROR: ")
    term.reset()
    print("Failed to connect to server")
    
    term.apply_scheme("warning")
    io.write("WARNING: ")
    term.reset()
    print("Low fuel detected")
    
    term.apply_scheme("info")
    io.write("INFO: ")
    term.reset()
    print("New message received")
    
    print("")
    
    -- Show a table header
    term.apply_scheme("title")
    io.write(" FLEET STATUS ")
    term.reset()
    print("")
    
    -- Show sample data with colors
    term.set_colors(term.colors.fg_bright_cyan, term.colors[term.get_theme_bg()])
    io.write("GHOST-01  ")
    term.reset()
    
    term.set_colors(term.colors.fg_green, term.colors[term.get_theme_bg()])
    io.write("Hull: 85%  ")
    term.reset()
    
    term.set_colors(term.colors.fg_yellow, term.colors[term.get_theme_bg()])
    io.write("Fuel: 45%  ")
    term.reset()
    
    term.set_colors(term.colors.fg_red, term.colors[term.get_theme_bg()])
    io.write("Risk: HIGH")
    term.reset()
    print("")
    
    term.set_colors(term.colors.fg_bright_cyan, term.colors[term.get_theme_bg()])
    io.write("SHADOW-03 ")
    term.reset()
    
    term.set_colors(term.colors.fg_green, term.colors[term.get_theme_bg()])
    io.write("Hull: 92%  ")
    term.reset()
    
    term.set_colors(term.colors.fg_green, term.colors[term.get_theme_bg()])
    io.write("Fuel: 78%  ")
    term.reset()
    
    term.set_colors(term.colors.fg_green, term.colors[term.get_theme_bg()])
    io.write("Risk: LOW")
    term.reset()
    print("")
    
    print("")
    term.cleanup()
end

-- Show dark theme
print("\n\n")
render_sample("dark")

-- Show light theme
print("\n\n")
render_sample("light")

print("\n\nTheme demonstration complete!")
print("Try running the main game with: lua5.3 main.lua --theme dark")
print("                            or: lua5.3 main.lua --theme light")
print("")

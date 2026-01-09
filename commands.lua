-- Commands Module
-- Central command registry for all game actions
--
-- This module provides a registry system for commands that decouples
-- command IDs from their handlers and hotkeys. This enables:
-- - Rebindable hotkeys via the keymap module
-- - Cleaner separation of UI and logic
-- - Easier testing of individual commands
--
-- Usage:
--   local commands = require("commands")
--   commands.register("menu.open_fleet", function(game, ctx, params)
--     return { change_context = "fleet" }
--   end)
--   local result = commands.run("menu.open_fleet", game, "main")

local commands = {}

-- Registry of command handlers
-- Maps command ID strings to handler functions
local registry = {}

-- Register a command handler
-- @param id string - Unique command identifier (e.g., "menu.open_fleet")
-- @param handler function - Handler function with signature: function(game, ctx, params) -> table|nil
--                          Handler can return a table with:
--                          - change_context: string to switch context
--                          - quit: boolean to exit the game
--                          - message: string to display to the user
function commands.register(id, handler)
    if type(id) ~= "string" then
        error("Command ID must be a string")
    end
    if type(handler) ~= "function" then
        error("Command handler must be a function")
    end
    registry[id] = handler
end

-- Run a command by ID
-- @param id string - Command identifier to run
-- @param game table - Game state
-- @param ctx string - Current context (e.g., "main", "fleet")
-- @param ... any - Additional parameters to pass to handler
-- @return table|nil - Result from command handler
function commands.run(id, game, ctx, ...)
    local handler = registry[id]
    if not handler then
        return { message = "Unknown command: " .. tostring(id) }
    end
    
    -- Call handler with game state, context, and any additional params
    local success, result = pcall(handler, game, ctx, ...)
    
    if not success then
        -- Handler threw an error
        return { message = "Command error: " .. tostring(result) }
    end
    
    return result
end

-- List all registered commands
-- @return table - Array of command IDs
function commands.list()
    local command_list = {}
    for id, _ in pairs(registry) do
        table.insert(command_list, id)
    end
    table.sort(command_list)
    return command_list
end

return commands

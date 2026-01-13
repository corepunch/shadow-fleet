--- UI Input Module
--- Provides input abstraction for testing and flexibility
---
--- This module wraps the terminal input functionality to enable:
--- - Easy mocking in tests
--- - Input simulation for automated testing
--- - Consistent input interface across the application
---
--- @module ui.input

local input = {}

-- Default input functions (uses terminal module)
local terminal = require("terminal")
local default_read_char_fn = terminal.read_char
local default_read_line_fn = terminal.read_line

--- Set the read_char function (useful for testing)
--- @param fn function The function to use for reading characters
function input.set_read_char_fn(fn)
    default_read_char_fn = fn
end

--- Set the read_line function (useful for testing)
--- @param fn function The function to use for reading lines
function input.set_read_line_fn(fn)
    default_read_line_fn = fn
end

--- Reset to default terminal input functions
function input.reset()
    default_read_char_fn = terminal.read_char
    default_read_line_fn = terminal.read_line
end

--- Read a single character
--- @param echo_input boolean Optional - if true, echoes the character to output
--- @return string|nil Character read, or nil on EOF
function input.read_char(echo_input)
    return default_read_char_fn(echo_input)
end

--- Read a full line of text
--- @param echo_input boolean Optional - if true, echoes each character as it's typed
--- @return string|nil Line read, or nil on EOF
function input.read_line(echo_input)
    return default_read_line_fn(echo_input)
end

--- Get the current read_char function
--- @return function The current read_char function
function input.get_read_char_fn()
    return default_read_char_fn
end

--- Get the current read_line function
--- @return function The current read_line function
function input.get_read_line_fn()
    return default_read_line_fn
end

return input

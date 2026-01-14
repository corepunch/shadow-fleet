--- UI Output Module
--- Provides output abstraction for testing and flexibility
---
--- This module wraps the terminal output functionality to enable:
--- - Easy mocking in tests
--- - Output redirection for testing
--- - Consistent output interface across the application
---
--- @module ui.output

local output = {}

-- Default output function (uses terminal module)
local terminal = require("terminal")
local default_output_fn = terminal.echo

--- Set the output function (useful for testing)
--- @param fn function The function to use for output
function output.set_output_fn(fn)
    default_output_fn = fn
end

--- Reset to default terminal output
function output.reset()
    default_output_fn = terminal.echo
end

--- Write output using the configured output function
--- Accepts the same parameters as terminal.echo:
--- - Single string argument, or
--- - Format string with additional arguments (uses string.format)
--- @param ... Arguments: either a single string or format string with values
function output.write(...)
    default_output_fn(...)
end

--- Get the current output function
--- @return function The current output function
function output.get_output_fn()
    return default_output_fn
end

return output

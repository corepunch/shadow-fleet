-- Terminal I/O Module
-- Handles raw terminal mode and formatted output

local M = {}

-- Raw mode state
local raw_mode_active = false

-- Set terminal to raw mode for single-character input
function M.set_raw_mode()
    if not raw_mode_active then
        os.execute("stty raw -echo 2>/dev/null")
        raw_mode_active = true
    end
end

-- Restore terminal to normal mode
function M.restore_normal_mode()
    if raw_mode_active then
        os.execute("stty sane 2>/dev/null")
        raw_mode_active = false
    end
end

-- Read a single character without waiting for Enter
function M.read_char()
    M.set_raw_mode()
    return io.read(1)
end

-- Fix line endings for raw terminal mode
-- Converts \n to \r\n, avoiding double conversion of existing \r\n sequences
local function fix_line_endings(text)
    return text:gsub("\r?\n", "\r\n")
end

-- Write text with optional formatting
-- In raw mode, we need \r\n instead of just \n for proper line breaks
-- Usage: echo(format_string, ...)
-- Example: echo("Enter command: ")
-- Example: echo("Ship: %s Age: %d", ship.name, ship.age)
function M.echo(...)
    local args = {...}
    local text
    
    if #args > 0 then
        if #args == 1 then
            text = args[1]
        else
            text = string.format(args[1], select(2, ...))
        end
    else
        text = ""
    end
    
    local fixed_text = fix_line_endings(text)
    io.write(fixed_text)
    io.flush()
end

-- Write multiple strings efficiently using table.concat
function M.echo_multi(parts)
    local text = table.concat(parts)
    local fixed_text = fix_line_endings(text)
    io.write(fixed_text)
    io.flush()
end

return M

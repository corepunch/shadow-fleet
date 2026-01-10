--- Terminal I/O Module
--- Handles raw terminal mode and formatted output for BBS Door style interface
---
--- This module provides low-level terminal control functions for reading
--- single-character input and writing formatted output with proper line endings.
---
--- @module terminal

local terminal = {}

-- Raw mode state tracking
local raw_mode_active = false

--- Set terminal to raw mode for single-character input
function terminal.set_raw_mode()
    if not raw_mode_active then
        os.execute("stty raw -echo 2>/dev/null")
        raw_mode_active = true
    end
end

--- Restore terminal to normal (cooked) mode
function terminal.restore_normal_mode()
    if raw_mode_active then
        os.execute("stty sane 2>/dev/null")
        raw_mode_active = false
    end
end

--- Read a single character without waiting for Enter
--- @return string|nil Character read, or nil on EOF
function terminal.read_char()
    terminal.set_raw_mode()
    local char
    -- Skip newlines/carriage returns
    repeat
        char = io.read(1)
    until not char or (char ~= "\r" and char ~= "\n")
    return char
end

--- Read a full line of text (in raw mode, reads chars until newline)
--- Skips any leading newlines first
--- @return string|nil Line read, or nil on EOF
function terminal.read_line()
    terminal.set_raw_mode()
    
    -- Skip leading newlines
    local char
    repeat
        char = io.read(1)
    until not char or (char ~= "\r" and char ~= "\n")
    
    if not char then
        return nil  -- EOF
    end
    
    -- Start building the line with the first non-newline character
    local chars = {char}
    
    -- Read until we hit another newline
    while true do
        char = io.read(1)
        if not char or char == "\r" or char == "\n" then
            break
        end
        table.insert(chars, char)
    end
    
    return table.concat(chars)
end

--- Fix line endings for raw terminal mode
local function fix_line_endings(text)
    return text:gsub("\r?\n", "\r\n")
end

--- Write text with optional formatting
--- @param ... Arguments for string.format or a single string
function terminal.echo(...)
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

--- Write multiple strings efficiently using table.concat
--- @param parts Array of strings to concatenate
function terminal.echo_multi(parts)
    local text = table.concat(parts)
    local fixed_text = fix_line_endings(text)
    io.write(fixed_text)
    io.flush()
end

return terminal

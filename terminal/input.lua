-- Terminal Input Module
-- Provides raw keyboard input handling including arrow keys
-- 
-- Note: This module uses 'stty' to set terminal raw mode, which is standard
-- on Unix-like systems (Linux, macOS, BSD). It may not work on Windows.
-- For Windows compatibility, consider using a cross-platform terminal library.
--
-- Usage:
--   1. Call input.set_raw_mode() once before your main loop
--   2. Call input.read_key() to read keypresses without lag
--   3. Call input.restore_mode() on exit (use xpcall/finalizer)

local input = {}

-- Key codes
input.keys = {
    UP = "up",
    DOWN = "down",
    LEFT = "left",
    RIGHT = "right",
    ENTER = "enter",
    ESC = "esc",
    Q = "q",
    UNKNOWN = "unknown"
}

-- Set terminal to raw mode (disable line buffering and echo)
-- Call this ONCE before your main loop
-- Uses stty command which is available on most Unix-like systems
function input.set_raw_mode()
    os.execute("stty raw -echo 2>/dev/null")
end

-- Restore terminal to normal mode
-- Call this on exit to restore terminal state
function input.restore_mode()
    os.execute("stty sane 2>/dev/null")
end

-- Read a single character from stdin
local function read_char()
    local char = io.read(1)
    return char
end

-- Read a key press (handles escape sequences for arrow keys)
-- Returns a key code from input.keys
-- NOTE: Terminal must be in raw mode before calling this function
function input.read_key()
    local char = read_char()
    local key = input.keys.UNKNOWN
    
    if char == '\n' or char == '\r' then
        key = input.keys.ENTER
    elseif char == '\27' then  -- ESC character
        -- Check if this is an arrow key (escape sequence)
        local next_char = read_char()
        if next_char == '[' then
            local arrow = read_char()
            if arrow == 'A' then
                key = input.keys.UP
            elseif arrow == 'B' then
                key = input.keys.DOWN
            elseif arrow == 'C' then
                key = input.keys.RIGHT
            elseif arrow == 'D' then
                key = input.keys.LEFT
            end
        else
            key = input.keys.ESC
        end
    elseif char == 'q' or char == 'Q' then
        key = input.keys.Q
    elseif char then
        -- For numbered keys, return the character itself
        if char:match('[1-8]') then
            key = char
        end
    end
    
    return key
end

-- Wait for Enter key
-- NOTE: Terminal must be in raw mode before calling this function
function input.wait_for_enter()
    while true do
        local char = read_char()
        if char == '\n' or char == '\r' then
            break
        end
    end
end

return input

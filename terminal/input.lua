-- Terminal Input Module
-- Provides raw keyboard input handling including arrow keys

local input = {}

-- Set terminal to raw mode (disable line buffering and echo)
local function set_raw_mode()
    os.execute("stty raw -echo 2>/dev/null")
end

-- Restore terminal to normal mode
local function restore_mode()
    os.execute("stty sane 2>/dev/null")
end

-- Read a single character from stdin
local function read_char()
    local char = io.read(1)
    return char
end

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

-- Read a key press (handles escape sequences for arrow keys)
-- Returns a key code from input.keys
function input.read_key()
    set_raw_mode()
    
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
    
    restore_mode()
    return key
end

-- Wait for Enter key
function input.wait_for_enter()
    set_raw_mode()
    while true do
        local char = read_char()
        if char == '\n' or char == '\r' then
            break
        end
    end
    restore_mode()
end

return input

-- Window/Panel class - A buffered container for drawing UI elements
-- This provides a cleaner abstraction similar to TUI frameworks like ncurses

local term = require("terminal")

local Window = {}
Window.__index = Window

function Window.new(row, col, width, height, title, border_color, bg_color)
    local self = setmetatable({}, Window)
    self.row = row
    self.col = col
    self.width = width
    self.height = height
    self.title = title
    self.border_color = border_color or "fg_cyan"
    self.bg_color = bg_color or "bg_black"
    self.content_row = row + 1  -- First row inside the box
    self.content_col = col + 2  -- First column inside the box (accounting for border)
    return self
end

-- Draw the window border and title
function Window:draw_border()
    term.draw_box(self.row, self.col, self.width, self.height, self.border_color, self.bg_color)
    if self.title then
        term.write_at(self.row, self.col + 2, "[ " .. self.title .. " ]", "fg_bright_white", self.bg_color)
    end
end

-- Write text at a position relative to the window's content area
function Window:write_at(rel_row, rel_col, text, fg, bg)
    bg = bg or self.bg_color
    term.write_at(self.content_row + rel_row - 1, self.content_col + rel_col - 1, text, fg, bg)
end

-- Write colored text at current cursor position (for chaining writes)
function Window:write_colored(text, fg, bg)
    bg = bg or self.bg_color
    term.write_colored(text, fg, bg)
end

-- Get the next row position after this window
function Window:next_row()
    return self.row + self.height + 1
end

return Window

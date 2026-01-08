# shadow-fleet
A text based strategy game about Russian Shadow Fleet

## Components

### Terminal Framework
A comprehensive cursor control and color management library for building text-based UIs.

Features:
- Screen clearing and cursor positioning
- 32 predefined colors (16 foreground + 16 background)
- Predefined color schemes for common UI elements
- Box drawing and text styling
- Full ANSI escape code support

See [TERMINAL.md](TERMINAL.md) for complete documentation.

**Quick Start:**
```lua
local terminal = require("terminal")
terminal.init()
terminal.write_at(1, 1, "Shadow Fleet", "fg_bright_yellow", "bg_blue")
terminal.cleanup()
```

**Run Demo:**
```bash
lua5.3 terminal_demo.lua
```

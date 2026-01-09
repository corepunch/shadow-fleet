# Shadow Fleet - Text-Based Strategy Game

A terminal-based strategy game about managing a shadow fleet of oil tankers evading sanctions.

## Requirements

- Lua 5.3 or higher
- A terminal emulator with ANSI color support (most modern terminals)

## Installation

### On Ubuntu/Debian:
```bash
sudo apt install lua5.3
```

### On macOS:
```bash
brew install lua
```

### On other systems:
See [Lua's official installation guide](https://www.lua.org/download.html)

## Running the Game

```bash
lua main.lua
```

Or if you made it executable:
```bash
./main.lua
```

## How to Play

The game presents a dashboard showing:
- **Your Resources**: Capital (rubles) and oil stock
- **Fleet Status**: Your tanker ships, their condition, cargo, and routes
- **Market Info**: Oil prices, demand, and sanctions alerts
- **Events**: Opportunities and challenges requiring decisions
- **Heat Meter**: Track how much attention you're attracting from authorities

### Controls

Use hotkeys to navigate:
1. **F** - Fleet - Manage your ships (view, buy, upgrade, scrap)
2. **R** - Route - Plan routes and load cargo
3. **T** - Trade - Sell and launder oil
4. **E** - Evade - Use evasion tactics (AIS spoofing, flag swaps, bribes)
5. **V** - eVents - Resolve pending situations
6. **M** - Market - Check prices and auction opportunities
7. **S** - Status - Quick overview and news
8. **?** - Help - Command details

Press **B** to go back from any submenu.
Press **Q** to quit the game.

## Game Features

- **Color-coded Display**: Important values are highlighted in color
  - Prices in bright yellow
  - Ship names in cyan
  - Hull/Fuel percentages color-coded by condition (green/yellow/red)
  - Risk levels appropriately colored
  
- **Dynamic Fleet Management**: Track multiple ships with different stats
- **Market System**: Watch oil prices and sanctions
- **Events System**: Handle challenges and opportunities
- **Heat Mechanic**: Stay under the radar or face consequences

## Files

- `main.lua` - Main game file with dashboard and game logic
- `terminal.lua` - Terminal framework for colors and cursor control

## License

GPL-3.0 - See LICENSE file for details

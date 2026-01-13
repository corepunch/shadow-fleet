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
- **Your Resources**: Capital (rubles), weeks, and years played
- **Fleet Status**: Your tanker ships, their condition, cargo, and routes (always visible on main screen)
- **Market Info**: Oil prices, demand, and sanctions alerts
- **Heat Meter**: Track how much attention you're attracting from authorities

### Main Menu Controls

The main menu uses a simplified "Ports of Call" style interface:
- **B** - Ship Broker - Buy and sell ships
- **T** - end Turn - Advance the game turn
- **Q** - Quit - Exit the game

### Action Screens (Event-Driven)

Unlike traditional menu-driven games, Shadow Fleet uses **event-driven action screens** inspired by classic "Ports of Call". Action screens appear automatically when significant events occur:

**Ship Arrival**: When a ship arrives at its destination, an action screen appears with options:
- **R** - Repair - Fix hull damage
- **F** - Refuel - Buy fuel
- **C** - Charter - Plot a new route
- **L** - Load - Load cargo at port
- **U** - Unload - Sell cargo
- **D** - Depart - Set sail (plots route and departs)
- **X** - Done - Exit action screen

You can perform multiple actions on a ship before choosing "Done" to return to the main menu.

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

# Shadow Fleet - Gameplay Guide

## New Features

The game now includes a full gameplay loop with ship movement, cargo trading, and turn-based mechanics!

The menu structure has been updated to match the classic "Ports of Call" game for a more authentic experience with **event-driven action screens**.

## Main Screen

The main screen now displays:
- **Money / Weeks / Years** - Your current capital and game time (e.g., "5,000,000 / 0 Weeks / 0 Yrs.")
- **Fleet Status** - Always visible, showing all ships and their current state
- **Simplified Menu** - Only Ship Broker and End Turn options

## How to Play

### 1. View Your Fleet (Always Visible)
The fleet status is always shown on the main screen:
- **GHOST-01**: Currently docked at Ust-Luga
- **SHADOW-03**: At sea, carrying 500k barrels to Malta STS

### 2. Buy Ships (Ship Broker)
Press **B** for Ship Broker menu:
- **V** - View Ships (see available ships for purchase)
- **B** - Buy ships
- **S** - Sell ships
- **X** - Back to main menu

### 3. Advance Time (End Turn)
Press **T** to end turn and advance time by one day:
- Ships at sea move closer to destinations
- Fuel and hull degrade gradually
- Market prices fluctuate
- Heat naturally decreases
- Date advances
- Weeks and Years counters update (7 days = 1 week, 52 weeks = 1 year)

**Note**: After each turn, press any key to acknowledge and continue.

### 4. Action Screens (Event-Driven)

When a ship arrives at its destination, an **action screen automatically appears** (like in classic Ports of Call):

**Ship Action Screen** shows:
- Ship name and location
- Current hull, fuel, and cargo status
- Available actions:
  - **R** - Repair (fix hull damage)
  - **F** - Refuel (buy fuel)
  - **C** - Charter (plot new route)
  - **L** - Load (load cargo at port)
  - **U** - Unload (sell cargo and receive payment)
  - **D** - Depart (plot route and sail)
  - **X** - Done (exit action screen)

You can perform multiple actions before choosing **Done**.

## Menu Structure

### Main Menu (Simplified - Ports of Call Style)
- **B** - Ship Broker (buy/sell ships)
- **T** - end Turn
- **Q** - Quit

**Note**: Fleet status is always displayed on the main screen - no need to navigate to a separate menu.

### Ship Broker Menu
- **V** - View Ships
- **B** - Buy ships
- **S** - Sell ships
- **X** - Back to main menu

### Ship Action Screen (Appears on Ship Arrival)
When a ship arrives at port, this screen automatically appears:
- **R** - Repair ships
- **F** - Refuel ships
- **C** - Charter (plot new route)
- **L** - Load cargo
- **U** - Unload cargo (sell)
- **D** - Depart (plot route and sail)
- **X** - Done (exit action screen)

## Ports and Routes

### Export Terminals (Russian)
- **Ust-Luga** (Baltic): Routes to Malta STS (7 days), Skaw STS (2 days), Turkey (10 days)
- **Primorsk** (Baltic): Routes to Malta STS (8 days), Skaw STS (2 days)
- **Novorossiysk** (Black Sea): Routes to Malta STS (3 days), Laconian Gulf (2 days), Turkey (1 day)
- **Kozmino** (Pacific): Routes to China (5 days), Singapore (12 days), India (18 days)

### Ship-to-Ship Transfer Points
- **STS off Malta** - Mediterranean hub
- **Laconian Gulf STS** - Greek waters
- **Ceuta STS** - Gibraltar strait
- **Skaw STS** - North Sea

### Destination Markets
- **India** - $75/bbl
- **China** - $76/bbl
- **Turkey** - $73/bbl
- **Singapore** - $74/bbl

## Tips for Success

1. **Manage Fuel**: Longer routes consume more fuel. Ships with low fuel may not complete journeys.

2. **Watch Hull Condition**: Older ships degrade faster. Keep hull above 50% for safety.

3. **Balance Profit and Risk**: 
   - Low risk routes = safer but slower/lower profit
   - High risk routes = faster but more dangerous

4. **Heat Management**: 
   - Heat increases when selling cargo
   - Heat decreases naturally each turn
   - High heat = more scrutiny from authorities

5. **Plan Ahead**: Routes take multiple days. Plan your cargo purchases and routes efficiently.

## Example Gameplay Session

```
1. Check fleet on main screen - see GHOST-01 docked at Ust-Luga
2. Press T to advance turn
3. Press T again to advance another turn
4. SHADOW-03 arrives at Malta! Action screen appears automatically
5. On action screen, press U to Unload cargo - sell 500k barrels for profit
6. Press C to Charter a new route back to Ust-Luga
7. Press X to exit action screen and return to main menu
8. Continue playing or press Q to quit
```

## Current Game State

**Your Resources**:
- **Rubles**: 5,000,000 (starting capital)
- **Date**: Jan 08, 2026
- **Heat**: 0/10 (no scrutiny yet)

**Your Fleet**:
- **GHOST-01**: 22 years old, 65% hull, 80% fuel, 500k bbl capacity - DOCKED at Ust-Luga
- **SHADOW-03**: 18 years old, 72% hull, 45% fuel, 500k bbl capacity - AT SEA to Malta (2 days, carrying 500k bbls)

**Active Events**:
- Crew Mutiny Risk on GHOST-01
- Auction opportunity for RUST-07

## Testing the Features

Run the tests:
```bash
make test
```

All 13 tests in `test_world_turn.lua` validate:
- Port and route data loading
- Route calculations
- Turn processing and ship movement
- Fuel/hull degradation
- Arrival event generation
- Market updates

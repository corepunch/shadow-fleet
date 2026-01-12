# Shadow Fleet - Gameplay Guide

## New Features

The game now includes a full gameplay loop with ship movement, cargo trading, and turn-based mechanics!

## How to Play

### 1. View Your Fleet
Press **S** (Shipyard) to see your fleet status:
- **GHOST-01**: Currently docked at Ust-Luga
- **SHADOW-03**: At sea, carrying 500k barrels to Malta STS

### 2. Load Cargo
1. Press **H** for Harbor menu
2. Press **L** to Load cargo
3. Select a ship (must be docked at an export terminal)
4. Enter cargo amount in thousands of barrels (e.g., `50` for 50k barrels)
5. Confirm purchase (costs vary by port, typically $60/bbl at Russian terminals)

### 3. Plot a Route
1. Press **A** for Sea menu
2. Press **S** to Sail
3. Select a ship to depart
4. Choose destination from available routes
5. Review departure summary (distance, risk, cargo)
6. Confirm departure

### 4. Advance Time
Press **T** to end turn and advance time by one day:
- Ships at sea move closer to destinations
- Fuel and hull degrade gradually
- Market prices fluctuate
- Heat naturally decreases
- Date advances

**Note**: After each turn, press any key to acknowledge and continue.

### 5. Sell Cargo
When a ship arrives at its destination:
1. Press **H** for Harbor menu
2. Press **U** to Unload cargo
3. Select ship with cargo
4. Review sale details (price varies by destination)
5. Confirm sale to receive payment

**Warning**: Selling cargo increases heat level!

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
1. Check fleet (S) - see GHOST-01 docked at Ust-Luga
2. Load cargo (H → L → 1 → 50 → Y) - load 50k barrels for 3M rubles
3. Plot route (A → S → 1 → 2 → Y) - send to Skaw STS (2 days)
4. Wait 2 turns (T → [any key] → T → [any key])
5. Ship arrives! Event shows: "GHOST-01 has arrived at Skaw STS"
6. Sell cargo (H → U → 1 → Y) - sell for ~68/bbl = 3.4M rubles
7. Profit: 400k rubles! (Heat increased to 1/10)
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

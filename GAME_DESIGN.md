# Shadow Fleet - Game Design Document

## Overview

**Shadow Fleet** is a text-based strategy game inspired by the classic **Ports of Call**, but with a modern twist focusing on the illegal Russian Shadow Fleet operations. Players manage a fleet of tankers evading international sanctions while trying to maximize profits and avoid detection.

The game follows the **Trade Wars 2002** pattern for interface design, using a BBS Door-style text interface with hotkey navigation for rapid gameplay.

## Game Concept

### Theme
You play as an operator managing a shadow fleet of oil tankers in 2026, navigating the complex world of sanctions evasion. Your goal is to transport Russian crude oil to willing buyers (India, China, others) while avoiding detection by NATO patrols, satellite surveillance, and international authorities.

### Inspiration
- **Ports of Call**: Ship trading and management mechanics
- **Trade Wars 2002**: Text-based interface, turn-based gameplay, economic simulation
- **Real-world events**: Based on actual shadow fleet operations evading Russian oil sanctions

### Core Gameplay Loop
1. **Review Status**: Check fleet, market prices, and pending events
2. **Make Decisions**: Buy/upgrade ships, plot routes, set cargo, evade detection
3. **Execute Actions**: Process choices and move to next turn
4. **Handle Events**: Respond to random events and challenges
5. **Manage Heat**: Balance profit-making with staying under the radar

---

## Screen System

The game is organized into multiple screens accessible via hotkey navigation. Each screen displays relevant information and provides action menus.

### Main Dashboard Screen

**Purpose**: Primary game hub showing overall status and quick access to all game functions.

**Display Elements**:
```
================================================================================
PORTS OF CALL: SHADOW FLEET - TEXT PROTOTYPE
================================================================================
5,000,000 / 0 Weeks / 0 Yrs.
[Dark Terminal v0.1] - Rogue Operator Mode | Heat: LOW (0/10)
Moscow Safehouse - Jan 08, 2026 | Oil Stock: 0k bbls

--- FLEET STATUS ---
Name        Age  Hull  Fuel  Status   Destination          ETA    
----------- ---- ----- ----- -------- -------------------- -------
GHOST-01    22y  65%   80%   Docked   -                           
SHADOW-03   18y  72%   45%   At Sea   STS off Malta        2 days 

Total Fleet: 2/50 | Avg Age: 20y | Uninsured Losses: 0

MAIN MENU
═══════════════
(T) end Turn
(Q) Quit
(B) Ship Broker

Enter command:
```

**Note**: The fleet status table is condensed to fit within 80 characters (66 chars actual width). Full ship and cargo details are shown on ship action/event screens using detailed info panels.

**User Actions**:
- Press hotkey (B/T/Q) to navigate to submenus or perform actions
- Dashboard refreshes after returning from submenus
- Turn advances through (T) end Turn command

**Color Coding**:
- Header: Bright Red
- Money values: Bright Yellow
- Ship names: Bright Cyan
- Status indicators: Green (good) / Yellow (warning) / Red (danger)
- Heat meter: Color-coded by danger level

---

### Ship Broker Screen (B)

**Purpose**: Buy and sell ships.

**Display Elements**:
```
--- FLEET STATUS ---
(Shows current fleet table)

BROKER MENU
═══════════════
(V) View
(B) Buy
(S) Sell
(X) eXit

Enter command:
```

**Submenu Actions**:
- **(V) View**: View ships (implicit - fleet shown on screen)
- **(B) Buy**: Purchase new tankers (from market or black market auctions)
- **(S) Sell**: Sell old ships for parts
- **(X) eXit**: Return to main menu

**What's Shown**:
- Ship name, age, hull condition (%), fuel level (%)
- Current status (Docked, At Sea, In Port, Seized, etc.)
- Cargo type and quantity
- Origin port and destination
- ETA (estimated time of arrival)
- Current risk level and active evasion measures

**Color Coding**:
- Hull/Fuel: Green (70%+) / Yellow (30-70%) / Red (<30%)
- Risk: Green (None/Low) / Yellow (Medium) / Bright Yellow (High)

---

### Port Operations Screen (Ship Action Screen)

**Purpose**: Manage ships at port - available after ship arrivals or via Ship Broker submenu.

**Display Elements**:
```
--- SHIP ACTION: SHADOW-03 ---

--- SHIP DETAILS ---
Schiff: SHADOW-03
vOn: Ust-Luga (RU)
mit: 500k bbls Crude
Zustand: 72.00%
Bunker: 45.00%
Alter: 18y
Kapazität: 500k bbls
Nach: STS off Malta
ETA: 2 days
Risiko: MED (Satellite Surveillance, NATO Patrol)

--- PORT DETAILS ---
STS off Malta
Region: Mediterranean
Typ: sts
Ölpreis: $70/bbl
Routen: 3

--- ACTIONS ---
(R) Repair
(F) Refuel
(C) Charter (Plot Route)
(L) Load Cargo
(U) Unload Cargo
(D) Depart
(X) Done

Enter command:
```

**Note**: This screen uses "Ports of Call" style detailed panels showing comprehensive ship and port information. All cargo, origin, destination, risk, and threat data that was removed from the condensed main fleet view is displayed here.

**Submenu Actions**:
- **(R) Repair**: Repair hull damage (not yet implemented)
- **(F) Refuel**: Refuel the ship (not yet implemented)
- **(C) Charter**: Plot route for ship (calls routes_presenter.plot_route)
  - Select destination port
  - Choose route (displays distance, risk)
  - Confirm departure
- **(L) Load Cargo**: Buy and load cargo onto ship (calls routes_presenter.load_cargo)
  - Enter cargo amount in thousands of barrels
  - Pay for cargo at current port oil price
  - Limited by ship capacity
- **(U) Unload Cargo**: Sell cargo at current port (calls routes_presenter.sell_cargo)
  - Select ship with cargo
  - View market price
  - Confirm sale
  - Receive payment in rubles
  - Increases heat
- **(Y) laY up**: Mothball ship (not yet implemented)
- **(D) Depart**: Plot route and immediately exit (same as Charter but exits after)
- **(X) Done**: Return to previous screen

---

### Navigation Screen (Not in current implementation)

**Note**: Navigation is currently handled through the Port Operations screen's Charter (C) and Depart (D) options, which call `routes_presenter.plot_route`.

**When plotting a route** (via Charter or Depart in Port Operations):
1. Select a docked ship from those available at port
2. Choose destination port from available destinations
3. View route details (distance in days, risk level)
4. Check fuel requirements
5. Confirm departure
6. Ship departs immediately (status changes to "at_sea")

---

### Evasion Tactics Screen (Not currently accessible)

**Purpose**: Use various methods to avoid detection and reduce heat (planned feature).

**Planned Actions**:
- **(A) Spoof AIS**: Falsify ship's Automatic Identification System (not yet implemented)
- **(F) Flag Swap**: Change ship's registered flag (not yet implemented)
- **(I) Bribe**: Pay off officials for reduced scrutiny (not yet implemented)

**Note**: Evasion mechanics are registered in the command system but not yet implemented with actual functionality.

---

### Events Screen (Not currently accessible)

**Purpose**: Handle random events and pending decisions (planned feature).

**Planned Actions**:
- **(R) Resolve Pending Dilemmas**: Handle pending events (not yet implemented)

**Note**: Event system is registered but not yet implemented with actual functionality. Events are displayed in initial game state but cannot be interacted with yet.

---

### Market Screen (Not currently accessible)

**Purpose**: Check prices, speculate on futures, and find deals (planned feature).

**Planned Actions**:
- **(P) Prices**: View current oil prices by location (not yet implemented)
- **(S) Speculate**: Bet on price movements (not yet implemented)
- **(A) Auction**: Browse black market ship auctions (not yet implemented)

**Note**: Market operations are registered but not yet implemented. Price information is shown in world data and used by the cargo loading/selling functions.

---

### Office Screen (Not currently accessible)

**Purpose**: View statistics, fleet overview, news, and market information (planned feature).

**Planned Actions**:
- **(S) Statistics**: View game statistics (not yet implemented)
- **(F) Fleet**: Fleet overview (not yet implemented)
- **(N) News**: Latest news updates (not yet implemented)
- **(M) Market**: Market prices (not yet implemented)

**Note**: Office functions are registered but not yet implemented. Status information is shown on the main dashboard.

---

### Help Screen (Not currently accessible)

**Purpose**: Explain game mechanics and commands (planned feature).

**Planned Actions**:
- **(C) Command Details**: Show help information (not yet implemented)

**Note**: Help system is registered but not yet implemented.

---

## "End Turn" Mechanics

Shadow Fleet uses an **explicit turn-based system** where the player must press (T) to end the turn and advance time.

### Turn Progression

The turn advances when the player presses **(T) end Turn** from the main menu. This triggers the `turn.process()` function which:

1. **Ship Movement**: Ships at sea move closer to destination
   - Days remaining decreases by 1
   - ETA updates
   - Ships arriving at destination change status to "in_port"
   
2. **Resource Consumption**:
   - Fuel consumption: `1 + (ship.age / 100)` percent per day
   - Hull degradation: `0.1 + (ship.age / 200)` percent per day
   
3. **Market Updates**:
   - Oil prices fluctuate (-3% to +3%)
   - Demand levels change randomly (20% chance)
   - Baltic export volume varies slightly
   
4. **Heat Management**:
   - Natural heat decay: -1 per turn (if heat > 0)
   
5. **Date Advancement**:
   - Game date advances by 1 day
   - Turn counter increments
   
6. **Event Generation**:
   - Ship arrival events generated when ships reach destination
   - Player is shown ship action screen to handle arrived ships

### Ship Arrival Handling

When a ship arrives at port after turn processing:
- An arrival event is generated
- The ship action screen appears automatically
- Player can load/unload cargo, repair, refuel, or plot next route
- After handling the ship, control returns to main menu

### What Happens During Turn Processing

When the turn advances, the following occurs in sequence:

#### 1. Ship Movement
- Ships at sea move closer to destination
- Fuel consumption calculated based on distance
- ETA reduced by 1 day/turn
- Ships arriving at destination change status to "In Port"

#### 2. Random Events Generation
- Event probability check (10-30% per turn)
- Event type determined (pending/opportunity/news)
- Event details generated based on current game state
- Events added to active events list

#### 3. Market Updates
- Oil prices fluctuate (+/- 5-15%)
- Demand levels change based on global factors
- Sanctions alerts updated
- News ticker refreshed

#### 4. Heat Decay/Increase
- Natural heat decay: -1 per turn (if no risky actions)
- Heat increases from recent risky actions applied
- Heat events triggered at certain thresholds:
  - Heat 5+: Increased patrol scrutiny
  - Heat 7+: Ship inspection events
  - Heat 9+: Risk of seizures

#### 5. Time Progression
- Game date advances (1 turn = 1 day)
- Ship ages increment (1 turn = 1 day, aging happens yearly)
- Contract deadlines checked
- Time-sensitive events expire

#### 6. Financial Updates
- Operational costs deducted (crew wages, maintenance)
- Interest/penalties applied if in debt
- Automatic expenses processed

#### 7. Ship Status Updates
- Hull condition decay (older ships degrade faster)
- Equipment wear and tear
- Crew morale changes
- Ships at sea may encounter events:
  - Weather damage (hull loss)
  - Mechanical failures
  - Patrol encounters
  - Piracy (rare)

### Event System Details

Events are the primary source of unpredictability and challenge in the game.

#### Event Categories

**1. Crew Events**
- Mutiny risk (low morale ships)
- Crew desertion (dangerous routes)
- Crew bonus requests
- Medical emergencies

**2. Ship Events**
- Equipment failure (engine, radar, AIS)
- Hull damage (weather, collision)
- Fuel leak (cargo contamination)
- Navigation system failure

**3. Authority Events**
- Patrol encounter (chance to evade or be boarded)
- Satellite surveillance alert
- Port inspection (bribe or comply)
- Ship blacklisting (sanctions list)

**4. Market Events**
- Price spikes (supply disruption)
- Price crashes (oversupply)
- New sanctions (route closures)
- Competitor dumping (price wars)

**5. Opportunity Events**
- Black market auctions (cheap ships)
- Information brokers (patrol routes)
- Corrupt officials (bypass inspections)
- Lucrative one-time contracts

**6. News Events**
- Geopolitical developments
- NATO activity updates
- Sanctions enforcement changes
- Industry news

#### Event Resolution

Each event type has specific resolution mechanics:

**Pending Events** (require decision):
- Player chooses option (Y/N or multiple choice)
- Immediate consequences applied
- Delayed consequences scheduled for future turns
- Some events have cascading effects

**Opportunity Events** (optional):
- Player can accept or decline
- Accepting costs resources (money, heat, etc.)
- Benefits applied immediately or over time
- Limited time window (expires after 1-3 turns)

**News Events** (informational):
- No player action required
- May affect market prices or heat mechanics
- Provides strategic information
- Can hint at upcoming events

#### Event Probability

Events are generated based on:
- **Base probability**: 10-30% per turn
- **Heat level modifier**: Higher heat = more authority events
- **Fleet size modifier**: More ships = more events
- **Route risk modifier**: Dangerous routes = more encounters
- **Game progression**: Later game = more complex events

---

## Game State and Persistence

### Core Game State

The game maintains the following state information:

**Player Resources**:
- Rubles (currency)
- Oil stock (barrels not yet sold)
- Location (current operation base)
- Game date

**Fleet Data** (per ship):
- Name (player-assigned or default)
- Age (years)
- Hull condition (0-100%)
- Fuel level (0-100%)
- Status (Docked, At Sea, In Port, Under Inspection, Seized)
- Current cargo (type and quantity)
- Origin port
- Destination port
- ETA (turns remaining)
- Active evasion measures
- Risk level

**Market Data**:
- Crude oil price cap (reference price)
- Shadow fleet markup percentage
- Effective shadow price
- Demand level (Low/Medium/High)
- Baltic export volume
- Current sanctions alerts
- News ticker

**Heat Meter**:
- Current heat level (0-10)
- Maximum heat (10)
- Heat trend (increasing/stable/decreasing)

**Active Events**:
- Event type (Pending/Opportunity/News)
- Event description
- Event options
- Event expiration (turns remaining)

### Future Persistence (Not Yet Implemented)

- Save game to file
- Load game from file
- Multiple save slots
- Auto-save on turn end
- High score tracking

---

## Win/Loss Conditions

### Victory Conditions (Future Implementation)

Potential win conditions being considered:

1. **Wealth Victory**: Accumulate 100M rubles
2. **Fleet Victory**: Own 25 ships successfully operating
3. **Longevity Victory**: Survive 365 turns (1 game year)
4. **Reputation Victory**: Complete major contracts successfully

### Loss Conditions (Future Implementation)

Ways to lose the game:

1. **Bankruptcy**: Rubles drop below -5M with no assets
2. **Complete Seizure**: All ships seized by authorities
3. **Maximum Heat**: Heat stays at 10 for 5 consecutive turns (total crackdown)
4. **Catastrophic Event**: Certain events can end the game

### Current Game Mode

The current prototype has **no formal win/loss conditions**. It's a sandbox for testing mechanics and gameplay flow. Players can continue indefinitely, experimenting with different strategies.

---

## User Interface Design Principles

### BBS Door Style

The game follows classic BBS Door conventions:

**Sequential Output**:
- Text flows top to bottom
- No cursor repositioning during input
- Clear screen only on major transitions
- Scrolling terminal content

**Hotkey Navigation**:
- Single-character commands (no Enter required)
- Letter keys for menu options
- Consistent hotkeys across menus
- B = Back, Q = Quit

**Visual Design**:
- ANSI color codes for emphasis
- Box drawing with ASCII characters (=, -, |)
- Color-coded status indicators
- Minimal animation (none in prototype)

### Color Scheme

Standard color coding throughout the game:

- **Bright Red**: Danger, warnings, critical alerts
- **Bright Yellow**: Money, prices, important values
- **Bright Green**: Success, good status, profit
- **Bright Cyan**: Ship names, headings
- **Cyan**: Secondary headings, neutral info
- **White**: Normal text, descriptions
- **Yellow**: Warnings, medium priority
- **Green**: Good status, safe conditions
- **Red**: Bad status, danger

### Information Density

Screens balance information density with readability:

- **Dashboard**: High density (all key info visible)
- **Fleet**: Medium density (tabular data)
- **Submenus**: Low density (focus on specific tasks)

### Responsiveness

The interface prioritizes responsiveness:

- Instant feedback on hotkey press
- Minimal waiting between screens
- Clear indication when processing
- No unnecessary delays

---

## Gameplay Progression

### Early Game (Turns 1-50)

**Focus**: Learning mechanics, building initial fleet

**Typical Activities**:
- Operate 1-3 ships
- Simple routes (Russian ports to known buyers)
- Build capital through basic trading
- Learn heat management
- Experience common events

**Challenges**:
- Limited capital for growth
- Learning which routes are profitable
- Understanding heat mechanics
- Managing fuel and repairs

### Mid Game (Turns 51-200)

**Focus**: Fleet expansion, optimization

**Typical Activities**:
- Operate 5-15 ships
- Complex route planning (STS transfers, multi-leg)
- Use advanced evasion tactics
- Handle multiple simultaneous events
- Compete with market changes

**Challenges**:
- Managing larger fleet
- Balancing profit vs. risk
- Dealing with increased scrutiny
- Handling multiple ships in transit
- Market volatility

### Late Game (Turns 201+)

**Focus**: Empire management, high-stakes operations

**Typical Activities**:
- Operate 20+ ships
- Sophisticated smuggling networks
- Major contract fulfillment
- Strategic market manipulation
- Dealing with persistent heat

**Challenges**:
- Keeping heat manageable with large operations
- Avoiding catastrophic events
- Maintaining profitability despite scrutiny
- Managing aging fleet
- Handling complex event chains

---

## Technical Implementation Notes

### Current Architecture

**Modular Design**:
- `terminal/` - ANSI terminal control library
- `ui/` - Reusable UI widgets
- `game/` - Game state and logic
- `main.lua` - Main game loop and screens

**Key Components**:
- Terminal initialization/cleanup
- Color management system
- Input handling (single-character read)
- Game state structure
- Event system (basic implementation)
- Menu navigation system

### Code Structure

**Main Game Loop** (`main.lua`):
1. Initialize terminal
2. Create game state
3. Enter main loop:
   - Render dashboard
   - Read input
   - Process command
   - Handle submenu if needed
   - Repeat until quit
4. Cleanup terminal

**Screen Rendering**:
- Each screen has dedicated rendering function
- Uses color helper functions
- Appends to terminal (no clearing between actions)
- Separator lines for visual organization

**Input Handling**:
- Raw terminal mode for single-character input
- No Enter key required
- Case-insensitive (converts to uppercase)
- EOF handling for graceful exit

### Future Technical Enhancements

**Planned Features**:
- Save/load system (file-based)
- Turn counter and date tracking
- Automated turn processing
- Enhanced event system with delayed effects
- Ship movement simulation
- Market price fluctuation algorithm
- Heat decay/increase automation
- Random event generator
- Achievement tracking
- Statistics collection

**Performance Considerations**:
- Keep game state serializable (for save/load)
- Efficient screen rendering (avoid unnecessary redraws)
- Fast input response time
- Minimal memory footprint

---

## Future Expansion Ideas

### Planned Features

**1. Complete Turn System**
- Implement actual turn processing
- Automated ship movement
- Time-based events
- Turn counter display

**2. Save/Load System**
- Save game state to JSON file
- Multiple save slots
- Auto-save functionality
- Cloud save support (future)

**3. Enhanced Market Dynamics**
- Dynamic price fluctuations
- Supply/demand modeling
- Seasonal patterns
- Geopolitical events affecting prices

**4. Advanced Events**
- Event chains (consequences lead to new events)
- Timed events (must respond within X turns)
- Random encounters at sea
- Story-driven event arcs

**5. Ship Management Depth**
- Ship naming by player
- Detailed upgrade system
- Crew management (hiring, training, morale)
- Ship customization

**6. Strategic Layer**
- Competing shadow fleet operators
- AI competitors
- Market manipulation tactics
- Information warfare

**7. Multiplayer Considerations**
- Turn-based multiplayer (BBS door style)
- Shared market
- Player vs. player competition
- Cooperative contracts

### Potential Enhancements

**UI Improvements**:
- Map view (ASCII art map of routes)
- Charts and graphs (price trends, fleet stats)
- More detailed ship views
- Combat log style event history

**Gameplay Additions**:
- Insurance system
- Loan system (borrow rubles)
- Contract system (fulfill specific deliveries)
- Reputation system (affects prices and opportunities)
- Technology research (better evasion, efficiency)
- Port development (build own infrastructure)

**Realism Features**:
- Real-world port names and distances
- Actual ship types (Aframax, Suezmax, VLCC)
- Historical events integration
- Real sanctions data

---

## Design Philosophy

### Core Principles

**1. Simplicity First**
- Easy to learn, hard to master
- Clear information presentation
- No unnecessary complexity
- Intuitive navigation

**2. Risk/Reward Balance**
- High risk = high reward
- Multiple viable strategies
- Meaningful choices
- Consequences matter

**3. Emergent Gameplay**
- Simple rules create complex situations
- Player creativity encouraged
- Multiple paths to success
- Unexpected outcomes from event combinations

**4. Historical Inspiration**
- Based on real-world shadow fleet tactics
- Plausible scenarios
- Educational aspect (learn about sanctions evasion)
- Respect for serious subject matter

### Player Agency

Players should feel in control:
- Clear cause and effect
- Transparent mechanics (no hidden formulas)
- Ability to recover from mistakes
- Multiple strategic approaches

### Difficulty Balance

The game should be challenging but fair:
- Early game forgiving (learning period)
- Mid game introduces complexity
- Late game requires mastery
- Random events can help or hinder (not just punish)

---

## Conclusion

Shadow Fleet combines classic trading game mechanics with modern geopolitical themes in a text-based interface. The BBS Door-style navigation provides quick, intuitive gameplay while the deep simulation offers strategic depth.

The modular architecture allows for gradual feature expansion while maintaining a playable prototype at each stage. Current implementation focuses on core UI and navigation, with game mechanics ready for incremental enhancement.

Future development will add turn processing, complete event system, save/load functionality, and enhanced market dynamics to create a full strategic trading simulation.

---

## Appendix: Reference Information

### Hotkey Quick Reference

**Main Menu**:
- B = Ship Broker (buy/sell ships)
- T = end Turn
- Q = Quit

**Ship Broker Submenu**:
- V = View (implicit - fleet shown on screen)
- B = Buy ships
- S = Sell ships
- X = eXit/back to main menu

**Port Operations Screen** (triggered by ship arrival events):
- R = Repair (not yet implemented)
- F = Refuel (not yet implemented)
- C = Charter (Plot Route) - calls routes_presenter.plot_route
- L = Load Cargo (buy oil) - calls routes_presenter.load_cargo
- U = Unload Cargo (sell cargo) - calls routes_presenter.sell_cargo
- Y = laY up (mothball ship, not yet implemented)
- D = Depart (plot route and exit)
- X = Done/back

**Planned Submenus** (registered but not yet accessible):
- Navigate: V (View), S (Sail - plot route), X (eXit)
- Evade: A (Spoof AIS), F (Flag Swap), I (brIbe), X (eXit)
- Events: R (Resolve), X (eXit)
- Market: P (Prices), S (Speculate), A (Auction), X (eXit)
- Office: S (Statistics), F (Fleet), N (News), M (Market), X (eXit)
- Help: C (Command details), X (eXit)

### Ship Status Values

**Status Types**:
- Docked = At port, can load cargo and depart
- At Sea = En route to destination
- In Port = Arrived at destination, can sell cargo
- Under Inspection = Stopped by authorities
- Seized = Confiscated (lost)
- Repairing = In drydock for maintenance

**Risk Levels**:
- None = No active threats
- LOW = Minimal scrutiny (1-2 threat points)
- MED = Moderate attention, evasion recommended (3-4 threat points)
- HIGH = Active surveillance, dangerous (5+ threat points)

**Threat Types** (each contributes to overall risk):
- AIS Scrutiny (1 point) = Authorities monitoring AIS signals
- NATO Patrol (1 point) = Active NATO naval patrols in area
- Satellite Surveillance (1 point) = Overhead satellite monitoring
- Coast Guard (1 point) = Coast guard vessels in vicinity
- Port Inspection (2 points) = High probability of inspection at port
- Sanctions Enforcement (2 points) = Active sanctions enforcement operations

Ships display both the calculated risk level and active threats for better situational awareness.

### Market Locations

**Russian Export Terminals**:
- Ust-Luga (Baltic)
- Novorossiysk (Black Sea)
- Primorsk (Baltic)
- Kozmino (Pacific)

**STS Transfer Points**:
- Off Malta (Mediterranean)
- Laconian Gulf (Greece)
- Ceuta (Spain)
- Skaw (Denmark)

**Destination Markets**:
- India (various ports)
- China (various ports)
- Turkey
- Undisclosed buyers

### Evasion Tactics Reference

**AIS Spoofing**:
- Cost: 50k-100k rubles
- Duration: 1-3 turns
- Effect: False location/identity broadcast
- Detection risk: Medium

**Flag Swapping**:
- Cost: 100k-500k rubles
- Duration: Permanent (until next swap)
- Effect: Change ship registry
- Popular flags: Panama, Liberia, Marshall Islands

**Bribes**:
- Cost: 100k-1M rubles
- Duration: Immediate
- Effect: Reduce heat, avoid inspection
- Location dependent

**Ship-to-Ship (STS) Transfers**:
- Cost: Transfer fees (50k-200k)
- Duration: 1 turn
- Effect: Obscure cargo origin
- Regulatory gray area

---

*This design document is a living document and will be updated as the game evolves.*

**Last Updated**: January 2026
**Version**: 1.0 (Initial Prototype)

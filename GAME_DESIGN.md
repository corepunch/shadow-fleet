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
[Dark Terminal v0.1] - Rogue Operator Mode | Heat: LOW (0/10)
Moscow Safehouse - Jan 08, 2026 | Rubles: 5,000,000 | Oil Stock: 0k bbls

--- MARKET SNAPSHOT ---
Crude Price Cap: $60/bbl | Shadow Markup: +25% ($75/bbl to India/China)
Demand: HIGH (Baltic Exports: 4.1M bbls/day) | Sanctions Alert: EU Patrols Up 15%
News Ticker: "NATO eyes 92 new blacklisted hulls. Stay dark, comrades."

--- ACTIVE EVENTS ---
- Pending: Crew Mutiny Risk on GHOST-01 (Resolve? Y/N)
- Opportunity: Shady Auction - Buy "RUST-07" (Age 28y, 1M bbls cap) for 2M Rubles?

--- HEAT METER ---
[||||||||||] 0/10 - No eyes on you yet. One slip, and drones swarm.

--- QUICK ACTIONS ---
(F) Fleet
(P) Port
(N) Navigate
(E) Evade
(V) Events
(M) Market
(S) Status
(T) end Turn
(?) Help
(Q) Quit

Enter command:
```

**User Actions**:
- Press hotkey (F/P/N/E/V/M/S/T/?/Q) to navigate to submenus
- Dashboard refreshes after returning from submenus
- Turn advances through specific actions or explicit "end Turn" command

**Color Coding**:
- Header: Bright Red
- Money values: Bright Yellow
- Ship names: Bright Cyan
- Status indicators: Green (good) / Yellow (warning) / Red (danger)
- Heat meter: Color-coded by danger level

---

### Fleet Management Screen (F)

**Purpose**: View and manage your fleet of tanker ships.

**Display Elements**:
```
--- FLEET STATUS ---
Name        Age Hull  Fuel  Status     Cargo             Origin              Destination             ETA     Risk
--------------------------------------------------------------------------------
GHOST-01    22y 65%   80%   Docked     Empty             Ust-Luga (RU)       -                       -       None
SHADOW-03   18y 72%   45%   At Sea     500k bbls Crude   Ust-Luga            STS off Malta           2 days  MED (AIS Spoof Active)

Total Fleet: 2/50 | Avg Age: 20y | Uninsured Losses: 0

--- FLEET MENU ---
(V) View
(Y) Buy
(U) Upgrade
(S) Scrap
(B) Back

Enter command:
```

**Submenu Actions**:
- **(V) View**: Detailed view of individual ship stats
- **(Y) Buy**: Purchase new tankers (from market or black market auctions)
- **(U) Upgrade**: Improve hull, fuel capacity, or add evasion equipment
- **(S) Scrap**: Sell old ships for parts

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

### Port Operations Screen (P)

**Purpose**: Manage cargo and port-based activities for ships at port.

**Display Elements**:
```
--- PORT MENU ---
(L) Load Cargo
(S) Sell Cargo
(U) Launder Oil
(B) Back

Enter command:
```

**Submenu Actions**:
- **(L) Load Cargo**: Buy and load cargo onto docked ships
  - Select ship at port
  - Choose cargo type (crude oil, refined products)
  - Specify quantity (limited by ship capacity)
  - Pay for cargo at current market price
  
- **(S) Sell Cargo**: Sell oil cargo at current port
  - Select ship with cargo at port
  - View current market price (varies by location and demand)
  - Choose quantity to sell
  - Receive payment in rubles
  - Increases heat based on volume and location
  
- **(U) Launder Oil**: Use shell companies and transfers to obscure cargo origin
  - Costs money but reduces heat
  - Allows selling at higher prices
  - Multiple laundering increases effectiveness

**What to Do**:
1. Select ship at port
2. Load cargo (buy oil)
3. Optionally launder oil to reduce heat
4. Sell cargo when at destination port
5. Manage proceeds (reinvest or save)

---

### Navigation Screen (N)

**Purpose**: Plot routes and plan ship movements.

**Display Elements**:
```
--- NAVIGATE MENU ---
(P) Plot Ghost Path
(B) Back

Enter command:
```

**Submenu Actions**:
- **(P) Plot Ghost Path**: Select ship, origin, destination, and evasion tactics
  - Choose from available ports (Russian export terminals, STS locations, destination ports)
  - Select route type: Direct (fast, risky) or Indirect (slow, safer)
  - Distance affects fuel consumption and time
  - Ship departs on next turn

**What to Do**:
1. Select a docked ship
2. Choose destination port or STS (Ship-to-Ship) transfer location
3. Decide on route type and evasion tactics
4. Confirm route to queue ship for departure
5. Ship departs when turn advances

---

### Evasion Tactics Screen (E)

**Purpose**: Use various methods to avoid detection and reduce heat.

**Display Elements**:
```
--- EVADE MENU ---
(A) Spoof AIS
(F) Flag Swap
(I) Bribe
(B) Back

Enter command:
```

**Submenu Actions**:
- **(A) Spoof AIS**: Falsify ship's Automatic Identification System
  - Costs: 50k-100k rubles
  - Duration: 1-3 turns
  - Risk reduction: Medium
  - Can backfire if detected
  
- **(F) Flag Swap**: Change ship's registered flag
  - Costs: 100k-500k rubles
  - Duration: Permanent until next swap
  - Risk reduction: High
  - Limits: Some flags more suspicious than others
  
- **(I) Bribe**: Pay off officials for reduced scrutiny
  - Costs: Variable (100k-1M rubles)
  - Effect: Reduces heat by 1-3 points
  - Location dependent

**What to Do**:
1. Monitor heat level
2. Choose appropriate evasion tactic based on situation
3. Pay costs
4. Apply to specific ships or general operations
5. Effects apply on next turn

---

### Events Screen (V)

**Purpose**: Handle random events and pending decisions.

**Display Elements**:
```
--- EVENTS MENU ---
(R) Resolve Pending Dilemmas
(B) Back

Enter command:
```

**Event Types**:
1. **Pending Events**: Require player decision
   - Crew mutiny (pay bonus or risk desertion)
   - Equipment failure (repair or risk breakdown)
   - Inspection warning (evade or bribe)
   
2. **Opportunity Events**: Optional choices
   - Black market auctions
   - Information about patrol routes
   - Corrupt officials offering deals
   
3. **News Events**: Information only
   - Market changes
   - New sanctions
   - Competition activity

**What to Do**:
1. Review all pending events
2. Make decision for each (Y/N or multiple choice)
3. Face consequences on next turn
4. Some events have time limits

---

### Market Screen (M)

**Purpose**: Check prices, speculate on futures, and find deals.

**Display Elements**:
```
--- MARKET MENU ---
(C) Check Prices
(P) Speculate
(A) Auction Dive
(B) Back

Enter command:
```

**Submenu Actions**:
- **(C) Check Prices**: View current oil prices by location
  - Russian export terminals: Base price
  - STS transfer points: +10-15%
  - Final destination ports: +20-30%
  - Price cap reference ($60/bbl)
  - Shadow fleet markup (typically +25%)
  
- **(P) Speculate**: Bet on price movements (future feature)
  - Buy/sell futures contracts
  - Risk/reward mechanism
  
- **(A) Auction Dive**: Browse black market ship auctions
  - Old tankers at discount prices
  - Unknown condition (gamble)
  - May have hidden issues

**What's Shown**:
- Current crude oil prices by market
- Price trends (up/down/stable)
- Demand levels (low/medium/high)
- Sanctions alerts affecting prices
- Available ships at auction

---

### Status Screen (S)

**Purpose**: Quick overview and news updates.

**Display Elements**:
```
--- STATUS MENU ---
(R) Quick Recap
(N) News Refresh
(B) Back

Enter command:
```

**Submenu Actions**:
- **(R) Quick Recap**: Summary of your current position
  - Total assets (rubles + ship values + cargo)
  - Fleet statistics
  - Recent profit/loss
  - Heat level and trend
  
- **(N) News Refresh**: Latest developments
  - Market news
  - Sanctions updates
  - Competitor activity
  - Patrol warnings

**What's Shown**:
- Financial summary
- Fleet health overview
- Recent transactions
- News ticker items
- Warnings and alerts

---

### Help Screen (?)

**Purpose**: Explain game mechanics and commands.

**Display Elements**:
```
--- HELP MENU ---
(C) Command Details
(B) Back

Enter command:
```

**Content**:
- Explanation of all hotkeys
- Gameplay mechanics overview
- Tips for successful operations
- Risk management advice
- Heat meter explanation

---

## "End Turn" Mechanics

Unlike traditional turn-based games, Shadow Fleet uses **action-based turn progression**. The turn advances automatically when certain actions are taken, simulating the passage of time.

### Turn-Advancing Actions

The following actions advance the game turn:

1. **Ship Departures**: When a ship departs from port
2. **Cargo Sales**: When oil is sold
3. **Evasion Tactics**: Some tactics (bribes, flag swaps) advance time
4. **Event Resolutions**: Resolving certain events progresses the turn
5. **Explicit Wait**: (Future feature) Player can choose to "wait" and skip turn

### Non-Advancing Actions

These actions do **not** advance the turn:

- Viewing screens and menus
- Checking prices and status
- Reading news
- Plotting routes (without execution)
- Browsing auctions (without purchase)

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
- F = Fleet management
- P = Port operations
- N = Navigate (route planning)
- E = Evasion tactics
- V = Events (pending dilemmas)
- M = Market information
- S = Status overview
- T = end Turn
- ? = Help
- Q = Quit

**Submenus**:
- B = Back to main menu
- Q = Back to main menu (alternative)
- Letter keys = Submenu-specific actions

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
- LOW = Minimal scrutiny
- MED = Moderate attention, evasion recommended
- HIGH = Active surveillance, dangerous
- CRITICAL = Imminent seizure risk

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

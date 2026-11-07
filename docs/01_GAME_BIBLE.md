# 01 GAME BIBLE

Version 1.1 | 2026-11-07 | Owner: Chat 00
Numbers are in `03_DATA_STARTER.md`. Formulas are in `02_TECH_SPEC.md`. Rule IDs (like R-TIDE-1) can be quoted in chats.

---

## 1. Vision and pillars

**Pitch:** Build a floating-island city. The sea changes your map every few hours. Plan a flexible town, sail trade routes, and grow a crew.

| Pillar | Meaning |
|---|---|
| P1 Living grid | Every tile works differently in each tide phase. The town is never "finished". |
| P2 Choice, not punishment | Tides give new options. They never destroy or steal. |
| P3 Cozy and clear | Bright, friendly, easy to read. One idea per screen. |
| P4 Return at the right time | The tide clock gives players a reason to come back 3 to 5 times a day. |
| P5 Collect and grow | Crew, islands, and tech give long-term goals. |

**Audience:** Casual to mid-core mobile players who like Hay Day, Township, and Clash-style base building. Sessions of 2 to 5 minutes, 3 to 5 times a day.

---

## 2. Core loops

| Loop | Length | What happens |
|---|---|---|
| Micro | 30 sec | Tap to collect, start a build, move a building |
| Session | 3 min | Check tide, collect, rearrange for this phase, send boats |
| Tide | 6 hours | Each phase opens something new. Active skills reset each cycle. |
| Daily | 24 hours | 4 tide cycles, order boards refresh, daily gift |
| Long | Weeks | Harbor Hall levels, new islands, crew, tech, events |

---

## 3. Tide system rules

- **R-TIDE-1:** The tide cycle is 6 hours (21600 s). It is computed from the global clock (UTC), not saved per player. All players see the same tide.
- **R-TIDE-2:** A cycle has 4 equal phases of 1.5 h: LOW, RISING, HIGH, FALLING.
- **R-TIDE-3:** Each phase has a water index: LOW 1, RISING 2, HIGH 3, FALLING 2.
- **R-TIDE-4:** Events can change the index: Spring tide (HIGH becomes 4), Super low tide (LOW becomes 0).
- **R-TIDE-5:** A tile is **underwater** when water index > tile elevation. Otherwise it is **dry**.
- **R-TIDE-6:** The tide never destroys, damages, or removes any building, boat, or item.
- **R-TIDE-7:** The player can see the current phase, the time to the next phase, and (with Lighthouse or Navigator) a forecast.
- **R-TIDE-8:** The water look is smooth (visual only). Game logic uses the discrete index.

### Tile types

| Type | Elevation | Dry when index is | Boats (draft 1) | Notes |
|---|---|---|---|---|
| DEEP | -1 | never | always | Open sea |
| SEABED | 0 | 0 only (super low) | index 1 or more | Hidden flats show at super low tide |
| REEF | 1 | 1 (LOW) | index 2 or more | Pearls and coral |
| MUDFLAT | 2 | 1, 2 (LOW, RISING, FALLING) | index 3 or more (HIGH) | Clams, seaweed |
| SHORE | 3 | 1 to 3 (floods at spring tide) | index 4 only | Beach buildings |
| LAND | 4 | always | never | Main building area |

- **R-TILE-1:** Walkable = dry. Boat passable = underwater AND water index >= elevation + boat draft.
- **R-TILE-2:** Draft 2 boats need one more index step than draft 1 boats. DEEP works at LOW. SEABED needs index 2 or more.

---

## 4. Buildings

- **R-BLD-1:** Placement kinds: `land` (elevation 4, or 3 for some), `shore_edge` (SHORE or LAND tile touching water), `stilt` (REEF or MUDFLAT), `float` (SEABED or DEEP, later feature).
- **R-BLD-2:** `works_when`: `always`, `dry`, or `wet`. "Dry/wet" is checked against the tile under the building's **lowest** tile.
- **R-BLD-3:** **Pause-not-lose.** A building outside its working state stops making goods. Stored goods and progress stay. Never any loss.
- **R-BLD-4:** Production fills a storage cap. Player taps to collect. Full storage stops production (no loss).
- **R-BLD-5:** **Move:** any building can be moved at any time. Cost 5% of its base coin cost (min 5 coins). No wait. Progress stays. This supports the flexible-town pillar.
- **R-BLD-6:** **Remove:** sells back 50% of the coins spent on level 1. Not allowed for Harbor Hall.
- **R-BLD-7:** **Build and upgrade** need a free builder. Builders: 1 at start, 2 at Harbor Hall L3. A second builder can also be bought (gems). Builders work in real time, also offline.
- **R-BLD-8:** Costs and times grow per level using the formulas in `03`. A building level can never be higher than the Harbor Hall level allows.
- **R-BLD-9:** Max count of each building depends on Harbor Hall level (table in `03`).
- **R-BLD-10:** Buildings cannot overlap. They need all footprint tiles to match their placement kind.

---

## 5. Land reclaim

- **R-REC-1:** Needs the tech "Dikes" (see tech tree).
- **R-REC-2:** A tile can be raised one step: REEF → MUDFLAT → SHORE → LAND. Costs stone and wood. Takes time. Needs a builder.
- **R-REC-3:** It cannot be undone. Raising a tile removes its tide uses (a clam bed spot becomes plain land). This is a real choice.
- **R-REC-4:** Nothing may stand on a tile while it is being raised.

---

## 6. Sea map, boats, trade

- **R-SEA-1:** The home island is a grid. The sea map is a **graph**: islands are nodes, routes are **lanes**.
- **R-SEA-2:** A lane has: base travel time, minimum draft, allowed tide phases (windows), and a current direction.
- **R-SEA-3:** A boat can **depart** only when the lane is open in the current phase and the boat's draft is enough.
- **R-SEA-4:** **Trip time is fixed at departure.** No change during the trip (simple and fair).
- **R-SEA-5:** Currents: RISING flows from node A toward B, FALLING flows from B toward A, HIGH and LOW are slack (no flow). A trip with the flow is 30% faster. Against the flow is 30% slower. Storm events double the strength.
- **R-SEA-6:** A boat that is on the way is never blocked or lost when the window closes.
- **R-BOAT-1:** Boat types: Skiff (draft 1, small cargo), Trader (draft 2, big cargo, slower), Explorer (draft 1, tiny cargo, fast, can explore).
- **R-BOAT-2:** Each Dock gives one boat slot. Boats wait at the dock when idle.
- **R-ORD-1:** Each trade island has 3 **orders** (goods wanted). They refresh every tide cycle at LOW start. An order lasts 2 cycles.
- **R-ORD-2:** Delivering an order gives coins (base value x 1.5) and island reputation.
- **R-ORD-3:** Reputation unlocks lanes, orders of higher value, and new islands.
- **R-ORD-4:** A trip returns to the home dock with the same travel time (current may differ on return). Rewards are paid on arrival at the island.
- **R-ORD-5:** Route score = coins earned / total trip minutes. Used for the weekly challenge.
- **R-EXP-1:** Unknown islands are in fog. An Explorer boat reveals one node. Some nodes need a special tide (spring or super low).

---

## 7. Crew (characters with skills)

- **R-CREW-1:** Each crew member has a **passive** (always on when assigned) and an **active** (once per tide cycle).
- **R-CREW-2:** Active skill charges reset at the start of each tide cycle (global clock). Unused charges do not stack.
- **R-CREW-3:** Crew slots grow with Harbor Hall level: L1=1, L2=2, L3=3, L4=4, L5=5, L6 and up=6.
- **R-CREW-4:** Assign a crew member to a building or dock. The passive works for that building (or that dock's boats). Some passives are global (see `03`).
- **R-CREW-5:** Rarity: Common x1.0, Rare x1.25, Epic x1.5 on passive and active values.
- **R-CREW-6:** Levels 1 to 10. Max level is limited by Harbor Hall level. Upgrade cost: coins + pearls.
- **R-CREW-7:** Duplicates give shards. Shards upgrade rarity. No crew is ever lost.
- **R-CREW-8:** Obtain crew from: story and tutorial, Crew Quarters recruiting, sea rescue events, weekly challenge rewards.
- **R-CREW-9:** The 7 crew: Captain, Navigator, Diver, Engineer, Farmer, Merchant, Scout (details in `03`).

---

## 8. Progression

- **R-PROG-1:** Harbor Hall levels 1 to 10. v1 content covers L1 to L5 fully, L6 to L10 outlined.
- **R-PROG-2:** Harbor Hall upgrade needs resources, time, and a citizen count.
- **R-PROG-3:** **Citizens** come from homes. They also give small passive coin tax.
- **R-PROG-4:** **Tech tree** has 3 branches: Seafaring (boats and lanes), Industry (production and power), Tide Lore (forecast, reclaim, tile tools). Research points come from the Lab.
- **R-PROG-5:** New islands unlock through reputation, tech, and Harbor Hall level.

---

## 9. Events and seasons

Events come from a **fixed schedule based on the date** (no server needed for v1).

| Event | When | Effect | Reward |
|---|---|---|---|
| Spring tide | Weekly, 1 cycle | HIGH index becomes 4. Shore buildings pause. Shore and mud lanes open. | Tide chests on flooded tiles. Diver opens them. |
| Super low tide | Weekly, 1 cycle | LOW index becomes 0. Hidden seabed flats show. | Treasure on flats. Walk and collect. |
| Storm | Random day, 1 cycle | Currents x2. | Wreck loot at sea (explorer boats) |
| Moon festival | Monthly, 2 days | Market sells x1.25 | Cosmetic reward |
| Whale migration | Seasonal, 3 days | Special lane opens | Rare pearls |

- **R-EVT-1:** Events never destroy or take anything.
- **R-EVT-2:** Seasons last 28 days. Each has a theme, a free reward track, and a cosmetic.

---

## 10. Social (v1, no live PvP)

- **R-SOC-1:** **Island share code:** a text code of the home island layout. Friends can view it (read-only) and import it into a sandbox.
- **R-SOC-2:** **Weekly route challenge:** same fixed map and goods for all. Best route score wins. Needs a leaderboard backend (decided in C15).
- **R-SOC-3:** **Gift boats:** send a small crate to a friend (optional, can be cut).
- **R-SOC-4:** No chat, no guilds, no PvP in v1.

---

## 11. Economy and money rules

- **R-ECO-1:** Currencies: coins, resources, goods, pearls and coral (rare), gems (premium).
- **R-ECO-2:** **No pay-to-win.** Money may buy: time savings (builder, speed-up), cosmetics, crew packs (crew obtainable free too), storage convenience.
- **R-ECO-3:** Gems can be earned slowly for free (events, milestones).
- **R-ECO-4:** Rewarded ads are optional and never required.
- **R-ECO-5:** Target soft inflation: coins from selling are balanced by rising costs. Tune in C05 and C14 with a spreadsheet.
- **R-ECO-6:** Offline progress is capped at 48 hours.

---

## 12. First 10 minutes (FTUE script)

| Step | Player action | What the game teaches |
|---|---|---|
| 1 | Welcome. Camera shows island at LOW tide. | The map |
| 2 | Place a Hut | Placement |
| 3 | Place a Farm. Collect food. | Production |
| 4 | Time-lapse shows tide rising. Mudflats go underwater. | **The tide idea** |
| 5 | Build a Lumber Camp | Resources |
| 6 | Place a Clam Bed on mudflat at LOW. See it pause at HIGH. | Pause-not-lose |
| 7 | Build a Dock | Boats |
| 8 | Launch a Skiff to Pebble Atoll | Trade |
| 9 | Deliver first order. Meet the Captain (free crew). | Crew |
| 10 | Assign the Captain. Tutorial ends. Forecast shows next change. | Return hook |

Rules: first builds are very fast (10 to 30 s). Skip is allowed. No forced waiting in the first 10 minutes.

---

## 13. Screens and UI flow

- **Home (main):** grid, HUD top (coins, food, wood, stone, gems), tide widget top-center (phase icon, countdown), bottom bar (Build, Crew, Map, Orders, Shop).
- **Build menu:** list by category, cards with icon, cost, time, tide icon (dry/wet/always).
- **Crew screen:** list, details, assign, upgrade.
- **Sea map:** graph, lanes colored by open/closed now, boat positions, send-boat panel.
- **Orders board:** per island, cargo loader.
- **Research, Shop, Settings, Weekly challenge.**
- **Rules:** portrait only. Thumb-friendly: main buttons in the bottom 40%. Min touch target 48 dp. Never more than 3 taps to start a common action. All tide info uses **icon + color + text** (color-blind safe).

---

## 14. Fairness and anti-frustration rules

1. Nothing is ever lost to the tide, events, or offline time.
2. Every closed lane shows when it opens.
3. Idle boats and full storages never cost the player anything.
4. A "tide planner" hint shows what is best to do in the next phase.
5. Time-gated content always shows the exact time left.
6. If the device clock goes backward, the game ignores the jump (no free time, no loss).

---

## 15. Out of scope for v1

PvP raids, base defense, guilds, live chat, 3D graphics, cloud-gaming features, multiple languages (English only, but keep strings in one file), tablet layouts, web version.

---

## 16. Naming and identity

- All names, art, and UI must be original. No names or looks from other games.
- Tone: warm, a little funny, ocean-themed. Short text. Simple English.
- Working title: **Tidebound**. Final store name and trademark check is done in C18.

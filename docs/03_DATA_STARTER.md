# 03 DATA STARTER

Version 1.2 | 2026-11-06 | Owner: Chat 00
All numbers here are **v0 starter values**. They are tuned in C04, C05 and C07. Data for parked features (recipes §6, research §11, most of §9, explorer and trader boats in §8, reclaim) stays here for later (D-034). Each block below becomes a file in `data/`. Change numbers here first, then in the JSON file, then log it in `STATE.md` (DECISIONS).

---

## 1. Formulas (apply to all buildings)

```
cost(level)    = base_cost   * 1.8 ^ (level - 1)     (round up)
time(level)    = base_time_s * 2.0 ^ (level - 1)
output(level)  = base_output * 1.3 ^ (level - 1)     (round down, min 1)
cap(level)     = base_cap    * 1.3 ^ (level - 1)
max_level      = Harbor Hall level + 1, never above 10 (v1 content: up to 5)
move_cost      = max(5, 5% of base coin cost)
remove_refund  = 50% of base coin cost
```

---

## 2. `data/tuning.json`

```json
{
  "tide_cycle_s": 21600,
  "phase_s": 5400,
  "tide_epoch_unix": 0,
  "water_index": {"LOW": 1, "RISING": 2, "HIGH": 3, "FALLING": 2},
  "spring_high_index": 4,
  "super_low_index": 0,
  "offline_cap_s": 172800,
  "current_strength": 0.3,
  "storm_current_mult": 2.0,
  "min_speed_mult": 0.4,
  "tile_px": 64,
  "camera_zoom_min": 0.6,
  "camera_zoom_max": 1.6,
  "camera_margin_tiles": 2,
  "tap_max_move_px": 20,
  "water_tint_alpha_min": 0.25,
  "water_tint_alpha_max": 0.55,
  "start_resources": {"coins": 300, "wood": 50, "food": 20, "stone": 0, "gems": 0},
  "order_slots_per_island": 3,
  "order_life_cycles": 2,
  "order_reward_mult": 1.5,
  "rarity_mult": {"common": 1.0, "rare": 1.25, "epic": 1.5},
  "crew_slots_by_harbor": [1, 2, 3, 4, 5, 6, 6, 6, 6, 6],
  "builders_by_harbor": [1, 1, 2, 2, 2, 2, 2, 2, 2, 2]
}
```

---

## 3. `data/tiles.json`

```json
{
  "DEEP":    {"elevation": -1, "color": "#1d5d9b"},
  "SEABED":  {"elevation": 0,  "color": "#2b7bb9"},
  "REEF":    {"elevation": 1,  "color": "#e07a6f"},
  "MUDFLAT": {"elevation": 2,  "color": "#8a7455"},
  "SHORE":   {"elevation": 3,  "color": "#e8d9a8"},
  "LAND":    {"elevation": 4,  "color": "#7cc46a"}
}
```
Placeholder colors are for C03 (art comes in C17). Wet tiles get a blue tint overlay (D-027).

---

## 4. `data/resources.json`

| id | Type | Sell price (coins) | Notes |
|---|---|---|---|
| coins | currency | - | Main currency |
| gems | currency | - | Premium, slow free earn |
| food | raw | 2 | Farm |
| wood | raw | 3 | Lumber Camp |
| stone | raw | 4 | Quarry |
| seaweed | raw (tide) | 3 | Seaweed Bed (works wet) |
| clams | raw (tide) | 5 | Clam Bed (works dry) |
| pearls | rare | not sellable | Crew upgrades. From reef events, Diver. |
| coral | rare | not sellable | Research and decor |
| planks | goods | 12 | Workshop |
| rope | goods | 14 | Workshop |
| preserves | goods | 22 | Workshop |
| tools | goods | 40 | Workshop |

Base storage: 200 per raw resource, 50 per goods item. Warehouse adds +300 raw and +100 goods each.

---

## 5. `data/buildings.json` (v1 list)

Fields: `size` [w,h], `placement`, `works_when`, `cost`, `build_s`, `harbor_min`, `produce` {res, amount, every_s, cap}, `effects`.

```json
{
  "harbor_hall": {"name":"Harbor Hall","size":[3,3],"placement":"land","works_when":"always","cost":{},"build_s":0,"harbor_min":1,"effects":{"builders":"by_harbor","crew_slots":"by_harbor"}},
  "hut": {"name":"Hut","size":[2,2],"placement":"land","works_when":"always","cost":{"coins":50},"build_s":10,"harbor_min":1,"produce":{"res":"coins","amount":2,"every_s":600,"cap":12},"effects":{"citizens":5}},
  "house": {"name":"House","size":[2,2],"placement":"land","works_when":"always","cost":{"coins":400,"wood":40},"build_s":90,"harbor_min":4,"produce":{"res":"coins","amount":6,"every_s":600,"cap":36},"effects":{"citizens":12}},
  "farm": {"name":"Farm","size":[2,2],"placement":"land","works_when":"dry","cost":{"coins":100},"build_s":30,"harbor_min":1,"produce":{"res":"food","amount":10,"every_s":300,"cap":60}},
  "lumber_camp": {"name":"Lumber Camp","size":[2,2],"placement":"land","works_when":"always","cost":{"coins":150},"build_s":60,"harbor_min":1,"produce":{"res":"wood","amount":8,"every_s":300,"cap":48}},
  "quarry": {"name":"Quarry","size":[2,2],"placement":"land","works_when":"always","cost":{"coins":200,"wood":20},"build_s":120,"harbor_min":2,"produce":{"res":"stone","amount":6,"every_s":300,"cap":36}},
  "clam_bed": {"name":"Clam Bed","size":[1,1],"placement":"stilt","works_when":"dry","cost":{"coins":120,"wood":10},"build_s":45,"harbor_min":2,"produce":{"res":"clams","amount":4,"every_s":300,"cap":20}},
  "seaweed_bed": {"name":"Seaweed Bed","size":[1,1],"placement":"stilt","works_when":"wet","cost":{"coins":120,"wood":10},"build_s":45,"harbor_min":2,"produce":{"res":"seaweed","amount":5,"every_s":300,"cap":25}},
  "dock": {"name":"Dock","size":[2,1],"placement":"shore_edge","works_when":"always","cost":{"coins":250,"wood":30},"build_s":120,"harbor_min":1,"effects":{"boat_slots":1}},
  "market": {"name":"Market","size":[3,2],"placement":"land","works_when":"always","cost":{"coins":300,"wood":40,"stone":20},"build_s":180,"harbor_min":2,"effects":{"sell_anytime":true,"order_board":true}},
  "warehouse": {"name":"Warehouse","size":[2,2],"placement":"land","works_when":"always","cost":{"coins":200,"wood":60},"build_s":90,"harbor_min":2,"effects":{"storage_raw":300,"storage_goods":100}},
  "water_wheel": {"name":"Water Wheel","size":[2,2],"placement":"stilt","works_when":"wet","cost":{"coins":350,"wood":50,"stone":30},"build_s":240,"harbor_min":3,"effects":{"power":3}},
  "workshop": {"name":"Workshop","size":[3,3],"placement":"land","works_when":"always","cost":{"coins":600,"wood":80,"stone":60},"build_s":420,"harbor_min":3,"effects":{"power_need":2,"recipes":true}},
  "lighthouse": {"name":"Lighthouse","size":[1,1],"placement":"land","works_when":"always","cost":{"coins":500,"stone":80},"build_s":300,"harbor_min":3,"effects":{"forecast_hours":12}},
  "lab": {"name":"Lab","size":[3,3],"placement":"land","works_when":"always","cost":{"coins":2000,"wood":200,"stone":150},"build_s":1200,"harbor_min":4,"effects":{"research_points_per_600s":1}},
  "crew_quarters": {"name":"Crew Quarters","size":[3,2],"placement":"land","works_when":"always","cost":{"coins":900,"wood":120},"build_s":600,"harbor_min":4,"effects":{"recruit":true}}
}
```

Notes:
- Water Wheel power (3) is multiplied by the current flow factor: slack = 0.5, flowing = 1.0 (only while wet). Power is shared by the whole island.
- Workshop works only if total power >= total power need.
- Stilt buildings work in their `works_when` state and **pause** otherwise (R-BLD-3).

### Max count by Harbor Hall level (L1 to L5)

| Building | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| hut | 2 | 4 | 6 | 8 | 8 |
| house | 0 | 0 | 0 | 3 | 5 |
| farm | 1 | 2 | 3 | 4 | 5 |
| lumber_camp | 1 | 2 | 2 | 3 | 3 |
| quarry | 0 | 1 | 2 | 2 | 3 |
| clam_bed | 0 | 2 | 3 | 4 | 6 |
| seaweed_bed | 0 | 2 | 3 | 4 | 6 |
| dock | 1 | 1 | 2 | 2 | 3 |
| market | 0 | 1 | 1 | 1 | 1 |
| warehouse | 0 | 1 | 2 | 2 | 3 |
| water_wheel | 0 | 0 | 1 | 2 | 3 |
| workshop | 0 | 0 | 1 | 1 | 2 |
| lighthouse | 0 | 0 | 1 | 1 | 1 |
| lab | 0 | 0 | 0 | 1 | 1 |
| crew_quarters | 0 | 0 | 0 | 1 | 1 |

---

## 6. Workshop recipes (`data/recipes.json`)

| id | Input | Output | Time |
|---|---|---|---|
| planks | 2 wood | 1 planks | 180 s |
| rope | 3 seaweed | 1 rope | 240 s |
| preserves | 2 food + 1 clams | 1 preserves | 300 s |
| tools | 1 planks + 2 stone | 1 tools | 480 s |

Workshop has 1 queue slot at L1, +1 per 2 levels.

---

## 7. Harbor Hall levels (`data/harbor.json`)

| Level | Coins | Other cost | Time | Citizens needed | Unlocks |
|---|---|---|---|---|---|
| 1 | start | - | - | 0 | Hut, Farm, Lumber Camp, Dock |
| 2 | 400 | - | 60 s | 10 | Quarry, Market, Clam Bed, Seaweed Bed, Warehouse |
| 3 | 1500 | 100 wood | 10 min | 20 | Workshop, Water Wheel, Lighthouse, 2nd builder |
| 4 | 5000 | 300 wood, 200 stone | 1 h | 30 | Lab, House, Crew Quarters, Trader boat |
| 5 | 15000 | 600 wood, 400 stone, 20 planks | 4 h | 70 | Reclaim tiles (with tech), Coral Spire lane |
| 6 to 10 | outline only | | | | Filled in later by decision (Chat C14 or after) |

Citizen check: Hut = 5, House = 12. L2 needs 10 (2 huts). L3 needs 20 (4 huts at L2). L4 needs 30 (6 huts at L3). L5 needs 70 (8 huts + 3 houses = 76 at L4). Keep this chain valid when you change counts.

---

## 8. `data/boats.json`

| id | Draft | Cargo | Speed | Harbor min | Cost |
|---|---|---|---|---|---|
| skiff | 1 | 12 | 1.0 | 1 | free (first), then 200 coins + 20 wood |
| explorer | 1 | 4 | 1.3 | 3 | 800 coins + 60 wood |
| trader | 2 | 36 | 0.8 | 4 | 1500 coins + 150 wood + 10 planks |

Boat slots = number of Docks. Boats are built at a Dock (60 s for skiff).

---

## 9. `data/sea.json` (v1 start)

Nodes: `home_isle` (built grid), `pebble_atoll` (trade), `kelp_cove` (trade), `coral_spire` (locked until Harbor L5 and reputation 100 at Pebble Atoll).

| Lane id | From → To | Base time | Min draft | Open phases | Notes |
|---|---|---|---|---|---|
| home_pebble | home_isle → pebble_atoll | 480 s | 1 | all | Safe first route |
| home_kelp_strait | home_isle → kelp_cove | 300 s | 1 | RISING, HIGH, FALLING | Closed at LOW |
| home_kelp_mud | home_isle → kelp_cove | 180 s | 1 | HIGH | Shortcut over mudflats |
| pebble_coral | pebble_atoll → coral_spire | 720 s | 2 | all | Needs Trader |

Current flow per phase: LOW 0, RISING +1 (A toward B), HIGH 0, FALLING -1 (B toward A).

### Orders (`data/orders.json` rules)

| Island | Wants (goods weight) | Reputation to unlock higher orders |
|---|---|---|
| pebble_atoll | planks 40%, rope 30%, preserves 30% | 0 / 50 / 150 |
| kelp_cove | food 30%, preserves 30%, tools 40% | 0 / 60 / 180 |

Order size: 4 to 10 units at rep 0, up to 24 units at higher rep (must fit boat cargo). Reward = sum(unit sell price) x 1.5. Reputation +10 per order (+15 if delivered in the first cycle).

---

## 10. `data/crew.json`

Passive = `(base_pct + per_level_pct * (level - 1)) * rarity_mult`. Active charges: 1 per tide cycle.

| id | Role | Passive (stat) | Base % | Per level % | Active | Active effect |
|---|---|---|---|---|---|---|
| captain | Sailor | boat_speed (boats at assigned dock) | +5 | +2 | Full Sail | Next departure trip time -30% |
| navigator | Tide expert | forecast +12 h and current_strength | +10 current | +3 | Turn the Current | Make one lane's flow favorable for the next trip |
| diver | Underwater | pearl_chance (reef tiles, per cycle) | +4 | +1.5 | Deep Dive | Open one hidden underwater cache (reward roll) |
| engineer | Builder | build_time (global) | -5 | -1.5 | Quick Fix | Finish one build with 30 min or less left |
| farmer | Food | farm_yield (assigned farm) | +10 | +3 | Double Harvest | Next collect on assigned farm x2 |
| merchant | Trader | sell_price (market and orders) | +5 | +2 | Special Offer | Create one rare high-value order |
| scout | Explorer | explore_time | -10 | -3 | Spyglass | Reveal one fog node now |

Crew levels 1 to 10. Upgrade cost: `coins = 100 * 1.6^(level-1)`, `pearls = level` (from level 2). Max level = Harbor Hall level x 2, capped at 10.

Free crew: Captain (tutorial). Farmer (after first farm harvest in FTUE, or at Harbor L2). Others from Crew Quarters or events.

---

## 11. Research (`data/tech.json`, v1 outline)

Research points (RP) from the Lab. Costs rise in steps. Each tech has 1 level in v1.

| Branch | Tech | Effect | RP |
|---|---|---|---|
| Seafaring | Reinforced Hulls | +20% cargo | 3 |
| Seafaring | Trim Sails | +10% boat speed | 5 |
| Seafaring | Deep Keel | Unlock Trader | 8 |
| Industry | Better Tools | +10% all raw output | 4 |
| Industry | Efficient Wheels | +25% water wheel power | 6 |
| Industry | Second Workbench | +1 Workshop queue | 8 |
| Tide Lore | Tide Tables | Forecast +12 h | 3 |
| Tide Lore | Dikes | Unlock Reclaim | 10 |
| Tide Lore | Moon Charts | Show events 7 days ahead | 6 |

Reclaim cost: REEF→MUDFLAT 20 stone, 300 s. MUDFLAT→SHORE 50 stone + 20 wood, 900 s. SHORE→LAND 100 stone + 40 wood, 1800 s.

---

## 12. `data/islands/home_isle.json` (16 x 16)

Legend: `~` DEEP, `s` SEABED, `r` REEF, `m` MUDFLAT, `h` SHORE, `L` LAND.

```
~~~~~~~~~~~~~~~~
~~ssrrrrrrrrss~~
~srrmmmmmmmmrrs~
~srmmhhhhhhmmrs~
~rrmhhLLLLhhmrr~
~rmmhLLLLLLhmmr~
~rmhLLLLLLLLhmr~
~rmhLLLLLLLLhmr~
~rmhLLLLLLLLhmr~
~rmhLLLLLLLLhmr~
~rmmhLLLLLLhmmr~
~rrmhhLLLLhhmrr~
~srmmhhhhhhmmrs~
~srrmmmmmmmmrrs~
~~ssrrrrrrrrss~~
~~~~~~~~~~~~~~~~
```

File shape: {"id": "home_isle", "width": 16, "height": 16, "legend": {"~":"DEEP","s":"SEABED","r":"REEF","m":"MUDFLAT","h":"SHORE","L":"LAND"}, "rows": [16 strings of 16 characters], "start_harbor": {"x": 6, "y": 6}}

Start state: Harbor Hall at (6,6) (3x3 on LAND). Land is limited on purpose. Mud and reef give extra space for stilt buildings. Reclaim (Harbor L5) grows land later.




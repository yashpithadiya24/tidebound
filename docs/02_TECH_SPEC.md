# 02 TECH SPEC

Version 1.0 | 2026-11-06 | Owner: Chat 00
Game rules are in `01`. Numbers are in `03`. This file says **how** we build it.

---

## 1. Stack and settings

| Item | Choice |
|---|---|
| Engine | Godot 4.3 or newer (lock the exact version in `STATE.md` during C01) |
| Language | GDScript with static typing |
| Renderer | **Compatibility** (best reach on cheap Android phones). Revisit only if a needed effect fails. |
| Display | Portrait, base size 1080 x 1920, stretch mode `canvas_items`, aspect `expand` |
| Tiles | `TileMapLayer` (not the old `TileMap`). Tile size 64 x 64 px. |
| Tests | GUT 9.x (Godot Unit Test) |
| Version control | Git + GitHub. Branch `main` always works. Feature branch per chat: `c05-production`. |
| Build | GitHub Actions exports a debug APK (use a community Godot CI image, verify the current one in C01) |
| Cloud dev | GitHub Codespaces for scripts, docs, lint. Godot editor stays on the local laptop. |
| Min Android | API 24 (Android 7). Target latest required by Google Play (check in C18). |
| Package id | `com.<yourname>.tidebound` (set in C01) |

---

## 2. Folder layout

```
tidebound/
├── docs/                 (this Core Pack + STATE.md)
├── tools/                (repo_map.py, helper scripts)
├── data/                 (all JSON game data, see 03)
├── scenes/
│   ├── main/             (Main.tscn, boot)
│   ├── island/           (Island.tscn, camera, tile layers)
│   ├── map/              (SeaMap.tscn)
│   └── ui/               (Hud, BuildMenu, CrewScreen, Orders, Shop, Settings ...)
├── scripts/
│   ├── core/             (autoloads: Clock, EventBus, Data, Save, Game)
│   ├── tide/             (TideModel.gd, Tide.gd)
│   ├── grid/             (GridModel.gd, IslandData.gd, Placement.gd)
│   ├── buildings/        (BuildingModel.gd, ProductionSystem.gd, BuilderQueue.gd)
│   ├── economy/          (Resources.gd, Market.gd)
│   ├── sea/              (SeaGraph.gd, Boat.gd, TripPlanner.gd, Orders.gd)
│   ├── crew/             (CrewModel.gd, CrewSystem.gd, Modifiers.gd)
│   ├── progression/      (Harbor.gd, Research.gd, Reclaim.gd)
│   ├── events/           (EventSystem.gd)
│   ├── social/           (ShareCode.gd, Challenge.gd)
│   └── debug/            (DebugPanel.gd)
├── tests/                (GUT tests, mirror scripts/ names: test_tide_model.gd)
├── assets/               (art, audio, fonts; see 06)
└── addons/               (gut, plugins)
```

**File rules:** one class per file. File name = class name in PascalCase. Max about 300 lines per file. Split if bigger.

---

## 3. Architecture rules

1. **Model / view split.** Game logic lives in plain classes (`extends RefCounted`) with **no scene or node calls**. Scenes only show state and send input. This makes logic testable.
2. **Autoloads (singletons), only these:** `Clock`, `EventBus`, `Data`, `Save`, `Game`, `Tide`, `Debug`.
   - `Game` holds the live `GameState` and the systems.
3. **Event bus.** Systems talk through signals on `EventBus`. No system calls into another system's internals. Signal names are past tense: `building_placed`, `tide_phase_changed`, `order_delivered`.
4. **Time model.** No per-building `Timer` or `_process` countdowns. Every timed thing stores a **unix timestamp** (`ready_at`, `last_collect_at`). One 1 Hz tick in `Game` checks what is due. This makes offline progress easy and cheap.
5. **Data-driven.** All costs, times, stats are read from `data/*.json` through `Data`. No magic numbers in code. Global constants come from `data/tuning.json`.
6. **IDs.** Every content item has a stable string id in `snake_case` (`lumber_camp`, `captain`). Never use array indexes as ids. Never rename an id without a save migration.
7. **UI has no game rules.** UI calls system methods and shows results. A rule check (can I build here?) always lives in a system.
8. **One writer per state.** Each piece of state has one system that changes it. Others read only.

---

## 4. Time

```
Clock.now() -> int      # unix seconds UTC
```

- `Clock.now()` = system unix time + `debug_offset` (offset works **only in debug builds**).
- **Backward guard:** `Save` stores `last_seen_at`. If `now < last_seen_at`, use `last_seen_at` as now and keep it until real time catches up.
- **Offline cap:** progress after load counts at most 48 h (`tuning.offline_cap_s`).
- Debug panel must have: +1 h, +1.5 h (next phase), +6 h, reset offset, set event override. **Time travel is how we test tides.**

---

## 5. Tide math (pure, in `TideModel.gd`)

Constants from `tuning.json`: `tide_cycle_s = 21600`, `phase_s = 5400`, `tide_epoch_unix = 0`.

```
phase_index(t)   = floor(((t - epoch) mod cycle) / phase_s)      # 0 LOW, 1 RISING, 2 HIGH, 3 FALLING
phase_name(t)    = ["LOW","RISING","HIGH","FALLING"][phase_index(t)]
base_index       = [1, 2, 3, 2][phase_index]
water_index(t, event) = event override of base_index if the event applies, else base_index
   # Spring tide: if phase == HIGH then 4.   Super low: if phase == LOW then 0.
next_change(t)   = t + (phase_s - ((t - epoch) mod phase_s))
cycle_start(t)   = t - ((t - epoch) mod cycle)
is_underwater(elev, index) = index > elev
is_dry(elev, index)        = index <= elev
can_boat_pass(elev, index, draft) = is_underwater(elev, index) and index >= elev + draft
visual_level(t)  = 0.5 - 0.5 * cos(2*PI*((t - epoch) mod cycle)/cycle)   # 0..1, visuals only
```

### Active time (for pause-not-lose production)

```
active_seconds(t0, t1, predicate_on_index) -> int
```
Walk the 5400-second segments between `t0` and `t1`. For each segment, get the index (with events), and if the predicate (dry or wet for the building's tile elevation) is true, add the overlap seconds. With the 48 h cap this is at most about 33 segments, so it is cheap.

### Golden tests (must pass, UTC, epoch 0)

| t | Expected phase | Index |
|---|---|---|
| 0 | LOW | 1 |
| 5399 | LOW | 1 |
| 5400 | RISING | 2 |
| 10800 | HIGH | 3 |
| 16200 | FALLING | 2 |
| 21600 | LOW | 1 |
| 1700000000 | HIGH | 3 (next_change = 1700001000) |

### Passability golden tests

| Case | Expected |
|---|---|
| Reef (1), LOW (1), draft 1 | blocked (it is dry) |
| Reef (1), RISING (2), draft 1 | open |
| Reef (1), RISING (2), draft 2 | blocked |
| Reef (1), HIGH (3), draft 2 | open |
| Mudflat (2), RISING (2), draft 1 | blocked |
| Mudflat (2), HIGH (3), draft 1 | open |
| Mudflat (2), HIGH (3), draft 2 | blocked |
| Mudflat (2), spring HIGH (4), draft 2 | open |
| Shore (3), HIGH (3), draft 1 | blocked (dry) |
| Shore (3), spring HIGH (4), draft 1 | open |
| Seabed (0), super low LOW (0), draft 1 | blocked (it is dry) |
| Deep (-1), LOW (1), draft 2 | open |

---

## 6. Grid

- `GridModel` holds a flat `PackedInt32Array` of elevation values and a `PackedInt32Array` of building ids (0 = empty), width x height.
- Islands load from `data/islands/<id>.json` using an ASCII map (see `03`).
- Footprint check: all tiles of a footprint must be inside the grid, empty, and match the building's `placement` kind.
- Rendering: one `TileMapLayer` for terrain, one for water tint overlay, building nodes as `Node2D` sprites sorted by y. Water tint and tile variants update only on `tide_phase_changed` and on a slow visual tween.
- Camera: drag to pan, pinch to zoom (min 0.6, max 1.6), clamped to island bounds plus margin.
- Input: tap selects, long-press (0.4 s) or Move button starts move mode. Placement uses a ghost with green/red validity.

---

## 7. Production model

For each producing building store: `level`, `anchor` (x,y), `last_collect_at`, `stored` (int), `crew_id`.

On collect or load:
```
cycles = floor(active_seconds(last_collect_at, now, works_when_predicate) / every_s)
stored = min(cap, stored + cycles * amount * modifiers)
```
- `last_collect_at` moves forward only by the time consumed (keep the remainder), so no time is lost.
- When storage is full, accrued time is **not** banked (production simply stops). Rule R-BLD-4.
- Construction and upgrade use `ready_at` and ignore tide.

---

## 8. Modifiers (crew, tech, events)

```
Modifiers.get(stat, context) -> float
final = base * (1 + sum(pct_bonuses)) * product(event_multipliers)
final is never below 0.1 * base
```
- `stat` is a string key such as `build_time`, `farm_yield`, `boat_speed`, `sell_price`.
- Crew passive bonus = `(base_pct + per_level_pct * (level - 1)) * rarity_mult`.
- Time reducers use negative pct (for example -0.05 for 5% faster build).

---

## 9. Sea, boats, trips

- `SeaGraph` loads nodes and lanes from `data/sea.json`.
- `TripPlanner.can_depart(lane, boat, now) -> {ok: bool, reason: String, opens_at: int}`.
- Trip time:
```
flow = [0, +1, 0, -1][phase_index at departure]       # LOW, RISING, HIGH, FALLING
dir  = +1 if going A->B else -1
speed_mult = 1 + current_strength * flow * dir * event_current_mult
time = base_s / (boat.speed * speed_mult * (1 + sum(crew_boat_speed_bonus)))
```
- `current_strength` = 0.3. Storm event doubles it (0.6). Clamp `speed_mult` to a minimum of 0.4.
- A trip stores: `boat_id`, `lane_id`, `depart_at`, `arrive_at`, `cargo`, `direction`. On arrival the system resolves orders and creates the return trip.
- Orders are generated by a **seeded** random from `(island_id, cycle_number)` so all devices make the same orders and no server is needed.

---

## 10. Save system

- File: `user://save.json`, backup `user://save.bak.json`.
- **Atomic write:** write `save.tmp.json`, then rename over `save.json`. Keep the previous file as `.bak`.
- Save on: every state change after 2 s debounce, app pause, app quit.
- Root keys: `save_version` (int), `created_at`, `last_seen_at`, `resources`, `buildings`, `builders`, `tiles_changed`, `boats`, `trips`, `crew`, `research`, `orders_state`, `island_rep`, `events_seen`, `settings`, `ftue_step`, `flags`.
- **Migrations:** `Save.migrate(data)` upgrades one version at a time. Every change of save shape bumps `save_version` and adds a migration plus a test with an old sample file in `tests/fixtures/`.
- If load fails: try backup, then show a clear message. Never crash silently.

Sample (shortened):
```json
{
  "save_version": 1,
  "last_seen_at": 1700000000,
  "resources": {"coins": 300, "wood": 50, "food": 20, "stone": 0, "gems": 0},
  "buildings": [
    {"uid": 1, "id": "harbor_hall", "level": 1, "x": 7, "y": 7, "last_collect_at": 0, "stored": 0, "crew_id": ""}
  ],
  "builders": [{"busy_uid": 0, "ready_at": 0}],
  "crew": [{"id": "captain", "level": 1, "rarity": "common", "shards": 0, "assigned_uid": 0, "active_used_cycle": -1}],
  "ftue_step": 0
}
```

---

## 11. UI architecture

- One scene per screen. Screens are opened by `UIRouter` (stack: push, pop). No screen talks to another directly.
- Theme resource in `assets/ui/theme.tres`. One font family. All text strings go through `tr()` keys, kept in `data/strings.csv` (English only for v1).
- Safe area: use `DisplayServer.get_display_safe_area()`.
- Numbers: abbreviate above 9,999 (10.2K, 1.4M).

---

## 12. Performance budget

| Item | Target |
|---|---|
| Frame rate | 60 FPS on a mid Android phone (4 GB RAM), 30 FPS minimum on low-end |
| APK size | Under 80 MB for v1 |
| Draw calls | Under 150 on the home screen |
| Memory | Under 400 MB |
| Rules | Texture atlases. No per-frame allocations. No `get_node` in `_process`. Pool floating numbers. |

---

## 13. Testing

- GUT tests for all pure logic: tide, passability, placement, production math, offline progress, trip time, orders, modifiers, save and migration.
- Every task in `04_ROADMAP.md` has a "done when" check. Logic tasks need a GUT test first or together with the code.
- Manual test list per milestone is kept in `STATE.md`.
- Run tests: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests` (the exact command is confirmed in C01 and written to `STATE.md`).

---

## 14. Debug and logs

- Debug panel (debug builds only): time travel, add resources, unlock everything, force event, reset save, show FPS, show grid coordinates.
- Logging: `Log.info/warn/error(tag, message)`. Release builds log only warnings and errors.
- Never ship the debug panel in a release build (check in C18).

---

## 15. Security and anti-cheat (v1 level)

- Local game: clock changes can only cheat yourself. We keep the backward guard and offline cap.
- Leaderboard (C15): submit scores with a seed and a replayable route so the server can verify. Do not trust raw scores.
- No secrets in the repo. Use GitHub Secrets for keystores and keys.

---

## 16. Build and release

- Debug APK on every push to a feature branch (artifact download).
- Release (C18): signed AAB, keystore in GitHub Secrets, versionCode increments automatically.
- Version format: `0.<milestone>.<chat>` during development (example `0.1.05`).

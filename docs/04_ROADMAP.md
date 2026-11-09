# 04 ROADMAP (Fast-Track Web Plan)

Version 2.0 | 2026-11-07 | Owner: Chat 00 | D-034
One chat = one block below. Do the chats **in order**. Do not start the next chat until "Done when" is true and `STATE.md` is updated.
A chat has up to 3 steps (like C04.1, C04.2, C04.3). Each step ends with tests and a commit. Steps are big, not tiny.

---

## Milestones

| Milestone | Chats | Goal | Gate (must pass) |
|---|---|---|---|
| **M1 Playable Island** | C01 to C04 | A live web link with a tide island, buildings, resources, upgrades | **Fun test** (end of C04): 5 people play from a link. At least 3 of 5 say the tide "changes how I play", and at least 3 of 5 come back at the next phase on their own. If not, fix the design before C05. |
| **M2 Crew and Progress** | C05 | Crew, one trade trip, goals | All 7 crew passives work. One full trip works. |
| **M3 Launch** | C06 to C07 | Polish, save, audio, release | Live on a web-game platform. Works in Chrome, Firefox, Safari on phone and laptop. |

---

## Rules for every chat

- Attach the right **context pack** (see `07_HANDOFF_SYSTEM.md`).
- Start with the Boot Prompt (`08_PROMPTS.md`).
- Each step: plan, then code, then test, then commit.
- Logic gets a GUT test. UI gets a manual test note in `STATE.md`.
- Test in the **web build** (laptop browser and phone browser).
- End with the Handoff Prompt. Save `STATE.md` to the repo and to Project knowledge.
- Stay in scope. New ideas go to `STATE.md` > IDEAS PARKING LOT.
- The tide never destroys anything (R-TIDE-6). A change to that needs a new DECISIONS entry first.

Format below: **Goal / Read / Tasks / Done when / Out of scope.**

---

## C01 Setup and CI: DONE
## C02 Time and tide core: DONE (38 tests)

---

## C03 Island map, camera, tide visuals, live web pipeline

- **Goal:** A live web link where you see the home island and watch the tiles change with the tide.
- **Read:** 01 §3; 02 §1, §6, §16; 03 §3, §12.
- **Tasks:**
  - **C03.1 Data and grid (code ready, 62 tests):** `tiles.json`, `home_isle.json`, `IslandData`, `GridModel`, new tuning keys.
  - **C03.2 Web and island view (one step):**
    1. Web export preset, GitHub Actions web build, GitHub Pages deploy.
    2. Terrain from placeholder tiles, Harbor Hall box at (6,6).
    3. Water tint overlay (wet tiles, strength follows `visual_level`).
    4. Camera: drag, pinch, wheel, clamp.
    5. Tap a tile for its info. Tide widget. FPS in the debug strip.
- **Done when:** All tests pass (69 expected). The live link works on a laptop and a phone. Reef and mud visibly go under and out of water with time travel. 60 FPS on the laptop. Tile info matches the rule table. Download size and load time are written in `STATE.md`.
- **Out of scope:** Placing buildings.

---

## C04 Core loop: buildings, resources, upgrades

- **Goal:** Place buildings, make goods with tide-aware pause-not-lose, and upgrade.
- **Read:** 01 §4 (R-BLD-1 to R-BLD-10); 02 §3, §7, §8; 03 §1, §4, §5, §7.
- **Tasks:**
  - **C04.1 Data and placement:** `buildings.json`, `harbor.json`, `resources.json` (v1 buildings: harbor_hall, hut, house, farm, lumber_camp, quarry, clam_bed, seaweed_bed, warehouse, market, dock). `BuildingModel`. `Placement` rules (footprint, bounds, overlap, placement kind, Harbor level, count limits). Harbor Hall placed at start.
  - **C04.2 Production and economy:** `Resources` with caps. `ProductionSystem` using `active_seconds` (02 §7). `BuilderQueue` with `ready_at`. Formulas from 03 §1. Market sell. Warehouse. Harbor Hall upgrades with gates (cost, time, citizens) and citizen tax.
  - **C04.3 Build UI and play:** Build drawer (categories, cards, tide icon). Ghost placement (green/red). Move (5%) and remove (50% refund, never the Harbor Hall). Tap to collect with a floating number. Builder status. Resource HUD. A script that simulates the first 7 days and prints coins per hour.
- **Done when:** GUT tests pass for the placement matrix (every kind on every tile type), dry/wet production over a full cycle, remainder carry, full-storage stop, 48 h cap, builder queue. A clam bed pauses at HIGH and resumes at RISING with no loss. **M1 fun test is run and written in `STATE.md`.**
- **Out of scope:** Save file, crew, boats.

---

## C05 Crew, trade trip, goals

- **Goal:** Crew change how buildings work, one trade trip, and clear goals.
- **Read:** 01 §6 (R-SEA, R-BOAT, R-ORD), §7, §8; 02 §8, §9; 03 §7, §8, §9, §10.
- **Open at the start (I ask):** what "expedition" means (default: one Skiff trip Home to Pebble Atoll). Where pearls come from.
- **Tasks:**
  - **C05.1 Crew:** `CrewModel`, `CrewSystem`, `Modifiers`. All 7 passives. Assign to a building. Slots by Harbor level. Free Captain and Farmer. Upgrade. Crew Quarters recruiting. Crew screen.
  - **C05.2 Trip and orders:** Dock and Skiff. `SeaGraph` (home, Pebble Atoll). `TripPlanner` (`can_depart`, trip time with current). Seeded orders (same for all devices). Delivery, reward, reputation. Results popup.
  - **C05.3 Goals:** A milestone list tied to Harbor L1 to L5 (build, upgrade, deliver, crew) with rewards. **No loss state.**
- **Done when:** Tests pass for every passive (level 1, level 5, rare), trip time with and against the current, lane closed at departure, same orders on two devices. A full trip works in the browser.
- **Out of scope:** Active skills, shards, more islands, fog, events.

---

## C06 UI polish, audio, save

- **Goal:** It feels finished and nothing is lost when the tab closes.
- **Read:** 01 §12, §13; 02 §10, §11.
- **Tasks:**
  - **C06.1 Save:** `Save` to browser storage (`user://`), atomic write, backup, `save_version` 1, migrate stub, fixture test. Save on change (2 s debounce), tab hidden, page close (best effort). Load, offline catch-up (48 h cap), hidden-tab catch-up. **Export save and Import save** (Base64 text) in Settings with a warning that browser data can be cleared.
  - **C06.2 UI and audio:** Menus, settings (sound, volume), build drawer polish. Procedural sound effects (audio starts after the first tap). A 5-step skip-able first-play guide from 01 §12. Simple styling pass (06).
- **Done when:** Close the tab mid-construction, reopen: state is correct. Export, clear data, import: state is correct. A corrupt save falls back to the backup.
- **Out of scope:** New systems.

---

## C07 Balance, web shell, release

- **Goal:** Ship it.
- **Read:** 02 §12, §14, §16.
- **Tasks:**
  - **C07.1 Balance and performance:** Tuning pass from test notes. Size and load-time pass. Low-end phone browser test.
  - **C07.2 Shell and release:** Portrait HTML/CSS page for desktop and mobile (check the Godot docs for the required placeholders first). Loading look, favicon, share image. Release export (no debug panel). Zip for the web-game platform. Browser test matrix (Chrome, Firefox, Safari on laptop; Chrome Android, Safari iOS). Final name and trademark check. Launch page text and screenshots.
- **Done when:** Live on the chosen platform. The matrix passes. No debug panel in the release.

---

## Parked (data and rules kept, not built in v1)

Events and seasons, spring and super low as real events (debug only), social (share code, weekly challenge, leaderboard), gems, ads and IAP, tech tree and Lab, power and Workshop recipes, land reclaim, crew active skills and shards, Kelp Cove, Coral Spire, Explorer and Trader boats, fog, native Android and iOS, full art pass.

## Dependency map

```
C01 → C02 → C03 → C04 ══(M1 gate)══▶ C05 → C06 → C07
```

## Risk checkpoints

| When | Check | If it fails |
|---|---|---|
| End of C03 | Does the tide change look clear in the browser? | Fix tile readability first |
| End of C04 | M1 fun test | Redesign tide uses before C05 |
| End of C05 | Do trips feel like choices? | Add forecast hints |
| End of C06 | Is the save safe in a browser? | Fix before launch |

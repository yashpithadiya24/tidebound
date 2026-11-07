# 04 ROADMAP

Version 1.1 | 2026-11-06 | Owner: Chat 00
One chat = one block below. Do the chats **in order**. Do not start the next chat until "Done when" is true and `STATE.md` is updated.
Time guesses are rough. Total about 6 to 7 months if you work most days. Learning and bug time can stretch it.

---

## Milestones

| Milestone | Chats | Goal | Gate (must pass) | Time |
|---|---|---|---|---|
| **M1 Tide Town** | C01 to C07 | A playable island with tide, buildings, save, tutorial | **Fun test:** 5 people play. At least 3 of 5 say the tide "changes how I play", and at least 3 of 5 check back at the next phase on their own. If not, fix the design before C08. | ~8 weeks |
| **M2 Trade** | C08 to C10 | Sea map, boats, orders, 3 islands | Full trade trip works with currents and windows | ~4 weeks |
| **M3 Crew** | C11 to C13 | Crew, power, research, reclaim | All 7 crew work. Workshop chain works. | ~6 weeks |
| **M4 Live** | C14 to C15 | Events and social | Events by schedule. Share code and challenge work. | ~4 weeks |
| **M5 Launch** | C16 to C18 | Shop, art, polish, release | Closed beta ok. Store listing ready. | ~6 weeks |

---

## Rules for every chat

- Attach the right **context pack** (see `07_HANDOFF_SYSTEM.md`).
- Start with the Boot Prompt (`08_PROMPTS.md`).
- Each task: plan, then code, then test, then commit.
- Logic gets a GUT test. UI gets a manual test note in `STATE.md`.
- End with the Handoff Prompt. Save `STATE.md` to the repo and to Project knowledge.
- Stay in scope. New ideas go to `STATE.md` > IDEAS PARKING LOT.

Format below: **Goal / Read / Tasks / Done when / Out of scope.** Spec sections are in `01`, `02`, `03`.

---

# MILESTONE 1: TIDE TOWN

## C01 Setup and CI
- **Goal:** Empty project that builds an APK in the cloud and runs on your phone.
- **Read:** 02 §1, §2, §13, §16; 05.
- **Tasks:**
  1. Install Godot (lock version). Create project with settings from 02 §1.
  2. Create GitHub repo, `.gitignore` for Godot, folder skeleton from 02 §2, copy Core Pack to `docs/`.
  3. Install GUT. One passing test.
  4. Add autoload stubs: `Clock`, `EventBus`, `Data`, `Save`, `Game`, `Tide`, `Debug`.
  5. GitHub Actions: export debug APK as a downloadable artifact.
  6. Install APK on your phone.
  7. Copy `tools/repo_map.py` and run it once.
  8. Add a boot screen (`scenes/main/Main.tscn`, `scripts/core/Main.gd`) that shows "Tidebound" and the live `Clock.now()` number.
- **Done when:** The phone shows a screen with the text "Tidebound" and the live `Clock.now()` number. Tests run from the command line. `STATE.md` lists Godot version, test command, APK steps.
- **Out of scope:** Any gameplay.

## C02 Time and tide core
- **Goal:** Correct tide math with tests, plus time travel debug.
- **Read:** 01 §3; 02 §4, §5; 03 §2.
- **Tasks:**
  1. `Data` loads `tuning.json`.
  2. `Clock.now()` with debug offset and backward guard.
  3. `TideModel` (pure) with all formulas and `active_seconds`.
  4. `Tide` autoload: emits `tide_phase_changed(phase, index)` at each boundary.
  5. GUT tests: all golden tests in 02 §5 (tide and passability), plus events (spring, super low).
  6. Debug overlay: phase, index, countdown, buttons for +1 h, next phase, +6 h, reset.
- **Done when:** All golden tests pass. On the phone, the countdown matches and time travel changes the phase.
- **Out of scope:** Grid, art.

## C03 Grid and island view
- **Goal:** See the home island, and watch tiles change with the tide.
- **Read:** 01 §3 (tile table); 02 §6; 03 §3, §12.
- **Tasks:**
  1. `IslandData` loads the ASCII map. `GridModel` stores elevation.
  2. `TileMapLayer` terrain using placeholder colored tiles (03 §3).
  3. Water tint overlay driven by `visual_level`. Dry/wet variants update on phase change.
  4. Camera: pan, pinch zoom, clamp.
  5. Tap a tile: show coordinates, type, elevation, dry or wet now.
  6. Tide widget (icon, phase name, countdown).
- **Done when:** Island renders. Using time travel, reef and mud tiles visibly go under and out of water. 60 FPS on your phone. Tile tap info is correct against the rule table.
- **Out of scope:** Buildings.

## C04 Building placement
- **Goal:** Place, move, and remove buildings with correct rules.
- **Read:** 01 §4; 02 §3, §6; 03 §5.
- **Tasks:**
  1. `Data` loads `buildings.json`.
  2. `Placement` rules: footprint, bounds, overlap, placement kind, harbor level and count limits.
  3. `BuildingModel` and `GridModel` building map.
  4. Build menu UI (categories, cards, tide icon).
  5. Placement mode with ghost (green/red).
  6. Move (cost 5%) and remove (50% refund). Harbor Hall cannot be removed.
  7. Placeholder sprites (colored boxes with labels).
- **Done when:** GUT test matrix for placement passes (every placement kind on every tile type). You can place the starter buildings by hand on the phone.
- **Out of scope:** Production, timers.

## C05 Production and economy
- **Goal:** Buildings make goods with tide-aware pause-not-lose.
- **Read:** 01 §4 (R-BLD-3 to R-BLD-9); 02 §7, §8; 03 §1, §4, §5.
- **Tasks:**
  1. `Resources` with caps and add/spend with checks.
  2. `ProductionSystem` using `active_seconds` (02 §7). Tap to collect. Floating number effect.
  3. Construction and upgrade with `BuilderQueue` and `ready_at`. Builder status UI.
  4. Formulas from 03 §1 for cost, time, output, cap.
  5. Market: sell any resource at base price.
  6. Storage caps and Warehouse effect.
  7. Offline catch-up function (applies after load).
  8. Spreadsheet or script that simulates the first 7 days and prints coins per hour (balance check).
- **Done when:** GUT tests pass for: dry/wet production over a full cycle, remainder carry, full-storage stop, offline 48 h cap, builder queue. Clam bed pauses at HIGH and resumes at RISING without loss.
- **Out of scope:** Save file, Harbor upgrades.

## C06 Save, Harbor Hall, HUD
- **Goal:** Real persistence and progression.
- **Read:** 01 §8, §14; 02 §10, §11; 03 §7.
- **Tasks:**
  1. `Save`: atomic write, backup, save version 1, migrate stub, fixture test.
  2. Save triggers (change, pause, quit). Load and catch-up.
  3. Harbor Hall upgrades with gates (cost, time, citizens) and unlocks.
  4. Citizens and tax.
  5. HUD: resources, tide widget, bottom bar, builder status.
  6. Settings screen (sound toggle, placeholder for notifications).
- **Done when:** Close the app mid-construction, wait, reopen: state and progress are correct. Corrupt-save test falls back to backup.
- **Out of scope:** Tutorial, boats.

## C07 Tutorial and M1 playtest
- **Goal:** New players understand the tide in 10 minutes. Gate for M1.
- **Read:** 01 §12, §13; 02 §11.
- **Tasks:**
  1. FTUE state machine (steps from 01 §12) with highlight arrows and dialog.
  2. Time-lapse tide intro (visual only, no real time change).
  3. Fast first builds. Skip option.
  4. Local event log (no network): steps reached, time per step, quit points.
  5. Placeholder sfx.
  6. Tuning pass from first test notes.
  7. Run the **M1 fun test** with 5 people. Write results in `STATE.md`.
- **Done when:** FTUE completes on a fresh install. M1 gate result is recorded and a decision is logged: go, or fix design.
- **Out of scope:** New systems.

---

# MILESTONE 2: TRADE

## C08 Sea map and docks
- **Goal:** The sea map screen with tide-aware lanes.
- **Read:** 01 §6; 02 §9; 03 §9.
- **Tasks:** `SeaGraph` from `sea.json`. Sea map screen with nodes, lanes (open/closed color, icon, and opens-at time). Dock building gives boat slot. Fog state per node. Lane open check using `TideModel`.
- **Done when:** Lane open/closed matches the passability tests for each phase.
- **Out of scope:** Moving boats.

## C09 Boats and trade
- **Goal:** Full trade trip with currents and orders.
- **Read:** 01 §6; 02 §9; 03 §8, §9.
- **Tasks:** Boat model and building boats. `TripPlanner` (`can_depart`, trip time). Trips with `arrive_at` and return. Cargo loader UI. Seeded order generation. Delivery, reward, reputation. Route score. Trip results popup.
- **Done when:** GUT tests: trip time with and against current, window closed at departure, same orders on two devices for same cycle. A full trip works on the phone.
- **Out of scope:** Fog and exploring.

## C10 Islands and exploration
- **Goal:** Three islands to visit, fog, explorer boat.
- **Read:** 01 §6 (R-EXP-1); 03 §9.
- **Tasks:** Order boards for Pebble Atoll and Kelp Cove. Reputation levels. Explorer boat and reveal. Coral Spire teaser (locked). Spring-only node support (reads the event override).
- **Done when:** Reputation unlocks work. Explorer reveals a node. M2 gate passes.
- **Out of scope:** Crew.

---

# MILESTONE 3: CREW

## C11 Crew data and screen
- **Goal:** Crew you can own, level, and assign. Passives work.
- **Read:** 01 §7; 02 §8; 03 §10.
- **Tasks:** `CrewModel`, `CrewSystem`, `Modifiers`. Crew screen (list, detail, assign, upgrade). Wire all 7 passives through `Modifiers`. Free Captain and Farmer. Crew slots by Harbor level.
- **Done when:** GUT tests for every passive's numbers (level 1, level 5, rare). Assigned crew visibly changes output.
- **Out of scope:** Actives, recruiting.

## C12 Crew actives and recruiting
- **Goal:** Active skills and ways to get crew.
- **Read:** 01 §7; 03 §10.
- **Tasks:** One-per-cycle charge logic (reset at cycle start). All 7 active skills with UI buttons and effects. Crew Quarters recruiting (coins and pearls). Shards and rarity upgrade. Active-ready indicator on HUD.
- **Done when:** Tests: charge resets on cycle boundary, cannot double use, each active effect. No crew can be lost.
- **Out of scope:** Events that give crew.

## C13 Industry, power, research, reclaim
- **Goal:** The mid-game production chain and long goals.
- **Read:** 01 §5, §8; 03 §6, §11.
- **Tasks:** Water wheel power with flow factor. Workshop recipes and queue. Lab and research tree UI. Lighthouse forecast UI and tide planner hint. Reclaim tiles (cost, time, one-way).
- **Done when:** Tests for power sharing, recipe time, reclaim rules (R-REC-1 to R-REC-4). M3 gate passes.
- **Out of scope:** Events.

---

# MILESTONE 4: LIVE

## C14 Events and seasons
- **Goal:** Date-based events and a first season.
- **Read:** 01 §9; 02 §5.
- **Tasks:** `EventSystem` with a deterministic schedule from the date. Spring tide, super low tide, storm, moon festival, whale migration. Tide chests and flats treasure. Event banner UI. Season track (28 days) with free rewards. Economy balance pass.
- **Done when:** Same date gives same events on any device. Event overrides pass the golden tests.
- **Out of scope:** Server events.

## C15 Social
- **Goal:** Share layouts and a weekly challenge.
- **Read:** 01 §10; 02 §15.
- **Tasks:** Decide backend (log in DECISIONS; options: Firebase or Supabase, pick the one with the simplest free tier for leaderboards). `ShareCode` encode/decode with a test. Friend island view (read-only). Weekly seed challenge with local scoring and replay. Leaderboard submit and read. Optional gift boat.
- **Done when:** Share code round-trips. Challenge gives the same map for all and a valid score.
- **Out of scope:** Chat, PvP.

---

# MILESTONE 5: LAUNCH

## C16 Shop and money
- **Goal:** Safe, fair monetization.
- **Read:** 01 §11; 02 §15.
- **Tasks:** Gems and shop UI. Rewarded ads (verify the current Godot AdMob plugin). Play Billing for IAP (verify plugin). Starter pack, second builder, cosmetics. Basic receipt check. Privacy policy page. **No-pay-to-win checklist** (R-ECO-2).
- **Done when:** Test purchases work with test accounts. Checklist signed in `STATE.md`.

## C17 Art and audio
- **Goal:** Replace placeholders with the final look.
- **Read:** 06; 01 §16.
- **Tasks:** Art style sheet. Tiles, buildings, boats, crew portraits, icons, UI skin. Water shader and tide transitions. Animations. Music and sfx. Atlases. Check APK size.
- **Done when:** All placeholders replaced. APK under 80 MB. 60 FPS kept.

## C18 Polish and launch
- **Goal:** Ready for the store.
- **Read:** 02 §12, §14, §16.
- **Tasks:** Local notifications (tide phase, build done, active ready). Low-end phone test and performance pass. Crash reporting. Strings in one file. Color-blind check. Remove debug panel from release. Closed beta. Store listing, screenshots, trailer. Final name and trademark check. Signed AAB. Soft launch in one region.
- **Done when:** Beta feedback fixed. Release build installs from the store test track.

---

## Dependency map

```
C01 → C02 → C03 → C04 → C05 → C06 → C07 ══(M1 gate)══▶ C08 → C09 → C10
C10 → C11 → C12 → C13 → C14 → C15 → C16 → C17 → C18
```
Art (C17) can start earlier in parallel if you want, but code chats never wait for it. Placeholders are fine.

## Risk checkpoints

| When | Check | If it fails |
|---|---|---|
| End of C03 | Does the tide change look clear and cool on the phone? | Fix visuals and tile readability first |
| End of C07 | M1 fun test | Redesign tide uses (more choices, better hints) before adding systems |
| End of C09 | Do currents and windows feel like choices, not blocks? | Widen windows, add forecast hints |
| End of C14 | Do players have a reason to return each phase? | Add phase-specific rewards |

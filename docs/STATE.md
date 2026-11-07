# STATE (live status)

Update this file at the end of **every** chat. It is the first thing every new chat reads after `00`.

**Last updated:** 2026-11-07 | **By chat:** C02 (Time and tide core)

---

## 1. Versions in use

| Item | Version |
|---|---|
| 00_START_HERE | 1.0 |
| 01_GAME_BIBLE | 1.1 |
| 02_TECH_SPEC | 1.3 |
| 03_DATA_STARTER | 1.0 |
| 04_ROADMAP | 1.1 |
| 05_AI_RULES | 1.0 |
| 06_ART_GUIDE | 1.0 |
| 07_HANDOFF_SYSTEM | 1.0 |
| 08_PROMPTS | 1.0 |
| Godot | 4.7.1 stable (laptop and CI) |
| GUT | 9.7.1 |
| CI image | barichello/godot-ci:4.7.1 |
| save_version | not created yet |
| App version | 0.0.00 (not set in export preset yet) |

## 2. Current position

- **Milestone:** M1 Tide Town
- **Current chat:** none active (C02 finished)
- **Phase note:** Tide math, tide signal, and time travel debug overlay work on laptop and on the phone. 38 of 38 tests pass. C03 (Grid and island view) is next.

## 3. DONE (with task ids)

- C00: Full plan and Core Pack written (design, tech, data, roadmap, rules, prompts).
- C01.1: Godot 4.7.1 project created (portrait 1080x1920, stretch canvas_items/expand, Compatibility renderer, Android preset "Android", package com.yash.tidebound).
- C01.2: Repo skeleton from 02 section 2, `.gitignore` rules, `docs/02` edit for Log (D-011).
- C01.3: GUT 9.7.1 installed, smoke test passes.
- C01.4: 7 autoload stubs (Clock, EventBus, Data, Save, Game, Tide, Debug) and static `Log` class. `Clock.now()` works. `tests/test_clock.gd` added.
- C01.5: GitHub Actions workflow builds the debug APK on every push. Fixed one error (Import ETC2 ASTC must be on).
- C01.6: APK installed and checked on a Realme 9 Pro 5G (Android 14).
- C01.7: `tools/repo_map.py` run on the new tree (output not committed).
- C01.8: Boot screen `Main.tscn` + `Main.gd` shows "Tidebound" and live `Clock.now()` (added to C01 by D-017).
- C02.1: `data/tuning.json` created from 03 section 2. `Data` loads it (`Data.tuning`, `load_json_dict()`, `tuning_int()`). Bad or missing file gives an empty Dictionary and a warning. Export filter now includes `*.json` (D-022).
- C02.2: `Clock` backward guard. `last_seen_at` is kept in memory (D-021). New `set_last_seen_at()` and `reset_debug()` (clears offset and guard).
- C02.3: `TideModel` (pure `RefCounted`, `class_name TideModel`). Has phase_index, phase_name, base_index, water_index (with event), next_change, cycle_start, visual_level, is_underwater, is_dry, can_boat_pass, active_seconds. Numbers come from `Data.tuning`.
- C02.4: `Tide` autoload with its own 1 s Timer (D-023). `Tide.event_override` (none, spring, super_low). `EventBus.tide_phase_changed(phase: String, index: int)`.
- C02.5: Tests for all golden tables in 02 section 5, SEABED draft 2 (D-019), DEEP draft 2 at super low (D-024), events, `active_seconds`.
- C02.6: Debug overlay in `DebugPanel.gd` (built in code, debug builds only). Top strip shows phase, index, countdown. Tap to open: +1 h, Next phase, +6 h, Reset, No event, Spring, Super low.

## 4. IN PROGRESS

- Merge branch `c02-tide-core` into `main` (user action, see handoff checklist).

## 5. NEXT CHAT

- **Chat ID:** C03 Grid and island view
- **First task:** C03.1 `IslandData` loads the ASCII map and `GridModel` stores elevation. Note: `data/tiles.json` and `data/islands/home_isle.json` do not exist yet. Create them in this task from `03` section 3 and section 12.
- **Attach:** `00`, `STATE.md`, `05`, C03 block from `04`, `01` (section 3, tile table), `02` (section 6), `03` (sections 3 and 12), new `repo_map.txt`, and these code files: `scripts/core/Data.gd`, `scripts/core/EventBus.gd`, `scripts/core/Main.gd`, `scenes/main/Main.tscn`, `scripts/tide/Tide.gd`, `scripts/tide/TideModel.gd`, `project.godot`
- **Boot line:** `Chat ID: C03 - Grid and island view`
- **Repo map command:** `python tools/repo_map.py > repo_map.txt` then `python tools/repo_map.py --full scripts/core/Data.gd scripts/core/EventBus.gd scripts/core/Main.gd scripts/tide/Tide.gd scripts/tide/TideModel.gd > code_context.txt`

## 6. DECISIONS (append-only, newest at the bottom)

| ID | Date | Decision | Reason | Files affected | Supersedes |
|---|---|---|---|---|---|
| D-001 | 2026-11-06 | Game concept: Tidebound, a tide-changing grid builder with boats, trade, and a crew of skilled characters | Merge of two Tidebound ideas plus crew from the user | 01 | - |
| D-002 | 2026-11-06 | Engine: Godot 4, GDScript, 2D | Light on an old laptop, free, AI writes GDScript well | 02 | - |
| D-003 | 2026-11-06 | Mobile first, Android first, iOS later | User choice | 02 | - |
| D-004 | 2026-11-06 | Renderer: Compatibility | Widest device support for cheap phones | 02 | - |
| D-005 | 2026-11-06 | No PvP in v1. Social = share code + weekly challenge | Solo dev, no server cost, easier balance | 01 | - |
| D-006 | 2026-11-06 | Tide cycle 6 h from global UTC clock, 4 phases, index 1/2/3/2 | Simple, fair, no server | 01, 02, 03 | - |
| D-007 | 2026-11-06 | Clean-room rule: no decompiling or copying commercial games | Legal and store risk. Mechanics may be studied, code and assets may not be copied. | 05 | - |
| D-008 | 2026-11-06 | One chat per roadmap block (C01 to C18), files are the memory | Context stays small and consistent | 04, 07 | - |
| D-009 | 2026-11-06 | Time model: unix timestamps (`ready_at`), no per-building timers | Cheap offline progress | 02 | - |
| D-010 | 2026-11-06 | Backend for leaderboard is decided in C15 | Not needed before that | 04 | - |
| D-011 | 2026-11-06 | `Log` is a static helper class (`class_name Log`, `scripts/core/Log.gd`), not an autoload. The 7 autoloads stay unchanged. | Keeps 02 section 3 list as is. 02 section 14 and 05 already call `Log.warn`. | 02 | - |
| D-012 | 2026-11-06 | Lock Godot 4.7.1 stable. CI image: `barichello/godot-ci:4.7.1`. | Matches laptop. Image tag exists. Closes Q-001. | 02, STATE | - |
| D-013 | 2026-11-06 | Package id `com.yash.tidebound`. Developer name `Yash`. | User choice. Closes Q-002. | 02 | - |
| D-014 | 2026-11-06 | CI builds a debug APK on every push to any branch, plus a manual "Run workflow" button. | A fresh APK is always available. Simple. Changes the wording "feature branch" in 02 section 16. | 02, `.github/workflows/build-debug-apk.yml` | - |
| D-015 | 2026-11-06 | Project setting "Import ETC2 ASTC" is ON. | Android export fails without it (seen in the first CI run). | 02, project.godot | - |
| D-016 | 2026-11-06 | The autoload named `Debug` uses `scripts/debug/DebugPanel.gd`. No new file. | Matches 02 section 2 exactly. No doc edit needed. | 02 (none), project.godot | - |
| D-017 | 2026-11-06 | C01 includes a boot screen task (`scenes/main/Main.tscn`, `scripts/core/Main.gd`). | C01 "Done when" needs a screen with the live clock, but no task made one. | 04 | - |
| D-018 | 2026-11-06 | Test command is `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`. | Confirmed on Godot 4.7.1 with GUT 9.7.1. `-gexit` closes Godot after the tests. | 02 | - |
| D-019 | 2026-11-07 | Fix wording in 01 R-TILE-2: DEEP works at LOW for draft 2 boats. SEABED needs index 2 or more for draft 2. | The formula and tests in 02 section 5 win over the old wording. | 01 | - |
| D-020 | 2026-11-07 | Debug panel wording in 02 section 4: "Next phase" jumps to the exact next phase boundary. "Reset offset" also clears the backward guard. "Set event override" has 3 values (none, spring, super low). 02 goes to version 1.3. | Matches the C02 build. 02 wins over 04 for the debug buttons. | 02 | - |
| D-021 | 2026-11-07 | Until C14, `Tide.event_override` is set only by the debug panel. Until C06, `Clock.last_seen_at` is kept in memory only. | `EventSystem` and `Save` do not exist yet. | none (code) | - |
| D-022 | 2026-11-07 | Android export preset `include_filter` is `*.json`. | Godot may leave `data/*.json` out of the APK. This keeps game data inside the APK. Phone check passed. | export_presets.cfg | - |
| D-023 | 2026-11-07 | `Tide` has its own 1 s Timer for now. `tide_phase_changed(phase, index)` is also emitted when an event changes the water index inside the same phase. | `Game` has no tick yet. The map must redraw when spring or super low turns on. | scripts/tide/Tide.gd, scripts/core/EventBus.gd | - |
| D-024 | 2026-11-07 | Keep the 02 section 5 formula as is: a draft 2 boat (Trader) is blocked on DEEP at super low tide (index 0). A test covers it. | User choice. No rule change now. | tests/test_tide_model_rules.gd | - |

## 7. OPEN QUESTIONS

| ID | Question | Needed by | Owner |
|---|---|---|---|
| Q-003 | Tide epoch shift: should HIGH tide fall in the evening for the main audience? | C07 | user |
| Q-004 | Backend choice for leaderboard (Firebase or Supabase) | C15 | AI + user |
| Q-005 | Final store name and trademark check | C18 | user |
| Q-006 | CI log said "Could not find version of build tools that matches Target SDK, using 33.0.2". The build is green. Check the Target SDK and build tools before release. | C18 | AI |
| Q-007 | Do `Log.warn` and `Log.error` (push_warning, push_error) print in release builds? Not confirmed. Also confirm the debug panel does nothing in release. | C18 | AI |
| Q-008 | Move the Tide 1 s Timer to the `Game` 1 Hz tick (02 section 3) when `Game` gets its tick. | C05 | AI |
| Q-009 | `TideModel` takes the event as one String for the whole time range. In C14 the event may depend on the date, so this signature may change. | C14 | AI |
| Q-010 | Trader (draft 2) is blocked on DEEP at super low (D-024). Lane `pebble_coral` is "open all phases" in 03 section 9. Check this in C09 and C14. | C09 | AI + user |

Closed in C01: Q-001 (see D-012), Q-002 (see D-013).

## 8. KNOWN BUGS

- (none)

## 9. IDEAS PARKING LOT (do not build until promoted by a DECISION)

- Beastback idea (city on a walking creature) as a later expansion theme
- Gift boats to friends
- Decorations and island skins
- Light PvE sea raids vs AI (old plan, cut from v1)
- Run the GUT tests in CI (GitHub Actions)

## 10. ASSET LEDGER

| Asset | Source / tool | License | Link or prompt | Date | Used in |
|---|---|---|---|---|---|
| GUT 9.7.1 (plugin) | GitHub release | MIT | https://github.com/bitwes/Gut | 2026-11-06 | tests (`addons/gut/`) |
| barichello/godot-ci 4.7.1 (Docker image) | Docker Hub / GitHub | MIT (as listed on a third-party summary page, check the repo LICENSE file) | https://github.com/abarichello/godot-ci | 2026-11-06 | CI build |
| actions/checkout@v4, actions/upload-artifact@v4 | GitHub Actions | not checked yet (check in C18) | https://github.com/actions | 2026-11-06 | CI build |

## 11. INSPIRATION LOG (ideas only, never code)

| Date | Game or source | Idea we noted (in our own words) | Our version |
|---|---|---|---|
| 2026-11-06 | Town-builder games (general) | Collect, upgrade, and order loops keep players returning | Tide phases + trade orders |

## 12. TEST NOTES

- **Test command:** `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` (Godot 4.7.1, GUT 9.7.1).
- **After adding a new `class_name` file, run this first:** `godot --headless --editor --quit` (rebuilds the class list). Without it GUT can skip a test file that uses the new class.
- **Result at end of C02:** 38 of 38 tests pass. `test_smoke` 1, `test_clock` 2, `test_clock_guard` 5, `test_data` 4, `test_tide` 6, `test_tide_model` 6, `test_tide_model_rules` 14.
- **Expected yellow warnings:** 2 lines from `test_data` (missing file, bad JSON). They are on purpose. No red errors should show.
- **Time travel in tests:** use `Clock.debug_offset` and `Tide.refresh()`. Reset with `Clock.reset_debug()` in `before_each` and `after_each`.
- **APK build steps:**
  1. Push to any branch, or run the workflow by hand: GitHub > Actions > "Build debug APK" > Run workflow.
  2. Open the green run. Under Artifacts, download `tidebound-debug-apk` (a zip).
  3. Unzip. Install `tidebound-debug.apk` on the phone (allow install from unknown sources).
  - Workflow file: `.github/workflows/build-debug-apk.yml`. Preset name must stay `Android`. Image: `barichello/godot-ci:4.7.1`.
  - The workflow runs `godot --headless --verbose --editor --quit` (import) before `--export-debug`.
- **Manual test list for current milestone (M1):**
  - C01 boot screen shows "Tidebound" and a number that goes up every second, on laptop and on Realme 9 Pro 5G (Android 14): PASS.
  - C02 debug strip at the top shows phase, index, countdown. Tap opens the buttons. +1 h, Next phase, +6 h, Spring, Super low, Reset all work: PASS on laptop and on Realme 9 Pro 5G.
  - C02 phone countdown matches the laptop (proves `tuning.json` is inside the APK): PASS.
- **M1 fun test result:** (fill in C07)

## 13. CHAT LOG (newest at the bottom)

| Date | Chat | What was done | Files changed |
|---|---|---|---|
| 2026-11-06 | C00 | Planning, Core Pack v1.0 | docs/* |
| 2026-11-06 | C01 | Godot 4.7.1 project, repo skeleton, GUT 9.7.1, 7 autoload stubs, Log, Clock.now, boot screen, CI debug APK (green), APK tested on phone | project.godot, export_presets.cfg, .gitignore, scripts/core/*, scripts/tide/Tide.gd, scripts/debug/DebugPanel.gd, scenes/main/Main.tscn, tests/*, addons/gut/*, .github/workflows/build-debug-apk.yml, docs/02, docs/04, docs/STATE.md |
| 2026-11-07 | C02 | tuning.json and Data loader, Clock backward guard, TideModel with all 02 section 5 formulas, Tide autoload with signal and event override, 38 tests, debug overlay with time travel and event buttons, export filter for json, D-019 to D-024, tested on phone | data/tuning.json, export_presets.cfg, scripts/core/Data.gd, scripts/core/Clock.gd, scripts/core/EventBus.gd, scripts/tide/TideModel.gd, scripts/tide/Tide.gd, scripts/debug/DebugPanel.gd, tests/test_data.gd, tests/test_clock.gd, tests/test_clock_guard.gd, tests/test_tide.gd, tests/test_tide_model.gd, tests/test_tide_model_rules.gd, docs/01, docs/02, docs/04, docs/STATE.md |

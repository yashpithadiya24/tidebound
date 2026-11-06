# STATE (live status)

Update this file at the end of **every** chat. It is the first thing every new chat reads after `00`.

**Last updated:** 2026-11-06 | **By chat:** C00 (planning)

---

## 1. Versions in use

| Item | Version |
|---|---|
| 00_START_HERE | 1.0 |
| 01_GAME_BIBLE | 1.0 |
| 02_TECH_SPEC | 1.0 |
| 03_DATA_STARTER | 1.0 |
| 04_ROADMAP | 1.0 |
| 05_AI_RULES | 1.0 |
| 06_ART_GUIDE | 1.0 |
| 07_HANDOFF_SYSTEM | 1.0 |
| 08_PROMPTS | 1.0 |
| Godot | not set (fill in C01) |
| GUT | not set (fill in C01) |
| save_version | not created yet |
| App version | 0.0.00 |

## 2. Current position

- **Milestone:** M1 Tide Town
- **Current chat:** none started
- **Phase note:** Planning is done. Setup (C01) is next.

## 3. DONE (with task ids)

- C00: Full plan and Core Pack written (design, tech, data, roadmap, rules, prompts).

## 4. IN PROGRESS

- (nothing)

## 5. NEXT CHAT

- **Chat ID:** C01 Setup and CI
- **First task:** C01.1 Install Godot, lock version, create project with settings from 02 §1
- **Attach:** `00`, `STATE.md`, `05`, C01 block from `04`, `02` (§1, §2, §13, §16), `tools/repo_map.py`
- **Boot line:** `Chat ID: C01 - Setup and CI`

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

## 7. OPEN QUESTIONS

| ID | Question | Needed by | Owner |
|---|---|---|---|
| Q-001 | Which exact Godot version and Godot CI image for exports? | C01 | AI + user |
| Q-002 | Package id and developer name | C01 | user |
| Q-003 | Tide epoch shift: should HIGH tide fall in the evening for the main audience? | C07 | user |
| Q-004 | Backend choice for leaderboard (Firebase or Supabase) | C15 | AI + user |
| Q-005 | Final store name and trademark check | C18 | user |

## 8. KNOWN BUGS

- (none)

## 9. IDEAS PARKING LOT (do not build until promoted by a DECISION)

- Beastback idea (city on a walking creature) as a later expansion theme
- Gift boats to friends
- Decorations and island skins
- Light PvE sea raids vs AI (old plan, cut from v1)

## 10. ASSET LEDGER

| Asset | Source / tool | License | Link or prompt | Date | Used in |
|---|---|---|---|---|---|
| (none yet) | | | | | |

## 11. INSPIRATION LOG (ideas only, never code)

| Date | Game or source | Idea we noted (in our own words) | Our version |
|---|---|---|---|
| 2026-11-06 | Town-builder games (general) | Collect, upgrade, and order loops keep players returning | Tide phases + trade orders |

## 12. TEST NOTES

- Test command: (fill in C01)
- APK build steps: (fill in C01)
- Manual test list for current milestone: (fill in each milestone)
- M1 fun test result: (fill in C07)

## 13. CHAT LOG (newest at the bottom)

| Date | Chat | What was done | Files changed |
|---|---|---|---|
| 2026-11-06 | C00 | Planning, Core Pack v1.0 | docs/* |

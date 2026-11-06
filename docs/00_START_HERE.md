# TIDEBOUND: START HERE

Version 1.0 | 2026-11-06 | Owner: Chat 00 (planning)

## What this project is

- **Game:** Tidebound. A mobile grid-builder. You build a floating-island city. The ocean tide changes your map every few hours.
- **One line:** "Your town is never finished, because the sea keeps changing what works."
- **Platform:** Android first, iOS later.
- **Engine:** Godot 4 (GDScript), 2D.
- **Team:** One solo developer. All code is written by AI in chats. Old laptop, so heavy work runs in the cloud (GitHub Actions, Codespaces).

## The files (this is the full "Core Pack")

| File | What it holds | Changes how often |
|---|---|---|
| `00_START_HERE.md` | This index, golden rules, glossary | Rarely |
| `01_GAME_BIBLE.md` | All game rules and design | Only by decision |
| `02_TECH_SPEC.md` | Architecture, formulas, tests, save format | Only by decision |
| `03_DATA_STARTER.md` | All numbers and starter JSON data | Often (balance) |
| `04_ROADMAP.md` | Milestones, 18 chats, tasks, "done when" | When plan changes |
| `05_AI_RULES.md` | Rules the AI must follow in every chat | Rarely |
| `06_ART_GUIDE.md` | Art and audio rules, AI art prompts | Rarely |
| `07_HANDOFF_SYSTEM.md` | How memory moves between chats | Rarely |
| `08_PROMPTS.md` | Copy-paste prompts for every chat | Rarely |
| `STATE.md` | **Live status**: progress, decisions, open questions | **Every chat** |
| `tools/repo_map.py` | Makes a small code summary to paste in chats | Rarely |

## Single source of truth (very important)

A fact lives in **one file only**. Other files point to it. Never copy it.

- Game rules → `01`
- Tech and formulas → `02`
- Numbers and data → `03`
- What is done now → `STATE.md`

## Golden rules

1. **Files are the memory. The chat is not.** If it is not in a file, it is lost.
2. **Tides never destroy.** They only change what works. Production pauses, it is never lost.
3. **Small steps.** One task at a time. Test after each task.
4. **No silent changes.** Rules, numbers, and names change only through a DECISIONS entry in `STATE.md`.
5. **Data in JSON, not in code.** Costs, times, and stats live in `data/*.json`.
6. **No guessing.** If the AI is unsure about a Godot API or a rule, it says so and asks.
7. **Clean-room only.** We never copy code, art, or UI from other games. We write our own rules from our own notes.
8. **Mobile first.** Test on a real phone often.
9. **Every chat ends with a handoff.** Updated `STATE.md` is mandatory.
10. **Fun check before more features.** Milestone M1 must feel fun before we build further.

## How one chat works

1. Open a new chat. Attach files (see `07_HANDOFF_SYSTEM.md`, section "Context packs").
2. Paste the **Boot Prompt** from `08_PROMPTS.md`. Add the chat ID (for example `C05`).
3. The AI replies `READY`, asks questions, shows a plan. You say `go`.
4. Build task by task. When done, say `END CHAT`. The AI gives the handoff. You save it to the repo.

## Glossary

| Term | Meaning |
|---|---|
| Tide cycle | 6 real hours. Same for all players (global clock). |
| Phase | One of LOW, RISING, HIGH, FALLING. Each is 1.5 hours. |
| Water index | Number for the water height now: LOW=1, RISING=2, HIGH=3, FALLING=2. |
| Elevation | Height of a tile: DEEP -1, SEABED 0, REEF 1, MUDFLAT 2, SHORE 3, LAND 4. |
| Underwater | A tile is underwater when water index > elevation. Dry otherwise. |
| Draft | How deep a boat sits. Skiff 1, Trader 2. |
| Lane | A sea route between two islands. Has tide windows and a draft limit. |
| Harbor Hall | The main building. Its level gates progress. |
| Crew | Characters with a passive skill and an active skill. |
| Pause-not-lose | Production stops in the wrong tide and keeps its progress. |
| Spring tide | Event: HIGH tide rises to index 4. |
| Super low tide | Event: LOW tide drops to index 0. |
| Core Pack | Files 00 to 08 plus STATE.md. |

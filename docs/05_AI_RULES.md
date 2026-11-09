# 05 AI RULES

Version 1.0 | 2026-11-06 | Owner: Chat 00
These rules apply to **every chat**. The AI must follow them without being reminded.

---

## 1. How the AI answers

1. Use simple, short English. No big words.
2. **Ask first.** If anything is unclear, ask up to 3 questions **before** starting. Do not guess. Do not ask after finishing.
3. **Plan first.** Before code, show a short plan: steps and files. Wait for the word `go`.
4. **One task at a time.** Finish, test, then move on.
5. Say what you are **not sure** about. Never invent Godot functions, node names, or plugin settings. If unsure, say "check the Godot docs for X" and give a safe alternative.
6. If you need a file you cannot see, ask for it. Do not rebuild it from memory.
7. Keep replies focused. No extra theory unless asked.
8. End each reply with **one** clear next step.

---

## 2. How the AI writes code

| Rule | Detail |
|---|---|
| Language | GDScript 4. Static types everywhere (`var x: int`, `func f(a: int) -> bool`). |
| Names | Files and classes `PascalCase`. Variables, functions, ids `snake_case`. Constants `UPPER_SNAKE`. Signals in past tense. |
| Size | One class per file. About 300 lines max. Small functions (about 30 lines). |
| Comments | `##` doc comment on every class and public function. Explain **why**, not what. |
| Data | No magic numbers. Read from `data/*.json` through `Data`. |
| Logic vs UI | Game rules in `RefCounted` classes. No node access in them. |
| Talk | Systems talk through `EventBus` signals. |
| Time | Use `Clock.now()`. Never call `Time` or `OS` time directly in game logic. |
| Godot version | Use only Godot 4.3+ APIs (`TileMapLayer`, `await`, typed arrays). No Godot 3 code (`yield`, `onready` without `@`, `TileMap` layers). |
| Errors | Check for null and missing ids. Log with `Log.warn`. Never crash on bad data. |
| Performance | No allocation in `_process`. No `get_node` in loops. Use atlases. |
| Web | Use only features Godot Web supports (check the docs): no threads, no native plugins, no GDExtension, no `OS.execute`. Keep file reads inside `res://` and `user://`. |
| Tests | Every pure-logic class gets a GUT test file `tests/test_<class>.gd`. |
| Dependencies | Do not add plugins or libraries without asking and logging a decision. |

---

## 3. How the AI delivers code

1. Give the **full file** for new files and for files under 200 lines.
2. For edits to bigger files: give the exact block to **find** and the exact block to **replace**, with the function name.
3. Always show the **path** above each code block, for example `scripts/tide/TideModel.gd`.
4. After the code, give: **how to run it**, **what you should see**, and **how to test it**.
5. List every file created or changed at the end.
6. Give a git commit message in this style: `feat(tide): add TideModel with golden tests`. Types: `feat`, `fix`, `test`, `docs`, `refactor`, `chore`.
7. Do not rewrite files that do not need to change.

---

## 3b. Definition of done (per task)

- [ ] Code follows these rules
- [ ] GUT test added and passing (for logic)
- [ ] Runs in the web build in a browser (for visible things). Touch things are checked in a phone browser.	
- [ ] No new warnings in the Godot output
- [ ] Data changes also updated in `03_DATA_STARTER.md`
- [ ] Commit made

---

## 4. Scope control

- Only do what the current chat's roadmap block says.
- New idea? Put it in `STATE.md` > IDEAS PARKING LOT. Do not build it now.
- Never change a rule, a number, a name, or the file layout without a **DECISIONS entry**. Process: propose, wait for the user's yes, write the entry, then change the file(s).
- If a rule in `01`, `02`, or `03` looks wrong or two files disagree, **stop and tell the user**. Do not pick silently.

---

## 5. Clean-room and legal rules

- We **do not** decompile, copy, or imitate code, art, UI layouts, sounds, or names from any commercial game.
- Game **mechanics and ideas** may be used (they are not protected), but we write our own rules, numbers, and code from our own notes.
- Any "inspiration" is logged in `STATE.md` > INSPIRATION LOG as a short note about the **idea**, not the code.
- Open-source code may be used only if the license allows it (MIT, Apache 2.0, BSD, CC0). **GPL code is for learning only**, never copy it.
- Every outside asset (art, font, sound, plugin) goes into `STATE.md` > ASSET LEDGER with source, license, and link **before** it is used.
- AI-generated art is allowed. Keep the prompts. Check the tool's commercial-use terms. Log them in the ledger.

---

## 6. Git and files

- Branch per chat: `c05-production`. Merge to `main` only when "Done when" is true.
- Commit small and often (one task = one commit).
- Never commit keystores, passwords, or API keys.
- Docs live in `docs/`. After each chat, commit the updated `docs/STATE.md`.

---

## 7. When the AI makes a mistake

- Say so plainly, fix it, and say what changed.
- If a bug appears, ask for the **error text and the file**. Do not guess a fix from a screenshot description alone.
- After 2 failed fixes, step back: restate the problem, list 3 possible causes, test the most likely cause first.

---

## 8. Context discipline

- If the chat grows long (about 40 messages) or the AI starts to forget rules, run the **Handoff** and start a new chat.
- If you ever feel unsure what is true, `STATE.md` and the Core Pack win over the chat history.

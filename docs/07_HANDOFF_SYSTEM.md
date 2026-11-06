# 07 HANDOFF SYSTEM

Version 1.0 | 2026-11-06 | Owner: Chat 00
Goal: every new chat starts with the same knowledge and the same quality as the last one.

---

## 1. The idea in 5 lines

1. **Files are memory. Chats are not.**
2. The **Core Pack** (files 00 to 08) holds the design. It rarely changes.
3. **`STATE.md`** holds the live truth. It changes in **every** chat.
4. Every chat starts with the **Boot Prompt** and ends with the **Handoff Prompt**.
5. The **repo on GitHub** is the master copy. Claude Project knowledge is a copy for convenience.

---

## 2. One-time setup (do this once, 15 minutes)

1. Create the GitHub repo. Put all files in `docs/` and `tools/` (see `02_TECH_SPEC.md` §2).
2. In your Claude Project ("Gride"):
   - **Project knowledge:** upload `00`, `01`, `02`, `03`, `05`, `07`, `08`, `STATE.md`. Upload `04` and `06` too if there is space.
   - **Project instructions:** paste the short text from `08_PROMPTS.md` > "Project instructions".
3. Keep the Core Pack in one place on your computer: `tidebound/docs/`. That folder is always the newest.
4. Optional: in Project settings, leave the memory feature on. It is only a helper. **Never rely on it** for rules.

---

## 3. Source of truth

| What | Master copy | Copies |
|---|---|---|
| Design, rules, numbers, plans | `docs/*.md` in GitHub | Project knowledge |
| Live status | `docs/STATE.md` in GitHub | Project knowledge (re-upload each chat) |
| Code | GitHub repo | Pasted pieces in chats |

**Project knowledge does not update by itself.** After each chat, replace the changed files there.

---

## 4. Context packs (what to attach for each chat type)

Attach **only** what is needed. Smaller context means better answers.

| Chat type | Always attach | Also attach |
|---|---|---|
| Any chat | `00`, `STATE.md`, `05` | The block of this chat from `04` |
| Logic and systems (C02, C04, C05, C08, C09, C12 to C15) | above | `02`, the needed part of `03`, repo map, files to edit |
| Game design and balance | above | `01`, `03` |
| UI (C03 UI parts, C06, C07, C11) | above | `02` §11, `06`, screenshots |
| Art and audio (C17) | above | `06`, `01` §16 |
| Bug fix | `STATE.md`, `05` | Error text, failing file, repo map |
| Planning or changing rules | all files | - |

In Project knowledge the files are always visible, so you only need to attach **new or changed** files, the repo map, and the code files being edited.

### Code context: the repo map

The AI cannot see your repo. Give it a small map instead of all the code.

```
python tools/repo_map.py > repo_map.txt
python tools/repo_map.py --full scripts/tide/TideModel.gd scripts/tide/Tide.gd > code_context.txt
```
- `repo_map.txt` shows the folder tree and each script's class, signals, and function signatures (small).
- `code_context.txt` adds the full text of only the files you list.
- Paste or attach both at the start of a code chat. Re-run after big changes.
- Run it in Codespaces if Python is not on your laptop.

---

## 5. The chat life cycle

```
START  → Attach pack → Paste Boot Prompt + chat ID
       → AI says READY (summary) + asks questions → You answer
       → AI shows plan → You say "go"
WORK   → One task at a time → run it → test → commit
       → If rules must change: propose → you approve → DECISIONS entry
END    → You say "END CHAT" → AI gives the handoff block
       → You save: STATE.md, doc edits, code → commit → re-upload to Project knowledge
```

**When to end a chat early:** about 40 messages, the AI repeats mistakes, or it forgets rules. Do the handoff and start fresh. A fresh chat with good files beats a long tired chat.

---

## 6. Handoff checklist (you, after each chat) - 5 minutes

- [ ] Save the new `STATE.md` into `docs/` and commit (`docs: handoff C05`)
- [ ] Apply any doc edits the AI listed (Bible, Tech, Data) and commit
- [ ] Commit and push all code. Merge the branch if "Done when" is true
- [ ] Re-upload changed files to Project knowledge (replace old versions)
- [ ] Check that `STATE.md` > NEXT CHAT names the right chat and first task

---

## 7. Rules that keep chats consistent

1. **One truth.** A fact lives in one file only (`00` explains where).
2. **Append-only DECISIONS.** Never edit old entries. A new entry can replace an old one (say "supersedes D-007").
3. **IDs everywhere.** Chats: `C05`. Decisions: `D-012`. Tasks: `C05.3` (chat 5, task 3). Rules: `R-TIDE-5`. Use them in prompts, commits, and notes.
4. **Versions.** Each doc header has `Version`. Bump the version when you change it. `STATE.md` records the versions in use.
5. **Dates** use `YYYY-MM-DD`.
6. **Naming drift guard.** All ids come from the JSON data files. The AI must not invent new ids.
7. **Disagreement rule.** If two files disagree, `01`/`02`/`03` win over `04`, and `STATE.md` DECISIONS win over everything older.
8. **Conflict between old chat and files:** files win.

---

## 8. Recovery cases

| Problem | Fix |
|---|---|
| New chat acts like it knows nothing | Use the **Recovery Prompt** (`08`). Attach the Core Pack. |
| AI changes a rule silently | Say: "Check 05 section 4. Revert and propose a DECISIONS entry." |
| Lost `STATE.md` | Rebuild from the last handoff block, the git log (`git log --oneline`), and the roadmap. Use the Recovery Prompt. |
| Two chats edited the same file | Use git: compare, keep the right parts, log a decision. Work on **one chat at a time**. |
| Project knowledge is full | Remove `04`/`06` from knowledge. Attach them only when needed. |
| Code and docs disagree | Run the **Audit Prompt** (`08`). Fix the one that is wrong and log it. |

---

## 9. What never goes into chat memory only

Rules, numbers, ids, decisions, file paths, the current task, bug list, asset licenses. All of these must be in a file.

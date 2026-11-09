# 08 PROMPTS

Version 1.0 | 2026-11-06 | Owner: Chat 00
Copy and paste. Replace the parts in `[brackets]`. Each prompt is in one code block.

---

## 1. Project instructions (paste once in Claude Project settings)

```
You are my senior game developer and tech lead for the mobile game "Tidebound" (Godot 4, GDScript).
I am a solo developer with an old laptop. All code is written by AI in chats.

The Core Pack files in Project knowledge are the truth. STATE.md has the live status.
Always follow 05_AI_RULES.md.
Use simple, short English.
Ask me questions BEFORE starting if anything is unclear. Never guess.
Plan first, then wait for "go".
Never change a rule, number, name, or file layout without a DECISIONS entry that I approve.
Never invent Godot APIs. Say when you are unsure.
```

---

## 2. BOOT PROMPT (start of every chat)

```
Chat ID: [C05] - [Production and economy]
Date: [YYYY-MM-DD]

You are my senior game developer and tech lead for "Tidebound" (Godot 4, GDScript, web).
I am a solo developer with an old laptop. I build only with AI.

Read in this order:
1. 00_START_HERE.md
2. STATE.md
3. 04_ROADMAP.md - only the block for this chat
4. 05_AI_RULES.md
5. Only the spec sections that block lists (01, 02, 03)
6. The repo map and code files I attached

Rules for this chat:
- Simple, short English.
- Ask me up to 3 questions first if anything is unclear. Do not guess.
- Then show a short plan (steps and files). Wait for my "go".
- One task at a time. Test before the next task.
- Do not change rules, numbers, names, or layout without a DECISIONS entry I approve.
- If you need a file you cannot see, ask me. Never invent file content or Godot APIs.
- Stay inside this chat's scope. New ideas go to the IDEAS PARKING LOT.
- When I say "END CHAT", run the Handoff.

Reply now with exactly this:
READY
- Phase / last done: ...
- Goal of this chat: ...
- Files I still need from you: ...
- Anything in the files that looks wrong or unclear: ...
- My questions (max 3): ...
```

---

## 3. TASK PROMPT (to start each task inside a chat)

```
Task [C05.3]: [Construction and upgrade with BuilderQueue].
Use the "Tasks" and "Done when" from 04_ROADMAP.md.
Give me: the plan (files and function signatures), then the code, then how to run it, what I should see, and how to test it.
Include the GUT test if this is logic.
End with the git commit message.
```

---

## 4. HANDOFF PROMPT (end of every chat)

```
END CHAT. Run the Handoff for [C05].

Give me ONE single code block with these parts in order:

1. NEW STATE.md - the full updated file. Update: version table, current phase, DONE list (with task ids), IN PROGRESS, NEXT CHAT (chat id + first task + files to attach), KNOWN BUGS, OPEN QUESTIONS, IDEAS PARKING LOT, ASSET LEDGER, INSPIRATION LOG, TEST NOTES, CHAT LOG entry for this chat (date, id, what was done, files changed).
2. DECISIONS - new entries only (D-xxx, date, decision, reason, files affected, supersedes).
3. DOC EDITS - exact find/replace blocks for any change to 01, 02, 03, 04. Say "none" if none.
4. FILES CHANGED - list of all code and data files created or changed, with paths.
5. COMMIT MESSAGES - one per task.
6. NEXT BOOT LINE - the first line I paste in the next chat, for example: "Chat ID: C06 - Save, Harbor Hall, HUD".
7. SELF-CHECK - list anything where code, rules, and numbers might now disagree. Say "none" if none.

Do not skip any part. Do not add new ideas. Keep it simple.
```

---

## 5. RECOVERY PROMPT (a chat lost context, or STATE.md is lost)

```
Recovery. I am starting fresh and need you to rebuild context.
I attached the Core Pack and [STATE.md / git log / last handoff].

Step 1: Read 00_START_HERE.md and 04_ROADMAP.md.
Step 2: From the files, tell me in 10 lines: what the game is, what is done, what is next.
Step 3: List anything you cannot confirm from the files. Ask me about it (max 3 questions).
Step 4: Propose a new STATE.md I can save.
Do not write any game code yet. Do not guess missing facts.
```

---

## 6. BUG FIX PROMPT

```
Bug in [C05.4].
What I did: [steps]
What I expected: [...]
What happened: [...]
Error text (copy from the Godot output):
[paste]
Files: [attached or pasted]

Follow 05 section 7. First ask for anything missing. Then list up to 3 likely causes, say which is most likely and why, and give the smallest fix. Add a test that would have caught it.
```

---

## 7. DESIGN CHANGE PROMPT (when a rule or number must change)

```
I want to change: [describe].
Reason: [why].
Check 01, 02, 03 and tell me:
1. Which rules, numbers, and files are affected.
2. Side effects on other systems.
3. A proposed DECISIONS entry.
4. Exact DOC EDITS (find and replace blocks).
Do not change anything yet. Wait for my approval.
```

---

## 8. AUDIT PROMPT (check code against the docs)

```
Audit mode for [system, for example Production].
Compare the attached code and tests with 01, 02, and 03.
List: (a) rules that the code breaks, (b) numbers not read from JSON, (c) missing tests, (d) files over 300 lines or with node calls in logic classes.
Rank by risk. Do not fix anything yet. Propose a fix plan with tasks.
```

---

## 9. MILESTONE REVIEW PROMPT (end of M1 to M5)

```
Milestone review for [M1].
Use the gate in 04_ROADMAP.md and the results I paste below.
Results: [playtest notes, test results, performance numbers]
Tell me: pass or fail, the top 3 risks, what to change before the next chat, and whether any DECISIONS entry is needed. Be honest and short.
```

---

## 10. ART PROMPT (for the AI chat that guides art work)

```
Art task: [asset list].
Follow 06_ART_GUIDE.md.
For each asset give: file name (per the naming rules), size, and a prompt using the template for my image tool, with the negative prompt.
Also give the ASSET LEDGER line to add to STATE.md.
```

---

## 11. Quick commands (type in any chat)

| Say | AI must do |
|---|---|
| `go` | Start the plan you showed |
| `status` | Give a 5-line status from STATE.md and the roadmap block |
| `scope check` | List what is in and out of scope for this chat |
| `rules check` | Re-read 05 and say which rules apply to the current task |
| `END CHAT` | Run the Handoff Prompt |

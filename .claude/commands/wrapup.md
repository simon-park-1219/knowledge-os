Session end routine — save context and summarize.

Input: $ARGUMENTS (optional: custom session summary text)

Follow this process:

---

## Step 1: SUMMARIZE — Collect Session Activity

### 1.1 Identify Modified Notes
- Use `Glob` to scan vault for `.md` files
- Compare modification timestamps with session start time
  (stored in mcp__memory "vault-state" → "last_session_date")
- Categorize: newly created vs modified
- Group by PARA folder

### 1.2 Reconstruct Session Activity
- Read `mcp__memory` "active-context" for session start state
- Diff against current state:
  - New notes: infer commands from file types:
    - `00-Inbox/*.md` → `/capture`
    - `sync-history/*-sync-report.md` → `/sync`
    - `devlogs/*-devlog.md` → `/devlog`
    - `30-Resources/business-documents/` → `/import`
  - Modified project notes → `/sync` or `/onboard`
- Count total notes created, modified, links added

### 1.3 Generate Session Summary
- If `$ARGUMENTS` provided → use as base summary
- If not → auto-generate:
  ```
  "[N]개 노트 생성, [N]개 수정.
  주요 작업: [top 3 actions from activity].
  Focus: [most-active project or topic]."
  ```

---

## Step 2: SAVE — Persist Context to mcp__memory

### 2.1 Update "active-context"

Determine current state:
- **current_focus**: Most-modified project folder, or main topic from created notes
- **active_projects**: Projects with activity today (created/modified notes in `10-Projects/*/`)
- **recent_topics**: Top 5 keywords from created/modified notes (titles + tags)
- **pending_tasks**: Open items found:
  - Specs with `status: draft` in active projects
  - Bugs with `status: open`
  - Inbox items not triaged
  - Notes flagged for review
- **next_session_suggestions**: Based on today's work:
  - Unfinished sync → "/sync [project]"
  - New imports not analyzed → "/analyze [[note]]"
  - Garden overdue → "/garden"
  - Project not synced recently → "/sync [project]"

```
mcp__memory__add_observations to "active-context":
  "current_focus: [detected focus]"
  "active_projects: [project list]"
  "recent_topics: [keywords]"
  "pending_tasks: [task list]"
  "next_session_suggestions: [suggestions]"
```

If observations > 10 → use `mcp__memory__delete_observations` to remove oldest ones first.

### 2.2 Create Session Entity

```
mcp__memory__create_entities:
  name: "session-YYYY-MM-DD"
  type: "session"
  observations:
    - "summary: [session summary]"
    - "notes_created: N ([file list])"
    - "notes_modified: N ([file list])"
    - "health_score_start: XX (from /autopilot)"
    - "health_score_end: XX (recalculate quick)"
    - "auto_fixes: N ([details])"
```

### 2.3 Update "vault-state"

```
mcp__memory__add_observations to "vault-state":
  "last_session_date: YYYY-MM-DD"
  "sessions_since_gardening: [increment by 1]"
```

### 2.4 Create Relations

```
mcp__memory__create_relations:
  session-today --"continues"--> [previous session entity if exists]
  active-context --"updated_by"--> session-today
  vault-state --"checked_by"--> session-today
```

---

## Step 3: RECORD — Update Daily Note

### 3.1 Find or Create Daily Note
- Check if `60-Daily/YYYY/MM/YYYY-MM-DD.md` exists
- If exists → read it
- If not exists → create from `50-Templates/daily-note.md`

### 3.2 Append Session Record
- Find `## Work Log` section (or create if missing)
- Append under `### Session Summary`:

```markdown
### Session Summary (Autopilot)

**Notes**: {{notes_created}} created, {{notes_modified}} modified
**Commands**: {{commands_used}}
**Health**: {{health_score_start}} → {{health_score_end}} ({{health_delta}})

**Key Work**:
- {{accomplishment_1}}
- {{accomplishment_2}}

**Created Notes**:
- [[note-1]]
- [[note-2]]
```

### 3.3 Add Wikilinks
- Ensure all created/significantly modified notes have wikilinks in the daily note

---

## Step 4: SUGGEST — Next Session Actions

### 4.1 Analyze Current State
Scan for actionable items:
- Inbox items needing triage (count)
- Projects needing `/sync` (check last_synced vs repo HEAD)
- Upcoming deadlines (spec target_dates within 7 days)
- Gardening due (`sessions_since_gardening` > 5)
- Stale active notes (not updated > 14 days)

### 4.2 Generate Priority Suggestions
Create 3-5 prioritized suggestions:

```
Priority scoring:
  - Overdue task → +50
  - Active project needs sync → +40
  - Approaching deadline → +35
  - Garden overdue → +30
  - Inbox needs triage → +25
  - Stale content → +20
  - General maintenance → +10
```

### 4.3 Store Suggestions
```
mcp__memory__add_observations to "active-context":
  "next_session_suggestions: 1. [suggestion] 2. [suggestion] 3. [suggestion]"
```

---

## Output Format

```
📋 SESSION WRAPUP — YYYY-MM-DD

━━━ SUMMARY ━━━
[Session summary]
Notes: [N] created, [N] modified
Health: [start] → [end] ([delta])

━━━ CONTEXT SAVED ━━━
Focus: [current focus]
Projects: [active projects]
Pending: [pending tasks]

━━━ NEXT SESSION ━━━
1. [priority suggestion]
2. [follow-up suggestion]
3. [maintenance suggestion]

✅ Context saved to mcp__memory.
💡 Run /autopilot next session to resume.
```

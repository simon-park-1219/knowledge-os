---
name: wrapup
description: 세션 종료 자동화 — 컨텍스트 저장, 세션 요약, 다음 세션 제안
---

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

### 3.4 Append "Today I Learned / 오늘의 인사이트" Section
- Find or create `## TIL / 오늘의 인사이트` section in today's daily note
- Auto-generate 3 bullet points:
  1. **의사결정**: 이 세션에서 내린 주요 결정과 그 근거 (예: "A 대신 B를 선택 — 이유: ...")
  2. **발견**: 새로 알게 된 사실, 패턴, 연결 (예: "X와 Y가 관련 있다는 것을 발견")
  3. **삽질/교훈**: 시행착오에서 배운 것 (없으면 생략)
- 이 3줄이 "복리의 원재료" — 나중에 `/distill`이나 AI 검색의 소스가 됨
- 세션에서 비자명한 인사이트가 없으면 "특이 사항 없음"으로 간략히 기록

### 3.5 Distill Trigger — `/distill` 제안 판단
- 이 세션에서 다음 조건 중 하나라도 충족하면 `/distill` 실행을 제안:
  - 새로운 개념/프레임워크가 대화에서 등장 (예: 비교 분석, 아키텍처 결정)
  - 문서 분석에서 비자명한 인사이트가 도출됨
  - 여러 노트를 교차 참조하여 새로운 연결을 발견
  - 의사결정 과정에서 근거 체계가 정리됨
- 판단 기준:
  ```
  distill_score = 0
  새 프레임워크/패턴 도출          → +40
  3개 이상 노트 교차 참조          → +30
  의사결정 + 근거 기록             → +25
  기존 vault에 없는 주제 논의       → +20
  단순 작업(import, sync, commit)만 → +0
  ```
- `distill_score >= 30` → 사용자에게 제안:
  ```
  💡 이 세션에서 증류할 만한 인사이트가 감지되었습니다.
  추천 토픽: "[detected topic]"
  실행하려면: /distill [topic]
  ```
- 제안 내용을 mcp__memory "active-context"에도 기록:
  `"distill_suggestion: [topic] (score: XX)"`

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

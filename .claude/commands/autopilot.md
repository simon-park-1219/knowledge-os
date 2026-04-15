Session startup automation — Knowledge OS morning routine.

Mode: $ARGUMENTS (default: "full")
Options: "quick" (heartbeat + light janitor only, ~2min), "full" (all 3 phases, ~5min)

Run the Autopilot Agent to execute these phases:

---

## Phase 1: HEARTBEAT (Context Load) — ~1 min

### 1.1 Load Previous Context
- Query `mcp__memory__open_nodes` for `["active-context", "vault-state"]`
- If entities exist → parse observations:
  - `current_focus`, `active_projects`, `recent_topics`
  - `pending_tasks`, `next_session_suggestions`
  - `last_session_date`, `health_score`
- If entities don't exist (first run) → initialize defaults:
  ```
  mcp__memory__create_entities:
    name: "vault-state", type: "system"
    observations: ["last_session_date: none", "health_score: 0", "sessions_since_gardening: 0"]

    name: "active-context", type: "context"
    observations: ["current_focus: none", "active_projects: []", "recent_topics: []"]

    name: "health-history", type: "metrics"
    observations: ["initialized: YYYY-MM-DD"]
  ```

### 1.2 Scan Recent Changes
- Use `Glob` pattern `**/*.md` in vault
- Compare file modification dates against `last_session_date`
- Categorize: new notes (created after last session), modified notes
- Group by PARA folder (00-Inbox, 10-Projects, 20-Areas, 30-Resources, 60-Daily)
- Check for externally added files (e.g., Obsidian mobile captures, other tools)

### 1.3 Check Active Projects (Code-to-Knowledge)
- For each project in `active_projects`:
  - Read `10-Projects/[name]/_project-overview.md` frontmatter
  - If `repo_path` exists:
    - Run `Bash`: `git -C [repo_path] rev-parse --short HEAD 2>/dev/null`
    - Compare with `last_synced_commit` from frontmatter
    - If different → flag: "프로젝트에 새 커밋 있음 → /sync 제안"
  - If `github_url` exists and `gh` available:
    - Check open issue/PR count changes

### 1.4 Generate Morning Briefing
Present to user in this format:

```
🤖 Good morning! Knowledge OS Autopilot Report

📅 Last session: [date] — [summary]
   Days since: [N]일

📝 Since then:
   - [N] new notes, [N] modified notes
   - [project] has [N] new commits → suggest: /sync [project]
   - [N] items waiting in Inbox

🎯 Current focus: [focus area]
📋 Pending: [task1], [task2]

💡 Suggestions:
   1. [suggestion from active-context]
   2. [suggestion from project status]
   3. [suggestion from pending items]
```

---

## Phase 2: JANITOR (Health Check) — ~2 min

### 2.1 Quick Health Scan (always runs)

**Inbox Age Check**:
- `Glob` pattern `00-Inbox/*.md`
- For each file, read frontmatter `created:` date
- Count items with created > 3 days ago

**Frontmatter Validation** (sample-based for speed):
- Get last 20 modified notes in vault (excluding `50-Templates/`, `.claude/`)
- For each, read first 20 lines and check for required YAML fields:
  - `title`, `created`, `updated`, `tags`, `type`, `status`
- Count notes with missing fields

**Broken Link Quick Check**:
- From same 20 recent notes, extract `[[wikilinks]]` via Grep
- For each unique wikilink target, verify file exists with `Glob`
- Count broken links

### 2.2 Auto-Fix (safe operations only)

For notes with missing frontmatter fields found in 2.1:
- Missing `updated:` → Add field with today's date
- Missing `status:` → Add `status: draft`
- Missing `type:` → Infer from location:
  - `00-Inbox/` → `type: note`
  - `10-Projects/*/bugs/` → `type: bug`
  - `10-Projects/*/specs/` → `type: spec`
  - `10-Projects/*/devlogs/` → `type: devlog`
  - `10-Projects/*/sync-history/` → `type: sync-report`
  - `60-Daily/` → `type: daily`
  - Default → `type: note`
- Use `Edit` to insert missing fields into YAML block
- Log every auto-fix: "Auto-fixed: [file] — added [field]: [value]"

### 2.3 Full Health Scan (only in "full" mode)

Run complete health check (Gardener Agent algorithm):
- Orphan note detection (no incoming [[wikilinks]])
- Stale content check (active + not updated >30 days)
- Full broken link scan (all notes, not just sample)
- Tag consistency check (against CLAUDE.md taxonomy)
- MOC freshness check (notes not reflected in MOCs)
- **DON'T auto-fix these — only REPORT**

### 2.4 Calculate Health Score

```
base = 100
penalties:
  orphan_count    × 2  (max -20)
  stale_count     × 3  (max -15)
  broken_links    × 5  (max -25)
  missing_fm      × 3  (max -15)
  bad_tags        × 1  (max -10)
  old_inbox_items × 2  (max -10)
  stale_mocs      × 2  (max -10)

health_score = max(0, base - sum(penalties))
```

Rating:
- 🟢 90-100: Excellent
- 🟢 75-89: Good
- 🟡 60-74: Fair — `/garden` 권장
- 🔴 0-59: Needs Attention — `/garden full` 강력 권장

### 2.5 Health Trend Analysis

- Load `health-history` from `mcp__memory`
- Compare current score with last 3-5 sessions
- Determine trend:
  - **Improving** (↑5+ points): "Vault 건강 상태가 개선되고 있습니다!"
  - **Stable** (±5): "Vault 건강 상태가 안정적입니다."
  - **Degrading** (↓5+ points): "Vault 건강 상태가 하락 추세입니다. /garden 권장."
- If degrading 3+ consecutive sessions → escalate to strong recommendation

### 2.6 Store Health Metrics

```
mcp__memory__add_observations to "vault-state":
  "health_score: [score]"
  "last_session_date: [today]"

mcp__memory__add_observations to "health-history":
  "YYYY-MM-DD: score=XX, orphans=N, stale=N, broken=N, inbox=N"
```

If health-history has >10 observations → delete oldest with `mcp__memory__delete_observations`

---

## Phase 3: PROCESSOR (Pending Items) — ~2 min
**(Skip in "quick" mode)**

### 3.1 Inbox Classification Suggestions

- Read all notes in `00-Inbox/`
- For each item > 1 day old:
  - Read content, extract top keywords
  - Check against `active_projects` from active-context
  - Calculate PARA destination confidence:
    - If keywords match project name/tags → `10-Projects/[name]/` (high confidence)
    - If keywords match area topics → `20-Areas/[area]/` (medium confidence)
    - If technical reference → `30-Resources/` (medium confidence)
  - **Report suggestion, NEVER auto-move**

### 3.2 Auto-Link Enhancement

- Find notes created since last session with < 3 outgoing [[wikilinks]]
- For each, run lightweight scoring (same as `/connect` Tier 1 + Tier 2):
  - Same project/ tag → +50
  - Same area/ tag → +30
  - mcp__memory relation → +30
  - Tag overlap → +10 each
- If any candidate scores ≥ 60:
  - Auto-add `[[wikilink]]` to `## Related Notes` section
  - Report: "Auto-linked: [[note]] → [[target]] (score: XX)"

### 3.3 Proactive Recommendations

Scan vault for actionable items and generate top 5 recommendations:

**Priority scoring**:
- Active project match → +40
- Urgency (approaching deadline within 7 days) → +30
- Staleness (active note not updated >14 days) → +20
- Unprocessed (import not analyzed, sync not run) → +15

**Check for**:
a. Specs with approaching `target_date` (within 7 days)
b. Bugs with `status: open` in active projects
c. Stale notes related to active projects (>14 days)
d. Recent `/import` results not yet `/analyze`d
e. Active projects not `/sync`ed in >7 days
f. `/garden` not run in >14 days (use `sessions_since_gardening`)

Sort by priority score, present top 5.

---

## Output Format

Display the Autopilot Report inline (don't save as file — too frequent):

```
🤖 AUTOPILOT REPORT — YYYY-MM-DD

━━━ BRIEFING ━━━
[Phase 1 output]

━━━ HEALTH CHECK ━━━
Health Score: XX/100 [trend]
[Phase 2 summary table]
Auto-fixes: [N] applied
[Phase 2 trend]

━━━ PROCESSING ━━━ (full mode only)
Inbox: [N] items to triage
Auto-linked: [N] new connections
[Phase 3 recommendations]

━━━ READY ━━━
Run /wrapup before ending this session.
```

Store session start state in `mcp__memory` for `/wrapup` to compare.

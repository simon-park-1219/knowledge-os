---
name: autopilot
description: 세션 시작 자동화 — 컨텍스트 로드, 건강 점검, 미처리 항목 처리
---

Session startup automation — Knowledge OS morning routine.

Mode: $ARGUMENTS (default: "full")
Options:
- "quick" (heartbeat + light janitor only, ~2min)
- "full" (all 3 phases, ~5min)
- "active" (full + 자동 실행 모드, ~10min) — 🟡 유지보수 항목을 사용자 확인 없이 바로 실행

Run the Autopilot Agent to execute these phases.

**Graceful Degradation**: If `mcp__memory` is not available, skip context load/save steps and operate with local file analysis only. Report: "⚠️ Memory server not configured. Running in local-only mode."

**First Run**: If infrastructure files (`_world-model.md`, `_master-index.md`, `_changelog.md`) don't exist, create them with default bootstrap content before proceeding.

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

### 1.4 Update World Model (`_world-model.md`)

Living document로 프로젝트 전체 상태를 관리한다. 매 세션마다 갱신.

- Read `_world-model.md` (vault 루트)
- For each project in `10-Projects/*/`:
  - Read `_project-overview.md`의 frontmatter + 첫 섹션
  - 프로젝트 상태 판단:
    - `status:` frontmatter 기반
    - 최근 수정일 (최신 파일 기준) → "활발" / "정체" / "비활성"
    - `repo_path` 있으면 git 커밋 상태 확인
  - 다음 마일스톤: spec의 `target_date`, 또는 overview에서 추출
  - 블로커: bugs with `status: open`, stale items

- `_world-model.md`의 프로젝트 상태 테이블 갱신 (`Edit`):
  ```markdown
  | 프로젝트 | 단계 | 최근 활동 | 다음 마일스톤 | 블로커 |
  ```

- 크로스-프로젝트 관계 섹션 갱신:
  - 공유 태그, 공유 참조 노트, 동일 area/ 태그 기반으로 관계 식별
  - 예: project-alpha ↔ project-beta (같은 area/startup)

- 우선순위 판단:
  ```
  마감 7일 이내        → 🔴 긴급
  활발 + 블로커 있음    → 🟡 주의
  정체 (7일+ 미수정)   → 🔵 재검토
  비활성 (30일+ 미수정) → ⚪ 아카이브 고려
  ```

### 1.5 Generate Morning Briefing
Present to user in this format:

```
🤖 Good morning! Knowledge OS Autopilot Report

📅 Last session: [date] — [summary]
   Days since: [N]일

📝 Since then:
   - [N] new notes, [N] modified notes
   - [project] has [N] new commits → suggest: /sync [project]
   - [N] items waiting in Inbox

🌍 World Model:
   | 프로젝트 | 상태 | 다음 마일스톤 | 블로커 |
   |---------|------|------------|-------|
   | [project-1] | 🟢 활발 | [milestone] | - |
   | [project-2] | 🟡 주의 | [milestone] | [blocker] |

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

### 3.3 Proactive Recommendations — "AI가 먼저 할 수 있는 일"

**목표**: 사용자가 묻기 전에 AI가 먼저 유용한 행동을 제안한다.
3가지 카테고리로 분류하여 각 1~2개씩, 총 3~5개 추천.

#### A. 🔴 긴급 (사용자가 모르고 있을 수 있는 것)

**Priority scoring**:
- Active project match → +40
- Urgency (approaching deadline within 7 days) → +30
- Staleness (active note not updated >14 days) → +20
- Unprocessed (import not analyzed, sync not run) → +15

**Check for**:
a. Specs with approaching `target_date` (within 7 days)
b. Bugs with `status: open` in active projects
c. `_world-model.md`에서 🔴 긴급 프로젝트의 미완료 항목
d. 미커밋 변경사항이 10개 이상 (데이터 손실 위험)

#### B. 🟡 유지보수 (AI가 자동으로 처리 가능한 것)

**Check for**:
e. `/garden` not run in >14 days (use `sessions_since_gardening`) → "제가 /garden 실행할까요?"
f. `_world-model.md` 갱신이 3일+ 지남 → "World Model을 갱신하겠습니다" (확인 없이 자동 실행)
h. Orphan 노트 3개 이상 → "/connect로 연결해드릴까요?"

#### C. 🟢 성장 (복리 효과를 위한 선제 제안)

**Check for**:
i. Daily Note가 3일 연속 없음 → "오늘 Daily Note를 생성할까요?"
j. Recent `/import` results not yet `/analyze`d → "분석 안 된 문서가 있습니다"
k. Active projects not `/sync`ed in >7 days → "/sync [project] 제안"
l. 최근 5세션 동안 `/distill` 0회 → "대화 인사이트를 vault에 기록하는 습관을 권장합니다"
m. TIL/캡처 노트가 최근 7일간 0개 → "배움/발견을 /capture TIL:로 기록해보세요"

#### 출력 형태

```
🤖 AI가 제안하는 오늘의 액션:

🔴 긴급:
  1. my-project 제출 마감 D-3 — 미완료 항목 확인 필요
  
🟡 유지보수 (제가 바로 실행 가능):
  2. /garden 14일 미실행 — 실행할까요?
  3. World Model 갱신 (자동 실행합니다)

🟢 성장:
  4. Daily Note 3일 연속 없음 — 오늘 생성할까요?
  5. TIL 캡처 7일간 0건 — /capture TIL: 로 배운 것을 기록해보세요
```

**실행 정책 (mode별)**:

| Mode | 🔴 긴급 | 🟡 유지보수 | 🟢 성장 |
|------|---------|-----------|---------|
| `full` | 보고만 | 제안 (확인 후 실행) | 제안만 |
| `active` | 보고 + 긴급 알림 | **확인 없이 자동 실행** | 제안 + Daily Note 자동 생성 |

**`active` 모드에서 자동 실행되는 항목** (사용자 입력 불필요):
- World Model 갱신
- Daily Note 생성 (없으면)
- frontmatter auto-fix (누락 필드)
- orphan 노트 3개 이상 → 자동 `/connect` (score≥60만)
- garden 14일+ 미실행 → 자동 `/garden` (report only, auto-fix만)

**`active` 모드에서도 사용자 확인 필요한 항목**:
- 노트 삭제/이동
- 프로젝트 아카이브
- 대규모 리팩터링 (/garden full)

Sort by priority score within each category, present top 5 total.

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

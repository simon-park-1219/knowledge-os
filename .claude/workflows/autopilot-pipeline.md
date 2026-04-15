# Autopilot Pipeline Workflow
# 오토파일럿 파이프라인 워크플로우

Automated vault operations inspired by David's Alfred system.
David의 Alfred 시스템에서 영감받은 세션 수명주기 자동화 파이프라인.

**Trigger**: 매 세션 시작(`/autopilot`)과 종료(`/wrapup`)
**Persistence**: `mcp__memory` 지식 그래프에 세션 간 상태 저장

## Architecture: 3 Subsystems / 아키텍처: 3개 서브시스템

```
┌──────────────────────────────────────────────────────────────────────┐
│                      AUTOPILOT PIPELINE                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  SESSION START (/autopilot)                                          │
│  ┌───────────┐   ┌───────────┐   ┌───────────┐                     │
│  │ HEARTBEAT │ → │  JANITOR  │ → │ PROCESSOR │                     │
│  │   (맥박)   │   │  (청소부)  │   │  (처리기)  │                     │
│  └───────────┘   └───────────┘   └───────────┘                     │
│       │               │               │                              │
│       ▼               ▼               ▼                              │
│  - ctx 로드        - 건강 점검    - 미처리 항목                       │
│  - 브리핑 생성     - 자동 수정    - 자동 분류 제안                    │
│  - 프로젝트 현황   - 점수 추세    - 선제적 추천                       │
│                                                                      │
│  SESSION ACTIVE (Post-Processing Hooks)                              │
│  ┌──────────────────────────────────────────┐                       │
│  │ /capture → cross-capture link + ctx       │                       │
│  │ /import  → project cross-ref + batch link │                       │
│  │ /sync    → spec alert + stale detection   │                       │
│  └──────────────────────────────────────────┘                       │
│                                                                      │
│  SESSION END (/wrapup)                                               │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐       │
│  │ SUMMARIZE │→ │   SAVE    │→ │  RECORD   │→ │  SUGGEST  │       │
│  │   (요약)   │  │  (저장)   │  │   (기록)   │  │  (제안)    │       │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘       │
│                                                                      │
│                     mcp__memory (영속 상태)                           │
│  ┌─────────────────────────────────────────────────────┐            │
│  │ vault-state │ active-context │ sessions │ health    │            │
│  └─────────────────────────────────────────────────────┘            │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Session Start — /autopilot

### Agent: Autopilot Agent (orchestrator)
### Delegates to: Gardener (health + review), Curator (inbox), Business-Analyst (activity + research)

### Steps
```markdown
- [ ] HEARTBEAT: Load active-context and vault-state from mcp__memory
- [ ] HEARTBEAT: Scan recent changes since last session
- [ ] HEARTBEAT: Check active project repos for new commits
- [ ] HEARTBEAT: Generate Morning Briefing
- [ ] JANITOR: Record health score BEFORE auto-fixes (Before 스냅샷)
- [ ] JANITOR: Quick health scan (inbox, frontmatter, links)
- [ ] JANITOR: Auto-fix safe issues (missing frontmatter fields)
- [ ] JANITOR: Record health score AFTER auto-fixes (After 스냅샷)
- [ ] JANITOR: Calculate delta (Before→After) and include in Morning Briefing
- [ ] JANITOR: Store Before/After in mcp__memory session entity:
        `"session-YYYY-MM-DD janitor: score XX→YY (+Z), auto-fixed: N items"`
- [ ] JANITOR: Analyze health trend (compare with previous 3-5 sessions)
- [ ] PROCESSOR: Suggest inbox classifications (full mode)
- [ ] PROCESSOR: Auto-link under-connected notes (full mode)
- [ ] PROCESSOR: Generate proactive recommendations (full mode)
```

### Morning Briefing에 포함할 Janitor Before/After
```markdown
### 🔧 Janitor Report

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| Health Score | XX | YY | +Z |
| Auto-fixed Items | — | N | — |
| 추세 (최근 3회) | XX, YY, ZZ | | ↑/→/↓ |
```

### Exit Criteria
- [ ] Autopilot Report displayed to user (including Janitor Before/After delta)
- [ ] Health metrics (Before/After) stored in mcp__memory
- [ ] Session start state recorded

---

## Phase 2: Session Active — Post-Processing Hooks

### Agent: Autopilot Agent (lightweight, triggered automatically)

### Triggers
```markdown
After /capture:
  - [ ] Update active-context with last_capture
  - [ ] Check cross-capture connections (7-day window)
  - [ ] Suggest project association if applicable

After /import:
  - [ ] Update active-context with last_import
  - [ ] Cross-reference with active projects
  - [ ] Check batch import inter-connections

After /sync:
  - [ ] Update active-context with last_sync
  - [ ] Alert if API/Schema changes affect specs
  - [ ] Detect stale knowledge from architecture changes
```

### Exit Criteria
- [ ] Post-processing alerts/suggestions displayed inline
- [ ] active-context updated

---

## Phase 3: Session End — /wrapup

### Agent: Autopilot Agent (orchestrator)
### Delegates to: Writer (summary), Business-Analyst (activity scan)

### Steps
```markdown
- [ ] SUMMARIZE: Collect session activity (created/modified notes)
- [ ] SUMMARIZE: Reconstruct commands used
- [ ] SUMMARIZE: Generate session summary
- [ ] SAVE: Update active-context in mcp__memory
- [ ] SAVE: Create session-YYYY-MM-DD entity
- [ ] SAVE: Update vault-state
- [ ] SAVE: Create session relations
- [ ] RECORD: Append to Daily Note
- [ ] RECORD: Add wikilinks to daily note
- [ ] SUGGEST: Analyze actionable items
- [ ] SUGGEST: Generate 3-5 priority suggestions
- [ ] SUGGEST: Store suggestions in active-context
```

### Exit Criteria
- [ ] Wrapup Report displayed to user
- [ ] Context saved to mcp__memory
- [ ] Daily Note updated
- [ ] Next session suggestions stored

---

## Modes / 모드

| Mode | Commands | Time | Use When |
|------|----------|------|----------|
| Quick | `/autopilot quick` | ~2min | 빠른 체크만 필요할 때 |
| Full | `/autopilot` | ~5min | 일반적인 세션 시작 |
| End | `/wrapup` | ~3min | 세션 종료 시 |

---

## Recommended Daily Flow / 권장 일일 흐름

```
1. 세션 시작:  /autopilot          → 브리핑 확인 + 추천 작업 검토
2. 작업 수행:  /capture, /import...  → 자동 후처리 (cross-link, ctx update)
3. 세션 종료:  /wrapup              → 컨텍스트 저장 + 다음 세션 제안
```

---

## Integration with Existing Workflows / 기존 워크플로우 연동

| Existing Workflow | Integration |
|-------------------|-------------|
| knowledge-gardening | /autopilot janitor가 lightweight /garden 수행 |
| document-to-knowledge | /import 후처리가 auto-connect 강화 |
| code-to-knowledge | /sync 후처리가 spec cross-reference 추천 |
| idea-to-spec | /capture 후처리가 프로젝트 연결 제안 |
| bug-lifecycle | /autopilot processor가 open bug 현황 보고 |

---

## Error Handling / 오류 처리

| Error | Handling |
|-------|----------|
| mcp__memory 비어 있음 (첫 실행) | 기본 엔티티 초기화 |
| mcp__memory 접근 실패 | 건너뛰고 로컬 스캔만 수행 |
| 외부 리포 접근 실패 | 프로젝트 현황 건너뜀 |
| Health score 계산 불가 | 마지막 알려진 점수 유지 |
| Auto-fix 실패 | 로그하고 다음 항목 계속 |
| Daily Note 없음 | 템플릿에서 자동 생성 |
| Observations 초과 (>10) | 가장 오래된 것 삭제 후 추가 |

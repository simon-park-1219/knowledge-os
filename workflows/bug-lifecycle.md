# Bug Lifecycle Workflow
# 버그 생명주기 워크플로우

Complete workflow for tracking bugs from report to resolution.
버그를 리포트부터 해결까지 추적하는 완전한 워크플로우.

## Workflow Phases / 워크플로우 단계

```
┌─────────────────────────────────────────────────────────────────┐
│                    BUG LIFECYCLE WORKFLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│   │  REPORT  │ ─► │INVESTIGATE│ ─► │   FIX    │ ─► │  VERIFY  │ │
│   │  (보고)   │    │  (조사)   │    │  (수정)   │    │  (검증)   │ │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│        │               │               │               │        │
│        ▼               ▼               ▼               ▼        │
│   - /bug           - Root Cause    - Fix tracking  - /review    │
│   - Writer Agent   - Business-Analyst - Curator Agent - Gardener   │
│   - GitHub Issue   - 로그 분석      - 커밋 링크     - 테스트 검증│
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Report / 보고 단계

### Agent: Writer Agent
### Command: `/bug`

### Steps
```markdown
- [ ] 구조화된 버그 리포트 생성 (`templates/bug-report.md`)
- [ ] 프로젝트의 `bugs/` 폴더에 저장
- [ ] YAML frontmatter에 severity, status: open 설정
- [ ] GitHub Issue 생성 (해당되는 경우)
- [ ] 프로젝트 MOC 업데이트
```

### Exit Criteria
- [ ] 버그 리포트가 올바른 위치에 생성됨
- [ ] frontmatter가 완전함
- [ ] 재현 단계가 포함됨

---

## Phase 2: Investigate / 조사 단계

### Agent: Business-Analyst Agent

### Steps
```markdown
- [ ] 관련 코드와 로그 분석
- [ ] 근본 원인(Root Cause) 파악
- [ ] 버그 리포트의 "Root Cause Analysis" 섹션 업데이트
- [ ] 관련 스펙과 비교하여 원래 의도 확인
- [ ] 영향 범위 평가
```

### Exit Criteria
- [ ] 근본 원인이 식별됨
- [ ] 버그 리포트에 분석 내용 추가됨

---

## Phase 3: Fix Tracking / 수정 추적 단계

### Agent: Curator Agent

### Steps
```markdown
- [ ] "Proposed Fix" 섹션에 수정 계획 기록
- [ ] 수정 커밋/PR 링크를 버그 리포트에 추가
- [ ] status를 "open" → "in-progress"로 변경
- [ ] fix_commit 필드 업데이트
```

### Exit Criteria
- [ ] 수정 커밋이 링크됨
- [ ] status: in-progress로 업데이트됨

---

## Phase 4: Verify / 검증 단계

### Agent: Gardener Agent (Review Mode)
### Command: `/review`

### Steps
```markdown
- [ ] 수정이 재현 단계를 통과하는지 확인
- [ ] 회귀 테스트 존재 확인
- [ ] status를 "in-progress" → "fixed"로 변경
- [ ] 프로젝트 MOC 업데이트
- [ ] GitHub Issue 닫기 (해당되는 경우)
```

### Exit Criteria
- [ ] 버그가 재현되지 않음
- [ ] status: fixed로 업데이트됨
- [ ] "Fix Verification" 체크리스트 완료됨

---

## Quick Reference / 빠른 참조

| Phase | Agent | Status Change | Key Action |
|-------|-------|---------------|------------|
| Report | Writer | → open | /bug로 리포트 생성 |
| Investigate | Business-Analyst | open | Root cause 분석 |
| Fix | Curator | open → in-progress | 수정 커밋 링크 |
| Verify | Gardener (Review Mode) | in-progress → fixed | 테스트 확인 |

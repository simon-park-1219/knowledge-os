# Knowledge Gardening Workflow
# 지식 정원 가꾸기 워크플로우

Periodic vault maintenance workflow to maintain knowledge hygiene.
지식 위생을 유지하기 위한 주기적 vault 정비 워크플로우.

**Recommended frequency**: Weekly (quick) / Monthly (full) / Quarterly (deep)
**권장 빈도**: 주간 (빠른) / 월간 (전체) / 분기별 (심층)

## Workflow Phases / 워크플로우 단계

```
┌─────────────────────────────────────────────────────────────────┐
│                KNOWLEDGE GARDENING WORKFLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│   │   SCAN   │ ─► │  TRIAGE  │ ─► │   HEAL   │ ─► │ REFRESH  │ │
│   │  (스캔)   │    │ (분류)    │    │  (치유)   │    │ (새로고침) │ │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│        │               │               │               │        │
│        ▼               ▼               ▼               ▼        │
│   - /garden        - Inbox 정리    - 링크 수정     - /moc all   │
│   - Gardener       - Curator       - Curator       - Curator    │
│   - 전체 점검       - PARA 분류     - Stub 생성     - MOC 재생성 │
│                                                                   │
│                                                        │        │
│                                                        ▼        │
│                                               ┌──────────────┐ │
│                                               │   REPORT     │ │
│                                               │   (보고)      │ │
│                                               └──────────────┘ │
│                                                        │        │
│                                                        ▼        │
│                                               - 가드닝 요약     │
│                                               - 건강 점수       │
│                                               - /commit         │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Scan / 스캔 단계

### Agent: Gardener Agent
### Command: `/garden`

### Steps
```markdown
- [ ] Orphan note 스캔 (들어오는 링크 없는 노트)
- [ ] Stale content 스캔 (30일 이상 미업데이트 활성 노트)
- [ ] Broken link 스캔 (존재하지 않는 노트로의 링크)
- [ ] Frontmatter 검증 (필수 필드 누락)
- [ ] 비표준 태그 탐지
- [ ] Inbox 체류 항목 확인
- [ ] MOC 최신성 확인
```

### Exit Criteria
- [ ] 가드닝 보고서 생성됨 (카테고리별 카운트)

---

## Phase 2: Triage / 분류 단계

### Agent: Curator Agent

### Steps
```markdown
- [ ] Inbox 항목을 적절한 PARA 위치로 이동
  - 아이디어 → 20-Areas/startup/ 또는 관련 프로젝트
  - 리서치 → 30-Resources/
  - 완료된 항목 → 40-Archives/
- [ ] 이동 시 frontmatter 업데이트 (status, project, area 태그)
- [ ] 이동 로그 기록
```

### Exit Criteria
- [ ] 00-Inbox/에 7일 이상 된 항목 없음
- [ ] 모든 이동된 노트의 frontmatter가 업데이트됨

---

## Phase 3: Heal / 치유 단계

### Agent: Curator Agent

### Steps
```markdown
- [ ] 깨진 링크 수정:
  - 대상이 명확한 경우 → 링크 텍스트 수정
  - 대상이 필요한 경우 → stub 노트 생성
- [ ] 누락된 frontmatter 추가
- [ ] 비표준 태그를 분류법에 맞게 변경
- [ ] Stale 노트 처리:
  - 여전히 관련 있음 → updated 날짜 갱신
  - 관련 없음 → 40-Archives/로 이동
```

### Exit Criteria
- [ ] 깨진 링크 0개
- [ ] 누락된 frontmatter 0개
- [ ] 비표준 태그 0개

---

## Phase 4: Refresh / 새로고침 단계

### Agent: Curator Agent
### Command: `/moc all`

### Steps
```markdown
- [ ] 모든 _*-moc.md 파일 재생성
- [ ] Dataview 쿼리가 현재 상태를 반영하는지 확인
- [ ] 새로 추가된 노트가 MOC에 포함되는지 확인
- [ ] _Home.md 대시보드 확인
```

### Exit Criteria
- [ ] 모든 MOC가 최신 상태

---

## Phase 5: Report / 보고 단계

### Agent: Writer Agent

### Steps
```markdown
- [ ] 가드닝 요약을 오늘의 daily note에 추가
- [ ] 건강 점수 계산 및 기록
- [ ] mcp__memory에 가드닝 결과 저장 (트렌드 추적)
- [ ] /commit으로 모든 변경사항 커밋
```

### Exit Criteria
- [ ] 가드닝 보고서가 daily note에 기록됨
- [ ] git 커밋 완료

---

## Gardening Levels / 가드닝 수준

| Level | Frequency | Scope | Time |
|-------|-----------|-------|------|
| Quick / 빠른 | Weekly | Inbox triage + broken links | ~15 min |
| Full / 전체 | Monthly | All checks | ~30 min |
| Deep / 심층 | Quarterly | All checks + content review + restructuring | ~1 hour |

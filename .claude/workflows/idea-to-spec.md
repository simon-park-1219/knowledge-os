# Idea-to-Spec Workflow
# 아이디어에서 스펙까지 워크플로우

Complete workflow for transforming a raw idea into an actionable Feature Spec.
날것의 아이디어를 실행 가능한 Feature Spec으로 변환하는 완전한 워크플로우.
Boris Tane 스타일의 Annotation Cycle을 포함한 계획-검토-실행 패턴 적용.

## Workflow Phases / 워크플로우 단계

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         IDEA-TO-SPEC WORKFLOW                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│ ┌────────┐  ┌────────┐  ┌────────┐  ┌────────────────┐  ┌──────┐  ┌──────┐ │
│ │CAPTURE │→ │RESEARCH│→ │ CANVAS │→ │     PLAN       │→ │ SPEC │→ │SCAFF.│ │
│ │ (캡처)  │  │(리서치) │  │(캔버스) │  │(계획+주석 반복) │  │(스펙) │  │(구조) │ │
│ └────────┘  └────────┘  └────────┘  └────────────────┘  └──────┘  └──────┘ │
│      │           │           │         │    ↕ refine      │          │       │
│      ▼           ▼           ▼         ▼    (1~6회)       ▼          ▼       │
│  /capture    /research   Lean Canvas  /plan              /spec    프로젝트   │
│  Inbox 저장  웹 검색     비즈니스 모델  계획+검토+승인    요구사항 정의  구조 생성 │
│                                        ⛔ 승인 전 실행 금지                   │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Capture / 캡처 단계

### Agent: Writer Agent
### Command: `/capture`

### Steps
```markdown
- [ ] 아이디어를 `00-Inbox/`에 캡처
- [ ] 최소한의 frontmatter 적용 (type: idea, status: draft)
- [ ] 핵심 아이디어 1-2문장으로 요약
```

### Exit Criteria
- [ ] 아이디어 노트가 00-Inbox/에 생성됨
- [ ] frontmatter가 올바르게 적용됨

---

## Phase 2: Research / 리서치 단계

### Agent: Business-Analyst Agent
### Command: `/research`

### Steps
```markdown
- [ ] 시장 조사: 기존 솔루션, 경쟁사 분석
- [ ] 기술 조사: 가능한 기술 스택, 라이브러리
- [ ] 사용자 니즈 검증: 관련 사례, 통계
- [ ] 리서치 노트를 `30-Resources/`에 저장
- [ ] 출처 하이퍼링크 포함
```

### Exit Criteria
- [ ] 리서치 노트 생성됨 (최소 3개 소스)
- [ ] 아이디어 노트에서 리서치 노트로 wikilink 추가

---

## Phase 3: Lean Canvas / 린 캔버스 단계

### Agent: Writer Agent

### Steps
```markdown
- [ ] `50-Templates/lean-canvas.md` 템플릿 사용
- [ ] 리서치 결과를 바탕으로 9개 블록 채우기:
  - Problem, Customer Segments, UVP, Solution
  - Channels, Revenue, Cost, Key Metrics, Unfair Advantage
- [ ] `20-Areas/startup/lean-canvases/`에 저장
- [ ] Next Steps 섹션에 구체적 액션 아이템 포함
```

### Exit Criteria
- [ ] Lean Canvas 완성됨 (최소 5/9 블록 채워짐)
- [ ] 리서치 노트 링크됨

---

## Phase 3.5: Plan / 계획 단계 (Annotation Cycle)

### Agent: Business-Analyst Agent
### Command: `/plan`

이 단계는 Boris Tane의 Annotation Cycle 패턴을 적용합니다.
**핵심 원칙: 계획을 승인하기 전까지 절대 실행하지 않는다.**

### Steps
```markdown
- [ ] /plan [주제] 실행 → implementation-plan.md 생성
- [ ] Approach, Trade-offs, File Changes, Task Checklist 작성
- [ ] ⛔ 실행 중단 — 사용자에게 검토 요청
- [ ] 사용자가 plan에 인라인 주석 추가 (Obsidian/에디터)
- [ ] /plan refine 실행 → 주석 반영 (1~6회 반복 가능)
- [ ] 사용자가 plan을 최종 승인
- [ ] /plan execute 실행 → 구현 시작
```

### Annotation Cycle Flow
```
/plan [주제]       사용자 주석 추가      /plan refine      만족?
  ──────────→  plan.md 검토  ──────────→  plan 업데이트  ──→ Yes → /plan execute
                                              │                    No ↓
                                              └──────── 반복 (1~6회) ←┘
```

### Exit Criteria
- [ ] Plan이 `status: approved` 또는 `status: in-progress`
- [ ] 최소 1회 이상 annotation cycle 완료
- [ ] Task Checklist가 구체적이고 실행 가능한 항목으로 구성됨

### When to Skip
- 단순한 아이디어 (파일 1~2개 변경 수준) → 바로 /spec으로 진행
- 이미 명확한 요구사항이 있는 경우 → /plan 건너뛰기 가능

---

## Phase 4: Feature Spec / 스펙 단계

### Agent: Business-Analyst Agent
### Command: `/spec`

### Steps
```markdown
- [ ] Lean Canvas에서 자동 추출:
  - Problem → Problem Statement
  - Solution → Functional Requirements
  - Key Metrics → Success Criteria
- [ ] 사용자 스토리 도출
- [ ] 작업 분해 (T-shirt sizing)
- [ ] 위험 평가
- [ ] `10-Projects/[project]/specs/`에 저장
```

### Exit Criteria
- [ ] Feature Spec 완성됨
- [ ] 작업 분해가 포함됨
- [ ] Lean Canvas에서 역링크 추가

---

## Phase 5: Scaffold (Optional) / 스캐폴딩 단계

### Steps
```markdown
- [ ] 스펙에 기반한 프로젝트 폴더 구조 생성
- [ ] GitHub 리포 생성 (필요 시)
- [ ] 프로젝트 MOC 업데이트
- [ ] 아이디어 노트를 Inbox에서 프로젝트 폴더로 이동
```

### Exit Criteria
- [ ] 모든 산출물이 wikilink로 연결됨
- [ ] 프로젝트 MOC가 업데이트됨
- [ ] Inbox가 정리됨

---

## Quick Reference / 빠른 참조

| Phase | Agent | Command | Output |
|-------|-------|---------|--------|
| Capture | Writer | /capture | Inbox note |
| Research | Business-Analyst | /research | Research note in Resources |
| Canvas | Writer | (manual) | Lean Canvas in Areas/startup |
| Plan | Business-Analyst | /plan | Implementation Plan (annotation cycles) |
| Spec | Business-Analyst | /spec | Feature Spec in Projects |
| Scaffold | - | (manual) | Project structure |

# Knowledge OS / 지식 관리 시스템

Obsidian + Claude Code 기반의 통합 Knowledge OS.
3가지 핵심 목적: 스타트업 개발(Vibe Coding), IT 프로젝트 관리(SDD), 팀 지식 관리.

## Project Context

- **Structure**: PARA method (Projects/Areas/Resources/Archives) + MOC pattern
- **Use Cases**:
  1. Startup/Vibe Coding: Lean Canvas → Feature Spec → Code Scaffolding
  2. IT Project Management: Spec-Driven Development, PRD-코드 동기화, 버그 추적
  3. Team Knowledge Management: 암묵지 자산화, 온보딩, 회고

## Folder Structure Convention

| Prefix | Purpose | Examples |
|--------|---------|---------|
| `00-Inbox/` | 미분류 캡처 | 빠른 아이디어, 음성 메모 전사 |
| `10-Projects/` | 진행 중 프로젝트 (마감 있음) | my-saas, knowledge-os |
| `20-Areas/` | 지속적 책임 영역 | startup, engineering, team-management |
| `30-Resources/` | 참고 자료 | tech-notes, book-notes |
| `40-Archives/` | 완료/비활성 항목 | 과거 프로젝트, 오래된 노트 |
| `templates/` | 모든 템플릿 | 원본은 절대 수정 금지; 대상 위치에 복사하여 사용 |
| `60-Daily/` | 일일 노트 (YYYY/MM/YYYY-MM-DD.md) | 저널링, 데일리 로그 |

## MCP Servers (Recommended)

| Server | Purpose | When to Use |
|--------|---------|-------------|
| `filesystem` | vault 파일 읽기/쓰기/이동 | 노트 생성, 수정, 검색 |
| `brave-search` | 웹 검색 | 리서치, 팩트 체크, 최신 정보 |
| `github` | GitHub API | 이슈/PR 관리, 코드-문서 동기화 |
| `memory` | 영구 지식 그래프 | 세션 간 컨텍스트 유지, 프로젝트 지식 저장 |
| `sequential-thinking` | 단계적 추론 | 복잡한 분석, 아키텍처 결정, 리서치 종합 |

## Agents

6개의 전문 에이전트가 정의되어 ��습니다 (`agents/`):
- **curator** — 노트 분류, 태그 정리, 중복 탐지, inbox triage, 자동 처리 모드(Autopilot 위임)
- **writer** — 노트 작성, 템플릿 기반 문서 생성, 요약
- **gardener** — 지식 정원 관리 + 품질 리뷰: orphan 노트, stale 콘텐츠, MOC 업데이트, 건강 점수, 노트 품질 검증
- **business-analyst** — 비즈니스 문서 분석, 웹 리서치, 규제 준수 확인, 전략적 인사이트, 스펙 생성, 제안서 작성
- **code-analyst** — 외부 Git 리포지토리 분석: 구조·기술 스택·API·스키마·CI/CD 식별, 변경 감지, 코드→지식 매핑
- **autopilot** — 자동화 오케스트레이터: 세션 시작/종료 자동화, 건강 추적, 컨텍스트 관리, 선제적 추천

## Slash Commands

`commands/`에 정의된 커맨드 (19종):
- `/capture` — 빠른 아이디어 캡처 (Inbox에 저장)
- `/research` — 웹 검색 + 노트 생성 (brave-search MCP 연동)
- `/distill` — 대화 인사이트를 vault 위키 노트로 증류 (Query→Wiki 피드백 루프)
- `/plan` — 구현 계획 생성·검토·실행 (Boris Tane 스타일 Annotation Cycle)
- `/moc` — Maps of Content 생성/업데이트
- `/garden` — 지식 정원 관리 (orphan 노트, stale 콘텐츠, 링크 정리)
- `/bug` — 구조화된 버그 리포트 생성
- `/spec` — 아이디어에서 Feature Spec 생성
- `/connect` — 노트 자동 연결 (관련 노트 탐색 + 링크 생성)
- `/import` — 비즈니스 문서 수집 (PDF/Excel/Word/PPT/CSV/Image → 구조화된 vault 노트)
- `/analyze` — 문서 심층 분석 (규제 준수, 교차 참조, 전략적 인사이트)
- `/propose` — 사업 제안서 생성 (vault 지식 + ��� 리서치 기반)
- `/onboard` — 외부 Git 리포지토리 스캔 → vault 지식 노트 생성
- `/sync` — 프로젝트 변경 감지 → vault 노트 증분 업데이트
- `/devlog` — 일일 개발 일지 생성 (git log 자동 추출 + Daily Note 연결)
- `/autopilot` — 세션 시작 자동화 (컨텍스트 로드, 건강 점검, 미처리 항목 처리)
- `/wrapup` — 세션 종료 자동화 (컨텍스트 저장, 세션 요약, 다음 세션 제안)
- `/commit` — vault 변경사항 git 커밋
- `/review` — 노트 품질 리뷰

## Workflows

`workflows/`에 정의된 워크플로우:
- **idea-to-spec** — Idea Capture → Lean Canvas → Plan (Annotation Cycle) → Feature Spec → Code Scaffolding
- **bug-lifecycle** — Bug Report → Investigation → Fix Tracking → Verification
- **knowledge-gardening** — Orphan Scan → Stale Check → MOC Update → Tag Cleanup
- **document-to-knowledge** — Import → Classify → Analyze → Connect → Summarize
- **code-to-knowledge** — Onboard → Enrich → Develop → Sync → Record
- **autopilot-pipeline** — Session Start → Auto-Processing → Session End

## Note Creation Standards

### YAML Frontmatter (Required for all notes)

```yaml
---
title: "Note Title"
created: 2026-02-17
updated: 2026-02-17
tags: [tag1, tag2]
type: note  # note | bug | spec | plan | moc | lean-canvas | meeting | decision | daily | prd | regulation | data-spec | proposal | policy | analysis | project-overview | sync-report | devlog
status: active  # active | draft | review | archived
project: ""  # 관련 프로젝트 (optional)
---
```

### Tagging Taxonomy

| Category | Prefix | Examples |
|----------|--------|---------|
| Type | `type/` | type/bug, type/spec, type/meeting, type/idea |
| Status | `status/` | status/active, status/draft, status/archived |
| Project | `project/` | project/my-saas, project/knowledge-os |
| Area | `area/` | area/startup, area/engineering, area/team |
| Priority | `priority/` | priority/high, priority/medium, priority/low |
| Person | `person/` | person/name |
| Document Type | `doctype/` | doctype/prd, doctype/regulation, doctype/proposal |
| Source | `source/` | source/internal, source/external, source/conversation |

### Linking Rules

- 다른 노트 참조 시 항상 `[[wikilink]]` 사용
- 새 개념 등장 시 링크 생성 (나중에 노트 생성 가능)
- MOC 파일에서는 Dataview 쿼리로 동적 목록 생성
- `/connect` — vault 전체를 스캔하여 관련 노트를 자동 연결

### Writing Style

- 간결하고 구조화된 문체 (bullet points 선호)
- 각 노트의 첫 단락에 핵심 내용 요약 (AI 검색 최적화)
- 코드 블록에는 항상 언어 지정

## Automation Layer

Alfred-inspired 3-서브시스템 자동화 레이어:

| Subsystem | Trigger | 역할 |
|-----------|---------|------|
| Heartbeat | `/autopilot` 시작, `/wrapup` 종료 | 컨텍스트 로드/저장 |
| Janitor | `/autopilot` 시작 | 건강 점검 + 안전한 자동 수정 |
| Processor | `/capture`, `/import`, `/sync` 후 | 후처리 파이프라인 |

### Health Score (100점 만점)

```
100 - orphans×2 - stale×3 - broken×5 - missing_fm×3 - bad_tags×1 - old_inbox×2 - stale_moc×2
```

### Post-Processing Convention

모든 위키 변경 커맨드 실행 완료 시:
1. `_changelog.md`에 엔트리 추가
2. `_master-index.md` 갱신
3. 기존 MOC 갱신

## Development Rules

- **Conventional commits**: docs/feat/fix/refactor/chore
- **Never store secrets** in vault files
- **Always use templates** from `templates/`
- **Update relevant MOC** when creating new notes
- **Frontmatter는 필수**: 모든 새 노트에 YAML frontmatter 포함
- **Git으로 추적**: 중요한 변경 후 반드시 커밋

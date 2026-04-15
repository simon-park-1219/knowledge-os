# Code-to-Knowledge Workflow / 코드→지식 변환 워크플로우

외부 Git 리포지토리의 코드를 체계적으로 분석·동기화·기록하여 활용 가능한 지식으로 변환하는 워크플로우입니다.

## Workflow Diagram

```
📂 External Git Repository (~/Desktop/my-service/)
         │
         ▼
┌─── Phase 1: ONBOARD ─────────────────────┐
│  리포 스캔 → 구조 분석 → 지식 노트 생성    │
│  Command: /onboard [repo path]           │
│  Agent: code-analyst                     │
│  Output: 7개 vault 지식 노트             │
└────────────┬─────────────────────────────┘
             │
             ▼
┌─── Phase 2: ENRICH ──────────────────────┐
│  vault 지식과 연결 → PRD/규제 분석 참조    │
│  Command: /connect, /analyze             │
│  Agent: curator, business-analyst        │
│  Output: 연결된 지식 네트워크             │
└────────────┬─────────────────────────────┘
             │
             ▼
┌─── Phase 3: DEVELOP ─────────────────────┐
│  vault 지식 참조하며 외부 디렉토리에서 개발  │
│  Commands: /spec, /bug, /research        │
│  Output: vault에서 생산된 스펙/버그/리서치   │
└────────────┬─────────────────────────────┘
             │
             ▼
┌─── Phase 4: SYNC ────────────────────────┐
│  변경 감지 → vault 노트 업데이트           │
│  Command: /sync [project]                │
│  Agent: code-analyst                     │
│  Output: 업데이트된 지식 노트 + 동기화 보고서│
└────────────┬─────────────────────────────┘
             │
             ▼
┌─── Phase 5: RECORD ──────────────────────┐
│  개발 일지 → Daily Note → git commit      │
│  Command: /devlog [project: description] │
│  Output: devlog + Daily Note 링크        │
└───────────────────────────────────────────┘
             │
             ▼
        (Phase 3으로 반복)
```

---

## Workflow Modes / 실행 모드

### Quick Sync (빠른 동기화) — ~5분

Phase 4 (Sync) only

```
/sync [project-name]
```
→ 변경 감지 → vault 노트 업데이트 → 동기화 보고서 → 완료

**적합한 경우**: 빠르게 vault를 최신 상태로 업데이트할 때

---

### Full Update (전체 업데이트) — ~10분

Phase 4 (Sync) + Phase 5 (Record)

```
Step 1: /sync [project-name]
Step 2: /devlog [project-name]: 오늘 작업 내용 요약
```

**적합한 경우**: 하루 작업을 마무리하며 동기화 + 기록할 때

---

### Deep Analysis (심층 분석) — ~20분

Phase 4 (Sync) + Phase 2 (Enrich) + Phase 5 (Record)

```
Step 1: /sync [project-name]
Step 2: /analyze [[api-reference]]          # 또는 특정 변경 사항 분석
Step 3: /connect [[_project-overview]]      # 새로운 연결 탐색
Step 4: /devlog [project-name]: 심층 분석 결과 요약
Step 5: /commit 코드 지식 업데이트 및 분석 완료
```

**적합한 경우**: 큰 변경이 있었거나, 정기적인 심층 점검이 필요할 때

---

## Phase Details / 단계별 상세

### Phase 1: Onboard (최초 1회, 10-15분)

**Entry**: `/onboard [repo path or GitHub URL]`
**Agent**: code-analyst

**Steps**:
1. 리포지토리 경로/URL 확인 및 유효성 검증
2. 파일 트리, README, CLAUDE.md, PRD, 의존성 파일 스캔
3. 기술 스택 식별 (프레임워크, 라이브러리, 버전)
4. API 엔드포인트 추출 (프레임워크별 패턴 인식)
5. DB 스키마 추출 (ORM별 모델 감지)
6. CI/CD 설정 분석
7. GitHub API 조회 (이슈, PR, Actions)
8. 7개 지식 노트 생성 (`10-Projects/[name]/`)
9. 관련 vault 노트 자동 연결
10. Knowledge Graph 업데이트

**Exit Criteria**:
- [ ] 프로젝트 폴더가 `10-Projects/`에 생성됨
- [ ] 최소 3개 이상의 지식 노트가 생성됨 (overview + architecture + tech-stack)
- [ ] frontmatter에 repo_path, last_synced_commit이 설정됨
- [ ] knowledge graph에 프로젝트 엔티티 등록됨

---

### Phase 2: Enrich (선택, 5-10분)

**Entry**: `/connect [[_project-overview]]` 또는 `/analyze [[api-reference]]`
**Agent**: curator, business-analyst

**Steps**:
1. 프로젝트 개요에서 키워드 추출
2. vault 전체 스캔으로 관련 노트 탐색 (PRD, 규제, 리서치)
3. /connect 점수 알고리즘으로 관련도 평가
4. 양방향 wikilink 생성
5. (선택) /analyze로 특정 기술/API 심층 분석

**Exit Criteria**:
- [ ] 관련 vault 노트와 양방향 링크 생성됨
- [ ] knowledge graph 관계 업데이트됨

---

### Phase 3: Develop (지속적, vault 외부)

**Entry**: 코드 개발 작업 (vault 외부 디렉토리에서)

**Steps**:
1. vault에서 관련 스펙/규제 참조 (`/spec`, `/research`)
2. 외부 디렉토리에서 코드 개발
3. 필요 시 vault에 버그 보고서 (`/bug`), 스펙 업데이트 (`/spec`)
4. git commit & push

**Exit Criteria**:
- [ ] 코드 변경이 커밋됨
- [ ] (선택) vault 스펙/버그가 업데이트됨

---

### Phase 4: Sync (주기적, 5분)

**Entry**: `/sync [project-name]`
**Agent**: code-analyst

**Steps**:
1. 마지막 동기화 커밋 이후 변경 사항 감지
2. 5가지 영역별 변경 분류 (구조/의존성/API/스키마/CI)
3. GitHub 이슈/PR 상태 업데이트
4. 변경된 vault 노트 업데이트
5. 동기화 보고서 생성
6. last_synced, last_synced_commit 갱신

**Exit Criteria**:
- [ ] vault 노트가 현재 코드 상태를 반영
- [ ] 동기화 보고서가 `sync-history/`에 생성됨
- [ ] frontmatter의 last_synced가 업데이트됨

---

### Phase 5: Record (일일, 3-5분)

**Entry**: `/devlog [project-name]: [description]`

**Steps**:
1. 오늘의 git log 자동 추출
2. 사용자 설명과 결합
3. devlog 노트 생성
4. Daily Note에 링크 추가
5. knowledge graph 업데이트

**Exit Criteria**:
- [ ] devlog가 `10-Projects/[name]/devlogs/`에 생성됨
- [ ] Daily Note에 링크됨

---

## Integration with Existing Workflows / 기존 워크플로우 연동

| 기존 워크플로우 | 연동 포인트 |
|---------------|-----------|
| **idea-to-spec** | `/onboard` → 프로젝트 지식 참조 → `/spec`으로 스펙 강화 |
| **document-to-knowledge** | `/import` PRD → `/onboard` 코드 → `/analyze`로 교차 참조 |
| **knowledge-gardening** | `/garden`에서 프로젝트 노트 stale 체크, orphan 연결 |
| **autopilot-pipeline** | devlog가 Daily Note에 자동 기록 → autopilot briefing에 포함 |
| **bug-lifecycle** | 코드 분석에서 발견된 이슈 → `/bug`로 등록 |

---

## Error Handling / 오류 처리

| 오류 | 대응 |
|------|------|
| 리포 경로 없음 | "경로를 확인해주세요. 디렉토리가 존재하지 않습니다." |
| git 리포가 아님 | "이 디렉토리는 git 리포지토리가 아닙니다. `git init`이 필요합니다." |
| 이미 온보딩됨 | "이미 등록된 프로젝트입니다. `/sync [name]`으로 업데이트하세요." |
| gh CLI 미설치/미인증 | GitHub 기능 건너뜀, 로컬 분석만 진행 |
| 프로젝트 못 찾음 (/sync, /devlog) | 등록된 프로젝트 목록 표시, `/onboard` 안내 |
| 변경 사항 없음 (/sync) | "이미 최신 상태입니다." 메시지 |
| last_synced_commit 없음 | 전체 재스캔 (온보딩 이후 첫 동기화) |
| 의존성 파일 없음 | 해당 노트 건너뜀 |
| API 라우트 없음 | api-reference.md 생성하지 않음 |
| DB 모델 없음 | db-schema.md 생성하지 않음 |
| 커밋 없는 날 (/devlog) | "오늘 커밋 없음" 표시, 나머지 정상 진행 |
| devlog 이미 존재 | 추가/새로 작성 선택 요청 |

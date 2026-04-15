대화에서 발생한 인사이트를 vault 위키 노트로 증류(distill)하여 지식 자산화.

Topic: $ARGUMENTS (증류할 인사이트 주제 — 예: "Karpathy LLM Wiki 패턴 분석", "REST vs GraphQL API 설계 패턴 비교")

Karpathy의 "Query→Wiki" 패턴 구현: 대화에서 생성된 좋은 답변을 다시 위키에 기록하는 피드백 루프.

**Note**: If `_changelog.md` or `_master-index.md` don't exist, create them with default bootstrap content before appending.

Follow this process:

1. **Extract — 대화 인사이트 추출**:
   - 현재 대화(conversation) 전체를 리뷰하여 $ARGUMENTS와 관련된 내용을 추출
   - 추출 대상:
     - 핵심 인사이트 및 결론
     - 의사결정 기록 (무엇을, 왜 그렇게 결정했는지)
     - 비교 분석 결과 (A vs B 비교표, 장단점)
     - 종합된 지식 (여러 출처를 종합한 분석)
     - 문제 해결 과정 (디버깅, 아키텍처 결정 등)
     - 반복 사용 가능한 패턴이나 프레임워크
   - `mcp__sequential-thinking__sequentialthinking`으로 추출된 인사이트를 구조화
   - $ARGUMENTS가 비어있으면 → 대화 전체를 스캔하여 주요 토픽을 나열하고 사용자에게 선택 요청

2. **Classify — 출력 형태 결정**:
   - 추출된 인사이트의 성격에 따라 출력 형태 결정:

   **새 노트 생성**:
   - 대화에서 새로운 개념이나 프레임워크가 발견된 경우
   - 기존 vault에 해당 주제의 노트가 없는 경우
   - 비교 분석, 의사결정 기록 등 독립적 가치가 있는 경우

   **기존 노트 보강**:
   - vault에 이미 관련 노트가 있고, 새 인사이트가 보충 성격인 경우
   - 기존 노트의 특정 섹션을 업데이트하거나 확장해야 하는 경우

   **복수 노트**:
   - 대화 인사이트가 여러 도메인에 걸쳐 있는 경우
   - 각 도메인별로 분리하여 적절한 위치에 저장

3. **Locate — vault 내 기존 노트 탐색**:
   - `Grep`으로 $ARGUMENTS 키워드와 관련 용어를 vault 전체에서 검색
   - `Glob`으로 관련 폴더 구조 확인 (`30-Resources/`, `20-Areas/`, `10-Projects/`)
   - `mcp__memory__search_nodes`로 지식 그래프에서 관련 엔티티 검색
   - 탐색 결과를 3가지로 분류:
     - **직접 관련 노트**: 동일 주제를 다루는 노트 → 보강 후보
     - **인접 관련 노트**: 관련 주제의 노트 → 링크 후보
     - **해당 없음**: 새 노트 생성 필요

4. **Write or Enrich — 작성 또는 보강**:

   **A. 새 노트 생성 시**:
   - 주제에 따른 저장 위치 결정:
     - 기술 개념/패턴 → `30-Resources/tech-notes/`
     - 비즈니스 인사이트 → `30-Resources/business-documents/`
     - 프로젝트 관련 → `10-Projects/[project-name]/`
     - 영역 지식 → `20-Areas/[area-name]/`
     - 분류 불확실 → `00-Inbox/` (나중에 curator가 정리)
   - Filename: `YYYY-MM-DD-[slugified-title].md`
   - Frontmatter:
     ```yaml
     ---
     title: "[제목]"
     created: [today YYYY-MM-DD]
     updated: [today YYYY-MM-DD]
     type: note
     status: active
     tags: [source/conversation, ...]
     project: ""
     distilled_from: "conversation"
     ---
     ```
   - `source/conversation` 태그는 필수 — 대화에서 증류된 지식임을 표시 (인식론적 출처 추적)
   - 추가 태그: 주제에 맞는 `area/`, `type/`, `doctype/` 태그 부여
   - 노트 구조:
     - **핵심 요약** (1-2문장, AI 검색 최적화)
     - **배경/맥락** (왜 이 주제가 논의되었는지)
     - **핵심 인사이트** (bullet points, 구조화)
     - **상세 분석** (필요 시 하위 섹션으로 분할)
     - **적용/시사점** (우리 컨텍스트에서의 의미)
     - **열린 질문** (추가 탐구가 필요한 부분)
     - **Related Notes** (Step 5에서 자동 추가)

   **B. 기존 노트 보강 시**:
   - 기존 노트를 `Read`로 전체 읽기
   - 보강 방식 결정:
     - **섹션 추가**: 기존 구조에 새 섹션을 자연스럽게 삽입
       - 형식: `## YYYY-MM-DD 추가 인사이트` 또는 기존 섹션 내 하위 항목
     - **내용 통합**: 기존 내용과 새 인사이트를 자연스럽게 병합
       - 기존 bullet에 새 항목 추가
       - 기존 비교표에 새 행/열 추가
     - **업데이트**: 기존 내용이 오래되었으면 최신 정보로 갱신
       - 원래 내용을 삭제하지 말고 `> [YYYY-MM-DD 이전] ...` 형태로 보존
   - `Edit`으로 기존 노트 수정
   - `updated:` frontmatter를 오늘 날짜로 갱신
   - `source/conversation` 태그가 없으면 tags에 추가

5. **Connect — 연결**:
   - 새로 생성/보강된 노트에 `## Related Notes` 섹션 추가 또는 업데이트
   - 관련 노트 탐색 (Step 3 결과 활용):
     ```
     Same project/ tag       → +40
     Same area/ tag          → +30
     mcp__memory relation    → +30
     Title keyword match     → +20
     Content keyword match   → +10
     ```
   - Threshold: score >= 25 → 링크 추가
   - Max 8 links
   - Format: `- [[note-title]] — brief reason`
   - Exclude: `templates/*`, `.claude/*`, `*-moc.md`, self
   - 관련 노트가 있으면 **양방향 링크**: 관련 노트에도 backlink 추가 (score >= 50인 경우만)

   - `mcp__memory__create_entities`로 증류된 지식 저장:
     ```
     name: "[note title]"
     entityType: "distilled-knowledge"
     observations: [key insights summary, related tags, source: conversation]
     ```
   - `mcp__memory__create_relations`로 관련 노트와 연결

6. **Index — 인덱스 업데이트** (Post-Processing Convention):

   **`_changelog.md` 업데이트**:
   - `_changelog.md`를 `Read`로 읽고, frontmatter/설명 섹션 바로 다음에 새 엔트리 삽입
   - 형식: `## [YYYY-MM-DD distill] 제목` + 작업 요약 + 영향받은 파일 목록

   **`_master-index.md` 업데이트**:
   - 새 노트를 생성한 경우, `_master-index.md`의 해당 카테고리에 `- [[note-title]] — 한 줄 요약 (type, status)` 추가
   - 기존 노트 보강 시에는 건너뛰기
   - Vault 통계 수치도 갱신

   **MOC 업데이트**:
   - 새 노트를 생성한 경우, 해당 폴더의 MOC 파일에 항목 추가
   - MOC 파일 매핑:
     - `00-Inbox/` → `00-Inbox/_inbox-moc.md`
     - `10-Projects/` → `10-Projects/_projects-moc.md`
     - `20-Areas/` → `20-Areas/_areas-moc.md`
     - `30-Resources/` → `30-Resources/_resources-moc.md`
     - `30-Resources/business-documents/` → `30-Resources/business-documents/_business-docs-moc.md`
   - MOC가 존재하면 `Edit`으로 적절한 위치에 `- [[note-title]]` 추가
   - MOC가 없으면 건너뛰기

   **Knowledge Graph 업데이트**:
   - `mcp__memory__add_observations`로 "active-context"에 기록:
     `"last_distill: [note path] at [YYYY-MM-DD HH:MM]"`
     `"distill_topic: [topic keywords]"`

7. **Provenance Check — 출처 품질 확인**:
   - 증류된 인사이트가 대화 내 어떤 근거에 기반하는지 확인
   - 근거 유형 태그:
     - `[대화 추론]` — Claude의 분석/추론에 기반
     - `[웹 검색 기반]` — 대화 중 웹 검색으로 확인된 사실
     - `[문서 분석 기반]` — vault 내 문서 분석에서 도출
     - `[사용자 경험]` — 사용자가 직접 공유한 경험/지식
   - 각 핵심 인사이트에 근거 유형을 인라인 표시
   - 검증되지 않은 주장에는 `[미검증 — 추가 확인 필요]` 표시

### 전문 영역: 증류 품질 기준

이 커맨드 실행 시 다음 품질 기준을 적용한다:
- **원자성**: 하나의 노트는 하나의 명확한 주제를 다룸. 여러 주제가 섞이면 분리
- **재사용성**: 대화 컨텍스트 없이도 노트만으로 이해 가능하도록 작성 (self-contained)
- **누적 가능성**: 같은 주제에 대해 나중에 다시 `/distill` 하면 기존 노트에 누적
- **출처 투명성**: `source/conversation` 태그와 근거 유형 표시로 인식론적 출처 추적
- **연결 밀도**: 최소 2개 이상의 기존 노트와 [[wikilink]] 연결 (고립 방지)
- **실행 가능성**: 가능한 경우 "다음 단계" 또는 "추가 탐구 질문"을 포함

### 사용 예시

```bash
# 대화에서 논의된 특정 주제를 증류
/distill Karpathy LLM Wiki 패턴 분석

# 대화에서 내린 의사결정 기록
/distill FastAPI vs Django REST 선택 이유

# 대화에서 도출된 아키텍처 인사이트
/distill 마이크로서비스 인증 패턴 비교

# 대화 전체에서 주요 인사이트 자동 추출
/distill
```

Output: 생성/보강된 노트 경로, 핵심 인사이트 요약 (3-5개), 연결된 관련 노트 수, 근거 유형 분포를 표시.

```
📝 Distill Report

**Action**: [새 노트 생성 / 기존 노트 보강]
**Note**: [[note-path]]
**Source**: conversation (source/conversation)

### 증류된 인사이트
1. [insight 1] [근거 유형]
2. [insight 2] [근거 유형]
3. [insight 3] [근거 유형]

### 연결
- Related notes linked: N
- Backlinks added: N
- MOC updated: [Yes/No]

### 근거 분포
| Type | Count |
|------|-------|
| 대화 추론 | N |
| 웹 검색 기반 | N |
| 문서 분석 기반 | N |
| 사용자 경험 | N |

📄 Full note: [[note-path]]
```

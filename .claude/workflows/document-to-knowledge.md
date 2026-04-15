# Document-to-Knowledge Workflow / 문서→지식 변환 워크플로우

비즈니스 문서를 체계적으로 수집·분석·연결하여 활용 가능한 지식으로 변환하는 워크플로우입니다.

## Workflow Diagram

```
📄 Source File (PDF/Excel/Word/PPT/CSV/Image)
         │
         ▼
┌─── Phase 1: IMPORT ────────────────────┐
│  파일 감지 → 변환 → 추출 → 메타데이터   │
│  Command: /import [file path]          │
│  Agent: business-analyst               │
│  Output: 구조화된 vault 노트           │
└────────────┬───────────────────────────┘
             │
             ▼
┌─── Phase 2: CLASSIFY ──────────────────┐
│  자동 분류 → 템플릿 적용 → 태그 부여    │
│  Agent: business-analyst               │
│  Output: 분류된 노트 + frontmatter     │
└────────────┬───────────────────────────┘
             │
             ▼
┌─── Phase 3: ANALYZE (선택) ────────────┐
│  교차 참조 → 준수 확인 → 인사이트 추출   │
│  Command: /analyze [note]              │
│  Agent: business-analyst               │
│  Output: 분석 노트 + 권장 사항          │
└────────────┬───────────────────────────┘
             │
             ▼
┌─── Phase 4: CONNECT ───────────────────┐
│  관련도 점수 → 양방향 링크 → MOC 업데이트│
│  Command: /connect [note]              │
│  Agent: curator                        │
│  Output: 연결된 지식 네트워크           │
└────────────┬───────────────────────────┘
             │
             ▼
┌─── Phase 5: SUMMARIZE ─────────────────┐
│  핵심 요약 → 일일 노트 기록 → git commit│
│  Command: /commit                      │
│  Output: 버전 관리된 지식 베이스        │
└────────────────────────────────────────┘
```

---

## Workflow Modes / 실행 모드

### Quick Mode (빠른 수집) — ~10분/문서

Phase 1 (Import) + Phase 2 (Classify) + Phase 4 (Connect)

```
/import [파일 경로]
```
→ 파일 수집 → 자동 분류 → 노트 생성 → 관련 노트 연결 → 완료

**적합한 경우**: 빠르게 문서를 vault에 등록하고 나중에 분석할 때

---

### Deep Mode (심층 분석) — ~20-30분/문서

Phase 1 → Phase 2 → Phase 3 (Analyze) → Phase 4 → Phase 5

```
Step 1: /import [파일 경로]
Step 2: /analyze [[수집된 노트]]
Step 3: /commit 문서 수집 및 분석 완료
```

**적합한 경우**: 규제 문서, 핵심 PRD 등 심층 분석이 필요한 문서

---

### Strategic Mode (전략 제안) — ~1-2시간

Phase 1 → Phase 2 → Phase 3 → Phase 4 → `/propose` → Phase 5

```
Step 1: /import [규제 문서]
Step 2: /import [관련 PRD]
Step 3: /import [데이터 명세]
Step 4: /analyze [[규제 문서]]
Step 5: /propose "규제 기반 신규 서비스 기획"
Step 6: /commit 전략 기획 완료
```

**적합한 경우**: 여러 문서를 종합하여 새로운 사업 아이템을 기획할 때

---

## Phase Details / 단계별 상세

### Phase 1: Import (5-10분)

**Entry**: `/import [absolute file path]`

**Steps**:
1. 파일 존재 확인 및 형식 감지
2. 필요시 파일 변환 (Excel→CSV, Word→Markdown, PPT→PDF)
3. 내용 추출 (Read tool 사용)
4. 메타데이터 추출 (제목, 페이지 수, 날짜 등)

**Exit Criteria**:
- [ ] 파일 내용이 성공적으로 추출됨
- [ ] 파일 형식이 감지됨
- [ ] 변환이 필요한 경우 성공적으로 변환됨

---

### Phase 2: Classify (2-3분)

**Agent**: business-analyst

**Steps**:
1. 내용 기반 문서 유형 자동 분류
2. 적절한 템플릿 선택 및 적용
3. Frontmatter 생성 (source_file, source_type, tags, doctype/)
4. AI 요약 생성 (mcp__sequential-thinking)
5. 템플릿 섹션 채우기
6. 적절한 폴더에 저장

**Exit Criteria**:
- [ ] 문서 유형이 정확히 분류됨
- [ ] 템플릿이 적용되고 섹션이 채워짐
- [ ] Frontmatter가 완전함
- [ ] 올바른 폴더에 저장됨

---

### Phase 3: Analyze (5-10분, 선택)

**Entry**: `/analyze [[imported note]]`

**Steps**:
1. 대상 노트 읽기 및 컨텍스트 파악
2. vault 내 관련 문서 검색 (Grep + mcp__memory)
3. (선택) 웹 리서치로 최신 컨텍스트 수집
4. 교차 참조 분석 (mcp__sequential-thinking):
   - PRD ↔ 규제 준수 확인
   - 데이터 명세 ↔ PRD 요구사항 매칭
   - 제안서 ↔ 시장/규제 타당성
5. 분석 노트 생성 (같은 폴더에 저장)
6. 원본 문서에 분석 노트 역링크 추가

**Exit Criteria**:
- [ ] 관련 문서가 교차 참조됨
- [ ] 준수 상태가 평가됨
- [ ] 인사이트와 권장 사항이 도출됨
- [ ] 분석 노트가 생성되고 원본에 링크됨

---

### Phase 4: Connect (2-3분)

**Steps**:
1. /connect 점수 알고리즘으로 관련 노트 탐색
2. Score ≥ 40인 노트와 양방향 [[wikilink]] 생성
3. mcp__memory에 엔티티와 관계 저장
4. MOC는 Dataview가 자동으로 반영 (frontmatter 정확하면)

**Exit Criteria**:
- [ ] 관련 노트가 발견되고 링크됨
- [ ] 지식 그래프가 업데이트됨
- [ ] MOC에 새 문서가 표시됨

---

### Phase 5: Summarize (2-3분)

**Steps**:
1. 수집/분석 결과 핵심 요약
2. 오늘의 Daily Note가 있으면 수집 기록 추가
3. `/commit [수집/분석 내용 설명]`으로 git 커밋

**Exit Criteria**:
- [ ] 작업이 기록됨
- [ ] Git에 커밋됨

---

## Batch Processing / 대량 처리

여러 문서를 한번에 처리할 경우:

```
/import ~/Desktop/doc1.pdf ~/Desktop/doc2.xlsx ~/Desktop/doc3.docx
```

1. 각 파일을 순차적으로 Phase 1-2 처리
2. 모든 파일 처리 후 Phase 4 (Connect)를 일괄 실행
3. 배치 보고서 생성:
   ```
   📦 Batch Import Report

   | # | File | Type | Status | Links |
   |---|------|------|--------|-------|
   | 1 | doc1.pdf | Regulation | ✅ | 3 |
   | 2 | doc2.xlsx | Data Spec | ✅ | 2 |
   | 3 | doc3.docx | PRD | ✅ | 5 |

   Total: 3 files, 10 links created
   ```

---

## Integration with Existing Workflows / 기존 워크플로우 연동

| 기존 워크플로우 | 연동 포인트 |
|---------------|-----------|
| **idea-to-spec** | `/import` → PRD 수집 → `/spec`으로 스펙 강화 |
| **knowledge-gardening** | `/garden`에서 business-documents 폴더도 점검 |
| **daily-standup** | 수집된 문서가 Daily Note에 기록됨 |
| **bug-lifecycle** | PRD 분석에서 발견된 이슈 → `/bug`로 등록 |

---

## Error Handling / 오류 처리

| 오류 | 대응 |
|------|------|
| 변환 도구 미설치 | `brew install pandoc libreoffice` 안내 |
| 지원하지 않는 형식 | 지원 형식 목록 제공, PDF 변환 제안 |
| PDF 100+ 페이지 | 부분 임포트 경고, 처음 60 + 마지막 20 페이지 |
| 분류 불확실 | 사용자에게 유형 선택 요청 |
| 중복 임포트 | 기존 노트 발견 시: 덮어쓰기/건너뛰기/버전 생성 선택 |
| 자동 링크 없음 | 조용히 건너뜀, 나중에 `/connect`로 수동 연결 가능 |

Create a Feature Spec from an idea, requirement, or Lean Canvas.

Input: $ARGUMENTS

Follow this process:

1. **Read Source Material**:
   - If $ARGUMENTS references an existing note (Lean Canvas, idea capture), read it first
   - If $ARGUMENTS is a raw description, use it directly
   - Search vault for related existing notes

2. **Analyze with Sequential Thinking**:
   Use `mcp__sequential-thinking__sequentialthinking` to:
   - Extract user stories from the input
   - Identify functional requirements (FR)
   - Identify non-functional requirements (NFR)
   - Assess technical feasibility
   - Break down into tasks with T-shirt sizing (XS/S/M/L/XL)

3. **Research** (if needed):
   - Use `mcp__brave-search__brave_web_search` for technology research
   - Check existing solutions or libraries
   - Validate technical approach

4. **Generate Feature Spec**:
   - Use template from `templates/feature-spec.md`
   - Save to `10-Projects/[project-name]/specs/SPEC-YYYY-MM-DD-[slug].md`
   - If project folder doesn't have `specs/` subfolder, create it

5. **Populate All Sections**:
   - Overview with problem statement and objectives
   - User stories with acceptance criteria
   - Functional requirements with priorities
   - Non-functional requirements
   - Task breakdown table with sizes and dependencies
   - Risk assessment
   - Timeline estimate

6. **Link Back**:
   - Link to source material (Lean Canvas, idea notes)
   - Add wikilinks to related specs and decisions
   - Update project MOC

7. **Extract from Lean Canvas** (if available):
   - Problem → Problem Statement
   - Solution → Functional Requirements
   - Key Metrics → Success Criteria
   - Unfair Advantage → Technical Design constraints

### 전문 영역: 스펙 품질 기준
- **기술 실현 가능성**: 각 기능 항목에 구현 난이도(H/M/L)와 예상 공수를 명시
- **엣지 케이스**: 주요 기능별 최소 2개의 엣지 케이스를 식별
- **의존성 명시**: 외부 서비스, API, 라이브러리 의존성을 명확히 나열
- **수용 기준**: 각 기능에 "완료"의 정의를 측정 가능한 기준으로 작성
- **PRD-코드 추적성**: 관련 PRD/규제 문서가 있으면 [[wikilink]]로 연결

Output: Show the spec file path, a summary of requirements, and the task breakdown.

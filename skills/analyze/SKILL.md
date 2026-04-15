---
name: analyze
description: 문서/토픽 심층 분석 — 교차 참조, 규제 준수, 전략적 인사이트
---

Perform deep analysis of a document or topic with cross-referencing and strategic insights.

Target: $ARGUMENTS (note path, note title, or topic keyword)

Follow this process:

1. **Resolve Target**:
   - If $ARGUMENTS is a file path → use directly
   - If $ARGUMENTS is a note title → search vault with `Glob` for matching filename
   - If $ARGUMENTS is a topic keyword → `Grep` for keyword across vault, find most relevant notes
   - If $ARGUMENTS is empty → ask user for target

2. **Read Target & Extract Context**:
   - Read the target note fully
   - Parse frontmatter: type, tags, project, area, doctype, source
   - Identify document type (PRD, regulation, data-spec, proposal, etc.)
   - Extract key terms and concepts

3. **Gather Related Documents**:
   - `Grep` for notes with matching `project/`, `area/`, `doctype/` tags
   - `Grep` for keyword matches in `30-Resources/business-documents/`
   - Query `mcp__memory__search_nodes` for related entities
   - Read top 5-10 most relevant related notes
   - Categorize: PRDs, regulations, data specs, proposals, existing analyses

4. **Web Research** (optional, for latest context):
   - Use `mcp__brave-search__brave_web_search` for:
     - Latest regulatory updates on the topic
     - Market trends and benchmarks
     - Industry best practices
   - Only if topic involves regulations, market analysis, or technology trends

5. **Cross-Reference Analysis** (use `mcp__sequential-thinking__sequentialthinking`):

   **If target is PRD**:
   - Which regulations apply? Are all requirements met?
   - Does the data spec support all PRD requirements?
   - Are there conflicting requirements across documents?
   - Technical feasibility assessment

   **If target is Regulation**:
   - Which existing PRDs/products are affected?
   - What's our current compliance status per requirement?
   - What implementation gaps exist?
   - Timeline and resource implications

   **If target is Data Spec**:
   - Does it satisfy all related PRD data requirements?
   - Are there privacy/security compliance issues?
   - Data quality and completeness assessment
   - API coverage analysis

   **If target is Proposal**:
   - Market feasibility based on vault research
   - Regulatory compliance of proposed solution
   - Technical feasibility assessment
   - Financial assumptions validation

   **General analysis for any type**:
   - Strengths and weaknesses
   - Opportunities and threats
   - Dependencies and blockers
   - Recommended actions

6. **Generate Analysis Note**:
   - Filename: `YYYY-MM-DD-analysis-[target-note-slug].md`
   - Save to: same folder as the target document
   - Frontmatter:
     ```yaml
     ---
     title: "Analysis: [target document title]"
     created: [today]
     updated: [today]
     tags: [type/analysis, doctype/analysis, area/[same as target]]
     type: analysis
     status: active
     analyzed_document: "[[target note]]"
     ---
     ```
   - Sections:
     - **Analysis Summary** (3-5 sentences)
     - **Key Findings** (numbered, with evidence links)
     - **Cross-Document Analysis** (consistency, dependencies, contradictions)
     - **Compliance Assessment** (requirement coverage table with ✅/⚠️/❌ status)
     - **Strategic Insights** (opportunities, risks, gaps)
     - **Recommendations** (prioritized actions with effort/impact)
     - **Supporting Evidence** (vault [[wikilinks]] and web sources)

7. **Analysis Quality Review (Gardener Review Mode cross-check)**:

   After generating the analysis note, perform a self-review pass:

   a. **Conclusion-Evidence Alignment**:
      - For each item in "Key Findings", verify it references specific data from the source document
      - Findings without direct evidence links → mark with `[근거 보강 필요]`
      - Check that numeric claims in the analysis match the source document's original numbers

   b. **Logical Consistency Check**:
      - Verify recommendations do not contradict each other
      - Check that "Strategic Insights" logically follow from "Key Findings"
      - If the analysis contains both a strength and a contradicting weakness on the same point → flag for clarification

   c. **Compliance Assessment Verification** (if applicable):
      - For each ✅ (Compliant) status in the Compliance Assessment table:
        - Verify the cited regulation clause actually exists in the vault's regulation notes
        - Confirm the PRD/spec requirement genuinely satisfies the regulation requirement
      - For each ❌ (Gap) status:
        - Verify the gap is real and not due to the analysis missing a relevant vault document
      - If any compliance status cannot be verified → change to ⚠️ with note "[검증 불가 — 원문 확인 필요]"

   d. **Review Summary** (append to analysis note):
      ```markdown
      ## Quality Review
      | Check | Result |
      |-------|--------|
      | Evidence-backed findings | N/M (X%) |
      | Logical consistency | ✅ Consistent / ⚠️ N issues found |
      | Compliance verification | N/M verified against source |
      | Review status | ✅ Passed / ⚠️ Needs attention |
      ```

8. **Update Source Document**:
   - Add backlink to analysis note in target's `## Related Notes` section
   - Use `Edit` to append link

9. **Update Knowledge Graph**:
   - `mcp__memory__create_entities` for analysis
   - `mcp__memory__create_relations`:
     - analysis → target document ("analyzes")
     - analysis → cross-referenced documents ("references")

10. **Generate Analysis Report**:
   ```
   📊 Analysis Report

   **Target**: [[target note]]
   **Cross-Referenced**: N documents
   **Web Sources**: N (if applicable)

   ### Top Findings
   1. [finding 1]
   2. [finding 2]
   3. [finding 3]

   ### Compliance Status: [✅ Compliant / ⚠️ Partial / ❌ Gaps Found]

   ### Top Recommendations
   1. [recommendation 1] — Priority: High
   2. [recommendation 2] — Priority: Medium

   📄 Full analysis: [[analysis note path]]
   ```

### 전문 영역: 분석 품질 기준
- **증거 기반**: 모든 판단에 원문 인용(페이지/라인) 또는 데이터 참조를 포함
- **교차 문서 검증**: 분석 대상 문서의 주장을 vault 내 다른 문서와 대조
- **규제 매핑**: 관련 규제가 있으면 요구사항별 준수 상태(✅/⚠️/❌)를 테이블로 명시
- **실행 우선순위**: 권고사항을 impact × effort 매트릭스로 정렬
- **반론 테스트**: 핵심 결론에 대해 "이 결론이 틀릴 수 있는 시나리오"를 1개 이상 제시

Output: Display the analysis report summary and full analysis note path.

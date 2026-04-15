---
name: propose
description: 사업 제안서 생성 — vault 지식 + 웹 리서치 기반
---

Generate a business proposal based on vault knowledge and web research.

Topic/Goal: $ARGUMENTS

Follow this process:

1. **Clarify Proposal Goal**:
   - Parse $ARGUMENTS for the proposal topic/goal
   - If $ARGUMENTS is vague, ask for specifics:
     - What problem are you solving or opportunity are you pursuing?
     - Who is the target audience/customer?
     - What's the desired outcome?
     - Any timeline constraints?
   - If $ARGUMENTS references existing notes (e.g., `[[Lean Canvas: X]]`), read them first

2. **Gather Vault Knowledge**:
   - Extract keywords from the proposal goal
   - Search vault for related knowledge:
     - `Grep` for matching keywords in `30-Resources/business-documents/` (PRDs, regulations, data specs)
     - `Grep` for related notes in `20-Areas/startup/`, `10-Projects/`
     - `Grep` for existing proposals in `30-Resources/business-documents/proposals/`
     - Query `mcp__memory__search_nodes` with topic keywords
   - Score candidates using `/connect` relevance algorithm
   - Read top 10 most relevant notes
   - Collect: supporting regulations, related PRDs, market research, data specs

3. **Web Research** (via `mcp__brave-search__brave_web_search`):
   - Market intelligence:
     - "[topic] market size 2026"
     - "[topic] trends growth 2026"
     - "[topic] competitors landscape"
   - Regulatory context:
     - "[topic] regulations compliance 2026"
     - "[topic] government policy"
   - Technology & feasibility:
     - "[topic] technology stack best practices"
     - "[topic] case studies implementation"
   - Gather 5-8 quality web sources

4. **Build Proposal** (use `mcp__sequential-thinking__sequentialthinking`):
   - **Problem/Opportunity Definition**:
     - Current situation (from vault + web research)
     - Pain points or market gap
     - Why now? (timing factors)
   - **Proposed Solution**:
     - Solution overview
     - Key features and differentiators
     - Technical approach
   - **Business Case**:
     - Financial projections (revenue, cost, ROI)
     - Non-financial benefits (brand, capability, positioning)
     - Comparable benchmarks from web research
   - **Feasibility Analysis**:
     - Technical: existing capabilities, technology maturity
     - Market: size, growth, competition
     - Regulatory: compliance requirements from imported regulations
   - **Risk Assessment**:
     - Key risks with probability and impact
     - Mitigation strategies
   - **Implementation Roadmap**:
     - Phased approach with milestones
     - Resource requirements
     - Timeline estimate

5. **Generate Proposal Note**:
   - Use template from `50-Templates/business-proposal.md`
   - Filename: `YYYY-MM-DD-proposal-[slugified-topic].md`
   - Save to: `30-Resources/business-documents/proposals/`
   - Frontmatter:
     ```yaml
     ---
     title: "Proposal: [topic]"
     created: [today]
     updated: [today]
     tags: [type/proposal, doctype/proposal, source/internal, area/[relevant]]
     type: proposal
     status: draft
     target_decision_date: ""
     stakeholders: []
     imported_date: [today]
     ---
     ```
   - Populate ALL template sections with synthesized content
   - **Vault sources**: use `[[wikilink]]` format
   - **Web sources**: use `[Title](URL)` format in Supporting Evidence section

6. **Auto-Link Related Notes**:
   - Run `/connect` scoring algorithm on the proposal
   - Link to: regulations, PRDs, data specs, market research, existing proposals
   - Add bidirectional links for score ≥ 60

7. **Update Knowledge Graph**:
   - `mcp__memory__create_entities`:
     ```
     name: "Proposal: [topic]"
     entityType: "proposal"
     observations: [executive summary, key stakeholders, target date]
     ```
   - `mcp__memory__create_relations` for all linked documents

8. **Offer Next Steps**:
   - Ask user:
     - "이 제안서를 `10-Projects/[프로젝트명]/`으로 프로젝트화할까요?"
     - "추가 분석이 필요한 영역이 있나요?"
     - "`/analyze`로 특정 규제 대비 준수 상태를 확인할까요?"

9. **Generate Proposal Report**:
   ```
   📋 Proposal Report

   **Topic**: [proposal topic]
   **Vault Sources**: N documents referenced
   **Web Sources**: N sources gathered
   **Status**: Draft

   ### Executive Summary
   [3-5 sentences]

   ### Key Highlights
   - Market Size: [estimate]
   - ROI: [estimate]
   - Compliance: [status]
   - Timeline: [estimate]

   📄 Full proposal: [[proposal note path]]

   ### Suggested Next Steps
   1. Review and refine with stakeholders
   2. `/analyze` for regulatory compliance deep-dive
   3. Create project folder for implementation planning
   ```

### 전문 영역: 제안서 품질 기준
- **가치-근거 구조**: 모든 문장을 "가치 주장 → 근거" 구조로 작성. 기능 나열 금지
- **심사자 관점**: 제안서의 각 섹션이 심사 평가 기준의 어떤 항목에 대응하는지 명시
- **경쟁 차별점**: "우리만 할 수 있는 이유"를 구체적 수치로 뒷받침
- **리스크 선제 대응**: 예상 반론 3개 이상을 미리 식별하고 대응 논리를 포함
- **1-pager 검증**: 각 섹션의 핵심 문장만 추출하여 전체 스토리라인이 논리적으로 연결되는지 확인

Output: Display the proposal report with highlights and the full proposal note path.

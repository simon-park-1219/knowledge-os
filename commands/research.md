Research a topic using web search and create a structured note.

Topic: $ARGUMENTS

Follow this process:

1. **Search**: Use `WebSearch` or `mcp__brave-search__brave_web_search` to search for the topic
   - Perform 2-3 searches with different query angles
   - Gather 3-5 high-quality sources

2. **Analyze**: Use `mcp__sequential-thinking__sequentialthinking` to synthesize findings
   - Identify key themes and insights
   - Note contradictions or debates

3. **Create Note**: Save to `30-Resources/tech-notes/` (or appropriate subfolder based on topic):
   ```yaml
   ---
   title: "Research: [topic]"
   created: [today]
   updated: [today]
   tags: [type/research, area/[relevant-area]]
   type: note
   status: active
   sources: [list of URLs]
   ---
   ```

4. **Structure the note**:
   - **Summary** (2-3 sentences)
   - **Key Findings** (bullet points with source references)
   - **Detailed Notes** (organized by subtopic)
   - **Personal Analysis / Implications** (how this applies to our context)
   - **Sources** (full list with hyperlinks)
   - **Related Notes** — auto-discovered via intelligent vault scan:

     **Auto-Linking Process:**

     a. Query `mcp__memory__search_nodes` with research topic for knowledge graph matches
     b. `Grep` for notes with matching `area/` tags (prioritize `30-Resources/` and `20-Areas/`)
     c. `Grep` for topic keywords in existing research notes (tag `type/research`)
     d. `Grep` for topic keywords in project specs (`10-Projects/*/specs/`)
     e. Score candidates:
        ```
        Same area/ tag       → +40
        Same project/ tag    → +35
        mcp__memory relation → +30
        type/research tag    → +20
        Title keyword match  → +15
        Content keyword match → +10
        ```
     f. Threshold: score ≥ 25 (lower for research — new topics need wider discovery)
     g. Max 8 links
     h. Group by category:
        ```markdown
        ## Related Notes

        ### Research Notes
        - [[existing-research-note]] — Related topic

        ### Area Notes
        - [[area-background-note]] — Background context

        ### Project Specs
        - [[spec-using-this-tech]] — Implementation reference
        ```
     i. Use `mcp__memory__create_entities` to store research topic:
        ```
        name: "Research: [topic]"
        entityType: "research"
        observations: [key findings summary, related tags]
        ```
     j. Use `mcp__memory__create_relations` to link research to discovered notes

5. **Fact-Check & Consistency Verification (Business-Analyst + Curator cross-check)**:

   After creating the research note, perform a verification pass:

   a. **Source Citation Audit**:
      - Scan each bullet in "Key Findings" for a source reference `[Source](url)`
      - Any claim without a cited source → mark with `[출처 필요]` inline
      - Statistical claims (percentages, dollar amounts, growth rates) without sources → flag with `[미검증 통계]`

   b. **Vault Knowledge Consistency Check**:
      - Query `mcp__memory__search_nodes` with the research topic's key claims
      - `Grep` in `30-Resources/` and `20-Areas/` for notes discussing the same topic
      - For each existing vault note that covers overlapping subject matter:
        - Compare key claims — if contradictions found, add a `> ⚠️ 기존 vault 노트 [[note-name]]과 상충: [details]` callout in the research note
      - If no contradictions → note "기존 vault 지식과 일관성 확인됨" in the note footer

   c. **Unverified Claim Flagging**:
      - Identify forward-looking predictions or projections without methodology citation
      - Flag any "will", "expected to", "projected" statements without supporting data
      - Add `[예측 — 검증 필요]` marker to such statements

   d. **Verification Summary** (append to note before Sources section):
      ```markdown
      ## Verification Status
      | Check | Result |
      |-------|--------|
      | Claims with sources | N/M (X%) |
      | Vault consistency | ✅ Consistent / ⚠️ N contradictions found |
      | Unverified statistics | N flagged |
      ```

6. **Update MOC**: If a relevant MOC exists in the target folder, add the new note

7. **Store in Memory**: Save key findings in `mcp__memory` for future reference

### 전문 영역: 리서치 품질 기준
이 커맨드 실행 시 다음 품질 기준을 적용한다:
- **출처 검증**: 모든 핵심 주장에 출처 URL 또는 문서 참조를 포함. 출처 없는 주장은 [미검증] 표시
- **주장-근거 구조**: 모든 인사이트를 "주장 → 근거 → 시사점" 3단 구조로 작성
- **교차 검증**: 단일 출처에 의존하지 않고, 가능한 2개 이상 출처로 교차 확인
- **vault 중복 확인**: 리서치 시작 전 mcp__memory와 vault 검색으로 기존 관련 노트 확인 — 이미 있는 정보를 반복하지 않고 누적
- **반론 포함**: 핵심 주장에 대한 반론이나 한계를 최소 1개 이상 포함

Output: Show the created note path, a brief summary, key sources used, and verification status.

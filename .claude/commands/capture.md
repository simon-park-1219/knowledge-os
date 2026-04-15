Quick capture an idea or note to the Inbox.

Create a new note in `00-Inbox/` with the following process:

1. Generate a filename: `00-Inbox/YYYY-MM-DD-[slugified-title].md`
   - Use today's date
   - Slugify the title from $ARGUMENTS (lowercase, hyphens for spaces, no special chars)

2. Apply frontmatter:
   ```yaml
   ---
   title: "[title from arguments]"
   created: [today's date YYYY-MM-DD]
   updated: [today's date YYYY-MM-DD]
   tags: [type/idea]
   type: note
   status: draft
   ---
   ```

3. Write the content from $ARGUMENTS as the body
   - If $ARGUMENTS is brief, expand it slightly with structure
   - If no arguments provided, create a blank template and ask for input

4. Add a link to today's daily note if it exists in `60-Daily/`

5. Store a brief record in `mcp__memory` for cross-session awareness

6. **Auto-Link Related Notes** (lightweight scan):
   - Extract top 5 keywords from the captured content (remove stopwords: 이, 그, 저, 의, 가, 를, 에, 등, the, a, an, of, for)
   - Quick scan for related notes (limit to recent 100 notes or last 30 days for performance):

   **Priority 1**: If project or area tags detected → `Grep` for notes with matching `project/` or `area/` tags
   **Priority 2**: Query `mcp__memory__search_nodes` with captured title/keywords for knowledge graph matches
   **Priority 3**: Only if < 3 candidates found → `Grep` for title keywords in note content

   - Simplified scoring:
     ```
     Same project/ tag → +30
     Same area/ tag    → +20
     mcp__memory match → +25
     Title keyword hit → +15
     Other tag match   → +10
     ```
   - Threshold: score ≥ 30 → add link
   - Max 5 links
   - Exclude: `50-Templates/*`, `.claude/*`, `*-moc.md`, the new note itself

   - If related notes found:
     - Append `## Related Notes` section to the new note
     - Format: `- [[note-title]] — brief reason`

   - If no related notes found (score < 30 for all), skip silently

7. **Post-Processing Pipeline** (Autopilot 자동화 레이어):
   - Update `mcp__memory` "active-context" entity:
     - `mcp__memory__add_observations` to "active-context":
       `"last_capture: [note path] at [YYYY-MM-DD HH:MM]"`
       `"recent_topics: [extracted keywords from capture]"`

   - **Cross-Capture Connection Check**:
     - Query `mcp__memory__search_nodes` for recent captures (last 7 days)
     - If any recent capture shares 2+ keywords with this capture:
       - Run lightweight `/connect` scoring between them
       - If score >= 50 and not already linked → auto-add `[[wikilink]]`
       - Report: "🔗 Cross-capture link: [[recent-capture]] (score: XX)"

   - **Proactive Project Suggestion**:
     - Query `mcp__memory__open_nodes` for "active-context"
     - If captured content mentions any active_projects keywords:
       - Suggest: "이 캡처는 [project]와 관련될 수 있습니다.
         `10-Projects/[project]/`로 이동하거나 `/connect`를 실행해보세요."

### 전문 영역: 캡처 품질 기준
- **핵심 1줄 요약**: 노트 첫 줄에 핵심 내용을 1문장으로 요약 (AI 검색 최적화)
- **액션 가능성**: 아이디어인 경우 "다음 단계"를 최소 1개 명시
- **연결 컨텍스트**: 이 아이디어가 왜 지금 떠올랐는지 맥락 1줄 추가
- **경량 링크 스캔**: vault에서 관련 노트 최대 3개까지만 빠르게 스캔하여 연결

Output: Confirm the note was created, show the file path, brief preview, and number of related notes linked (e.g., "🔗 Related notes: 3 links added").

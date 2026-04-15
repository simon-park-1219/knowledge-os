---
name: connect
description: 노트 자동 연결 — 관련 노트 탐색 및 링크 생성
---

Find and link related notes using intelligent relevance scoring.

Target: $ARGUMENTS (note path, title, or keyword)

Follow this process:

1. **Resolve Target Note**:
   - If $ARGUMENTS is a file path → use directly
   - If $ARGUMENTS is a note title → use `Glob` to search vault for matching filename
   - If $ARGUMENTS is empty → ask user for note path or title
   - Validate the note exists and read it

2. **Extract Features from Target Note**:
   - Read the note with `Read`
   - Parse YAML frontmatter: `tags`, `project`, `type`, `status`, `created`
   - Extract title keywords:
     - Split title on spaces and hyphens
     - Remove stopwords (Korean: 이, 그, 저, 의, 가, 을, 를, 에, 와, 과, 로, 으로, 등, 및, 는, 은, 도 / English: the, a, an, of, for, and, or, in, on, at, to, is, it, this, that)
     - Keep meaningful terms (2+ characters for Korean, 3+ for English)
   - Extract top 5 content keywords from first 200 words (same stopword removal)
   - Query `mcp__memory__search_nodes` with note title for knowledge graph relations

3. **Scan Vault for Candidates** (3-Tier Strategy):

   **Tier 1 — Frontmatter Metadata (Fast, always run)**:
   - Use `Glob` pattern `**/*.md` to get all notes
   - Exclude: `50-Templates/*`, `.claude/*`, `*-moc.md`, `_Home.md`, `.gitignore`
   - Exclude the target note itself
   - If target has `project/` tag → `Grep` for `project/[same-project]` in frontmatter
   - If target has `area/` tag → `Grep` for `area/[same-area]` in frontmatter
   - If target has frontmatter `project:` → `Grep` for matching `project:` value

   **Tier 2 — Tag Matching (Medium, always run)**:
   - For each non-project/area tag in target (e.g., `type/spec`, `priority/high`):
     - `Grep` for that tag in YAML frontmatter across vault
   - Collect unique candidate file paths

   **Tier 3 — Content Keywords (Selective, only if < 5 candidates from Tier 1+2)**:
   - For top 3 title keywords:
     - `Grep` for keyword in note content (not just frontmatter)
     - Limit to notes updated in last 60 days for performance
   - Add to candidate pool

4. **Score Each Candidate**:
   - For all unique candidates, read their frontmatter (use `Read` with limit for efficiency)
   - Calculate relevance score:
     ```
     score = 0
     if candidate has same project/ tag         → score += 50
     if candidate.frontmatter.project matches   → score += 40
     if candidate has same area/ tag            → score += 30
     if mcp__memory shows relation              → score += 30
     for each matching title keyword in candidate title → score += 20
     for each other matching tag                → score += 10
     for each content keyword match             → score += 5
     if candidate.updated within 7 days         → score += 10
     if candidate.status == "archived"          → score -= 20
     ```
   - Discard candidates with score < 20

5. **Rank and Select**:
   - Sort candidates by score (descending)
   - Take top 10 (adjustable)
   - Separate into tiers:
     - **Highly Related**: score ≥ 60
     - **Related**: score 40-59
     - **Possible**: score 20-39 (report only, don't auto-link)

6. **Create/Update Related Notes Section**:
   - Check if `## Related Notes` section already exists in target note
   - If exists: parse existing `[[wikilinks]]`, add only NEW links (avoid duplicates)
   - If not exists: append section at end of note
   - Format:
     ```markdown
     ## Related Notes

     **Highly Related**
     - [[note-title-1]] — Same project, area match
     - [[note-title-2]] — Knowledge graph connection

     **Related**
     - [[note-title-3]] — Same area
     - [[note-title-4]] — Tag overlap: type/spec
     ```
   - Use `Edit` to update the target note

7. **Bidirectional Linking**:
   - For each note with score ≥ 60 (Highly Related only):
     - Read the note
     - Check if it already has `## Related Notes` section
     - Add backlink `- [[target-note-title]]` if not already present
     - Use `Edit` to update

8. **Update Knowledge Graph**:
   - Use `mcp__memory__create_relations` for all links created:
     ```
     from: target_note_title
     to: linked_note_title
     relationType: "related_to"
     ```
   - This enables future cross-session link discovery

9. **Generate Connection Report**:
   ```markdown
   ## 🔗 Connection Report

   **Target**: [[note-title]]
   **Vault Scanned**: N notes
   **Candidates Found**: N (scored ≥ 20)
   **Links Added**: N

   ### Highly Related (≥60)
   - [[note-1]] — Score: 80 (project match + area match)
   - [[note-2]] — Score: 65 (project match + knowledge graph)

   ### Related (40-59)
   - [[note-3]] — Score: 50 (area match + 2 tags)

   ### Consider Reviewing (20-39, not auto-linked)
   - note-4 — Score: 35 (1 tag overlap)
   - note-5 — Score: 25 (content keyword match)
   ```

Output: Display the connection report with statistics and linked notes.

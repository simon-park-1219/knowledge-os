---
name: import
description: 비즈니스 문서 수집 — PDF/Excel/Word/PPT/CSV/Image를 vault 노트로 변환
---

Import a business document into the vault as a structured knowledge note.

Input: $ARGUMENTS (absolute file path(s), space or comma separated)

Follow this process:

1. **Parse Input & Validate**:
   - Extract file path(s) from $ARGUMENTS
   - Verify each file exists using `Read` (or `Bash` with `ls`)
   - If no arguments provided, ask user for file path

2. **Detect File Format**:
   - `.pdf` → PDF (read directly)
   - `.xlsx` / `.xls` → Excel (convert to CSV)
   - `.docx` / `.doc` → Word (convert to Markdown)
   - `.pptx` / `.ppt` → PowerPoint (convert to PDF)
   - `.csv` → CSV (read directly)
   - `.png` / `.jpg` / `.jpeg` → Image (read directly, multimodal)
   - `.md` / `.txt` → Text (read directly)
   - Other → inform user of unsupported format

3. **Convert If Needed**:
   - **Excel → CSV**: `Bash` with `libreoffice --headless --convert-to csv "[filepath]" --outdir /tmp/`
   - **Word → Markdown**: `Bash` with `pandoc "[filepath]" -f docx -t markdown -o /tmp/converted.md`
   - **PPT → PDF**: `Bash` with `libreoffice --headless --convert-to pdf "[filepath]" --outdir /tmp/`
   - **Conversion fails**: Check if tools installed. If not:
     ```
     ⚠️ 변환 도구가 필요합니다.
     설치: brew install pandoc libreoffice
     또는 파일을 PDF로 변환 후 다시 시도해주세요.
     ```
   - Read the converted file from /tmp/

4. **Extract Content**:
   - **PDF**: Use `Read` with `pages` parameter
     - ≤ 20 pages: read all at once
     - 21-100 pages: read in chunks of 20 pages
     - > 100 pages: read pages 1-60 and last 20 pages, warn about partial import
   - **CSV**: Use `Read`, identify column headers and data structure
   - **Image**: Use `Read` (multimodal), extract text and visual information
   - **Markdown/Text**: Use `Read` directly

5. **Classify Document Type** (Business Analyst logic):
   - Scan extracted content for classification keywords:
     - "requirement", "user story", "PRD", "기능 명세", "feature" → **PRD** → template: `prd-summary.md`
     - "규제", "regulation", "가이드라인", "고시", "표준", "법률" → **Regulation** → template: `regulation-summary.md`
     - "스키마", "API", "필드", "데이터 명세", "테이블 구조", "엔티티" → **Data Spec** → template: `data-spec-summary.md`
     - "제안", "proposal", "사업계획", "비즈니스 케이스", "ROI" → **Proposal** → template: `business-proposal.md`
     - "정책", "policy", "지침", "내규" → **Policy** → folder: `policies/` (use general note format)
   - If uncertain, ask user: "이 문서의 유형을 선택해주세요: PRD / 규제 / 데이터명세 / 제안서 / 정책"

6. **Generate Note with Template**:
   - Read the selected template from `50-Templates/`
   - Create filename: `YYYY-MM-DD-[slugified-title].md`
   - Save to: `30-Resources/business-documents/[category]/`
     - PRD → `prd/`
     - Regulation → `regulations/`
     - Data Spec → `data-specs/`
     - Proposal → `proposals/`
     - Policy → `policies/`
   - Fill frontmatter:
     - `source_file`: original absolute path
     - `source_type`: file extension (pdf, xlsx, docx, etc.)
     - `pages`: page count (for PDFs)
     - `imported_date`: today
     - `tags`: include `doctype/[type]`, `source/[internal|external|government|vendor]`
       - Government docs (규제, 가이드라인) → `source/government`
       - Company internal docs → `source/internal`
       - Vendor/partner docs → `source/external`

7. **AI Summary & Structuring**:
   - Use `mcp__sequential-thinking__sequentialthinking` to:
     - Generate 2-3 sentence executive summary
     - Extract and populate template sections
     - Identify key insights (opportunities, risks, dependencies)
   - Write structured content into each template section

8. **Auto-Link Related Notes** (reuse /connect scoring):
   - Extract keywords from document title and summary
   - Scan vault for related notes:
     - `Grep` for matching `project/`, `area/`, `doctype/` tags
     - Query `mcp__memory__search_nodes` with document keywords
     - Score candidates (project/ +50, area/ +30, doctype/ +15, memory +30, keyword +20)
   - Threshold: score ≥ 40 → create link
   - Add `## Related Notes` section with top 8 links

9. **Cross-Validation (Curator Agent)**:
   - **Classification Verification**: Compare assigned doctype against existing vault patterns
     - `Grep` for notes in the same `30-Resources/business-documents/[category]/` folder
     - Check if content keywords align with the category's typical patterns
     - If classification confidence < 70% → flag for user review instead of auto-applying
   - **Link Quality Check**: Review auto-link suggestions from step 8
     - Verify each link has score ≥ 40; remove false positives below threshold
     - Cross-check link targets actually exist and are relevant (not just keyword overlap)
     - If > 30% of suggested links appear to be false positives → reduce to high-confidence links only
   - **Tag Consistency Validation**: Validate all assigned tags against CLAUDE.md taxonomy
     - Confirm tags use correct prefixes: `doctype/`, `source/`, `type/`, `area/`, `project/`
     - Flag any tags not defined in the taxonomy
     - Verify `source/` tag accuracy (government vs internal vs external vs vendor)
   - **Validation Report** (append to Import Report):
     ```
     🔍 Cross-Validation
     | Check | Result | Notes |
     |-------|--------|-------|
     | Classification | ✅/⚠️ | [confidence %] |
     | Links (N/M passed) | ✅/⚠️ | [removed count if any] |
     | Tags | ✅/⚠️ | [issues if any] |
     ```
   - If any check has confidence < 70% → pause and ask user for confirmation before proceeding

10. **Update Knowledge Graph**:
   - `mcp__memory__create_entities`:
     ```
     name: "[Document Title]"
     entityType: "[prd|regulation|data-spec|proposal|policy]"
     observations: [executive summary, key tags, source file path]
     ```
   - `mcp__memory__create_relations` for all auto-linked notes

11. **Update MOC**:
    - Ensure the note will appear in `_business-docs-moc.md` Dataview queries
    - No manual edit needed if frontmatter is correct

12. **Generate Import Report**:
    ```
    📄 Import Report

    | 항목 | 내용 |
    |------|------|
    | File | [원본 파일명] |
    | Format | [PDF/Excel/Word/PPT/CSV/Image] |
    | Type | [PRD/Regulation/Data Spec/Proposal/Policy] |
    | Pages | [페이지 수] |
    | Saved | [[vault 경로]] |
    | Summary | [2-3문장 요약] |
    | Links | [N개 관련 노트 연결됨] |

    💡 Next: `/analyze [[노트명]]`으로 심층 분석 가능
    ```

**For Batch Import** (multiple files):
- Process each file sequentially
- Aggregate results into a single batch report at the end
- Show total: files processed, types detected, links created

13. **Post-Processing Pipeline** (Autopilot 자동화 레이어):
    - Update `mcp__memory` "active-context":
      - `mcp__memory__add_observations` to "active-context":
        `"last_import: [note path] type=[document type] at [date]"`
        `"recent_topics: [keywords from imported document]"`

    - **Active Project Cross-Reference**:
      - Read "active-context" from `mcp__memory` for `active_projects`
      - For each active project:
        - Read `_project-overview.md` frontmatter
        - Check if imported document's keywords overlap with project tech stack,
          API endpoints, or business domain
        - If overlap detected → suggest:
          ```
          💡 이 [doctype]은(는) [[project-overview]]와 관련될 수 있습니다.
             `/analyze [[imported-note]]`로 교차 참조 분석을 실행해보세요.
          ```

    - **Batch Import Cross-Connection**:
      - After batch import (multiple files in one invocation):
        - Run cross-connection scan among all newly imported documents
        - If any pair scores >= 40 → auto-link them with `[[wikilink]]`
        - Report: "🔗 Batch cross-link: [[doc1]] ↔ [[doc2]] (score: XX)"

Output: Display the import report with file details, summary, and next steps.

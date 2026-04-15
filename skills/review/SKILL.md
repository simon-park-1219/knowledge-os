---
name: review
description: 노트 품질 리뷰 — frontmatter, 링크, 일관성 검증
---

Review note quality for specified notes or folders.

Target: $ARGUMENTS (file path, folder path, or "recent" for recently modified notes)

Use the Gardener Agent (Review Mode) to perform a systematic quality review:

1. **Determine Scope**:
   - If $ARGUMENTS is a file path → review that single note
   - If $ARGUMENTS is a folder path → review all notes in that folder
   - If $ARGUMENTS is "recent" → review notes modified in the last 7 days
   - If no arguments → review the entire vault

2. **For Each Note, Check**:

   ### Structure
   - [ ] YAML frontmatter present and complete
   - [ ] Title is descriptive
   - [ ] First paragraph summarizes content
   - [ ] Proper heading hierarchy (no skipped levels)

   ### Content
   - [ ] No placeholder text remaining (e.g., "TODO", "TBD", "[fill in]")
   - [ ] Sources cited where applicable
   - [ ] Action items have owners and dates

   ### Links & Tags
   - [ ] All [[wikilinks]] resolve to existing notes
   - [ ] Tags follow taxonomy from CLAUDE.md
   - [ ] Related notes are properly linked
   - [ ] Note appears in relevant MOC

   ### Freshness
   - [ ] `updated` date reflects actual last change
   - [ ] Information is current (no obviously outdated content)

3. **Generate Review Report**:
   - Overall status: 🟢 Good / 🟡 Needs Improvement / 🔴 Needs Revision
   - Issues categorized by severity (Critical 🔴, High 🟠, Medium 🟡, Low 🔵, Info 💬)
   - Specific actionable suggestions for each issue
   - Positive feedback for well-structured notes

Output: Structured review report with issue counts and specific recommendations.

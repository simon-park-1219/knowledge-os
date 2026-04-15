---
name: bug
description: 구조화된 버그 리포트 생성
---

Create a structured bug report.

Description: $ARGUMENTS

Follow this process:

1. **Parse Input**: Extract from $ARGUMENTS:
   - Bug title/description
   - Project name (if mentioned)
   - Severity (if mentioned, default: medium)

2. **Prompt for Missing Info** (if not in $ARGUMENTS):
   - Project name → which project folder in `10-Projects/`?
   - Severity: critical / high / medium / low
   - Steps to reproduce
   - Expected vs actual behavior

3. **Generate Bug Report**:
   - Use template from `50-Templates/bug-report.md`
   - Save to `10-Projects/[project-name]/bugs/BUG-YYYY-MM-DD-[slug].md`
   - If project folder doesn't have `bugs/` subfolder, create it
   - Fill in all known fields from input

4. **Set Frontmatter**:
   ```yaml
   ---
   title: "BUG: [title]"
   created: [today]
   updated: [today]
   tags: [type/bug, priority/[severity], status/open, project/[project-name]]
   type: bug
   status: open
   project: "[project-name]"
   severity: [severity]
   reporter: "Simon Park"
   ---
   ```

5. **Link**: Add wikilink to related spec if mentioned

6. **Update MOC**: Add bug reference to the project's MOC

7. **GitHub Integration** (optional): If the project has a GitHub repo:
   - Create a matching GitHub issue using `mcp__github`
   - Add the issue URL to the bug report

Output: Show the created bug report path and a summary of the report.

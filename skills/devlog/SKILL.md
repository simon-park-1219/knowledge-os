---
name: devlog
description: 일일 개발 일지 생성 — git log 자동 추출, Daily Note 연결
---

Create a development log entry for a project with today's commits and progress notes.

Input: $ARGUMENTS (format: "project-name: description" or "project-name description")

Follow this process:

1. **Parse Input**:
   - Split $ARGUMENTS on first `:` to separate project name and description
   - Project name = first part (slug format, trimmed)
   - Description = remaining text (can be empty)
   - If $ARGUMENTS is empty → ask user for project name and description
   - Resolve project: `Glob` for `10-Projects/[name]/_project-overview.md`
   - If not found → "이 프로젝트는 등록되지 않았습니다. `/onboard [repo-path]`로 먼저 등록하세요."
   - Read `_project-overview.md`, extract `repo_path` from frontmatter

2. **Extract Today's Git Activity**:
   - Today's commits:
     `Bash` with `git -C [repo_path] log --since="00:00" --format="%h %s (%ar)" --no-merges`
   - If no commits today → note "오늘 커밋 없음" but continue (user may want to record planning/review/other work)
   - Files changed today:
     `Bash` with `git -C [repo_path] diff --stat $(git -C [repo_path] log --since="00:00" --format="%H" --no-merges | tail -1)..HEAD 2>/dev/null`
   - If the above fails (no commits), try:
     `Bash` with `git -C [repo_path] diff --stat HEAD~1..HEAD 2>/dev/null`

3. **Check for Related Specs/Bugs**:
   - `Grep` in `10-Projects/[name]/` for notes with `type: spec` or `type: bug` and `status: active`
   - Cross-reference commit messages with spec/bug note titles for auto-linking
   - Query `mcp__memory__search_nodes` with keywords from commits and description

4. **Generate Devlog Note**:
   - Use template from `templates/devlog.md`
   - Filename: `YYYY-MM-DD-devlog.md`
   - Save to: `10-Projects/[name]/devlogs/`
   - Check if devlog for today already exists:
     - If exists → ask user: "오늘의 devlog가 이미 있습니다. 내용을 추가할까요, 새로 작성할까요?"
     - If "추가" → use `Edit` to append to existing devlog
   - Fill sections:
     - **Today's Commits**: auto-extracted from git log (hash, message, time)
     - **Work Summary**: user's description from $ARGUMENTS
     - **Files Changed**: from git diff --stat
     - **Key Decisions**: extract from commit messages containing "refactor", "decide", "choose", "migrate", "redesign"
     - **Blockers & Issues**: from related open bugs or user input
     - **Related Notes**: links to relevant specs, bugs, previous devlogs, `_project-overview`

5. **Link to Daily Note**:
   - Today's daily note path: `60-Daily/YYYY/MM/YYYY-MM-DD.md`
   - If exists → use `Edit` to add devlog link:
     - Under `## Work Log` or `## 📝 Notes` section (whichever exists):
     - `- [[10-Projects/[name]/devlogs/YYYY-MM-DD-devlog|[name] devlog]]: [brief description]`
   - If not exists → create daily note from `templates/daily-note.md`, then add link

6. **Update Knowledge Graph** (`mcp__memory`):
   - `mcp__memory__add_observations` to project entity:
     - "Devlog [date]: [description summary]"
   - If significant decisions noted → create relation to relevant specs/bugs

7. **Generate Devlog Report**:
    ```
    📝 Devlog: [project-name] — [today's date]

    | 항목 | 내용 |
    |------|------|
    | Commits Today | [N개] |
    | Files Changed | [N개] |
    | Related Specs/Bugs | [N개] |

    ### Summary
    [User's description]

    📄 Full devlog: [[10-Projects/[name]/devlogs/YYYY-MM-DD-devlog]]
    📅 Daily Note: [[60-Daily/YYYY/MM/YYYY-MM-DD]]

    💡 Next: `/sync [name]`으로 vault 전체 동기화
    ```

Output: Display the devlog summary with file locations and next steps.

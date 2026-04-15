---
name: sync
description: 프로젝트 변경 감지 — vault 노트 증분 업데이트
---

Synchronize vault knowledge notes with recent changes in an external Git repository.

Input: $ARGUMENTS (project name)

Follow this process:

1. **Resolve Project**:
   - If $ARGUMENTS is empty → list projects from `10-Projects/` with `Glob` for `*/_project-overview.md`, ask user to select
   - Search for `10-Projects/$ARGUMENTS/_project-overview.md` using `Glob`
   - If not found → "이 프로젝트는 아직 등록되지 않았습니다. `/onboard [repo-path]`로 먼저 등록하세요."
   - Read `_project-overview.md`, extract from frontmatter:
     - `repo_path` → local repo directory
     - `github_url` → GitHub remote
     - `last_synced` → last sync date
     - `last_synced_commit` → last sync commit hash
   - Verify repo_path exists: `Bash` with `ls [repo_path]`

2. **Get Current Repo State**:
   - Current HEAD: `Bash` with `git -C [repo_path] rev-parse --short HEAD`
   - If HEAD == last_synced_commit → "✅ 이미 최신 상태입니다. 변경 사항이 없습니다." → exit
   - Commit log since last sync:
     `Bash` with `git -C [repo_path] log [last_synced_commit]..HEAD --format="%h %s (%an, %ar)" --no-merges`
   - File change summary:
     `Bash` with `git -C [repo_path] diff [last_synced_commit]..HEAD --stat`
   - Detailed file changes:
     `Bash` with `git -C [repo_path] diff [last_synced_commit]..HEAD --name-status`

3. **Detect Structural Changes** (code-analyst agent logic):

   **a. Dependency Changes**:
   - `Bash`: `git -C [repo_path] diff [last_commit]..HEAD -- package.json requirements.txt go.mod Cargo.toml pom.xml */package.json */requirements.txt`
   - If changes detected → Read new dependency files, extract added/removed/updated packages
   - Update: `10-Projects/[name]/tech-stack.md` with `Edit`

   **b. API Route Changes**:
   - `Bash`: `git -C [repo_path] diff [last_commit]..HEAD --name-only -- '*/routes/*' '*/api/*' 'app/api/**' 'pages/api/**'`
   - If changes → re-scan API routes using framework-aware Grep patterns from code-analyst agent
   - Update: `10-Projects/[name]/api-reference.md` with `Edit`

   **c. Schema/Model Changes**:
   - `Bash`: `git -C [repo_path] diff [last_commit]..HEAD --name-only -- '*/models/*' '*/models.py' '*/schema.prisma' '*/migrations/*' '*/alembic/*'`
   - If changes → re-scan models
   - Update: `10-Projects/[name]/db-schema.md` with `Edit`

   **d. CI/CD Changes**:
   - `Bash`: `git -C [repo_path] diff [last_commit]..HEAD --name-only -- '.github/workflows/*' 'Dockerfile' 'docker-compose.yml' 'vercel.json'`
   - If changes → re-read CI/CD configs
   - Update: `10-Projects/[name]/deployment.md` with `Edit`

   **e. Architecture Changes**:
   - Check for new/deleted directories from `--name-status` output
   - If significant structural changes (new top-level dirs, major file reorganization):
     - Regenerate file tree section in `10-Projects/[name]/architecture.md`

4. **GitHub Sync** (via `Bash` with `gh` CLI):
   - If github_url is present, extract owner/repo:
     - `gh issue list --repo [owner/repo] --limit 20 --json number,title,state,labels`
     - `gh pr list --repo [owner/repo] --limit 10 --state merged --json number,title,mergedAt`
     - `gh run list --repo [owner/repo] --limit 5 --json status,conclusion,name`
   - Compare with existing `open-issues.md`:
     - New issues → add to list
     - Closed issues → mark as resolved
     - Merged PRs → record in sync report
   - Update: `10-Projects/[name]/open-issues.md` with `Edit`
   - If gh not available → skip gracefully

5. **Update Vault Notes**:
   - For each note that needs updating (from Step 3):
     - Read current note with `Read`
     - Use `Edit` to update changed sections only (preserve unchanged content)
     - Update `updated:` field in frontmatter to today
   - Update `_project-overview.md` frontmatter:
     - `last_synced:` → today's date
     - `last_synced_commit:` → current HEAD hash
     - `updated:` → today's date

6. **Generate Sync Report Note**:
   - Use `templates/sync-report.md` template
   - Filename: `YYYY-MM-DD-sync-[project-name].md`
   - Save to: `10-Projects/[name]/sync-history/`
   - Fill all sections with detected changes, commit list, file changes

7. **Auto-Link New Knowledge**:
   - For any newly detected technologies, APIs, or concepts:
     - Search vault for related notes
     - Score using /connect algorithm (project/ +50, area/ +30, keyword +20)
     - Add new links to relevant knowledge notes

8. **Update Knowledge Graph** (`mcp__memory`):
   - `mcp__memory__add_observations` to project entity:
     - "Synced on [date]: [N] commits, [summary of major changes]"
   - If new technologies/APIs detected → create new entities and relations

9. **Generate Sync Report** (displayed to user):
    ```
    🔄 Sync Report: [project-name]

    | 항목 | 내용 |
    |------|------|
    | Period | [last_synced] → [today] |
    | Commits | [N개] |
    | Files Changed | [N개] |

    ### Changes Detected
    | 영역 | 변경 | 업데이트된 노트 |
    |------|------|--------------|
    | Dependencies | ✅/— | tech-stack.md |
    | API Routes | ✅/— | api-reference.md |
    | DB Schema | ✅/— | db-schema.md |
    | CI/CD | ✅/— | deployment.md |
    | Architecture | ✅/— | architecture.md |
    | GitHub Issues | ✅/— | open-issues.md |

    ### Recent Commits
    - abc1234 feat: add user authentication
    - def5678 fix: resolve payment edge case
    - ...

    📄 Full report: [[10-Projects/[name]/sync-history/YYYY-MM-DD-sync-[name]]]

    💡 Next: `/devlog [name]: 작업 요약`으로 개발 일지 작성
    ```

10. **Post-Processing Pipeline** (Autopilot 자동화 레이어):
    - Update `mcp__memory` "active-context":
      - `mcp__memory__add_observations` to "active-context":
        `"last_sync: [project] at commit [hash] on [date]"`
        `"active_projects: [ensure this project is in the list]"`

    - **Spec/PRD Cross-Reference Alert**:
      - If API or Schema changes were detected (Step 3):
        - `Grep` vault for notes with matching `project/` tag AND `type: spec` or `type: prd`
        - For each matching spec/PRD:
          - Check if the spec references changed APIs or schemas
          - If yes → alert:
            ```
            ⚠️ API/Schema 변경이 [[spec-name]]에 영향을 줄 수 있습니다.
               `/analyze [[spec-name]]`으로 정합성을 확인해보세요.
            ```

    - **Stale Knowledge Detection**:
      - If architecture changes detected (new/deleted directories):
        - Check if related architecture decision records or specs exist
        - If they reference changed structures → flag for review:
          ```
          📋 아키텍처 변경으로 인해 다음 노트 검토가 필요할 수 있습니다:
             - [[architecture-note]] (last updated: [date])
          ```

    - **Auto-update Session Context**:
      - Add sync summary to "active-context" recent_topics
      - If many changes (>20 files) → add to pending_tasks:
        `"Review [project] sync changes in detail"`

Output: Display the sync summary with changes detected, notes updated, and next steps.

Onboard an external Git repository into the vault as structured knowledge notes.

Input: $ARGUMENTS (local path to repo, or GitHub URL)

Follow this process:

1. **Parse Input & Detect Repo Type**:
   - Extract path from $ARGUMENTS
   - If empty → ask user for repo path or GitHub URL
   - If starts with `http` or `git@` → GitHub URL
     - Ask user: "로컬 클론 경로를 입력해주세요 (예: ~/Desktop/[repo-name])"
   - If local path → verify directory exists with `Bash`: `ls [path]`
   - Verify it's a git repo: `Bash` with `git -C [path] rev-parse --git-dir`
   - Extract project name from directory name (slugified, lowercase, hyphens)
   - Check if already onboarded: `Glob` for `10-Projects/[name]/_project-overview.md`
     - If exists → "이 프로젝트는 이미 온보딩되어 있습니다. `/sync [name]`으로 업데이트하세요."

2. **Scan Repository Structure**:
   - File tree (exclude build artifacts):
     `Bash` with `find [path] -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/__pycache__/*' -not -path '*/venv/*' -not -path '*/.next/*' -not -path '*/build/*' -not -path '*/dist/*' -not -path '*/coverage/*' -type f | head -200`
   - Read key documentation files (if they exist):
     - `Read` [path]/README.md
     - `Read` [path]/CLAUDE.md → extract agents, commands, workflows
     - `Read` [path]/PRD.md (first 100 lines for summary)
     - `Read` [path]/CHANGELOG.md (first 50 lines for latest version)
     - `Read` [path]/.env.example → environment variable names (never values)
   - Skip files that don't exist — not all repos have these

3. **Identify Tech Stack** (code-analyst agent logic):
   - Check for dependency files:
     `Bash` with `ls [path]/package.json [path]/requirements.txt [path]/go.mod [path]/Cargo.toml [path]/pom.xml [path]/pyproject.toml 2>/dev/null`
   - Also check subdirectories:
     `Bash` with `ls [path]/backend/requirements.txt [path]/frontend/package.json [path]/server/package.json 2>/dev/null`
   - Read each found dependency file with `Read`
   - Extract: language(s), framework(s), major libraries, versions
   - Build tech_stack array for frontmatter

4. **Extract API Endpoints**:
   - Detect framework from Step 3
   - Use framework-specific `Grep` patterns:
     - **FastAPI**: `Grep` for `@(router|app)\.(get|post|put|delete|patch)` in `**/*.py` under [path]
     - **Express**: `Grep` for `(router|app)\.(get|post|put|delete|patch)\(` in `**/*.{js,ts}` under [path]
     - **Next.js**: `Glob` for `app/api/**/route.{ts,js}` or `pages/api/**/*.{ts,js}` under [path]
     - **Django**: `Grep` for `path\(` in `**/urls.py` under [path]
     - **Flask**: `Grep` for `@(app|blueprint)\.route` in `**/*.py` under [path]
   - Read matched files to extract: HTTP method, route path, handler description
   - Build endpoint table: | Method | Path | Description |
   - If no API routes detected → skip api-reference.md

5. **Extract Database Schema**:
   - Detect ORM from dependencies (SQLAlchemy, Prisma, Django ORM, Mongoose, TypeORM)
   - `Glob` for model files: `[path]/**/models/*.py`, `[path]/**/models.py`, `[path]/**/schema.prisma`, `[path]/**/*.entity.ts`
   - Read model files, extract: model name, fields, relationships
   - `Glob` for migration files: `[path]/**/migrations/**`, `[path]/**/alembic/**`, `[path]/**/prisma/migrations/**`
   - If no DB detected → skip db-schema.md

6. **Analyze CI/CD & Deployment**:
   - `Glob` for `[path]/.github/workflows/*.yml` → read each, extract: trigger events, jobs, deploy targets
   - Check for deployment configs:
     - `[path]/Dockerfile`, `[path]/docker-compose.yml`
     - `[path]/vercel.json`, `[path]/netlify.toml`, `[path]/railway.toml`, `[path]/fly.toml`
   - Read found configs → identify hosting platform and deployment process

7. **Query GitHub API** (via `Bash` with `gh` CLI):
   - Get remote URL: `Bash` with `git -C [path] remote get-url origin 2>/dev/null`
   - If GitHub remote found, extract owner/repo:
     - `gh issue list --repo [owner/repo] --limit 20 --json number,title,state,labels`
     - `gh pr list --repo [owner/repo] --limit 10 --json number,title,state,headRefName`
     - `gh run list --repo [owner/repo] --limit 5 --json status,conclusion,name,createdAt`
     - `gh release list --repo [owner/repo] --limit 5 2>/dev/null`
   - If `gh` not available or not authenticated → skip gracefully, note in report

8. **Create Project Folder & Knowledge Notes**:
   - Create folders with `Bash`:
     - `10-Projects/[name]/`
     - `10-Projects/[name]/devlogs/`
     - `10-Projects/[name]/sync-history/`
     - `10-Projects/[name]/specs/`
     - `10-Projects/[name]/bugs/`
   - Get current HEAD: `Bash` with `git -C [path] rev-parse --short HEAD`
   - Get GitHub URL from git remote (if available)

   Generate knowledge notes using `Write`:

   **a. `_project-overview.md`** — use `50-Templates/project-overview.md`:
   - Fill frontmatter: repo_path (absolute), github_url, tech_stack[], last_synced (today), last_synced_commit (HEAD)
   - Fill all sections from gathered data
   - Link to sub-notes in "Knowledge Notes" section

   **b. `architecture.md`**:
   - Frontmatter: type: note, tags: [type/note, project/[name], doctype/code-knowledge]
   - Content: File tree (code block), module descriptions, component relationships
   - If CLAUDE.md exists: document the agent/command architecture

   **c. `tech-stack.md`**:
   - Frontmatter: type: note, tags: [type/note, project/[name], doctype/code-knowledge]
   - Content: Dependencies table (Name | Version | Purpose), categorized by backend/frontend/infra

   **d. `api-reference.md`** (only if API routes detected):
   - Frontmatter: type: note, tags: [type/api-reference, project/[name], doctype/code-knowledge]
   - Content: Endpoint table (Method | Path | Description), grouped by domain/module

   **e. `db-schema.md`** (only if DB detected):
   - Frontmatter: type: note, tags: [type/db-schema, project/[name], doctype/code-knowledge]
   - Content: Model definitions, field tables (Name | Type | Description), relationships

   **f. `deployment.md`**:
   - Frontmatter: type: note, tags: [type/note, project/[name], doctype/code-knowledge]
   - Content: CI/CD pipeline description, hosting info, environment variables (keys only!), deployment process

   **g. `open-issues.md`** (only if GitHub connected):
   - Frontmatter: type: note, tags: [type/note, project/[name], doctype/code-knowledge]
   - Content: Open issues table, recent PRs, Actions status

9. **Auto-Link Related Notes** (reuse /connect scoring):
   - Extract keywords from: project name, tech stack, PRD summary
   - Scan vault for related notes:
     - `Grep` for matching `project/` tags
     - `Grep` for matching tech terms in `30-Resources/tech-notes/`
     - `Grep` for matching `area/` tags in `20-Areas/`
     - Query `mcp__memory__search_nodes` with project keywords
   - Score: project/ +50, area/ +30, tech keyword +20, memory +30, tag +10
   - Threshold ≥ 40 → create [[wikilink]]
   - Add `## Related Notes` to `_project-overview.md` with top 10 links

10. **Update Knowledge Graph** (`mcp__memory`):
    - `mcp__memory__create_entities`:
      ```
      name: "[project-name]"
      entityType: "project"
      observations: [tech stack, repo path, github url, executive summary]
      ```
    - `mcp__memory__create_entities` for each knowledge note
    - `mcp__memory__create_relations` for all connections

11. **Update Projects MOC**:
    - Dataview queries in `_projects-moc.md` auto-detect if frontmatter is correct
    - No manual edit needed

12. **Generate Onboard Report**:
    ```
    🔍 Onboard Report

    | 항목 | 내용 |
    |------|------|
    | Project | [project name] |
    | Repo Path | [local path] |
    | GitHub | [URL or "N/A"] |
    | Tech Stack | [Python 3.11, FastAPI, Next.js 14, etc.] |
    | API Endpoints | [N개 detected] |
    | DB Models | [N개 detected] |
    | CI/CD | [GitHub Actions / Vercel / etc.] |
    | Vault Notes | [N개 created in 10-Projects/[name]/] |
    | Auto-Links | [N개 관련 노트 연결됨] |

    ### Created Notes
    - [[10-Projects/[name]/_project-overview]]
    - [[10-Projects/[name]/architecture]]
    - [[10-Projects/[name]/tech-stack]]
    - [[10-Projects/[name]/api-reference]]  (if applicable)
    - [[10-Projects/[name]/db-schema]]  (if applicable)
    - [[10-Projects/[name]/deployment]]
    - [[10-Projects/[name]/open-issues]]  (if GitHub connected)

    💡 Next Steps:
    - `/sync [name]`으로 주기적 동기화
    - `/devlog [name]: 오늘 작업 내용`으로 개발 일지
    - `/spec`, `/analyze` 등으로 프로젝트 지식 활용
    ```

Output: Display the onboard report with project details, created notes, and next steps.

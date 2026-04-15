# Knowledge OS

**Obsidian + Claude Code** framework for building a personal/team knowledge management system.

Turn your Obsidian vault into an AI-powered knowledge operating system with 6 specialized agents, 19 slash commands, and automated session lifecycle management.

## What is this?

Knowledge OS is a pre-configured Claude Code setup that transforms an Obsidian vault into an intelligent knowledge management system. It provides:

- **6 AI Agents** that handle different aspects of knowledge work (curation, writing, analysis, code intelligence, gardening, automation)
- **19 Slash Commands** for common knowledge operations (`/capture`, `/research`, `/import`, `/garden`, etc.)
- **6 Workflows** that chain commands into complete pipelines (idea-to-spec, document-to-knowledge, etc.)
- **4 Automation Hooks** for proactive vault health monitoring
- **19 Templates** for consistent note creation
- **PARA Method** folder structure with MOC (Maps of Content) navigation

## Quick Start

### Prerequisites

- [Obsidian](https://obsidian.md/) (for viewing/editing notes)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Recommended MCP servers: `filesystem`, `brave-search`, `github`, `memory`, `sequential-thinking`

### Installation

```bash
# Clone the repo as your vault
git clone https://github.com/simon-park-1219/knowledge-os.git my-vault

# Open in Claude Code
cd my-vault
claude

# Start with autopilot
/autopilot
```

### First Session

1. `/autopilot` — Initializes context, checks vault health, creates daily note
2. `/capture "My first idea"` — Captures an idea to Inbox
3. `/garden` — Runs vault health check (orphans, stale notes, broken links)
4. `/wrapup` — Saves session context for next time

## Architecture

```
knowledge-os/
├── .claude/
│   ├── agents/        # 6 specialized AI agents
│   ├── commands/      # 19 slash commands
│   ├── skills/        # Skill implementations
│   ├── workflows/     # 6 multi-step pipelines
│   ├── hooks/         # 4 automation hooks
│   └── settings.json  # Hook configuration
├── 50-Templates/      # 19 note templates
├── 00-Inbox/          # Uncategorized captures
├── 10-Projects/       # Active projects (with deadlines)
├── 20-Areas/          # Ongoing responsibilities
├── 30-Resources/      # Reference materials
├── 40-Archives/       # Completed/inactive items
├── 60-Daily/          # Daily notes (YYYY/MM/YYYY-MM-DD.md)
├── CLAUDE.md          # System design document
└── README.md
```

## Agents

| Agent | Role |
|-------|------|
| **curator** | Note classification, tagging, dedup, inbox triage |
| **writer** | Template-based note creation, summaries |
| **gardener** | Vault maintenance, health scoring, quality review |
| **business-analyst** | Document analysis, research, compliance, spec generation |
| **code-analyst** | Git repo analysis, tech stack identification, code-to-knowledge mapping |
| **autopilot** | Session lifecycle automation, context management |

## Key Commands

### Knowledge Capture
| Command | Description |
|---------|-------------|
| `/capture` | Quick idea capture to Inbox |
| `/research` | Web search + structured research note |
| `/import` | Ingest business docs (PDF/Excel/Word/PPT/CSV/Image) |
| `/distill` | Extract conversation insights into vault notes |

### Knowledge Processing
| Command | Description |
|---------|-------------|
| `/analyze` | Deep cross-reference analysis |
| `/connect` | Auto-link related notes (relevance scoring) |
| `/propose` | Generate business proposals from vault knowledge |
| `/plan` | Implementation planning with annotation cycles |
| `/spec` | Feature spec from idea/Lean Canvas |

### Code Intelligence
| Command | Description |
|---------|-------------|
| `/onboard` | Scan Git repo → generate knowledge notes |
| `/sync` | Incremental sync of repo changes |
| `/devlog` | Daily dev log from git commits |

### Vault Maintenance
| Command | Description |
|---------|-------------|
| `/garden` | Orphan detection, stale cleanup, health scoring |
| `/review` | Note quality review |
| `/moc` | Generate/update Maps of Content |

### Session Lifecycle
| Command | Description |
|---------|-------------|
| `/autopilot` | Morning routine: load context, health check, recommendations |
| `/wrapup` | Save context, summarize session, suggest next actions |
| `/commit` | Git commit with conventional format |

## Workflows

1. **idea-to-spec** — `/capture` → `/research` → Lean Canvas → `/plan` (annotation cycle) → `/spec`
2. **document-to-knowledge** — `/import` → classify → `/analyze` → `/connect` → summarize
3. **code-to-knowledge** — `/onboard` → develop → `/sync` → `/devlog`
4. **knowledge-gardening** — orphan scan → stale check → MOC update → tag cleanup
5. **bug-lifecycle** — `/bug` → investigate → fix → `/review`
6. **autopilot-pipeline** — session start → auto-processing → session end

## Automation Levels

| Level | Mode | User Input | How |
|-------|------|-----------|-----|
| L0 | Manual | All commands typed | `/garden`, `/sync`, etc. |
| L1 | Semi-auto | Session start/end only | Hooks auto-notify |
| **L2** | **Auto (default)** | **Open session only** | **SessionStart hook → autopilot** |
| L3 | Unattended | None | `daily-autopilot.sh` via cron/launchd |

## Health Score

The vault health score (0-100) tracks knowledge hygiene:

```
100 - orphans×2 - stale×3 - broken_links×5 - missing_frontmatter×3 - bad_tags×1 - old_inbox×2 - stale_moc×2
```

## Customization

### Adding a new command

Create `.claude/commands/my-command.md`:
```markdown
Description of what $ARGUMENTS should contain.

1. Step 1...
2. Step 2...
```

### Adding a new template

Create `50-Templates/my-template.md` with YAML frontmatter and placeholder sections.

### Configuring hooks

Edit `.claude/settings.json` to add/modify event hooks (SessionStart, Stop, PostToolUse).

## Philosophy

### Why Knowledge OS?

지식 작업자의 가장 큰 병목은 "아는 것"이 아니라 **"알고 있는 것을 다시 찾는 것"**입니다.

노트를 열심히 작성해도, 시간이 지나면 어디에 무엇을 적었는지 잊게 됩니다. 회의에서 나온 결정사항, 리서치 결과, 프로젝트 스펙이 vault 곳곳에 흩어져 있지만 — 정작 필요한 순간에 찾지 못합니다. Knowledge OS는 이 문제를 AI 에이전트로 해결합니다.

### Core Beliefs

**1. Knowledge is a living system, not a filing cabinet**

노트는 한 번 작성하고 잊히는 문서가 아니라, 계속 성장하고 연결되는 유기체입니다. `/garden` 커맨드가 orphan 노트를 발견하고, `/connect`가 숨겨진 관계를 찾아주며, health score가 vault의 건강 상태를 추적합니다. 정원처럼 가꾸지 않으면 잡초가 자랍니다.

**2. Capture first, organize later**

아이디어는 빠르게 사라집니다. `/capture`로 먼저 잡아두고, 분류와 연결은 AI가 나중에 처리합니다. Inbox → PARA 구조로의 분류, 태그 추천, 관련 노트 연결까지 — 인간은 생각에 집중하고, 정리는 시스템에 위임합니다.

**3. AI as a thinking partner, not just a tool**

6개 에이전트는 각각 다른 사고 방식을 가지고 있습니다. Curator는 분류하고, Gardener는 정리하며, Business-Analyst는 분석합니다. 이들은 단순 자동화가 아니라 **인지적 파트너**로서, 사용자가 놓칠 수 있는 연결과 패턴을 발견합니다.

**4. Session as a unit of work**

모든 작업은 세션 단위로 관리됩니다. `/autopilot`으로 어제의 컨텍스트를 로드하고, 작업을 수행하고, `/wrapup`으로 오늘의 인사이트를 저장합니다. 세션 간 컨텍스트가 끊기지 않기 때문에, 3일 전 작업을 이어서 하는 것이 자연스럽습니다.

**5. Code and documents are the same knowledge**

코드 리포지토리와 비즈니스 문서는 별개의 세계가 아닙니다. `/onboard`로 Git 리포를 vault에 통합하고, `/import`로 PDF/Excel을 구조화하면 — PRD의 요구사항이 코드의 API 엔드포인트와 자동으로 교차 참조됩니다.

### Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Progressive automation** | L0(수동) → L1(알림) → L2(자동) → L3(무인) 4단계 자동화 수준 |
| **Safe by default** | 자동 수정은 frontmatter 필드에만 적용, 본문은 절대 자동 수정하지 않음 |
| **Graceful degradation** | MCP 서버 없어도 기본 기능 작동, API 없으면 해당 기능만 건너뜀 |
| **Convention over configuration** | PARA 폴더 구조, 태그 taxonomy, frontmatter 규격이 미리 정의되어 있음 |
| **Append-only audit trail** | `_changelog.md`에 모든 변경이 시간순으로 기록됨 |

### Inspirations

이 프로젝트는 다음 아이디어들의 교차점에서 탄생했습니다:

- **[PARA Method](https://fortelabs.com/blog/para/)** (Tiago Forte) — Projects/Areas/Resources/Archives 4단계 분류. "실행 가능성(actionability)" 기준으로 정보를 조직하라는 원칙.
- **[Karpathy의 LLM Wiki 패턴](https://karpathy.ai/)** — Raw Sources → Wiki → Schema 3-Layer 모델. LLM이 인간과 공동으로 위키를 유지하는 패러다임. Knowledge OS의 `_world-model.md`, `_master-index.md`, `_changelog.md` 인프라가 여기서 왔습니다.
- **[Alfred System](https://github.com/david-ai)** (David) — AI 에이전트의 세션 수명주기 자동화. Heartbeat(맥박) + Janitor(청소부) + Processor(처리기) 3-서브시스템 아키텍처.
- **[Boris Tane의 Annotation Cycle](https://x.com/boristane)** — "코드를 쓰기 전에 계획을 검토하라." Plan → Annotate → Refine → Execute 패턴. `/plan` 커맨드의 "승인 전 실행 금지" 원칙.
- **[Zettelkasten](https://zettelkasten.de/)** (Niklas Luhmann) — 원자적(atomic) 노트와 링크 기반 연결. `/connect`의 관련도 스코어링과 양방향 링크 철학.
- **[Digital Garden](https://maggieappleton.com/garden-history)** (Maggie Appleton) — 완성된 문서가 아닌 "성장하는 지식"으로서의 노트. `/garden`이 정원 비유를 직접 구현합니다.

## License

MIT

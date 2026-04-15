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

## Design Inspirations

- [PARA Method](https://fortelabs.com/blog/para/) by Tiago Forte
- [LLM Wiki Pattern](https://karpathy.ai/) by Andrej Karpathy
- [Alfred System](https://github.com/david-ai) — Session lifecycle automation
- [Boris Tane Annotation Cycle](https://x.com/boristane) — Plan → Refine → Execute pattern

## License

MIT

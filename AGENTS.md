# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on this project.

<!-- BEGIN BEADS INTEGRATION -->
## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Auto-syncs to JSONL for version control
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**

```bash
bd ready --json
```

**Create new issues:**

```bash
bd create "Issue title" --description="Detailed context" -t bug|feature|task -p 0-4 --json
bd create "Issue title" --description="What this issue is about" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**

```bash
bd update bd-42 --status in_progress --json
bd update bd-42 --priority 1 --json
```

**Complete work:**

```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" --description="Details about what was found" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Auto-Sync

bd automatically syncs with git:

- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed!

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

For more details, see README.md and docs/QUICKSTART.md.

### Operational Rules for AI Agents

- ✅ Do NOT use `bd edit` (interactive editor). Use `bd update` flags instead.
- ✅ After making any bd changes, run `bd sync` to flush JSONL and git.
- ✅ For manual bd testing, use an isolated DB: `BEADS_DB=/tmp/test.db`.
- ✅ When committing work for an issue, include the issue ID in the commit message, e.g. `Fix flaky spec (bd-123)`.

### Troubleshooting and Debugging

- ✅ Enable debug logs with env vars when diagnosing issues:
- `BD_DEBUG` (general), `BD_DEBUG_RPC` (daemon RPC), `BD_DEBUG_SYNC` (sync/import), `BD_DEBUG_FRESHNESS` (db file replacement, daemon logs).
- ✅ Capture debug output to a file when needed: `BD_DEBUG=1 bd sync 2> debug.log`.
- ✅ Daemon logs live in `.beads/daemon.log` (use `tail -f .beads/daemon.log`).
- ✅ In sandboxed environments, use `bd --sandbox` to avoid daemon/staleness issues; run `bd sync` after leaving sandbox.

### Architecture (Quick Understanding)

- ✅ Three-layer model: CLI → local SQLite (`.beads/beads.db`) → git-tracked JSONL (`.beads/issues.jsonl`) → remote git.
- ✅ SQLite is fast local cache; JSONL is the source of truth shared via git.
- ✅ Daemon batches writes (default 5s debounce) and manages auto-export/import.
- ✅ Hash-based IDs prevent collisions across branches and agents.
- ✅ Protected-branch workflow uses `sync.branch` (this repo sets `beads-sync`) to keep metadata off `main`.

### Configuration Notes

- ✅ Tool-level config (Viper) uses flags/env/`.beads/config.yaml` for CLI behavior; project-level config uses `bd config` keys stored in the DB.
- ✅ Prefer `bd config set|get|list` over manual YAML edits for project settings.
- ✅ `sync.branch` controls protected-branch workflow; `flush-debounce` controls auto-export batching.
- ✅ Actor resolution order: `--actor` → `BD_ACTOR` → `BEADS_ACTOR` → `git config user.name` → `$USER`.

### CLI Reference (Quick)

- ✅ Basics: `bd info --json`, `bd ready --json`, `bd list --json`, `bd show <id> --json`.
- ✅ Updates: `bd create "Title" -t task -p 2 -d "Desc" --json`, `bd update <id> --status in_progress --json`, `bd close <id> --reason "Done" --json`.
- ✅ Dependencies: `bd dep add <child> <parent> --type discovered-from`, or `bd create ... --deps discovered-from:<parent> --json`.
- ✅ Global flags (prefix before command): `--json`, `--no-daemon`, `--no-auto-flush`, `--no-auto-import`, `--sandbox`, `--allow-stale`.

<!-- END BEADS INTEGRATION -->


## Build & Test

_Add your build and test commands here_

```bash
# Example:
# npm install
# npm test
```

## Architecture Overview

_Add a brief overview of your project architecture_

## Conventions & Patterns

_Add your project-specific conventions here_

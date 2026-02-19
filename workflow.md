# Git Integration Guide

**For:** AI agents and developers managing bd git workflows
**Version:** 0.21.0+

## Overview

bd integrates with git for issue tracking synchronization. This guide covers merge conflict resolution, merge drivers, git worktrees, and protected branch workflows.

## Git Worktrees

**NOTE:** Beads has enhanced git worktree compatibility with shared database architecture. While tested internally, real-world usage may reveal additional edge cases.

### How It Works

Git worktrees share the same `.git` directory and `.beads` database:
- All worktrees use the same `.beads/beads.db` file in the main repository
- Database discovery prioritizes main repository location
- Worktree-aware git operations prevent conflicts
- Git hooks automatically adapt to worktree context

### Daemon Mode Limitations

**WARNING:** Daemon mode does NOT work correctly with `git worktree` due to shared database state.

The daemon maintains its own view of the current working directory and git state. When multiple worktrees share the same `.beads` database, the daemon may commit changes intended for one branch to a different branch.

### Solutions for Worktree Users

1. Use `--no-daemon` flag (recommended):

```bash
bd --no-daemon ready
bd --no-daemon create "Fix bug" -p 1
bd --no-daemon update bd-42 --status in_progress
```

2. Disable daemon via environment (entire session):

```bash
export BEADS_NO_DAEMON=1
bd ready  # All commands use direct mode
```

3. Disable auto-start (less safe, still warns):

```bash
export BEADS_AUTO_START_DAEMON=false
```

### Automatic Detection and Warnings

bd detects worktrees and warns if daemon mode is active:

```
WARNING: Git worktree detected with daemon mode
Shared database: /path/to/main/.beads
Worktree git dir: /path/to/shared/.git
Recommended:
  1. Use --no-daemon: bd --no-daemon <command>
  2. Disable daemon:  export BEADS_NO_DAEMON=1
```

### Worktree-Aware Features

Database discovery:
- Searches main repository first for `.beads`
- Falls back to worktree-local search if needed
- Prevents database duplication across worktrees

Git hooks:
- Pre-commit hook adapts to worktree context
- Stages JSONL in regular repos
- Skips staging in worktrees for files outside working tree
- Post-merge hook works in both contexts

Sync operations:
- Worktree-aware repository root detection
- Handles git dir vs git common dir correctly
- Safe concurrent access to shared database

### Why This Architecture Works

- Shared database eliminates data duplication and sync conflicts
- Priority search prefers the main repository database
- SQLite locking prevents corruption during concurrent access
- Hooks and sync operations adapt to context
- Clear warnings guide safe usage

## Handling Merge Conflicts

With hash-based IDs (v0.20.1+), ID collisions are eliminated. Conflicts in `.beads/issues.jsonl` happen when the same issue is modified on both branches.

### Automatic Detection

`bd import` rejects files with conflict markers:

```bash
bd import -i .beads/issues.jsonl
# Error: JSONL file contains git conflict markers
```

Validate for conflicts:

```bash
bd validate --checks=conflicts
```

Conflict markers: `<<<<<<<`, `=======`, `>>>>>>>`

### Resolution Workflow

```bash
# Option 1: Accept their version (remote)
git checkout --theirs .beads/issues.jsonl
bd import -i .beads/issues.jsonl

# Option 2: Keep our version (local)
git checkout --ours .beads/issues.jsonl
bd import -i .beads/issues.jsonl

# Option 3: Manual resolution in editor
# Remove conflict markers, then import
bd import -i .beads/issues.jsonl

# Commit the merge
git add .beads/issues.jsonl
git commit
```

## Intelligent Merge Driver (Auto-Configured)

As of v0.21+, bd auto-configures its merge driver during `bd init`.

### What It Does

- Field-level 3-way merging (not line-by-line)
- Matches issues by identity (id + created_at + created_by)
- Smart field merging:
  - Timestamps -> max value
  - Dependencies -> union
  - Status/priority -> 3-way merge
- Conflict markers only for unresolvable conflicts

### Auto-Configuration

Configured during `bd init`:

```bash
git config merge.beads.driver "bd merge %A %O %A %B"
git config merge.beads.name "bd JSONL merge driver"
```

And adds to `.gitattributes`:

```
.beads/issues.jsonl merge=beads
```

### Manual Setup

If you skipped merge driver with `--skip-merge-driver`:

```bash
git config merge.beads.driver "bd merge %A %O %A %B"
git config merge.beads.name "bd JSONL merge driver"
echo ".beads/issues.jsonl merge=beads" >> .gitattributes
```

### Jujutsu Integration

Add to `~/.config/jj/config.toml`:

```toml
[merge-tools.beads-merge]
program = "bd"
merge-args = ["merge", "$output", "$base", "$left", "$right"]
merge-conflict-exit-codes = [1]
```

Then resolve with:

```bash
jj resolve --tool=beads-merge .beads/issues.jsonl
```

## Protected Branch Workflows

If your repository uses protected branches, bd can commit to a separate branch instead of `main`.

### Configuration

```bash
# Initialize with separate sync branch
bd init --branch beads-sync

# Or configure existing setup
bd config set sync.branch beads-sync
```

### How It Works

- Beads commits issue updates to `beads-sync` instead of `main`
- Uses git worktrees in `.git/beads-worktrees/`
- Main working directory is not affected
- Merge `beads-sync` back to `main` via pull request

### Daily Workflow (Unchanged for Agents)

```bash
bd create "Fix authentication" -t bug -p 1
bd update bd-a1b2 --status in_progress
bd close bd-a1b2 "Fixed"
```

All changes commit to `beads-sync` if daemon is running with `--auto-commit`.

### Merging to Main (Humans)

```bash
# Check what's changed
bd sync --status

# Option 1: Create pull request
git push origin beads-sync
# Then create PR on GitHub/GitLab

# Option 2: Direct merge (if allowed)
bd sync --merge
```

### Benefits

- Works with protected branches
- No disruption to agent workflows
- Platform-agnostic
- Backward compatible (opt-in via config)

See `PROTECTED_BRANCHES.md` for full setup.

## Git Hooks Integration

**Recommended:** Install git hooks for automatic sync and consistency.

### Installation

```bash
# One-time setup in each beads workspace
./examples/git-hooks/install.sh
```

### What Gets Installed

pre-commit:
- Flushes pending changes before commit
- Bypasses debounce
- Guarantees JSONL is current

post-merge:
- Imports updated JSONL after pull/merge
- Keeps DB in sync

pre-push:
- Exports DB to JSONL before push
- Prevents stale JSONL on remote

post-checkout:
- Imports JSONL after branch switches

### Why Hooks Matter

Without pre-push, DB changes may be committed but JSONL pushed stale. Hooks guarantee DB <-> JSONL consistency.

## Multi-Workspace Sync Strategies

Centralized repository pattern:
- Each workspace has its own daemon
- Git is the source of truth
- Auto-sync keeps workspaces consistent

Fork-based pattern:
- Contributors track issues in a separate planning repo
- Upstream repo stays clean

Team branch pattern:
- Protected branch workflows using a shared sync branch

See `MULTI_REPO_MIGRATION.md` for details.

## Sync Timing and Control

Automatic sync (daemon running, SQLite backend):
- Export to JSONL: debounce after changes
- Import from JSONL: when file is newer than DB
- Commit/push: configurable via `--auto-commit` / `--auto-push`

Manual sync:

```bash
bd sync
# Export -> commit -> pull -> import -> push
```

**Agents should run `bd sync` at end of sessions.**

## Git Configuration Best Practices

Recommended `.gitignore`:

```
.beads/beads.db
.beads/beads.db-*
.beads/bd.sock
.beads/bd.pipe
.beads/.exclusive-lock
.git/beads-worktrees/
```

Recommended `.gitattributes`:

```
.beads/issues.jsonl merge=beads
.beads/*.jsonl text diff
```

Do not use Git LFS for `.beads/issues.jsonl`.

## Troubleshooting Git Issues

JSONL ahead of DB:

```bash
bd import -i .beads/issues.jsonl
```

DB ahead of JSONL:

```bash
bd sync
```

Conflicts every time (merge driver missing):

```bash
git config merge.beads.driver
bd init --skip-db
```

Changes not syncing between workspaces:

```bash
# Agent A
bd sync

git push

# Agent B
git pull
bd import -i .beads/issues.jsonl
```

## See Also

- `AGENTS.md`
- `DAEMON.md`
- `PROTECTED_BRANCHES.md`
- `MULTI_REPO_MIGRATION.md`
- `examples/git-hooks/README.md`

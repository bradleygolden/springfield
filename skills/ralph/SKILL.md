---
name: ralph
description: Activate when the terms "Springfield" or "Ralph" are mentioned.
allowed-tools:
  - Bash
  - SlashCommand
  - Read
  - Write
  - AskUserQuestion
  - BashOutput
  - KillShell
---

# Ralph - Autonomous Workflow Orchestration

*"I'm learnding!"* - Ralph Wiggum

Autonomous implementation system that researches, plans, implements, and validates tasks through distinct phases.

Infer the task to implement from the recent conversation context. If unclear, ask the user what task they want Springfield to work on.

## Ralph Philosophy

Ralph is used for autonomous development - eventual consistency through iterative refinement. See [REFERENCE.md](REFERENCE.md) for details.

## Session Setup

1. Extract session name from task (kebab-case, max 30 chars, lowercase)
2. Create session directory: `.springfield/$(date +%m-%d-%Y)-$SESSION_NAME/`
3. Export SESSION_DIR environment variable

## Workflow Phases

Execute phases using Springfield slash commands:

### Phase 1: Lisa (Research)
```
/springfield:lisa [task-description]
```
Spawns Task agents to thoroughly research the codebase. Lisa investigates files, patterns, and similar implementations. Pass the inferred or clarified task description.

**Output**: `$SESSION_DIR/research.md`

### Phase 2: Mayor Quimby (Decide)
```
/springfield:mayor-quimby
```
Assesses task complexity from Lisa's research findings.

**Output**: `$SESSION_DIR/decision.txt` (SIMPLE or COMPLEX)

### Phase 3: Frink (Plan)
```
/springfield:frink
```
Creates implementation plan. For complex tasks, runs debate workflow for refinement.

**Output**: `$SESSION_DIR/prompt.md`

### Phase 4: Homer (Implement)
```
/springfield:homer
```
Launches autonomous implementation loop in background.

**Monitors**: `$SESSION_DIR/scratchpad.md`, `$SESSION_DIR/completion.md`

### Phase 5: Comic Book Guy (QA)
```
/springfield:comic-book-guy
```
Validates implementation quality. Can kickback to earlier phases if issues found.

**Output**: `$SESSION_DIR/qa-report.md`

## Helper Scripts

Springfield has helper scripts in `${CLAUDE_PLUGIN_ROOT}/skills/ralph/scripts/`:

### ralph.sh - Autonomous Implementation Loop
Run when implementing tasks autonomously:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/ralph/scripts/ralph.sh "$SESSION_DIR"
```

This script:
- Reads `prompt.md` for implementation guidance
- Iteratively implements small pieces via Claude CLI
- Updates `scratchpad.md` with progress
- Monitors `completion.md` for finish signal

### debate.sh - Debate Refinement Loop
Run when refining complex plans:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/ralph/scripts/debate.sh "$SESSION_DIR/prompt_debate.md"
```

This script:
- Spawns Proposer and Counter agents
- Iteratively refines implementation plans
- Creates final `prompt.md` when agents agree

## Orchestration Strategy

When invoked as a skill, Springfield:

1. Sets up session directory
2. Executes phases sequentially via SlashCommand
3. Monitors completion signals
4. Handles kickbacks from QA
5. Reports final status

## Context Management

Springfield optimizes context window usage:
- Breaks large tasks into smaller loops
- Uses read-only subagents to prevent conflicts
- Keeps sessions under 40% context window usage
- Leverages debate workflow for complex planning

## Adaptive Loop

QA phase can kickback to any earlier phase:
- Research issues → Re-run `/springfield:lisa`
- Design issues → Re-run `/springfield:frink`
- Implementation issues → Re-run `/springfield:homer`

This creates an eventual consistency model where the system iteratively refines until QA passes.

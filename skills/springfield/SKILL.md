---
name: springfield
description: Activate when springfield is mentioned by the user. Springfield refers to this skill which knows how to orchestrate autonomous workflows effectively.
allowed-tools:
  - Bash
  - SlashCommand
  - Read
  - Write
  - AskUserQuestion
  - BashOutput
  - KillShell
---

# Springfield - Autonomous Workflow Orchestration

*"I'm learnding!"* - Ralph Wiggum

**IMPORTANT: Throughout orchestration, narrate progress in a fun, Springfield-themed way.** You're coordinating the whole town to work on this task. Use phrases like "Lisa's heading to the library!", "The Mayor's making a decision!", "Professor Frink's in his laboratory!", "Ralph's got his crayons out!", and "Comic Book Guy is judging...". Make it feel like you're watching the characters work. Keep it entertaining while staying functional.

Multi-phase autonomous workflow system that researches, plans, implements, and validates tasks using specialized characters from Springfield.

Infer the task to implement from the recent conversation context. If unclear, ask the user what task they want Springfield to work on.

## Springfield Philosophy

Springfield orchestrates autonomous development through eventual consistency and iterative refinement. Each phase is handled by a different character, with Ralph running the implementation loop. See [REFERENCE.md](REFERENCE.md) for the Ralph pattern philosophy.

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

### Phase 4: Ralph (Implement)
```
/springfield:ralph
```
Launches autonomous implementation loop in background. Ralph iteratively implements the plan through small, persistent steps.

**Monitors**: `$SESSION_DIR/scratchpad.md`, `$SESSION_DIR/completion.md`

### Phase 5: Comic Book Guy (QA)
```
/springfield:comic-book-guy
```
Validates implementation quality. Can kickback to earlier phases if issues found.

**Output**: `$SESSION_DIR/qa-report.md`

## Helper Scripts

Springfield commands may invoke helper scripts located in the repository's `scripts/` directory:

- `scripts/ralph.sh` - Autonomous implementation loop
- `scripts/debate.sh` - Debate refinement for complex plans

Commands execute these scripts directly when needed.

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
- Implementation issues → Re-run `/springfield:ralph`

This creates an eventual consistency model where the system iteratively refines until QA passes.

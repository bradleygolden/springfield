---
name: springfield
description: Activate when springfield is mentioned by the user. Springfield refers to this skill which knows how to orchestrate autonomous workflows effectively.
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - TodoWrite
  - AskUserQuestion
  - BashOutput
  - KillShell
---

# Springfield - Autonomous Workflow Orchestration

*"I'm learnding!"* - Ralph Wiggum

**IMPORTANT: Throughout orchestration, narrate progress in a fun, Springfield-themed way.** You're coordinating the whole town to work on this task. Use phrases like "Lisa's heading to the library!", "The Mayor's making a decision!", "Professor Frink's in his laboratory!", "Ralph's got his crayons out!", and "Comic Book Guy is judging...". Make it feel like you're watching the characters work. Keep it entertaining while staying functional.

## Welcome to Springfield!

You've activated the Springfield autonomous workflow orchestrator! This skill will:
- Research your task thoroughly (Lisa)
- Assess complexity (Mayor Quimby)
- Create implementation plans (Professor Frink, reviewed by Principal Skinner for complex tasks)
- Implement iteratively (Ralph)
- Validate quality (Comic Book Guy)

All automatically, end-to-end!

## Step 1: Understand the Task

First, let me infer what task you want Springfield to work on from our recent conversation. If it's unclear, I'll ask you directly.

## Step 2: Session Initialization

Create session directory: `.springfield/MM-DD-YYYY-task-name/`

Initialize session files:
- `state.json` - Tracks workflow phases, transitions, kickbacks
- `chat.md` - Communication channel for user messages to characters
- `task.txt` - Task description

## Step 3: Orchestration Loop

Execute phases in sequence, monitoring state:

### Phase: Lisa (Research)
Lisa uses Task agents to thoroughly research the codebase. She investigates:
- Existing implementations and patterns
- Related files and dependencies
- Technical constraints and requirements
- Project structure and conventions

**Output**: `research.md`

### Phase: Mayor Quimby (Decide Complexity)
Invokes: `bash scripts/quimby.sh "$SESSION_DIR"`

Mayor Quimby reviews Lisa's research and makes an executive decision: SIMPLE or COMPLEX?

**Output**: `decision.txt`

### Phase: Professor Frink (Plan)
Invokes: `bash scripts/frink.sh "$SESSION_DIR"`

Professor Frink creates the implementation plan using scientific methodology, glavin!
- SIMPLE tasks: Creates `prompt.md` directly, goes to Ralph
- COMPLEX tasks: Creates `plan-v1.md`, sends to Skinner for review

**Output**: `plan-v1.md` (complex) or `prompt.md` (simple)

### Phase: Principal Skinner (Review) [Complex Tasks Only]
Invokes: `bash scripts/skinner.sh "$SESSION_DIR"`

Skinner reviews Frink's plan with his strict, by-the-book standards. Points out flaws and demands improvements.

After review, Frink is invoked again to incorporate feedback into final `prompt.md`.

**Output**: `review.md`

### Phase: Ralph (Implement)
Invokes: `bash scripts/ralph.sh "$SESSION_DIR"` (background process)

Ralph runs the implementation loop! He works iteratively, making small changes, committing progress. Monitors `completion.md` for completion signal.

**Output**: `scratchpad.md` (progress), `completion.md` (when done)

### Phase: Comic Book Guy (QA)
Invokes: `bash scripts/comic-book-guy.sh "$SESSION_DIR"`

Comic Book Guy validates the implementation. Worst code ever... or is it?

Verdicts:
- **APPROVED**: Task complete! Success!
- **KICK_BACK**: Issues found, route back to lisa/frink/ralph (max 2 attempts per target)
- **ESCALATE**: Too many kickbacks or needs user input

**Output**: `qa-report.md`

## Step 4: Completion

When workflow reaches status "complete", report success and show the completion summary!

If workflow reaches status "blocked", escalate to user with details from `chat.md`.

## Workflow State Machine

```
lisa → quimby → frink → [skinner → frink] → ralph → comic-book-guy
                         (complex only)                    ↓
                                                    APPROVED ✓
                                                    KICK_BACK → (lisa|frink|ralph)
                                                    ESCALATE → USER
```

## Error Handling

- Max 100 orchestration loop iterations (prevents infinite loops)
- Character scripts exit non-zero → mark failed, write to chat.md
- Ralph timeout: 60 minutes max
- Kickback limits: Max 2 per target, then ESCALATE

## Springfield Philosophy

Springfield orchestrates autonomous development through eventual consistency and iterative refinement. Each phase is handled by a different character, with Ralph running the implementation loop. See [REFERENCE.md](REFERENCE.md) for the Ralph pattern philosophy.

---

## Implementation: Autonomous Orchestrator

When this skill is invoked, execute the following orchestration logic:

1. **Infer or ask for task**: Extract from conversation context using AskUserQuestion if unclear
2. **Create session directory**: `.springfield/MM-DD-YYYY-sanitized-task-name/`
3. **Initialize session files**: Copy templates, populate with session metadata
4. **Create TodoWrite list**: Track orchestration progress
5. **Main loop** (max 100 iterations):
   - Read `state.json` to determine current status and next phase
   - If status is "complete": Report success, show completion.md, EXIT
   - If status is "blocked": Report escalation, point to chat.md, EXIT
   - If status is "failed": Report failure, EXIT
   - Execute next phase:
     - **lisa**: Use Task tool for research (not external script), write research.md
     - **quimby**: Bash tool → `scripts/quimby.sh "$SESSION_DIR"`
     - **frink**: Bash tool → `scripts/frink.sh "$SESSION_DIR"`
     - **skinner**: Bash tool → `scripts/skinner.sh "$SESSION_DIR"`, then invoke frink again
     - **ralph**: Bash tool with run_in_background → `scripts/ralph.sh "$SESSION_DIR"`, poll for completion.md
     - **comic-book-guy**: Bash tool → `scripts/comic-book-guy.sh "$SESSION_DIR"`, handle verdict
   - Sleep 2 seconds between phases
   - Update TodoWrite with phase completion
6. **Handle errors**: Non-zero exit → mark failed, write to chat.md
7. **Kickback routing**: When Comic Book Guy kicks back, update state and re-run target phase
8. **Timeout protection**: If iteration >= 100, mark failed and EXIT

Let's get Springfield working!

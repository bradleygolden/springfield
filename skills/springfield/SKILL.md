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
- Generate comprehensive documentation (Martin Prince)
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
Invokes: `${CLAUDE_PLUGIN_ROOT}/scripts/lisa.sh SESSION_DIR`

Lisa thoroughly researches the codebase. She investigates:
- Existing implementations and patterns
- Related files and dependencies
- Technical constraints and requirements
- Project structure and conventions

**Output**: `research.md`

### Phase: Mayor Quimby (Decide Complexity)
Invokes: `${CLAUDE_PLUGIN_ROOT}/scripts/quimby.sh SESSION_DIR`

Mayor Quimby reviews Lisa's research and makes an executive decision: SIMPLE or COMPLEX?

**Output**: `decision.txt`

### Phase: Professor Frink (Plan)
Invokes: `${CLAUDE_PLUGIN_ROOT}/scripts/frink.sh SESSION_DIR`

Professor Frink creates the implementation plan using scientific methodology, glavin!
- SIMPLE tasks: Creates `prompt.md` directly, goes to Martin
- COMPLEX tasks: Creates `plan-v1.md`, sends to Skinner for review

**Output**: `plan-v1.md` (complex) or `prompt.md` (simple)

### Phase: Principal Skinner (Review) [Complex Tasks Only]
Invokes: `${CLAUDE_PLUGIN_ROOT}/scripts/skinner.sh SESSION_DIR`

Skinner reviews Frink's plan with his strict, by-the-book standards. Points out flaws and demands improvements.

After review, Frink is invoked again to incorporate feedback into final `prompt.md`.

**Output**: `review.md`

### Phase: Martin Prince (Documentation)
Invokes: `${CLAUDE_PLUGIN_ROOT}/scripts/martin.sh SESSION_DIR`

Martin creates prospective documentation BEFORE implementation! He's thorough and academic:
- Determines work item type (initiative, feature, task, or bug)
- Creates comprehensive PRDs for COMPLEX work
- Creates lightweight docs for SIMPLE work
- Maintains `/docs/planning/{type}/{work-item-id}/` structure
- Generates `state.yaml` with work item metadata
- Answers @martin questions in chat.md

**Inputs**: `research.md`, `decision.txt`, `prompt.md`, `task.txt`

**Outputs**: `/docs/planning/{type}/{id}/[prd.md|doc.md]`, `/docs/planning/{type}/{id}/state.yaml`

### Phase: Ralph (Implement)
Invokes: `${CLAUDE_PLUGIN_ROOT}/scripts/ralph.sh SESSION_DIR`

Ralph runs the implementation loop! He works iteratively, making small changes, committing progress. Monitors `completion.md` for completion signal.

**Output**: `scratchpad.md` (progress), `completion.md` (when done)

### Phase: Comic Book Guy (QA)
Invokes: `${CLAUDE_PLUGIN_ROOT}/scripts/comic-book-guy.sh SESSION_DIR`

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
lisa → quimby → frink → [skinner → frink] → martin → ralph → comic-book-guy
                         (complex only)                             ↓
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

## Meta-Ralph: Continuous Self-Improvement

*"I'm gonna loop forever!"*

Meta-Ralph is an alternative mode that runs Springfield in an infinite loop for continuous self-improvement. Based on the original Ralph pattern from [Geoff Huntley's blog](https://ghuntley.com/ralph/).

**When to use Meta-Ralph:**
- Continuous improvement of the codebase
- Working on open-ended optimization tasks
- Iterative refinement until manually stopped

**How it works:**
1. Takes a prompt string or file path
2. Runs the prompt through Springfield workflow
3. Repeats infinitely until stopped (Ctrl+C)
4. Each iteration builds on previous improvements

**Invocation:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/meta-ralph.sh "PROMPT"
# or
${CLAUDE_PLUGIN_ROOT}/scripts/meta-ralph.sh path/to/prompt-file.md
```

**Examples:**
- `meta-ralph.sh "Fix all bugs and improve documentation"`
- `meta-ralph.sh PROMPT.md`

**Note:** Meta-Ralph runs forever. User must manually stop it (Ctrl+C). Use for tasks that benefit from continuous iteration and eventual consistency.

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
   - Execute next phase (always pass SESSION_DIR as first argument):
     - **lisa**: Bash tool → `${CLAUDE_PLUGIN_ROOT}/scripts/lisa.sh SESSION_DIR`
     - **quimby**: Bash tool → `${CLAUDE_PLUGIN_ROOT}/scripts/quimby.sh SESSION_DIR`
     - **frink**: Bash tool → `${CLAUDE_PLUGIN_ROOT}/scripts/frink.sh SESSION_DIR`
     - **skinner**: Bash tool → `${CLAUDE_PLUGIN_ROOT}/scripts/skinner.sh SESSION_DIR`, then invoke frink again
     - **martin**: Bash tool → `${CLAUDE_PLUGIN_ROOT}/scripts/martin.sh SESSION_DIR`
     - **ralph**: Bash tool → `${CLAUDE_PLUGIN_ROOT}/scripts/ralph.sh SESSION_DIR` (runs in background)
     - **comic-book-guy**: Bash tool → `${CLAUDE_PLUGIN_ROOT}/scripts/comic-book-guy.sh SESSION_DIR`, handle verdict
   - Sleep 2 seconds between phases
   - Update TodoWrite with phase completion
6. **Handle errors**: Non-zero exit → mark failed, write to chat.md
7. **Kickback routing**: When Comic Book Guy kicks back, update state and re-run target phase
8. **Timeout protection**: If iteration >= 100, mark failed and EXIT

Let's get Springfield working!

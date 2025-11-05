---
description: Execute autonomous implementation loop (Ralph Wiggum - I'm learnding!)
allowed-tools: Bash, BashOutput, Read, Write, Skill
---

# Ralph - Implementation Loop

*"I'm learnding!"*

Execute the autonomous Ralph implementation loop for the session at $SESSION_DIR.

Ralph implements through persistent iteration - small, incremental steps that eventually reach completion through eventual consistency.

The implementation loop:
- Reads `$SESSION_DIR/prompt.md` for implementation guidance
- Iteratively implements small pieces of the plan
- Updates `$SESSION_DIR/scratchpad.md` with progress after each step
- Runs autonomously in the background
- Continues until `$SESSION_DIR/completion.md` is created

Monitor progress by checking:
- `$SESSION_DIR/scratchpad.md` - Recent progress updates
- `$SESSION_DIR/completion.md` - Completion signal

When completion.md is detected, report the final summary to the user.

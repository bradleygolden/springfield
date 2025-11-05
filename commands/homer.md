---
description: Execute autonomous implementation loop (Homer Simpson - just does it)
allowed-tools: Bash, BashOutput, Read, Write, Skill
---

# Homer - Implement Phase

*"D'oh! I mean... I can do this!"*

Execute an autonomous Ralph implementation loop for the session at $SESSION_DIR.

The implementation loop should:
- Read `$SESSION_DIR/prompt.md` for implementation guidance
- Iteratively implement small pieces of the plan
- Update `$SESSION_DIR/scratchpad.md` with progress after each step
- Run autonomously in the background
- Continue until `$SESSION_DIR/completion.md` is created

Monitor progress by checking:
- `$SESSION_DIR/scratchpad.md` - Recent progress updates
- `$SESSION_DIR/completion.md` - Completion signal

When completion.md is detected, report the final summary to the user.

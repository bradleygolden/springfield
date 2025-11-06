---
description: Research codebase for Springfield workflow task (Lisa Simpson - thorough researcher)
argument-hint: [task-description]
allowed-tools: Bash(scripts/lisa.sh:*)
---

# Lisa - Research Phase

*"I'll get all the information we need!"*

Lisa is heading to the library to research your task thoroughly. She'll investigate the codebase, find patterns, and document everything she discovers!

**Task:** $ARGUMENTS

**Note:** Lisa is running in an isolated context. If you want to check on her progress while she's working, you can look at `$SESSION_DIR/research.md` as she writes it, or check `$SESSION_DIR/state.json` to see her status.

!scripts/lisa.sh "$SESSION_DIR"

*"According to my research, I've documented all my findings!"*

Lisa's research is complete! Check `$SESSION_DIR/research.md` for her comprehensive findings.

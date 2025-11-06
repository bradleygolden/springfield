---
description: Research codebase for Springfield workflow task (Lisa Simpson - thorough researcher)
argument-hint: [task-description]
allowed-tools: Bash(scripts/lisa.sh:*)
---

# Lisa - Research Phase

*"I'll get all the information we need!"*

Lisa is heading to the library to research your task thoroughly. She'll investigate the codebase, find patterns, and document everything she discovers!

**Task:** $2

**Note:** Lisa is running in an isolated context. If you want to check on her progress while she's working, you can look at `$1/research.md` as she writes it, or check `$1/state.json` to see her status.

!scripts/lisa.sh "$1"

*"According to my research, I've documented all my findings!"*

Lisa's research is complete! Check `$1/research.md` for her comprehensive findings.

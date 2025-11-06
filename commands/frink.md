---
description: Create implementation prompt based on complexity (Professor Frink - scientific planner)
allowed-tools: Bash(scripts/frink.sh:*)
---

# Professor Frink - Planning Phase

*"With the calculating and the planning, glavin!"*

Professor Frink is in his laboratory, reviewing Lisa's research and Mayor Quimby's decision. He'll create a scientifically sound implementation plan using rigorous methodology!

**Inputs:**
- `$1/research.md` (Lisa's findings)
- `$1/decision.txt` (Quimby's complexity decision)

**Note:** Professor Frink is running in an isolated context. If you want to check on his progress while he's working, you can look at `$1/plan-v1.md` or `$1/prompt.md` as he writes them, or check `$1/state.json` to see his status.

!scripts/frink.sh "$1"

*"The plan is complete with the finalization and the ready-for-implementation, glavin!"*

Professor Frink's plan is ready! Check `$1/prompt.md` for the final implementation instructions.

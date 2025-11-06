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

**Note:** This command is informational only. The Springfield skill will handle execution of Frink's planning phase by calling the underlying script directly. You can check his progress:
- `$1/plan-v1.md` or `$1/prompt.md` - Frink's plans
- `$1/state.json` - Current status

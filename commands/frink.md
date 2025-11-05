---
description: Create implementation prompt based on complexity (Professor Frink - scientific planner)
allowed-tools: Read, Write, Bash, Skill
---

# Professor Frink - Plan Phase

*"With the calculating and the planning, glavin!"*

Read: `$SESSION_DIR/decision.txt` and `$SESSION_DIR/research.md`

**If SIMPLE:**
- Create concise `$SESSION_DIR/prompt.md` directly
- Include: goal, files to modify, patterns to follow, success criteria
- Keep focused and under 100 lines

**If COMPLEX:**
- Create `$SESSION_DIR/prompt_debate.md` with high-level goal (under 50 lines)
- Run a debate refinement loop to iteratively improve the plan
- The debate loop should spawn Proposer and Counter agents
- Continue until agents reach agreement
- Debate creates final `$SESSION_DIR/prompt.md`

Output: `$SESSION_DIR/prompt.md` ready for implementation.

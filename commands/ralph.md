---
description: Execute autonomous implementation loop (Ralph Wiggum - I'm learnding!)
allowed-tools: Bash(scripts/ralph.sh:*)
---

# Ralph - Implementation Loop

*"I'm learnding!"*

Ralph is ready to implement! He'll work through the plan step by step, making small incremental changes and committing his progress. He's very excited to help!

**Implementing:** `$SESSION_DIR/prompt.md`

**Note:** Ralph is running in an isolated context and will work autonomously for a while. You can check on his progress by looking at:
- `$SESSION_DIR/scratchpad.md` - Ralph's latest work (updated every iteration)
- `$SESSION_DIR/state.json` - Current status and iteration count
- `$SESSION_DIR/completion.md` - Will appear when Ralph is done!

!scripts/ralph.sh "$SESSION_DIR"

*"Me made everything! I'm helping!"*

Ralph completed his implementation! Check `$SESSION_DIR/completion.md` for the summary of what he accomplished.

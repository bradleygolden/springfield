---
description: Execute autonomous implementation loop (Ralph Wiggum - I'm learnding!)
allowed-tools: Bash(scripts/ralph.sh:*)
---

# Ralph - Implementation Loop

*"I'm learnding!"*

Ralph is ready to implement! He'll work through the plan step by step, making small incremental changes and committing his progress. He's very excited to help!

**Implementing:** `$1/prompt.md`

**Note:** Ralph is running in an isolated context and will work autonomously for a while. You can check on his progress by looking at:
- `$1/scratchpad.md` - Ralph's latest work (updated every iteration)
- `$1/state.json` - Current status and iteration count
- `$1/completion.md` - Will appear when Ralph is done!

!scripts/ralph.sh "$1"

*"Me made everything! I'm helping!"*

Ralph completed his implementation! Check `$1/completion.md` for the summary of what he accomplished.

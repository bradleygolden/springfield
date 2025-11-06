---
description: Review implementation plan for quality (Principal Skinner - strict reviewer)
allowed-tools: Bash(scripts/skinner.sh:*)
---

# Principal Skinner - Plan Review Phase

*"Pathetic work, Professor. Let me show you how it's done."*

Principal Skinner is reviewing Professor Frink's plan with his strict, by-the-book standards. He'll point out any flaws and demand improvements!

**Reviewing:** `$SESSION_DIR/plan-v1.md`

**Note:** Principal Skinner is running in an isolated context. If you want to check on his progress, look at `$SESSION_DIR/review.md` or `$SESSION_DIR/state.json` for his status.

!scripts/skinner.sh "$SESSION_DIR"

*"I've completed my review. It's... adequate. Barely."*

Principal Skinner's review is complete! Check `$SESSION_DIR/review.md` for his detailed feedback.

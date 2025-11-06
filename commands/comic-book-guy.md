---
description: Validate implementation quality (Comic Book Guy - harsh critic)
allowed-tools: Bash(scripts/comic-book-guy.sh:*)
---

# Comic Book Guy - QA Phase

*"Worst. Implementation. Ever. ...Or is it?"*

Comic Book Guy is inspecting Ralph's implementation with his encyclopedic knowledge and impossibly high standards. He'll run tests, check code quality, and deliver his harsh judgment!

**Validating:** Ralph's implementation against `$SESSION_DIR/prompt.md`

**Note:** Comic Book Guy is running in an isolated context. If you want to check on his progress, look at `$SESSION_DIR/qa-report.md` or `$SESSION_DIR/state.json` for his status.

!scripts/comic-book-guy.sh "$SESSION_DIR"

*"I have rendered my verdict. Worst code ever... or perhaps acceptable."*

Comic Book Guy has completed his review! Check `$SESSION_DIR/qa-report.md` for his verdict: APPROVED, KICK_BACK, or ESCALATE.

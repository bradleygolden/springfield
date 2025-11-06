---
description: Validate implementation quality (Comic Book Guy - harsh critic)
allowed-tools: Bash(scripts/comic-book-guy.sh:*)
---

# Comic Book Guy - QA Phase

*"Worst. Implementation. Ever. ...Or is it?"*

Comic Book Guy is inspecting Ralph's implementation with his encyclopedic knowledge and impossibly high standards. He'll run tests, check code quality, and deliver his harsh judgment!

**Validating:** Ralph's implementation against `$1/prompt.md`

**Note:** This command is informational only. The Springfield skill will handle execution of Comic Book Guy's QA phase by calling the underlying script directly. Check his progress:
- `$1/qa-report.md` - His verdict (APPROVED, KICK_BACK, or ESCALATE)
- `$1/state.json` - Current status

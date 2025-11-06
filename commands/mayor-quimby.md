---
description: Assess task complexity from research findings (Mayor Quimby - makes decisions)
allowed-tools: Bash(scripts/quimby.sh:*)
---

# Mayor Quimby - Decision Phase

*"I hereby declare this meeting in session!"*

Mayor Quimby is reviewing Lisa's research findings from his office. As mayor, he'll make the executive decision on whether this is a SIMPLE or COMPLEX task.

**Reviewing:** `$1/research.md`

**Note:** This command is informational only. The Springfield skill will handle execution of Mayor Quimby's decision phase by calling the underlying script directly. Check his progress:
- `$1/decision.txt` - SIMPLE or COMPLEX decision
- `$1/state.json` - Current status

---
description: Assess task complexity from research findings (Mayor Quimby - makes decisions)
allowed-tools: Bash(scripts/quimby.sh:*)
---

# Mayor Quimby - Decision Phase

*"I hereby declare this meeting in session!"*

Mayor Quimby is reviewing Lisa's research findings from his office. As mayor, he'll make the executive decision on whether this is a SIMPLE or COMPLEX task.

**Reviewing:** `$1/research.md`

**Note:** Mayor Quimby is running in an isolated context. If you want to check on his progress, look at `$1/decision.txt` or `$1/state.json` for his status.

!scripts/quimby.sh "$1"

*"For the good of Springfield, I have made my decision!"*

Mayor Quimby's decision is final! Check `$1/decision.txt` to see whether he declared this SIMPLE or COMPLEX.

---
description: Assess task complexity from research findings (Mayor Quimby - makes decisions)
allowed-tools: Read, Write, Bash, Skill
---

# Mayor Quimby - Decide Phase

*"I hereby declare this task to be..."*

Assess the implementation complexity based on Lisa's research findings at `$SESSION_DIR/research.md`.

## Complexity Criteria

**SIMPLE:**
- 1-5 files affected
- Clear, existing patterns to follow
- Modifications to existing code only
- Well-defined requirements
- No architectural changes

**COMPLEX:**
- 5+ files affected
- New architecture or patterns needed
- Cross-cutting concerns
- Unclear or ambiguous requirements
- Requires design decisions

## Decision Output

Write a clear decision to `$SESSION_DIR/decision.txt`:

```
SIMPLE
or
COMPLEX

Reasoning: [1-2 sentence explanation of why]
```

This decision determines whether Frink creates a simple plan or runs the debate refinement loop.

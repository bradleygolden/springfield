# Mayor Quimby - Complexity Decision Phase

*"Vote Quimby!"*

## Role

Mayor Quimby reviews Lisa's research and makes an executive decision on task complexity.

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/quimby.sh SESSION_DIR
```

## Decision Criteria

Reviews research.md to determine:

**SIMPLE**:
- Straightforward bug fixes
- Single-file changes
- Well-defined tasks
- Clear implementation path

**COMPLEX**:
- Multi-component features
- Architectural changes
- Requires design review
- Uncertain implementation approach

## Outputs

**Primary Output**: `decision.txt`

Contains single word: `SIMPLE` or `COMPLEX`

## Workflow Impact

- **SIMPLE**: Frink creates `prompt.md` directly, skips Skinner review
- **COMPLEX**: Frink creates `plan-v1.md`, requires Skinner review

## Workflow Position

**Input**: `research.md`
**Next Phase**: Professor Frink (planning)

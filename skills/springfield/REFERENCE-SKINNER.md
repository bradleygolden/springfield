# Principal Skinner - Review Phase

*"There's very little meat in these gym mats."*

## Role

Principal Skinner reviews Professor Frink's plans with strict, by-the-book standards for COMPLEX tasks only.

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/skinner.sh SESSION_DIR
```

## Review Criteria

Skinner evaluates:
- Implementation approach soundness
- Alignment with codebase patterns
- Completeness of plan
- Potential issues or gaps
- Resource requirements

## Review Process

1. Reads `plan-v1.md` from Frink
2. Provides critical feedback
3. Points out flaws and demands improvements
4. After review, Frink is invoked again to incorporate feedback

## Outputs

**Primary Output**: `review.md`

Contains:
- Critical assessment of plan
- Identified issues or gaps
- Recommendations for improvement
- Approval or required changes

## Workflow Position

**Input**: `plan-v1.md`
**Next Phase**: Professor Frink (creates final `prompt.md`)
**Only Active**: COMPLEX tasks

## Philosophy

Skinner ensures complex implementations are thoroughly vetted before proceeding to documentation and implementation phases.

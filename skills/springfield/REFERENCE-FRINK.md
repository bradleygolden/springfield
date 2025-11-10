# Professor Frink - Planning Phase

*"With the glavin and the hey-hey!"*

## Role

Professor Frink creates implementation plans using scientific methodology.

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/frink.sh SESSION_DIR
```

## Planning Behavior

### SIMPLE Tasks
- Creates `prompt.md` directly
- Proceeds to Martin without review
- Concise implementation guidance

### COMPLEX Tasks
- Creates `plan-v1.md` for Skinner review
- After Skinner's feedback, creates final `prompt.md`
- Comprehensive implementation strategy

## Outputs

**Simple Path**: `prompt.md` (direct)
**Complex Path**: `plan-v1.md` → (Skinner review) → `prompt.md` (final)

## Workflow Position

**Inputs**: `research.md`, `decision.txt`, `task.txt`
**Next Phase**:
- SIMPLE: Martin (documentation)
- COMPLEX: Skinner (review), then invoked again for final prompt

## Kickback Handling

If Comic Book Guy kicks back to Frink:
- Re-evaluates implementation approach
- Updates prompt.md with better strategy
- Considers alternative technical solutions

# Ralph Wiggum - Implementation Phase

*"I'm learnding!"*

## Role

Ralph runs the implementation loop, working iteratively to complete the task.

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/ralph.sh SESSION_DIR
```

## Implementation Approach

Ralph works iteratively:
- Makes small, incremental changes
- Commits progress regularly
- Follows Martin's documentation as guidance
- Uses Martin's acceptance criteria as checklist

## Monitoring

Monitors `completion.md` for completion signal indicating implementation is done.

## Outputs

**During Implementation**: `scratchpad.md`
- Tracks progress
- Notes decisions
- Documents blockers

**When Complete**: `completion.md`
- Signals implementation finished
- Summarizes what was done
- Notes any issues or deviations

## Timeout Protection

Maximum runtime: 60 minutes

If Ralph runs longer than 60 minutes, workflow marks as blocked and escalates.

## Workflow Position

**Inputs**: Martin's documentation (`prd.md` or `doc.md`), `prompt.md`
**Next Phase**: Comic Book Guy (QA validation)

## Kickback Handling

If Comic Book Guy kicks back to Ralph:
- Reviews QA findings
- Makes necessary corrections
- Re-tests implementation
- Updates completion.md with fixes

## Philosophy

Ralph embodies eventual consistency - iterative refinement until the implementation meets requirements. See [REFERENCE.md](REFERENCE.md) for the Ralph pattern philosophy.

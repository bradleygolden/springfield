# Comic Book Guy - QA Phase

*"Worst. Code. Ever."*

## Role

Comic Book Guy validates the implementation against Martin's acceptance criteria and project standards.

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/comic-book-guy.sh SESSION_DIR
```

## Validation Process

Reviews:
- Code quality and standards
- Completeness vs. Martin's acceptance criteria
- Test coverage and passing tests
- Documentation accuracy
- Edge cases and error handling

## Verdicts

Comic Book Guy returns one of three verdicts:

### APPROVED ✓
Task complete! Implementation meets all requirements.

**Result**: Workflow status → "complete", success reported

### KICK_BACK
Issues found, route back to specific phase for fixes.

**Kickback Targets**:
- `lisa` - Research was incomplete or incorrect
- `frink` - Plan was flawed or insufficient
- `ralph` - Implementation has bugs or missing features

**Limits**: Max 2 kickbacks per target to prevent infinite loops

**Result**: Workflow routes back to specified phase

### ESCALATE
Too many kickbacks or needs user input.

**Triggers**:
- Exceeded max kickbacks (2 per target)
- Blocker requiring user decision
- Fundamental issues requiring human intervention

**Result**: Workflow status → "blocked", escalate to user with details

## Outputs

**Primary Output**: `qa-report.md`

Contains:
- Validation results
- Issues found (if any)
- Verdict (APPROVED/KICK_BACK/ESCALATE)
- Kickback target (if KICK_BACK)
- Rationale for decision

## Workflow Position

**Inputs**: Ralph's implementation, Martin's acceptance criteria, all session artifacts
**Next Phase**:
- APPROVED: Workflow complete
- KICK_BACK: Route to lisa/frink/ralph
- ESCALATE: Block and notify user

## Philosophy

Comic Book Guy ensures quality through harsh but fair validation. Prevents incomplete or buggy implementations from being marked complete.

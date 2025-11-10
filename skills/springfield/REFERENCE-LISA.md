# Lisa Simpson - Research Phase

*"If anyone wants me, I'll be in my room."* - Lisa heading to the library

## Role

Lisa thoroughly researches the codebase to understand the task context and identify relevant implementation patterns.

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/lisa.sh SESSION_DIR
```

## Research Areas

Lisa investigates:
- Existing implementations and patterns
- Related files and dependencies
- Technical constraints and requirements
- Project structure and conventions

## Outputs

**Primary Output**: `research.md`

Contains comprehensive findings from codebase investigation including:
- Relevant existing code
- Dependencies and relationships
- Technical requirements
- Implementation patterns to follow

## Workflow Position

**Input**: `task.txt`
**Next Phase**: Mayor Quimby (complexity decision)

## Kickback Handling

If Comic Book Guy kicks back to Lisa, she:
- Re-investigates based on QA findings
- Updates research.md with additional context
- Provides more detailed technical information

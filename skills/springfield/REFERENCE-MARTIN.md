# Martin Prince - Documentation Phase

*"I'm going to put this on my résumé!"*

## Role

Martin creates prospective documentation BEFORE Ralph implements. He's the perfectionist student who plans everything in advance.

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/martin.sh SESSION_DIR
```

## Purpose

Martin produces planning documents that:
- Guide Ralph's implementation
- Serve as acceptance criteria for Comic Book Guy's validation
- Provide clear requirements and specifications

Every task flows through Martin - both COMPLEX and SIMPLE.

## Work Item Type Determination

Martin analyzes the task and categorizes it into one of four types:

- **initiatives**: Large, multi-feature efforts (e.g., "add authentication system")
- **features**: New functionality or capabilities (e.g., "add dark mode toggle")
- **tasks**: Improvements, refactoring, or maintenance (e.g., "update documentation")
- **bugs**: Defects and fixes (e.g., "fix login error")

## Documentation Paths

### COMPLEX Path (initiatives/features after Skinner review)

Creates comprehensive Product Requirements Document (PRD):
- **Overview**: High-level description and context
- **Requirements**: Detailed functional requirements
- **Acceptance Criteria**: Testable conditions for completion
- **Implementation Notes**: Technical guidance and constraints

**Location**: `/docs/planning/{type}/{work-item-id}/prd.md`

Detailed enough for Ralph to follow step-by-step and serves as validation checklist for Comic Book Guy.

### SIMPLE Path (tasks/bugs without Skinner review)

Creates lightweight documentation:
- **Task description**: Clear overview of what needs to be done
- **Key points**: Important considerations
- **Basic guidance**: Implementation hints

**Location**: `/docs/planning/{type}/{work-item-id}/doc.md`

Concise but still provides Ralph clear direction.

## Output Structure

For all tasks, Martin creates:

**Planning Directory**: `/docs/planning/{type}/{work-item-id}/`

**Documentation File**:
- `prd.md` (COMPLEX tasks)
- `doc.md` (SIMPLE tasks)

**Metadata File**: `state.yaml`
- Work item ID
- Work item type (initiatives/features/tasks/bugs)
- Status information

All created BEFORE Ralph begins implementation.

## Connection to Ralph

Ralph reads Martin's documentation during implementation:
- Martin's requirements become Ralph's checklist
- Martin's acceptance criteria become Comic Book Guy's validation rules
- Provides clear success criteria

## Inputs

- `research.md` (from Lisa)
- `decision.txt` (from Mayor Quimby)
- `prompt.md` (from Professor Frink)
- `task.txt` (original task description)

## Outputs

- `/docs/planning/{type}/{id}/[prd.md|doc.md]`
- `/docs/planning/{type}/{id}/state.yaml`

## Workflow Position

**Previous Phase**: Professor Frink (after Skinner review for COMPLEX)
**Next Phase**: Ralph (implementation)

---
description: Research codebase for Springfield workflow task (Lisa Simpson - thorough researcher)
argument-hint: [task-description]
allowed-tools: Read, Grep, Glob, Task, Bash, Write, Skill
---

# Lisa - Research Phase

*"I'm conducting a thorough investigation!"*

Thoroughly research the codebase to understand: $ARGUMENTS

## Research Objectives

Investigate and document:
1. **Files Affected** - Which files will need modifications or additions
2. **Existing Patterns** - Similar implementations and conventions to follow
3. **Architecture Context** - How this fits into the existing system
4. **Dependencies** - Related modules, libraries, or external systems
5. **Complexity Estimate** - Initial assessment of task complexity

## Execution Strategy

Spawn parallel Task agents with "thorough" exploration level to:
- Search for related implementations
- Identify architectural patterns
- Locate test files and testing patterns
- Find configuration files if relevant

## Output Format

Write comprehensive findings to `$SESSION_DIR/research.md`:

```markdown
## Files Affected
- path/to/file.ext:line (brief reason)

## Patterns Found
- Pattern description at path:line

## Architecture Context
- How this integrates with existing systems

## Dependencies
- External or internal dependencies

## Complexity Estimate
SIMPLE - 1-5 files, clear pattern, modifications only
OR
COMPLEX - 5+ files, new architecture, cross-cutting changes

Reason: [brief explanation]
```

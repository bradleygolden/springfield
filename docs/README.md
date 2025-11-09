# Springfield Documentation Structure

This directory contains the documentation created by Springfield's autonomous workflow.

## Directory Structure

Springfield organizes documentation into two complementary systems:

### 📝 Planning Documentation (Prospective)
**Created by**: Martin Prince
**When**: Before implementation
**Location**: `/docs/planning/{type}/{work-item-id}/`

Martin creates documentation to guide implementation:

```
/docs/planning/
├── initiatives/       # High-level, architectural work (COMPLEX)
├── features/          # Product features (COMPLEX)
├── tasks/             # Smaller engineering tasks (SIMPLE)
└── bugs/              # Bug fixes (SIMPLE or COMPLEX)
```

Each work item directory contains:
- `prd.md` or `doc.md` - Main documentation (PRD format for COMPLEX, lightweight for SIMPLE)
- `state.yaml` - Quick-reference metadata for agents

### 📚 Retrospective Documentation
**Created by**: Apu (future character)
**When**: After implementation
**Location**: `/docs/retrospectives/{session}/`

Apu will document what was actually done:

```
/docs/retrospectives/
└── {session-id}/
    ├── summary.md
    └── decisions.md
```

## Work Item Types

### Initiatives
**Complexity**: COMPLEX
**Scope**: High-level, long-horizon architectural work
**Examples**: "Refactor authentication system", "Platform migration to Kubernetes"
**Documentation**: Full PRD with architecture, design, timeline

### Features
**Complexity**: COMPLEX
**Scope**: Product features requiring design and planning
**Examples**: "Add dark mode toggle", "Implement user notifications"
**Documentation**: Full PRD with problem statement, design, implementation plan

### Tasks
**Complexity**: SIMPLE (or COMPLEX without feature/initiative keywords)
**Scope**: Smaller engineering tasks
**Examples**: "Update README installation instructions", "Add logging to API endpoint"
**Documentation**: Lightweight format with description, acceptance criteria

### Bugs
**Complexity**: SIMPLE or COMPLEX
**Scope**: Bug fixes
**Examples**: "Fix authentication error on login", "Resolve memory leak in WebSocket handler"
**Documentation**: Bug-specific format with reproduction steps, root cause, proposed fix

## Work Item Metadata (state.yaml)

Each work item includes `state.yaml` for quick agent access:

```yaml
type: initiative|feature|task|bug
id: work-item-id
status: planning|implementing|testing|complete
phase: design|ready|in_progress|qa|done
complexity: SIMPLE|COMPLEX
created: YYYY-MM-DD
updated: YYYY-MM-DD
session:
  id: session-id
  path: .springfield/{session-id}/
documentation:
  primary: prd.md|doc.md
  session_research: .springfield/{session}/research.md
  session_plan: .springfield/{session}/prompt.md
workflow:
  created_by: martin
  implements_by: ralph
  validated_by: comic-book-guy
ready_for_implementation: true
blocking_issues: []
```

## Navigation

### For Developers
- **Planning a new feature?** → Check `/docs/planning/features/`
- **Looking for architectural decisions?** → Check `/docs/planning/initiatives/`
- **Need bug fix history?** → Check `/docs/planning/bugs/`
- **Want to see what was implemented?** → Check `/docs/retrospectives/` (when Apu is added)

### For Agents
- **Martin**: Reads session files, writes to `/docs/planning/{type}/{id}/`
- **Ralph**: Reads `/docs/planning/{type}/{id}/prd.md` and `state.yaml` for implementation guidance
- **Comic Book Guy**: References documentation during QA validation
- **Apu** (future): Reads session completion, writes to `/docs/retrospectives/{session}/`

## Springfield Workflow

```
Lisa → Quimby → Frink → [Skinner] → Martin → Ralph → Comic Book Guy
                         (COMPLEX)     ↓                    ↓
                                   planning/           retrospectives/
                                      docs              (future: Apu)
```

## Philosophy

Springfield maintains dual documentation:

1. **Prospective** (Martin): Documents the plan before work begins
2. **Retrospective** (Apu): Documents what actually happened after work completes

This approach ensures:
- Clear implementation guidance for Ralph
- Accurate historical record of decisions
- Traceability between plan and execution
- Knowledge base for future work

---

**Character Credits**:
- 📚 **Martin Prince**: Prospective documentation creation
- 🏪 **Apu Nahasapeemapetilon** (future): Retrospective documentation

*"I've earned an A+ on this documentation structure!"* - Martin Prince

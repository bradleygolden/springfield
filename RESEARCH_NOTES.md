# Research Notes: Applying Denario/CMBAgent Techniques to Springfield

**Date:** 2025-11-05
**Primary Paper:** The Denario project: Deep knowledge AI agents for scientific discovery (arXiv:2510.26887)
**Lead Author:** Francisco Villaescusa-Navarro (with 35 co-authors)
**Related Paper:** CMBAgent - Open Source Planning & Control System (arXiv:2507.07257)

## Paper Overview

**Denario** is a multi-agent AI system designed to serve as a scientific research assistant. The system can perform end-to-end scientific research including:
- Generating research ideas
- Conducting literature reviews
- Developing research plans
- Writing and executing code
- Creating visualizations
- Drafting scientific manuscripts
- Performing peer review

**Key Achievement:** Successfully demonstrated across multiple scientific disciplines (astrophysics, biology, chemistry, medicine, neuroscience, etc.) with domain expert evaluation.

**Paper Size:** 272 pages with 11 example AI-generated research papers

## Architectural Components

### 1. Modular Multi-Agent Design

Denario uses a modular architecture where different modules (yellow shapes in their diagrams) exchange messages among them. Each module is composed of multiple agents (bots) that communicate with each other.

**Core Modules:**
- **Idea Module**: Generates research concepts from data specifications
- **Literature Module**: Searches existing research, ensures novelty
- **Methods Module**: Develops experimental methodologies
- **Analysis Module**: Executes computations using CMBAgent backend
- **Results Module**: Produces visualizations and findings
- **Paper Module**: Synthesizes findings into formatted publications

**Key Insight:** Modules can be used independently or in sequence. Users can inject custom content at any stage using `set_idea()`, `set_method()`, or `set_results()`, enabling hybrid human-AI workflows.

### 2. CMBAgent: Planning & Control Strategy

CMBAgent serves as Denario's "deep research backend" and implements a sophisticated Planning & Control strategy.

**Architecture:**
- ~30 specialized LLM agents
- No human-in-the-loop during execution
- Agent specializations include:
  - Retrieval on scientific papers and codebases
  - Writing code
  - Interpreting results
  - Critiquing output of other agents
  - Code execution

**Two-Phase Strategy:**

#### Phase 1: Planning
1. **plan_setter agent**: Selects which agents should be involved in the session and stores detailed instructions in context
2. **planner agent**: Proposes initial task decomposition plans
3. **plan_reviewer agent**: Critiques plans and suggests improvements
4. **Iterative conversation**: Planner and reviewer engage in dialogue (controlled by `n_reviews` hyperparameter, typically set to 1)

**Plan Structure:**
- Each subtask contains three fields:
  - Specific task description
  - Assigned agent name
  - Bullet-point action details
- Plans constrained to max steps (controlled by `n_steps` hyperparameter, typically 3-8)
- Larger plans increase costs and context bloat

**Critical Finding:** More review rounds don't help. Recommendations become "increasingly overly complex and ineffective" with additional iterations. One review cycle is optimal.

#### Phase 2: Control
1. **control agent**: Orchestrates execution, monitoring completion status
2. **Step-by-step execution**: Subtasks handed to single agents sequentially
3. **Status tracking**: Agents call `record_status` function to mark subtasks as complete, failed, or in-progress
4. **Error handling**: Code execution failures trigger installer agent for missing dependencies
5. **Failure threshold**: If failures exceed `n_fails` threshold, system terminates rather than retry infinitely
6. **Hard limit**: Message count tracked with `n_rounds` limit (default 500) to prevent infinite loops

### 3. Agent Communication Patterns

**Context Sharing:**
- Agents exchange messages asynchronously through function calls
- Shared context variable dictionary persists information
- Downstream agents access upstream outputs without direct message passing
- This allows flexible, non-linear communication patterns

**Persistence:**
- Each module generates markdown files (idea.md, methods.md, results.md)
- Files persist in project directory structure
- Enables intervention at any stage
- Supports branching workflows rather than strictly linear pipelines

### 4. Quality Control Mechanisms

**Self-Reflection:**
- Agents review their own output before passing to successors
- Checkpoints allow human intervention
- Paper module has four sequential versions representing review points

**Multi-Modal Validation:**
- LLMs validate outputs (e.g., figure captions) against context
- Visual outputs checked for consistency with data

**Domain Expert Oversight:**
- Literature module intentionally doesn't auto-gate subsequent work
- Allows domain experts final judgment on novelty and quality
- Human oversight remains critical despite automation

## Key Techniques Applicable to Springfield

### 1. Two-Agent Planning Conversation (Planner + Reviewer)

**Current Springfield:** Professor Frink runs a debate loop with proposer vs counter perspectives for complex tasks.

**Denario Approach:** Two specialized agents (planner + plan_reviewer) with constrained iteration (n_reviews=1).

**Key Insight:** More debate rounds don't improve quality - they make plans "overly complex and ineffective."

**Recommendation for Springfield:**
- Keep Frink's debate loop but limit rounds (similar to n_reviews=1)
- Consider explicit planner/reviewer roles instead of proposer/counter
- Focus on practical vs theoretical solutions
- Add hyperparameter to control debate rounds

### 2. Plan Structure with Subtasks

**Denario Plans Include:**
- Specific task description
- Assigned agent (character) name
- Bullet-point actions

**Springfield Application:**
- Professor Frink's `prompt.md` could use this structure
- Break down implementation into subtasks
- Assign each subtask to Ralph iterations
- Ralph tracks which subtask he's currently working on

### 3. Status Tracking with record_status

**Denario:** Agents explicitly call `record_status` to mark progress.

**Springfield Application:**
- Add status tracking to Ralph's scratchpad.md
- Explicitly mark subtasks as: pending, in_progress, complete, failed
- Control agent (could be Ralph himself) monitors progress
- Enables better restart/recovery from failures

### 4. Failure Thresholds (n_fails)

**Denario:** Terminates after n_fails to avoid infinite retry loops.

**Springfield Application:**
- Currently Ralph iterates until completion or max iterations
- Add explicit failure threshold
- If same subtask fails n_fails times, escalate or abort
- Prevents wasteful iteration on unfixable problems

### 5. Message Count Limits (n_rounds)

**Denario:** Hard limit of 500 rounds prevents infinite loops.

**Springfield Application:**
- Add explicit message/iteration counter
- Set reasonable hard limits per phase
- Provides safety net against runaway processes

### 6. Modular Architecture with Injection Points

**Denario:** Users can inject custom content at any module stage.

**Springfield Application:**
- Allow users to provide pre-written research (skip Lisa)
- Allow users to force SIMPLE or COMPLEX decision (skip Mayor Quimby)
- Allow users to provide implementation plan (skip Frink)
- Enable hybrid human-AI workflows

### 7. Persistent Markdown Files

**Both systems already do this!** Springfield creates:
- research.md (Lisa)
- decision.txt (Mayor Quimby)
- prompt.md (Frink)
- scratchpad.md (Ralph)
- completion.md (Ralph)
- qa-report.md (Comic Book Guy)

**Enhancement:** Structure these files more consistently following Denario's patterns.

### 8. Self-Reflection Checkpoints

**Denario:** Agents review own output before passing to next stage.

**Springfield Application:**
- Lisa could self-review research before passing to Mayor Quimby
- Frink could self-review plan before passing to Ralph
- Ralph could self-review implementation before declaring completion
- Add explicit "self-review" step to each phase

### 9. Specialized Agent Roles

**Denario has ~30 agents including:**
- Retrieval agents (search papers/codebases)
- Code writing agents
- Interpretation agents
- Critique agents
- Installer agents (handle dependencies)

**Springfield Application:**
- Currently has 5 characters (Lisa, Mayor Quimby, Frink, Ralph, Comic Book Guy)
- Could add more specialized characters:
  - Installer agent for dependencies (Professor Frink's assistant?)
  - Retrieval agent for documentation (Database Comic Book Guy?)
  - Test writing agent (Martin Prince?)
  - Consider keeping character count manageable vs Denario's 30

### 10. No Human-in-the-Loop Execution

**Denario:** Fully autonomous execution once started.

**Springfield:** Currently autonomous with `--dangerously-skip-permissions`.

**Both share philosophy:** Eventual consistency through autonomous iteration.

## Implementation Recommendations for Springfield

### Priority 1: Enhance Planning Structure (Frink)

**Current:** Frink creates prompt.md with debate loop for complex tasks.

**Enhancement:**
```markdown
# Implementation Plan

## Subtasks
1. [PENDING] Setup authentication middleware
   - Assigned: Ralph
   - Actions:
     * Install passport.js
     * Create auth config
     * Add middleware to app.js

2. [PENDING] Create login endpoint
   - Assigned: Ralph
   - Actions:
     * Define POST /login route
     * Implement credential validation
     * Return JWT token

3. [PENDING] Add protected routes
   - Assigned: Ralph
   - Actions:
     * Create auth middleware
     * Apply to protected endpoints
     * Test access control
```

**Benefits:**
- Clear subtask boundaries
- Explicit status tracking
- Better progress visibility
- Easier restart/recovery

### Priority 2: Add Status Tracking (Ralph)

**Current:** Ralph updates scratchpad.md with progress notes.

**Enhancement:**
Add explicit status tracking to scratchpad:

```markdown
# Ralph's Scratchpad

## Current Status
- Subtask: 2/3
- Iteration: 4
- Status: IN_PROGRESS

## Subtask Status
1. [COMPLETE] Setup authentication middleware (iterations: 3)
2. [IN_PROGRESS] Create login endpoint (iterations: 4, failures: 1)
3. [PENDING] Add protected routes

## Failure Log
- Iteration 3: Missing passport dependency → installed
- Iteration 4: JWT secret undefined → fixed

## Next Actions
- Test login endpoint
- Verify token generation
```

**Benefits:**
- Clear progress tracking
- Failure pattern identification
- Easier debugging
- Better restart capability

### Priority 3: Implement Failure Thresholds

**Add hyperparameters:**
- `n_fails`: Max failures per subtask (default: 3)
- `n_rounds`: Max total iterations (default: 500)
- `n_reviews`: Max debate rounds for Frink (default: 1)
- `n_steps`: Max subtasks in plan (default: 8)

**Benefits:**
- Prevents infinite loops
- Saves costs on unfixable problems
- Forces escalation or human intervention

### Priority 4: Add Self-Reflection Checkpoints

**Add reflection step to each phase:**
- Lisa reviews research quality before passing to Mayor Quimby
- Frink reviews plan feasibility before passing to Ralph
- Ralph reviews implementation before marking complete
- Comic Book Guy reviews with explicit criteria

**Implementation:**
Add `review()` function to each character that asks:
- "Did I complete my objective?"
- "Is the quality sufficient?"
- "What could be improved?"
- "Should I iterate or pass forward?"

### Priority 5: Enable Injection Points

**Allow users to skip phases:**
```bash
# Skip research, provide own
/springfield:frink --research-file=my-research.md

# Skip planning, provide own plan
/springfield:ralph --plan-file=my-plan.md

# Force complexity decision
/springfield:mayor-quimby --force=COMPLEX
```

**Benefits:**
- Hybrid human-AI workflows
- Faster iteration when you know what you want
- Cost savings by skipping unnecessary phases

### Priority 6: Improve Communication Patterns

**Current:** Linear pipeline (Lisa → Quimby → Frink → Ralph → Comic Book Guy)

**Enhancement:** Allow feedback loops
- Comic Book Guy can kick back to specific phase:
  - Research gap → back to Lisa
  - Design flaw → back to Frink
  - Implementation bug → back to Ralph

**Already in diagram!** The workflow diagram shows this, just ensure implementation supports it.

## Technical Implementation Details

### Framework Choices

**Denario uses:**
- AG2 for agent orchestration
- LangGraph for workflow graphs
- Python 3.12+

**Springfield uses:**
- Bash scripts for orchestration
- Claude Code CLI for agent execution
- Markdown files for persistence

**Considerations:**
- Springfield's bash approach is simpler and more transparent
- Could benefit from structured state management (like LangGraph)
- Consider whether to stay bash-native or adopt framework
- Trade-off: simplicity vs sophistication

### Context Management

**Denario:** Shared context dictionary with function calls

**Springfield:** Markdown files in session directory

**Hybrid Approach:**
- Keep markdown files for human readability
- Add structured JSON metadata for agent coordination
- Example: `session-state.json` with status tracking

### Cost Tracking

**Denario:** 272-page paper doesn't explicitly mention cost tracking

**Springfield:** Should add (see earlier notes on "AI Agents That Matter")

**Recommendation:** Track costs across phases to understand efficiency

## Open Questions for Discussion

1. **Planning Structure:**
   - Should we adopt Denario's explicit subtask structure in Frink's plans?
   - How granular should subtasks be for coding tasks?

2. **Failure Handling:**
   - What should n_fails default be for coding tasks?
   - Should different subtask types have different thresholds?
   - When to escalate vs abort?

3. **Agent Count:**
   - Denario has ~30 agents, Springfield has 5 characters
   - Should we add more specialized characters?
   - Or keep it simple with fewer, more versatile agents?

4. **Framework vs Scripts:**
   - Should Springfield adopt AG2/LangGraph or similar?
   - Or keep bash-based approach for transparency?
   - Trade-offs: complexity vs capabilities

5. **Review Iterations:**
   - Denario found n_reviews=1 optimal (more makes plans worse)
   - Should we limit Frink's debate loop to 1 round?
   - Or test empirically with Springfield's coding tasks?

6. **Human-in-the-Loop:**
   - Denario is fully autonomous, but allows injection points
   - Should Springfield add interactive checkpoints?
   - Or maintain full autonomy with override options?

7. **Self-Reflection:**
   - How to implement effective self-reflection without adding too much overhead?
   - Should reflection be mandatory or optional per phase?
   - What criteria should agents use to evaluate their own work?

## References

- **Primary Paper:** https://arxiv.org/abs/2510.26887 (The Denario Project)
- **HTML Version:** https://arxiv.org/html/2510.26887
- **CMBAgent Paper:** https://arxiv.org/abs/2507.07257
- **Denario GitHub:** https://github.com/AstroPilot-AI/Denario
- **CMBAgent GitHub:** https://github.com/CMBAgents/cmbagent
- **Springfield Ralph Pattern:** https://ghuntley.com/ralph/

## Next Steps

1. Review and discuss these recommendations
2. Prioritize which techniques to implement first
3. Design implementation approach for chosen techniques
4. Test on sample tasks
5. Iterate based on findings
6. Consider submitting findings back to Denario project (open source collaboration)

## Additional Note: "AI Agents That Matter" (arXiv:2407.01502)

While not the intended reference, this paper also offers valuable insights about:
- Cost-accuracy tradeoffs
- Simple baselines vs complex agents
- Proper evaluation practices
- Preventing overfitting

Consider reviewing this paper separately for complementary techniques focused on cost optimization and evaluation.

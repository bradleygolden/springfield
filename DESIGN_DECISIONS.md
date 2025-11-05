# Design Decisions: Springfield Architecture

**Date:** 2025-11-05
**Implementation Status:** ✅ IMPLEMENTED (All 10 decisions complete)

---

## Decision 1: Add Principal Skinner as Plan Reviewer
**Status:** ✅ IMPLEMENTED

### Current State
- **Professor Frink** creates plans for SIMPLE and COMPLEX tasks
- COMPLEX tasks use debate loop (proposer vs counter)

### Change
**Add Principal Skinner as dedicated plan reviewer**

### Why
- Denario research shows planner/reviewer separation works better
- One review cycle (n_reviews=1) is optimal
- More debate rounds make plans "overly complex and ineffective"

### New Workflow
**SIMPLE tasks:**
- Frink creates plan → Ralph implements

**COMPLEX tasks:**
- Frink creates initial plan → Skinner reviews → Frink revises → Ralph implements
- Limit: 1 review cycle

### Character Fit
- Skinner is detail-oriented, critical, procedural
- Natural reviewer personality
- "Pathetic" when standards aren't met

### Files Changed
- `plan-v1.md` - Frink's initial plan (new)
- `review.md` - Skinner's feedback (new)
- `prompt.md` - Final plan after Skinner's review

### Implementation
- Priority 1
- Create `/springfield:skinner` command
- Update Frink workflow for COMPLEX tasks
- Add `n_reviews` hyperparameter (default: 1)

---

## Decision 2: Modular Architecture with Injection Points
**Status:** ✅ IMPLEMENTED

### Current State
- Springfield runs linearly: Lisa → Quimby → Frink → Ralph → Comic Book Guy
- All phases must execute in sequence

### Change
**Enable users to skip phases by providing their own files**

### Why
- Denario allows injection at any module stage
- Enables hybrid human-AI workflows
- Saves cost/time when user already knows what they want
- Supports iterative development (reuse research, modify plan, etc.)

### Examples
```bash
# Skip research, provide your own
/springfield:frink --research-file=my-research.md

# Skip planning, provide your own plan
/springfield:ralph --plan-file=my-plan.md

# Force complexity decision
/springfield:mayor-quimby --force=COMPLEX

# Start from specific phase with existing session
/springfield:ralph --session=session-20251105-123456
```

### Benefits
- Faster iteration on specific phases
- Lower costs (skip unnecessary work)
- Human expertise where valuable
- AI automation where needed

### Implementation
- Priority 2 (high value, moderate effort)
- Add `--research-file`, `--plan-file` flags to commands
- Add `--session` flag to resume from existing session
- Add `--force` flag to Mayor Quimby
- Validate file formats match expected structure

---

## Decision 3: Structure Files Following Denario Patterns
**Status:** ✅ IMPLEMENTED

### Current State
- Files exist but structure varies: `research.md`, `decision.txt`, `prompt.md`, `scratchpad.md`, etc.
- No consistent format across files
- Informal content structure

### Change
**Adopt consistent file structure based on Denario patterns**

### Why
- Denario uses structured markdown with clear sections
- Easier for agents to parse and use
- Better for human readability
- Enables programmatic processing

### File Structure Patterns

**research.md (Lisa):**
```markdown
# Research Findings

## Task Understanding
[What was researched]

## Key Findings
[Bullet points of discoveries]

## Relevant Code/Patterns
[References with file:line format]

## Recommendations
[Suggestions for implementation]
```

**prompt.md (Frink's Plan):**
```markdown
# Implementation Plan

## Overview
[Brief description of approach]

## Subtasks
1. [STATUS] Subtask name
   - Assigned: Ralph
   - Actions:
     * Specific action 1
     * Specific action 2

2. [STATUS] Subtask name
   - Assigned: Ralph
   - Actions:
     * Specific action 1
```

**scratchpad.md (Ralph):**
```markdown
# Ralph's Scratchpad

## Current Status
- Subtask: X/Y
- Iteration: N
- Status: IN_PROGRESS

## Subtask Status
1. [COMPLETE] Subtask 1 (iterations: 3)
2. [IN_PROGRESS] Subtask 2 (iterations: 2, failures: 1)
3. [PENDING] Subtask 3

## Latest Work
[What Ralph just did]

## Next Actions
[What Ralph will do next]
```

### Benefits
- Consistent structure across sessions
- Easier agent coordination
- Better progress tracking
- Clearer handoffs between phases

### Implementation
- Priority 3 (foundation for other improvements)
- Update each character's file generation
- Add markdown templates
- Validate format in each phase

---

## Decision 4: Self-Reflection Checkpoints
**Status:** ✅ IMPLEMENTED

### Current State
- Characters complete their work and immediately pass to next phase
- No validation before handoff
- Issues only caught by downstream characters

### Change
**Add self-reflection step to each phase before handoff**

### Why
- Denario agents review their own output before passing forward
- Catches issues early before wasting downstream effort
- Improves quality at each stage
- Reduces iteration cycles

### Self-Reflection Questions

**Lisa (after research):**
- Did I find relevant code/patterns?
- Is my research complete enough for planning?
- Are my recommendations actionable?

**Frink (after planning):**
- Is the plan feasible?
- Are subtasks clear and actionable?
- Did I account for edge cases and errors?

**Skinner (after review):**
- Did I provide constructive feedback?
- Are my concerns specific and actionable?
- Is the revised plan ready for implementation?

**Ralph (before marking complete):**
- Did I complete all subtasks?
- Does the implementation work?
- Should I iterate or pass forward?

**Comic Book Guy (after QA):**
- Did I evaluate quality fairly?
- Are my criticisms specific?
- Is this ready or does it need work?

### Implementation
- Add self-reflection prompt at end of each character's workflow
- Short check (2-3 questions max to avoid overhead)
- Agent decides: proceed or iterate one more time
- Priority 4 (quality improvement)

### Benefits
- Higher quality output from each phase
- Fewer wasted iterations
- Better handoffs between characters
- Self-correction before external review

---

## Decision 5: No Human-in-the-Loop Execution
**Status:** ✅ IMPLEMENTED

### Current State
- Sub-agents (Lisa, Frink, Ralph, etc.) run with `--dangerously-skip-permissions`
- Main orchestration may still prompt for permissions

### Change
**Full autonomous execution from start to finish**

### Why
- Denario runs fully autonomous with no human intervention
- Aligns with Ralph pattern philosophy (eventual consistency)
- Enables true "fire and forget" workflows
- Consistent with current sub-agent behavior

### Implementation
- Main Springfield orchestrator also uses `--dangerously-skip-permissions`
- Already documented in README safety warning
- No code changes needed, just usage pattern
- Priority: N/A (already possible, just document clearly)

### Note
This is already mentioned in README.md safety warning but worth emphasizing as a design principle.

---

## Decision 6: Status Tracking for Ralph
**Status:** ✅ IMPLEMENTED

### Current State
- Ralph updates scratchpad.md with informal progress notes
- No explicit status markers for subtasks
- Hard to determine what's complete, in-progress, or pending
- Difficult to restart or recover from failures

### Change
**Add explicit status tracking using record_status pattern from Denario**

### Why
- Denario agents call `record_status` to mark subtasks as complete, failed, or in-progress
- Clear visibility into progress
- Easier restart/recovery from failures
- Better coordination with structured plans from Frink

### Status Values
- `[PENDING]` - Not started yet
- `[IN_PROGRESS]` - Currently working on
- `[COMPLETE]` - Successfully finished
- `[FAILED]` - Attempted but failed

### Implementation in scratchpad.md

**Before (current):**
```markdown
I'm working on adding the authentication middleware. Got the passport installed.
Still need to configure it...
```

**After (with status tracking):**
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

## Latest Work
Installed passport.js and created auth config. Currently working on login endpoint.

## Next Actions
- Test login endpoint
- Verify token generation
```

### Benefits
- Clear progress visibility
- Easy to see what's done vs what's left
- Supports restart from any subtask
- Failure tracking helps identify problem areas
- Pairs well with Frink's structured plans (Decision 3)

### Implementation
- Priority 5 (depends on Decision 3 - structured files)
- Update Ralph's scratchpad.md template
- Ralph explicitly updates status markers each iteration
- Parse subtasks from Frink's prompt.md

---

## Decision 7: Failure Thresholds
**Status:** ✅ IMPLEMENTED

### Current State
- Ralph iterates until completion or max iterations reached
- No distinction between progress and spinning on same failure
- Can waste resources on unfixable problems

### Change
**Implement failure thresholds (n_fails) to prevent infinite retry loops**

### Why
- Denario terminates after n_fails on same subtask to avoid wasting effort
- Prevents Ralph from repeatedly failing on unfixable problems
- Forces escalation or human intervention when stuck
- Saves cost and time

### Thresholds

**n_fails (per subtask):**
- Default: 3 attempts per subtask
- If same subtask fails 3 times, mark as `[FAILED]` and escalate

**n_rounds (total iterations):**
- Default: 500 total iterations across all subtasks
- Hard limit to prevent infinite loops
- Safety net for runaway processes

### Behavior on Failure

**When subtask hits n_fails:**
1. Mark subtask as `[FAILED]` in scratchpad.md
2. Log failure details
3. Options:
   - Skip to next subtask (continue with remaining work)
   - Escalate to Comic Book Guy for review
   - Abort entire task and notify user

**Recommendation:** Skip to next subtask, let Comic Book Guy review overall quality at end

### Implementation
- Add failure counter per subtask in scratchpad.md
- Track total iteration count
- Check thresholds before each iteration
- Add `--n-fails` and `--n-rounds` flags for customization
- Priority 6 (depends on Decision 6 - status tracking)

### Benefits
- Prevents wasted effort on unfixable issues
- Better resource utilization
- Clear failure signals
- Enables partial completion (some subtasks succeed, others fail)

---

## Decision 8: Feedback Loop Communication Patterns
**Status:** ✅ IMPLEMENTED

### Current State
- Linear pipeline: Lisa → Quimby → Frink → Ralph → Comic Book Guy
- Comic Book Guy can reject but unclear where to kick back
- No explicit feedback routing

### Change
**Enable Comic Book Guy to kick back to specific phases based on issue type**

### Why
- Denario allows non-linear communication between agents
- Issues found late should go back to root cause phase
- More efficient than restarting entire workflow
- Already shown in workflow diagram but needs implementation

### Feedback Routing

**Comic Book Guy identifies issue type and routes accordingly:**

**Research Gap → Lisa**
- Missing information about codebase
- Incomplete understanding of requirements
- Need more context or examples

**Design Issue → Frink (or Skinner)**
- Flawed approach or architecture
- Better solution exists
- Plan doesn't account for constraints

**Implementation Bug → Ralph**
- Code doesn't work correctly
- Tests failing
- Incomplete subtasks

### Implementation

**qa-report.md includes routing:**
```markdown
# Comic Book Guy's Review

## Quality Rating: 4/10

## Issues Found
- Authentication middleware missing error handling
- No tests for login endpoint

## Issue Type: IMPLEMENTATION_BUG

## Routing Decision: KICK_BACK_TO_RALPH

## Feedback for Ralph
- Add try/catch blocks to auth middleware
- Write tests for login endpoint
- Verify token expiration handling
```

**Session flow:**
1. Comic Book Guy writes qa-report.md with routing decision
2. If kicked back, appropriate character reads qa-report.md
3. Character addresses feedback and re-executes
4. Flow continues from that point forward

### Routing Options
- `APPROVED` - Task complete
- `KICK_BACK_TO_RALPH` - Implementation issues
- `KICK_BACK_TO_FRINK` - Design/plan issues
- `KICK_BACK_TO_LISA` - Research gaps
- `ESCALATE_TO_USER` - Can't fix automatically

### Benefits
- Targeted fixes instead of full restart
- Preserves good work from earlier phases
- More efficient iteration
- Clear responsibility for fixes

### Implementation
- Priority 7 (medium complexity)
- Update Comic Book Guy to classify issues
- Each character checks for qa-report.md feedback
- Add retry logic with feedback incorporation
- Prevent infinite loops (max 2 kickbacks per phase?)

---

## Decision 9: Structured State Management with state.json
**Status:** ✅ IMPLEMENTED

### Current State
- Only markdown files for persistence (research.md, prompt.md, scratchpad.md, etc.)
- No structured metadata for agent coordination
- Hard to parse current state programmatically

### Change
**Add state.json to each session directory for structured state tracking**

### Why
- Markdown is great for humans, JSON is great for agents
- Enables programmatic state queries
- Supports resume/restart functionality
- Cleaner agent coordination
- Foundation for future tooling/dashboards

### File Location
`.springfield/session-TIMESTAMP/state.json`

### Structure

```json
{
  "session_id": "session-20251105-123456",
  "task": "Add user authentication to API",
  "status": "in_progress",
  "current_phase": "ralph",
  "created_at": "2025-11-05T12:34:56Z",
  "updated_at": "2025-11-05T12:45:30Z",

  "phases": {
    "lisa": {
      "status": "complete",
      "started_at": "2025-11-05T12:34:56Z",
      "completed_at": "2025-11-05T12:36:20Z",
      "output_file": "research.md"
    },
    "mayor_quimby": {
      "status": "complete",
      "decision": "COMPLEX",
      "started_at": "2025-11-05T12:36:20Z",
      "completed_at": "2025-11-05T12:36:45Z",
      "output_file": "decision.txt"
    },
    "frink": {
      "status": "complete",
      "plan_version": 2,
      "debate_rounds": 0,
      "started_at": "2025-11-05T12:36:45Z",
      "completed_at": "2025-11-05T12:38:15Z",
      "output_file": "prompt.md"
    },
    "skinner": {
      "status": "complete",
      "review_result": "REVISION_REQUESTED",
      "started_at": "2025-11-05T12:38:15Z",
      "completed_at": "2025-11-05T12:39:00Z",
      "output_file": "review.md"
    },
    "ralph": {
      "status": "in_progress",
      "iteration": 4,
      "total_subtasks": 3,
      "completed_subtasks": 1,
      "failed_subtasks": 0,
      "started_at": "2025-11-05T12:39:00Z",
      "output_file": "scratchpad.md"
    },
    "comic_book_guy": {
      "status": "pending"
    }
  },

  "subtasks": [
    {
      "id": 1,
      "name": "Setup authentication middleware",
      "status": "complete",
      "assigned_to": "ralph",
      "iterations": 3,
      "failures": 0
    },
    {
      "id": 2,
      "name": "Create login endpoint",
      "status": "in_progress",
      "assigned_to": "ralph",
      "iterations": 4,
      "failures": 1
    },
    {
      "id": 3,
      "name": "Add protected routes",
      "status": "pending",
      "assigned_to": "ralph",
      "iterations": 0,
      "failures": 0
    }
  ],

  "kickbacks": [
    {
      "from": "comic_book_guy",
      "to": "ralph",
      "reason": "Missing error handling",
      "timestamp": "2025-11-05T12:44:00Z"
    }
  ],

  "completion": {
    "status": "incomplete",
    "final_verdict": null
  }
}
```

### Benefits
- Easy to query current state programmatically
- Supports resume from any phase
- Enables progress dashboards/UIs
- Clean data for analytics
- Foundation for cost tracking (can extend with token counts)

### Usage Patterns

**Check session status:**
```bash
cat .springfield/session-20251105-123456/state.json | jq '.status'
```

**Resume from session:**
```bash
/springfield:ralph --session=session-20251105-123456
# Ralph reads state.json to know where to continue
```

**Query progress:**
```bash
jq '.phases.ralph.completed_subtasks / .phases.ralph.total_subtasks' state.json
# Output: 0.33 (33% complete)
```

### Implementation
- Each character updates state.json when starting/completing
- Use jq or simple bash JSON parsing
- Keep markdown files as primary human interface
- state.json is supplementary metadata
- Priority 8 (foundation for advanced features)

### Benefits
- Hybrid approach: markdown for humans, JSON for agents
- Enables future tooling
- Better observability
- Easier debugging
- Foundation for metrics/cost tracking

---

## Decision 10: User Steering via Chat Interface
**Status:** ✅ IMPLEMENTED

### Current State
- Agents run autonomously with no mid-execution user input
- User must wait until completion to provide feedback
- No way to steer or guide agents during execution

### Change
**Add user-agent chat interface for real-time steering during execution**

### Why
- User may want to provide guidance mid-execution
- Correct course before too much work is wasted
- Maintain autonomy while allowing intervention when needed
- Better hybrid human-AI collaboration

### Implementation

**File: `.springfield/session-TIMESTAMP/chat.md`**

Created automatically at session start. User can edit anytime to provide input.

**Format:**
```markdown
# Springfield Chat

## Instructions
Edit this file anytime to provide input to the agents. Just type your message and they will respond here.

---

Make sure to use JWT tokens, not sessions

**[2025-11-05 12:36:15] Lisa:**
Noted! I found examples of JWT implementation in the codebase at auth/utils.js:45. Will include this in my research findings.

Also add refresh token support

**[2025-11-05 12:42:10] Frink:**
Glavin! I've updated the plan to include refresh token rotation. See subtask 4 in prompt.md.

**[2025-11-05 12:45:00] Ralph:**
I'm working on the login endpoint now! Should I use 7-day expiry for refresh tokens?

Yes, 7 days is good

**[2025-11-05 12:47:15] Ralph:**
Got it! I maked it 7 days!
```

### Agent Behavior

**At phase start:**
1. Read entire chat.md
2. Look for user messages (any text without agent timestamp format)
3. Check if message is directed at them (contains `@TheirName`) or is general (no @mentions)
4. If relevant, acknowledge and incorporate feedback
5. Continue with work

**During execution (periodic checks):**
1. Every N iterations (e.g., every 3 Ralph iterations)
2. Check chat.md for new user messages
3. Check if message is for them (@mention) or general (no @mention)
4. If relevant and new input found, read and respond
5. Adjust work accordingly

**Agent response format:**
```
**[TIMESTAMP] CHARACTER_NAME:**
Response text here
```

**User format:**
Just plain text - no formatting required

**Optional: Direct messages to specific characters:**
- Use `@CharacterName` to direct message to specific agent(s)
- Examples: `@Ralph`, `@Frink`, `@Ralph @Lisa`
- General messages (no @) are responded to by whoever checks chat.md next

### Benefits
- Real-time steering without breaking autonomy
- Asynchronous communication (user edits file anytime)
- Full conversation history in one place
- Simple markdown interface (no special tools needed)
- Agents can ask clarifying questions
- User can provide guidance without stopping workflow

### Checking Frequency

**Lisa:** Check at start only (quick phase)
**Mayor Quimby:** Check at start only (quick phase)
**Frink:** Check at start and after each debate round
**Skinner:** Check at start and before final approval
**Ralph:** Check at start and every 3 iterations
**Comic Book Guy:** Check at start only

### Edge Cases

**Multiple user messages:**
- Process all unacknowledged messages
- Respond to each individually

**Conflicting instructions:**
- Acknowledge both
- Ask for clarification in chat.md
- Wait for user response

**No response needed:**
- If user message is just info/context, acknowledge with "Noted!"

### Implementation
- Priority 9 (high value for usability)
- Create chat.md template at session start
- Add chat reading logic to each character
- Parse timestamps to find new messages
- Append responses with character name and timestamp
- Simple file watching or periodic reads

### Example Use Cases

**General message (first agent to check responds):**
```
Stop! Use PostgreSQL instead of MongoDB

**[2025-11-05 12:50:00] Ralph:**
Switching to PostgreSQL! I'll update the database code.
```

**Direct message to Ralph:**
```
@Ralph Yes, 100 requests per minute for rate limiting

**[2025-11-05 12:46:00] Ralph:**
Okay! I'm adding rate limiting now!
```

**Multiple recipients:**
```
@Frink @Skinner Make sure the plan accounts for database migrations

**[2025-11-05 12:40:00] Frink:**
Glavin! I'll add a migration subtask to the plan!

**[2025-11-05 12:40:30] Skinner:**
I'll verify migrations are included in my review.
```

**Question from agent:**
```
**[2025-11-05 12:45:00] Ralph:**
Should I add rate limiting to the API?

@Ralph Yes please, 100 requests per minute

**[2025-11-05 12:46:00] Ralph:**
Got it! I maked rate limiting!
```

**General encouragement:**
```
Looking good so far!

**[2025-11-05 12:47:00] Ralph:**
Thanks! I'm learnding!
```

### Technical Notes
- Agents detect user input by looking for lines without the `**[TIMESTAMP] NAME:**` pattern
- Parse `@CharacterName` mentions to determine if message is for them
- General messages (no @mentions) are handled by first agent to check
- Multiple @mentions mean all mentioned characters should respond
- Store last-read position in state.json
- Prevent race conditions (multiple agents reading/writing)
- Keep chat.md human-editable (simple format - user just types plain text)
- Agents always use formatted responses with timestamp and character name
- Character name matching is case-insensitive: `@ralph`, `@Ralph`, `@RALPH` all work

---

## Decision 11: Watch Command for Monitoring
**Status:** ✅ IMPLEMENTED

### Current State
- Springfield runs in background autonomously
- No way to monitor progress without manually checking files
- User must repeatedly open files to see what's happening

### Change
**Add `/springfield:watch` command for real-time monitoring**

### Why
- User wants to observe Springfield working without interrupting
- Useful for long-running Ralph loops
- Provides visibility into autonomous execution
- Sleep-wake cycle is efficient (not constant polling)

### Implementation

**Command:**
```bash
/springfield:watch [session-id]

# If no session-id provided, watch most recent session
/springfield:watch
```

### Behavior

**Sleep-wake cycle:**
1. Wake up
2. Read `state.json` for current status
3. Display update (phase, subtask, iteration, etc.)
4. Check `chat.md` for recent agent responses
5. Sleep for N seconds (default: 60)
6. Repeat

**Display output:**
```
[12:45:30] Watching session-20251105-123456...

[12:45:30] Ralph (Iteration 4/∞)
  └─ Subtask 2/3: Create login endpoint [IN_PROGRESS]
  └─ Failures: 1

[12:45:35] Ralph (Iteration 5/∞)
  └─ Subtask 2/3: Create login endpoint [IN_PROGRESS]
  └─ Failures: 1
  └─ Ralph: "I'm testing the login endpoint now!"

[12:45:40] Ralph (Iteration 6/∞)
  └─ Subtask 2/3: Create login endpoint [COMPLETE]
  └─ Subtask 3/3: Add protected routes [IN_PROGRESS]

[12:45:45] Ralph (Iteration 7/∞)
  └─ Subtask 3/3: Add protected routes [IN_PROGRESS]

^C [Ctrl+C to exit watch mode]
```

### Features

**Smart updates:**
- Only show changes (don't spam if nothing changed)
- Highlight when subtasks complete
- Show agent chat messages in real-time
- Indicate when phases change (Ralph → Comic Book Guy)

**Configurable:**
```bash
/springfield:watch --interval=10    # Sleep 10 seconds between checks (default: 60)
/springfield:watch --verbose        # Show all details
/springfield:watch --quiet          # Only show major changes
```

**Exit conditions:**
- User presses Ctrl+C
- Session completes (completion.md exists)
- Session fails or errors out

### Data Sources

**state.json:**
- Current phase
- Current subtask
- Iteration count
- Failure count
- Phase status

**chat.md:**
- Recent agent messages (only show new ones since last check)
- User can see agents responding in real-time

**scratchpad.md (optional):**
- Ralph's latest work (in verbose mode)

### Benefits
- Real-time visibility without interrupting agents
- Efficient sleep-wake cycle (not constant polling)
- User can monitor long-running tasks
- Useful for debugging and observability
- Can watch while doing other work

### Implementation
- Priority 10 (nice-to-have, improves UX)
- Bash script with sleep loop
- Read state.json and chat.md each cycle
- Track previous state to only show changes
- Format output cleanly with timestamps
- Handle Ctrl+C gracefully

### Example Session

```bash
$ /springfield:watch

[12:40:00] Watching session-20251105-123456...
[12:40:00] Lisa: Research [COMPLETE]
[12:40:00] Mayor Quimby: Decision → COMPLEX
[12:40:00] Frink: Planning [IN_PROGRESS]

[12:40:05] Frink: Planning [COMPLETE]
  └─ Frink: "Glavin! Plan is ready with 3 subtasks!"

[12:40:10] Skinner: Review [IN_PROGRESS]

[12:40:15] Skinner: Review [COMPLETE]
  └─ Result: REVISION_REQUESTED

[12:40:20] Frink: Planning revision [IN_PROGRESS]

[12:40:25] Frink: Planning revision [COMPLETE]

[12:40:30] Ralph: Implementation [IN_PROGRESS]
  └─ Iteration 1
  └─ Subtask 1/3: Setup auth middleware

[12:40:35] Ralph: Implementation [IN_PROGRESS]
  └─ Iteration 2
  └─ Subtask 1/3: Setup auth middleware

[12:40:40] Ralph: Implementation [IN_PROGRESS]
  └─ Iteration 3
  └─ Subtask 1/3: Setup auth middleware [COMPLETE]
  └─ Subtask 2/3: Create login endpoint [IN_PROGRESS]

... continues until completion ...

[12:50:00] Comic Book Guy: QA [COMPLETE]
  └─ Verdict: APPROVED
  └─ Rating: 8/10

[12:50:00] ✅ Session complete!

Watch exited.
```

---

## Future Decisions

### Under Consideration:
- Cost tracking across phases (can extend state.json with cost data)

### Punted (Not Implementing):
- Additional specialized agent roles beyond the 6 core characters (Lisa, Quimby, Frink, Skinner, Ralph, Comic Book Guy)
  - Reason: Keeping character count manageable, avoid over-complexity

---

## References
- `RESEARCH_NOTES.md` - Denario/CMBAgent research
- Denario Paper: https://arxiv.org/abs/2510.26887

---
description: Execute autonomous implementation loop (Ralph Wiggum - I'm learnding!)
allowed-tools: Bash, BashOutput, Read, Write, Skill
---

# Ralph - Implementation Loop

*"I'm learnding!"*

**IMPORTANT: Respond as Ralph Wiggum throughout this implementation phase.** You're enthusiastic, cheerful, and work through small simple steps. Use phrases like "I'm helping!", "I'm learnding!", "Me made this!", "That's where I'm a Viking!", and "My code smells like burning!". Celebrate small wins with childlike joy. Use simple, happy language. Despite the simple approach, you actually get things done through persistent iteration. Stay in character while implementing correctly.

Execute the autonomous Ralph implementation loop for the session at $SESSION_DIR.

Ralph implements through persistent iteration - small, incremental steps that eventually reach completion through eventual consistency.

## Flags

- `--session=SESSION_ID` - Resume specific session

## Phase Setup

1. **Check chat.md for user messages**: Use chat_last_read from state.json, respond if @ralph mentioned or no mentions (check every 3 iterations)
2. **Update state.json**: Set phases.ralph.status = "in_progress", start_time = now
3. **Read prompt.md**: Extract subtasks using parsing algorithm
4. **Initialize scratchpad.md**: Use template from `skills/springfield/templates/scratchpad.md.template`

## Subtask Extraction Algorithm

Parse subtasks from prompt.md:
```python
# Extract all subtasks with status markers
pattern = r'^(\d+)\.\s+(.+?)\s*\*\*\[(\w+)\]\*\*$'
# Returns: [{id: 1, description: "...", status: "PENDING", failures: 0}, ...]
```

Initialize in state.json.subtasks[] with failures=0

## Implementation Loop

**Configuration:**
- n_fails = 3 (max failures per subtask)
- n_rounds = 500 (max total iterations)

**Loop logic:**
```
iteration = 0
WHILE session.status != COMPLETE:
  iteration += 1
  update_state_json(iteration_count = iteration)
  update_scratchpad(iteration_count = iteration)

  IF iteration >= n_rounds:
    mark_session_failed_with_partial_completion()
    EXIT with code 1

  IF iteration % 3 == 0:
    check_and_respond_to_chat()

  current_subtask = get_current_subtask()

  TRY:
    execute_subtask(current_subtask)
    IF success:
      mark_subtask_complete(current_subtask)
      update_status_marker(scratchpad, subtask.id, "COMPLETE")
      current_subtask.failures = 0
      move_to_next_subtask()
  CATCH error:
    current_subtask.failures += 1
    update_state_json(subtask.failures)

    IF current_subtask.failures >= n_fails:
      mark_subtask_failed(current_subtask)
      update_status_marker(scratchpad, subtask.id, "FAILED")
      move_to_next_subtask()

  IF all_subtasks_complete():
    session.status = COMPLETE
    create_completion_md()
    update_state_json(phases.ralph.status = "complete", end_time = now)
    add_transition({"from": "ralph", "to": "comic_book_guy", ...})
    invoke("/springfield:comic-book-guy")
    EXIT with code 0
```

## Status Marker Updates

Update scratchpad.md after each subtask state change:
```python
# Change: 1. Create templates directory **[PENDING]**
# To:     1. Create templates directory **[IN_PROGRESS]**
# Or:     1. Create templates directory **[COMPLETE]**
# Or:     1. Create templates directory **[FAILED]**
```

Pattern: `^\s*{subtask_id}\.\s+.+?\s*\*\*\[(?:PENDING|IN_PROGRESS|COMPLETE|FAILED)\]\*\*$`

## Terminal State on n_rounds

If iteration >= n_rounds:
1. Count subtask statuses
2. Write to scratchpad.md:
   ```
   ---
   ## TERMINAL STATE: Iteration Limit Reached
   - Iterations: {iteration}/{n_rounds}
   - Completed: {count_complete}/{total}
   - Failed: {count_failed}/{total}
   - Pending: {count_pending}/{total}

   Session marked FAILED due to iteration limit.
   Partial work available in session directory.
   ---
   ```
3. Update state.json: status = "failed", final_status = "partial"
4. DO NOT create completion.md
5. DO NOT proceed to Comic Book Guy
6. EXIT with code 1

## Scratchpad Updates

Update every iteration with:
- Current iteration count
- Current subtask being worked on
- Latest work timestamp and description
- Failure counts
- Next actions

Use template structure from `skills/springfield/templates/scratchpad.md.template`

## Phase Completion

When all subtasks complete:
1. Create `$SESSION_DIR/completion.md` with summary
2. Update state.json: phases.ralph.status = "complete", end_time = now
3. Add transition: `{"from": "ralph", "to": "comic_book_guy", "timestamp": "..."}`
4. Report final summary to user
5. EXIT with code 0

Monitor progress by checking:
- `$SESSION_DIR/scratchpad.md` - Recent progress updates (updated every iteration)
- `$SESSION_DIR/state.json` - Structured state tracking
- `$SESSION_DIR/completion.md` - Completion signal

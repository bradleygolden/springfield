---
description: Monitor Springfield workflow session progress
argument-hint: [session-id]
allowed-tools: Read, Bash, BashOutput
---

# Watch - Session Monitoring

Monitor the progress of a Springfield workflow session in real-time.

## Usage

```bash
/springfield:watch [session-id] [--interval=N] [--quiet]
```

## Arguments

- **session-id** (optional): Specific session to monitor. If not provided, watches most recent session
- **--interval=N**: Sleep interval in seconds between checks (default: 60)
- **--quiet**: Minimal output, just status updates

## Session Detection Logic

Find session directory:
```bash
# If session-id provided
session_dir=".springfield/${session_id}"

# Otherwise find most recent
session_dir=$(find .springfield -maxdepth 1 -type d -name "[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]-*" | sort -r | head -1)
```

## Validation

Before starting watch loop:

1. **Check session directory exists**:
   ```bash
   if [ ! -d "$session_dir" ]; then
     echo "ERROR: Session directory not found: $session_dir"
     exit 1
   fi
   ```

2. **Check state.json exists**:
   ```bash
   state_file="$session_dir/state.json"
   if [ ! -f "$state_file" ]; then
     echo "WARN: Old session format detected (no state.json)"
     echo "WARN: Watch command requires state.json - cannot monitor"
     exit 1
   fi
   ```

3. **Validate state.json is valid JSON**:
   ```bash
   if ! jq . "$state_file" >/dev/null 2>&1; then
     echo "ERROR: Corrupt state.json detected"
     echo "ERROR: Cannot proceed - manual repair needed"
     exit 3
   fi
   ```

## Watch Loop

Sleep-wake cycle that reads state.json and displays progress:

```bash
while true; do
  # Read state.json (read-only, no locking)
  status=$(jq -r '.status' "$state_file")
  phase=$(jq -r '.current_phase' "$state_file")
  iteration=$(jq -r '.iteration_count // 0' "$state_file")

  # If Ralph phase, get current subtask
  if [ "$phase" = "ralph" ]; then
    current_subtask_idx=$(jq -r '.phases.ralph.current_subtask_index // 0' "$state_file")
    total_subtasks=$(jq -r '.subtasks | length' "$state_file")
    subtask_desc=$(jq -r ".subtasks[$current_subtask_idx].description // \"N/A\"" "$state_file")
    subtask_status=$(jq -r ".subtasks[$current_subtask_idx].status // \"PENDING\"" "$state_file")
    failures=$(jq -r ".subtasks[$current_subtask_idx].failures // 0" "$state_file")
  fi

  # Display current status
  timestamp=$(date '+%H:%M:%S')

  if [ "$quiet" != "true" ]; then
    clear
    echo "=== Springfield Session Monitor ==="
    echo "Session: $(basename $session_dir)"
    echo "Status: $status"
    echo "Phase: $phase"
    echo ""
  fi

  case "$phase" in
    lisa)
      echo "[$timestamp] Lisa researching codebase..."
      ;;
    quimby)
      echo "[$timestamp] Mayor Quimby assessing complexity..."
      ;;
    frink)
      echo "[$timestamp] Professor Frink planning implementation..."
      ;;
    skinner)
      echo "[$timestamp] Principal Skinner reviewing plan..."
      ;;
    ralph)
      echo "[$timestamp] Ralph (Iteration $iteration)"
      echo "  └─ Subtask $((current_subtask_idx + 1))/$total_subtasks: $subtask_desc **[$subtask_status]**"
      echo "  └─ Failures: $failures/3"
      ;;
    comic_book_guy)
      echo "[$timestamp] Comic Book Guy evaluating quality..."
      ;;
  esac

  # Show recent scratchpad update if Ralph
  if [ "$phase" = "ralph" ] && [ -f "$session_dir/scratchpad.md" ]; then
    recent=$(grep "^## Latest Work" -A 1 "$session_dir/scratchpad.md" | tail -1)
    echo "  └─ Recent: $recent"
  fi

  # Check for completion or terminal states
  if [ "$status" = "complete" ]; then
    verdict=$(jq -r '.phases.comic_book_guy.verdict // "UNKNOWN"' "$state_file")
    echo ""
    echo "✓ Session completed successfully!"
    echo "  Verdict: $verdict"
    exit 0
  elif [ "$status" = "failed" ]; then
    echo ""
    echo "✗ Session failed"
    exit 1
  elif [ "$status" = "blocked" ]; then
    echo ""
    echo "⚠ Session blocked - awaiting user input"
    echo "  Check chat.md for details"
    # Don't exit - keep monitoring in case user unblocks
  fi

  # Sleep before next check
  sleep "${interval:-60}"
done
```

## Exit Codes

- **0**: Session completed successfully (status="complete", verdict="APPROVED")
- **1**: Session failed (status="failed", n_rounds exceeded or unrecoverable error)
- **2**: User cancelled (Ctrl+C caught gracefully)
- **3**: State corruption detected (invalid JSON)

## Ctrl+C Handling

Trap SIGINT for graceful exit:
```bash
trap 'echo ""; echo "Watch cancelled by user"; exit 2' INT
```

## Concurrency Notes

- Watch uses **read-only access** to state.json
- No file locking - optimistic reads
- Accept stale data - worst case shows old data for 1 cycle
- Race conditions acceptable for monitoring
- jq operations are atomic reads

## Automation Support

Use exit codes for scripting:
```bash
/springfield:watch --interval=30 --quiet

if [ $? -eq 0 ]; then
  echo "Session completed successfully!"
  # Continue with next steps
elif [ $? -eq 1 ]; then
  echo "Session failed - check logs"
  # Handle failure
elif [ $? -eq 3 ]; then
  echo "State corruption - manual intervention required"
  # Alert operator
fi
```

## Example Output

```
=== Springfield Session Monitor ===
Session: 11-05-2025-add-authentication
Status: in_progress
Phase: ralph

[14:32:15] Ralph (Iteration 42/500)
  └─ Subtask 3/5: Update character commands **[IN_PROGRESS]**
  └─ Failures: 1/3
  └─ Recent: "I'm adding state.json tracking! I'm helping!"
```

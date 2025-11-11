#!/usr/bin/env bash
set -euo pipefail

# Springfield CLI - Self-contained workflow orchestrator
# Usage: ./scripts/springfield.sh <command> [args...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/skills/springfield/templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1" >&2
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Command: init <task-description>
cmd_init() {
  local task_description="${1:-}"

  if [ -z "$task_description" ]; then
    log_error "Task description required"
    echo ""
    echo "Usage: $0 init \"<task-description>\""
    echo ""
    echo "Example:"
    echo "  $0 init \"add dark mode feature\""
    exit 1
  fi

  # Create session directory name
  local date_stamp=$(date +"%m-%d-%Y")
  local sanitized_task=$(echo "$task_description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
  local session_dir=".springfield/${date_stamp}-${sanitized_task}"

  # Check if session already exists
  if [ -d "$session_dir" ]; then
    log_error "Session already exists: $session_dir"
    exit 1
  fi

  log_info "Creating session directory: $session_dir"
  mkdir -p "$session_dir"

  # Initialize task.txt
  echo "$task_description" > "$session_dir/task.txt"
  log_success "Created task.txt"

  # Initialize state.json from template
  if [ -f "$TEMPLATES_DIR/state.json.template" ]; then
    cp "$TEMPLATES_DIR/state.json.template" "$session_dir/state.json"
    # Update with actual values
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local session_name=$(basename "$session_dir")
    local tmp=$(mktemp)
    jq --arg ts "$timestamp" \
       --arg sid "$session_name" \
       --arg task "$task_description" \
       --arg phase "lisa" \
       '.created_at = $ts | .updated_at = $ts | .session_id = $sid | .task = $task | .current_phase = $phase | .status = "initialized"' \
       "$session_dir/state.json" > "$tmp"
    mv "$tmp" "$session_dir/state.json"
    log_success "Created state.json"
  else
    # Create basic state.json if template doesn't exist
    cat > "$session_dir/state.json" <<EOF
{
  "status": "initialized",
  "current_phase": "lisa",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "iteration": 0,
  "phases": {
    "lisa": {"status": "pending"},
    "quimby": {"status": "pending"},
    "frink": {"status": "pending"},
    "skinner": {"status": "pending"},
    "martin": {"status": "pending"},
    "ralph": {"status": "pending"},
    "comic-book-guy": {"status": "pending"}
  },
  "kickbacks": {}
}
EOF
    log_success "Created state.json"
  fi

  log_success "Session initialized: $session_dir"
  echo ""
  echo "Next steps:"
  echo "  $0 auto    # Run full autonomous workflow"
  echo "  $0 step    # Run one phase at a time"
  echo "  $0 status  # Check current status"
  echo ""
  echo "Session directory: $session_dir"
}

# Command: status
cmd_status() {
  local session_dir=$(find_latest_session)

  if [ -z "$session_dir" ]; then
    log_error "No active session found"
    echo ""
    echo "Create a session with: $0 init \"<task-description>\""
    exit 1
  fi

  local state_file="$session_dir/state.json"

  if [ ! -f "$state_file" ]; then
    log_error "State file not found: $state_file"
    exit 1
  fi

  log_info "Session: $session_dir"
  echo ""

  local status=$(jq -r '.status' "$state_file")
  local current_phase=$(jq -r '.current_phase' "$state_file")
  local iteration=$(jq -r '.iteration' "$state_file")

  echo "Status: $status"
  echo "Current Phase: $current_phase"
  echo "Iteration: $iteration"
  echo ""

  echo "Phase Status:"
  jq -r '.phases | to_entries[] | "  \(.key): \(.value.status)"' "$state_file"
}

# Command: step
cmd_step() {
  local session_dir=$(find_latest_session)

  if [ -z "$session_dir" ]; then
    log_error "No active session found"
    echo ""
    echo "Create a session with: $0 init \"<task-description>\""
    exit 1
  fi

  local state_file="$session_dir/state.json"
  local status=$(jq -r '.status' "$state_file")
  local current_phase=$(jq -r '.current_phase' "$state_file")

  # Check if workflow is complete
  if [ "$status" = "complete" ]; then
    log_success "Workflow already complete!"
    exit 0
  fi

  if [ "$status" = "blocked" ]; then
    log_warn "Workflow is blocked. Check state.json for details."
    exit 1
  fi

  if [ "$status" = "failed" ]; then
    log_error "Workflow has failed. Check state.json for details."
    exit 1
  fi

  log_info "Running phase: $current_phase"

  # Execute the current phase
  execute_phase "$current_phase" "$session_dir"

  log_success "Phase complete: $current_phase"
}

# Command: auto
cmd_auto() {
  local session_dir=$(find_latest_session)

  if [ -z "$session_dir" ]; then
    log_error "No active session found"
    echo ""
    echo "Create a session with: $0 init \"<task-description>\""
    exit 1
  fi

  log_info "Starting autonomous workflow: $session_dir"
  echo ""

  local max_iterations=100
  local iteration=0

  while [ $iteration -lt $max_iterations ]; do
    local state_file="$session_dir/state.json"
    local status=$(jq -r '.status' "$state_file")
    local current_phase=$(jq -r '.current_phase' "$state_file")

    # Check exit conditions
    if [ "$status" = "complete" ]; then
      log_success "Workflow complete!"
      if [ -f "$session_dir/completion.md" ]; then
        echo ""
        cat "$session_dir/completion.md"
      fi
      exit 0
    fi

    if [ "$status" = "blocked" ]; then
      log_warn "Workflow blocked. Check state.json for details."
      exit 1
    fi

    if [ "$status" = "failed" ]; then
      log_error "Workflow failed."
      exit 1
    fi

    # Execute current phase
    log_info "[$iteration] Running phase: $current_phase"
    execute_phase "$current_phase" "$session_dir"

    # Sleep between phases
    sleep 2

    iteration=$((iteration + 1))
  done

  log_error "Max iterations ($max_iterations) reached. Workflow timeout."
  exit 1
}

# Helper: Find latest session directory
find_latest_session() {
  local latest=$(find .springfield -maxdepth 1 -type d -name "[0-9]*" 2>/dev/null | xargs ls -td 2>/dev/null | head -n 1)
  echo "$latest"
}

# Helper: Execute a character phase
execute_phase() {
  local phase="$1"
  local session_dir="$2"
  local script=""

  case "$phase" in
    lisa)
      script="$SCRIPT_DIR/lisa.sh"
      ;;
    quimby)
      script="$SCRIPT_DIR/quimby.sh"
      ;;
    frink)
      script="$SCRIPT_DIR/frink.sh"
      ;;
    skinner)
      script="$SCRIPT_DIR/skinner.sh"
      ;;
    martin)
      script="$SCRIPT_DIR/martin.sh"
      ;;
    ralph)
      script="$SCRIPT_DIR/ralph.sh"
      ;;
    comic-book-guy)
      script="$SCRIPT_DIR/comic-book-guy.sh"
      ;;
    *)
      log_error "Unknown phase: $phase"
      exit 1
      ;;
  esac

  if [ ! -f "$script" ]; then
    log_error "Script not found: $script"
    exit 1
  fi

  # Execute the character script
  if ! bash "$script" "$session_dir"; then
    log_error "Phase failed: $phase"
    # Update state to failed
    local tmp=$(mktemp)
    jq '.status = "failed"' "$session_dir/state.json" > "$tmp"
    mv "$tmp" "$session_dir/state.json"
    exit 1
  fi
}

# Main command dispatcher
main() {
  local command="${1:-}"

  if [ -z "$command" ]; then
    echo "Springfield CLI - Autonomous Workflow Orchestrator"
    echo ""
    echo "Usage: $0 <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  init <task>    Initialize a new workflow session"
    echo "  auto           Run full autonomous workflow"
    echo "  step           Execute next phase only"
    echo "  status         Show current workflow status"
    echo ""
    echo "Examples:"
    echo "  $0 init \"add dark mode feature\""
    echo "  $0 auto"
    echo "  $0 status"
    exit 0
  fi

  shift

  case "$command" in
    init)
      cmd_init "$@"
      ;;
    status)
      cmd_status "$@"
      ;;
    step)
      cmd_step "$@"
      ;;
    auto)
      cmd_auto "$@"
      ;;
    *)
      log_error "Unknown command: $command"
      echo ""
      echo "Run '$0' without arguments to see usage."
      exit 1
      ;;
  esac
}

main "$@"

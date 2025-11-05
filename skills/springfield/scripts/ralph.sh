#!/usr/bin/env bash

set -euo pipefail

RALPH_DIR="${1:-}"
if [ -z "$RALPH_DIR" ]; then
  echo "❌ Error: Ralph session directory required"
  echo ""
  echo "Usage:"
  echo "  bash $0 /path/to/session/directory"
  echo ""
  exit 1
fi

canonical=""
if command -v readlink >/dev/null 2>&1 && readlink -f /dev/null >/dev/null 2>&1; then
  canonical=$(readlink -f "$RALPH_DIR" 2>/dev/null || echo "")
elif command -v realpath >/dev/null 2>&1; then
  canonical=$(realpath "$RALPH_DIR" 2>/dev/null || echo "")
else
  case "$RALPH_DIR" in
    */..|*/../*|../*) canonical="" ;;
    /*) canonical="$RALPH_DIR" ;;
    *) canonical="$(pwd)/$RALPH_DIR" ;;
  esac
fi

if [ -z "$canonical" ]; then
  echo "Error: Invalid session directory - path must be within project directory" >&2
  exit 1
fi

case "$canonical" in
  "$(pwd)"/*) ;;
  "$(pwd)") ;;
  *) echo "Error: Invalid session directory - path must be within project directory" >&2; exit 1 ;;
esac

PROMPT_FILE="$RALPH_DIR/prompt.md"
SCRATCHPAD_FILE="$RALPH_DIR/scratchpad.md"
COMPLETION_FILE="$RALPH_DIR/completion.md"
SLEEP_DURATION="${SLEEP_DURATION:-10}"

if ! [[ "$SLEEP_DURATION" =~ ^[0-9]+$ ]] || [ "$SLEEP_DURATION" -lt 0 ] || [ "$SLEEP_DURATION" -gt 3600 ]; then
  echo "Error: SLEEP_DURATION must be 0-3600, got '$SLEEP_DURATION'" >&2
  exit 1
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ Error: $PROMPT_FILE does not exist!"
  echo ""
  echo "Ralph requires prompt.md to exist in the session directory."
  echo "Create it first, then run Ralph again."
  exit 1
fi

iteration=0
start_time=$(date +%s)

echo "🎯 Ralph Wiggum starting..."
echo "📁 Session directory: $RALPH_DIR"
echo "📝 Prompt file: $PROMPT_FILE"
echo "📋 Scratchpad: $SCRATCHPAD_FILE"
echo "⏱️  Sleep duration: ${SLEEP_DURATION}s"
echo ""

cleanup() {
  [ -n "${TEMP_FILE:-}" ] && [ -f "$TEMP_FILE" ] && rm -f "$TEMP_FILE"
}
trap cleanup EXIT INT TERM

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 Starting Implementation Loop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

while true; do
  iteration=$((iteration + 1))
  iteration_start=$(date +%s)

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔄 Iteration #$iteration started at $(date '+%Y-%m-%d %H:%M:%S')"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [ -f "$COMPLETION_FILE" ]; then
    echo ""
    echo "🎉 Completion file found - Ralph has finished the task!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 Summary:"
    cat "$COMPLETION_FILE"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
  fi

  TEMP_FILE=$(mktemp)
  chmod 600 "$TEMP_FILE"

  cat > "$TEMP_FILE" <<EOF
$(cat "$PROMPT_FILE")

---

## Recent Progress (last 20 lines):
$(tail -20 "$SCRATCHPAD_FILE" 2>/dev/null || echo "Starting fresh")

---

## Iteration #$iteration

Implement one small piece. Update $SCRATCHPAD_FILE. Commit.
When 100% done: create $COMPLETION_FILE with summary.
EOF

  if ! claude \
    --dangerously-skip-permissions \
    --output-format=stream-json \
    --verbose \
    < "$TEMP_FILE" | npx repomirror visualize; then
    echo "❌ Error in iteration #$iteration: claude or repomirror command failed"
  fi

  iteration_end=$(date +%s)
  iteration_duration=$((iteration_end - iteration_start))
  total_duration=$((iteration_end - start_time))

  echo ""
  echo "✅ Iteration #$iteration completed in ${iteration_duration}s"
  echo "📊 Total runtime: ${total_duration}s across $iteration iterations"
  echo "💤 Sleeping for ${SLEEP_DURATION}s..."
  echo ""

  sleep "$SLEEP_DURATION"
done

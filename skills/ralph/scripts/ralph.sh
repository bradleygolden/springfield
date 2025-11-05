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

PROMPT_FILE="$RALPH_DIR/prompt.md"
SCRATCHPAD_FILE="$RALPH_DIR/scratchpad.md"
COMPLETION_FILE="$RALPH_DIR/completion.md"
SLEEP_DURATION="${SLEEP_DURATION:-10}"

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

  cat > /tmp/iteration_prompt.md <<EOF
$(cat "$PROMPT_FILE")

---

## Recent Progress (last 20 lines):
$(tail -20 "$SCRATCHPAD_FILE" 2>/dev/null || echo "Starting fresh")

---

## Iteration #$iteration

Implement one small piece. Update scratchpad. Commit.
When 100% done: create completion.md with summary.
EOF

  if ! claude \
    --dangerously-skip-permissions \
    --output-format=stream-json \
    --verbose \
    < /tmp/iteration_prompt.md | npx repomirror visualize; then
    echo "❌ Error in iteration #$iteration"
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

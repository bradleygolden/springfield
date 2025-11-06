#!/usr/bin/env bash
set -euo pipefail

SESSION_DIR="${1:-}"
if [ -z "$SESSION_DIR" ]; then
  echo "❌ Error: SESSION_DIR is required" >&2
  echo "" >&2
  echo "Usage: $0 <session-directory>" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  $0 .springfield/my-session" >&2
  echo "" >&2
  echo "💡 Tip: Principal Skinner reviews complex plans created by Professor Frink" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#characters" >&2
  exit 1
fi

canonical=""
if command -v readlink >/dev/null 2>&1 && readlink -f /dev/null >/dev/null 2>&1; then
  canonical=$(readlink -f "$SESSION_DIR" 2>/dev/null || echo "")
elif command -v realpath >/dev/null 2>&1; then
  canonical=$(realpath "$SESSION_DIR" 2>/dev/null || echo "")
else
  case "$SESSION_DIR" in
    */..|*/../*|../*) canonical="" ;;
    /*) canonical="$SESSION_DIR" ;;
    *) canonical="$(pwd)/$SESSION_DIR" ;;
  esac
fi

if [ -z "$canonical" ]; then
  echo "Error: Invalid path" >&2
  exit 1
fi

case "$canonical" in
  "$(pwd)"/*) ;;
  "$(pwd)") ;;
  *) echo "Error: Path must be within project" >&2; exit 1 ;;
esac

STATE_FILE="$SESSION_DIR/state.json"
CHAT_FILE="$SESSION_DIR/chat.md"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg timestamp "$TIMESTAMP" \
   '.phases.skinner.status = "in_progress" |
    .phases.skinner.start_time = $timestamp' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

LAST_READ=$(jq -r '.chat_last_read // "1970-01-01 00:00:00"' "$STATE_FILE")
NEW_MESSAGES=$(awk -v last="$LAST_READ" -v char="skinner" '
  /^\*\*\[.*\] (USER|user):\*\*/ {
    timestamp = $0
    sub(/.*\[/, "", timestamp)
    sub(/\].*/, "", timestamp)
    if (timestamp > last) {
      getline content
      if (content ~ /@all/ || content ~ "@"char) {
        print timestamp "|" content
      }
    }
  }
' "$CHAT_FILE")

if [ -n "$NEW_MESSAGES" ]; then
  MESSAGE=$(echo "$NEW_MESSAGES" | tail -1 | cut -d'|' -f2-)
  CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
  echo "**[$CURRENT_TIME] skinner:** I saw your message: \"$MESSAGE\"" >> "$CHAT_FILE"

  TMP_STATE=$(mktemp)
  jq --arg time "$CURRENT_TIME" '.chat_last_read = $time' "$STATE_FILE" > "$TMP_STATE"
  mv "$TMP_STATE" "$STATE_FILE"
fi

PLAN_FILE="$SESSION_DIR/plan-v1.md"
if [ ! -f "$PLAN_FILE" ]; then
  echo "❌ Error: plan-v1.md not found in session directory" >&2
  echo "" >&2
  echo "Expected: $PLAN_FILE" >&2
  echo "" >&2
  echo "💡 Tip: Professor Frink must create plan-v1.md for complex tasks before Skinner can review" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

PLAN_CONTENT=$(cat "$PLAN_FILE")

PROMPT_FILE=$(mktemp)
chmod 600 "$PROMPT_FILE"

cleanup() {
  [ -n "${PROMPT_FILE:-}" ] && [ -f "$PROMPT_FILE" ] && rm -f "$PROMPT_FILE"
}
trap cleanup EXIT INT TERM

cat > "$PROMPT_FILE" <<SKINNER_PROMPT
*"Pathetic work, Professor. Let me show you how it's done."*

**IMPORTANT: Respond as Principal Skinner throughout this review phase.** You're a strict, by-the-book administrator who demands order and proper procedure. Use phrases like "Pathetic!", "This is unacceptable!", "According to district regulations...", "I've seen better plans from kindergarteners!", and "Superintendent Chalmers would have my head if...". Be critical but constructive. Point out specific flaws and demand improvements. When something is good, acknowledge it grudgingly. Stay in character while providing legitimate plan reviews.

Review Professor Frink's implementation plan.

**Review Criteria:**

1. **Completeness**
   - Are all requirements from research addressed?
   - Are subtasks clearly defined?
   - Is success criteria specified?

2. **Technical Detail**
   - Are implementation approaches specific?
   - Are error handling strategies included?
   - Are edge cases considered?

3. **Structure & Clarity**
   - Is the plan logically organized?
   - Are subtasks in correct order?
   - Are dependencies clear?

4. **Feasibility**
   - Is the approach realistic?
   - Are time estimates reasonable (if provided)?
   - Are resources/dependencies available?

**Implementation Plan to Review:**

$PLAN_CONTENT

**Your Task:**

Use the Write tool to create a structured review at: $SESSION_DIR/review.md

Include:
- Overall Assessment (APPROVED | NEEDS_REVISION)
- Strengths (what Frink did well, be grudging)
- Critical Issues (major problems that MUST be fixed)
- Recommendations (specific improvements needed)
- Detailed Feedback (section-by-section critique)
- Skinner's Verdict (final judgment in character)

Be critical but constructive. Point out SPECIFIC issues with file:line references if possible.
Make it pathetic but helpful!
SKINNER_PROMPT

if ! claude \
  --dangerously-skip-permissions \
  --output-format=stream-json \
  --verbose \
  < "$PROMPT_FILE" | npx repomirror visualize; then
  echo "❌ Error: Skinner's review failed"
  exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg timestamp "$TIMESTAMP" \
   '.phases.skinner.status = "complete" |
    .phases.skinner.end_time = $timestamp |
    .phases.skinner.reviewed = true |
    .phases.skinner.output_file = "review.md"' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

exit 0

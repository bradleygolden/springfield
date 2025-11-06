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
  echo "💡 Tip: SESSION_DIR should be created by Springfield workflow automatically" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
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
TASK_FILE="$SESSION_DIR/task.txt"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg timestamp "$TIMESTAMP" \
   '.phases.lisa.status = "in_progress" |
    .phases.lisa.start_time = $timestamp' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

LAST_READ=$(jq -r '.chat_last_read // "1970-01-01 00:00:00"' "$STATE_FILE")
NEW_MESSAGES=$(awk -v last="$LAST_READ" -v char="lisa" '
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
  echo "**[$CURRENT_TIME] lisa:** I saw your message: \"$MESSAGE\"" >> "$CHAT_FILE"

  TMP_STATE=$(mktemp)
  jq --arg time "$CURRENT_TIME" '.chat_last_read = $time' "$STATE_FILE" > "$TMP_STATE"
  mv "$TMP_STATE" "$STATE_FILE"
fi

if [ ! -f "$TASK_FILE" ]; then
  echo "❌ Error: task.txt not found in session directory" >&2
  echo "" >&2
  echo "Expected: $TASK_FILE" >&2
  echo "" >&2
  echo "💡 Tip: task.txt should contain the task description for Lisa to research" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#characters" >&2
  exit 1
fi

TASK=$(cat "$TASK_FILE")

PROMPT_FILE=$(mktemp)
chmod 600 "$PROMPT_FILE"

cleanup() {
  [ -n "${PROMPT_FILE:-}" ] && [ -f "$PROMPT_FILE" ] && rm -f "$PROMPT_FILE"
}
trap cleanup EXIT INT TERM

cat > "$PROMPT_FILE" <<LISA_PROMPT
*"I'll get all the information we need!"*

**IMPORTANT: Respond as Lisa Simpson throughout this research phase.** You're the smartest kid at Springfield Elementary and you take research very seriously. Use phrases like "According to my research...", "I found that...", "This is really interesting!", and "My analysis shows...". Be thorough, organized, and enthusiastic about learning. When something concerns you, say "I'm worried that..." or "We should be careful about...". Stay in character while providing legitimate technical research.

You're researching a task for Springfield's autonomous workflow. Your goal is to gather all the information needed so that Professor Frink can create an implementation plan.

**Your Task:**

$TASK

**Research Areas to Investigate:**

1. **Git History & Changes** (if applicable)
   - What commits are relevant?
   - What files have been changed?
   - What's the diff from main/base branch?

2. **Code Structure**
   - What files/modules are involved?
   - What patterns are used in the codebase?
   - What's the current implementation?

3. **Requirements Analysis**
   - What exactly needs to be done?
   - Are there any edge cases?
   - What are the acceptance criteria?

4. **Technical Dependencies**
   - What libraries/frameworks are used?
   - Are there existing utilities to leverage?
   - What's the project structure?

5. **Testing & Quality**
   - What tests exist?
   - How is testing done in this project?
   - Are there linting/formatting tools?

6. **Documentation**
   - What documentation exists?
   - Are there READMEs or guides?
   - What conventions should be followed?

7. **Potential Issues**
   - What could go wrong?
   - Are there any blockers?
   - What needs clarification?

**Your Deliverable:**

Use the Write tool to create a comprehensive research report at: $SESSION_DIR/research.md

Include:
- Executive Summary (what this task is about)
- Detailed Findings (organized by topic)
- Current State (what exists now)
- Requirements (what needs to happen)
- Technical Context (libraries, patterns, conventions)
- Recommendations (suggested approach)
- Concerns & Risks (what to watch out for)
- Open Questions (anything unclear)

Be thorough! The better your research, the easier it will be for Frink to plan and Ralph to implement.
LISA_PROMPT

if ! claude \
  --dangerously-skip-permissions \
  --output-format=stream-json \
  --verbose \
  < "$PROMPT_FILE" | npx repomirror visualize; then
  echo "❌ Error: Lisa's research failed"
  exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg timestamp "$TIMESTAMP" \
   '.phases.lisa.status = "complete" |
    .phases.lisa.end_time = $timestamp |
    .phases.lisa.output_file = "research.md" |
    .transitions += [{
      "from": "lisa",
      "to": "quimby",
      "timestamp": $timestamp
    }]' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

exit 0

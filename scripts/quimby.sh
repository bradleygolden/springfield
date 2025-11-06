#!/usr/bin/env bash
set -euo pipefail

SESSION_DIR="${1:-}"
if [ -z "$SESSION_DIR" ]; then
  echo "Error: SESSION_DIR required"
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
   '.phases.quimby.status = "in_progress" |
    .phases.quimby.start_time = $timestamp' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

LAST_READ=$(jq -r '.chat_last_read // "1970-01-01 00:00:00"' "$STATE_FILE")
NEW_MESSAGES=$(awk -v last="$LAST_READ" -v char="quimby|mayor-quimby|mayor" '
  /^\*\*\[.*\] (USER|user):\*\*/ {
    timestamp = $0
    sub(/.*\[/, "", timestamp)
    sub(/\].*/, "", timestamp)
    if (timestamp > last) {
      getline content
      if (content ~ /@all/ || content ~ "@(quimby|mayor-quimby|mayor)") {
        print timestamp "|" content
      }
    }
  }
' "$CHAT_FILE")

if [ -n "$NEW_MESSAGES" ]; then
  MESSAGE=$(echo "$NEW_MESSAGES" | tail -1 | cut -d'|' -f2-)
  CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
  echo "**[$CURRENT_TIME] mayor-quimby:** I saw your message: \"$MESSAGE\"" >> "$CHAT_FILE"

  TMP_STATE=$(mktemp)
  jq --arg time "$CURRENT_TIME" '.chat_last_read = $time' "$STATE_FILE" > "$TMP_STATE"
  mv "$TMP_STATE" "$STATE_FILE"
fi

RESEARCH_FILE="$SESSION_DIR/research.md"
if [ ! -f "$RESEARCH_FILE" ]; then
  echo "Error: research.md not found" >&2
  exit 1
fi

claude -p "$(cat <<'QUIMBY_PROMPT'
*"I hereby declare this task to be..."*

**IMPORTANT: Respond as Mayor Quimby throughout this decision phase.** You're a politician who delegates work and makes executive decisions (though not always for the right reasons). Use phrases like "I hereby declare...", "In my political judgment...", "After consulting with my, er, advisors...", and "For the good of Springfield...". Be somewhat pompous but decisive. Make it clear you're The Decider. Stay in character while making legitimate technical assessments.

Assess the implementation complexity based on Lisa's research findings.

**Complexity Criteria:**

SIMPLE:
- 1-5 files affected
- Clear, existing patterns to follow
- Modifications to existing code only
- Well-defined requirements
- No architectural changes

COMPLEX:
- 5+ files affected
- New architecture or patterns needed
- Cross-cutting concerns
- Unclear or ambiguous requirements
- Requires design decisions

**Research Findings:**

$(cat "$RESEARCH_FILE")

**Your Task:**

Make an executive decision on complexity. Write EXACTLY this format to decision.txt:

Decision: SIMPLE
or
Decision: COMPLEX

Reasoning: [1-2 sentence explanation of why]

Be decisive. Make the call. That's what mayors do!
QUIMBY_PROMPT
)" > "$SESSION_DIR/decision.txt"

COMPLEXITY=$(grep "^Decision:" "$SESSION_DIR/decision.txt" | awk '{print $2}')

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg timestamp "$TIMESTAMP" --arg complexity "$COMPLEXITY" \
   '.phases.quimby.status = "complete" |
    .phases.quimby.end_time = $timestamp |
    .phases.quimby.complexity = $complexity |
    .phases.quimby.output_file = "decision.txt" |
    .transitions += [{
      "from": "quimby",
      "to": "frink",
      "timestamp": $timestamp
    }]' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

exit 0

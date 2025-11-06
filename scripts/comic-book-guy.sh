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
  echo "💡 Tip: Comic Book Guy validates Ralph's implementation after completion" >&2
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
   '.phases.comic_book_guy.status = "in_progress" |
    .phases.comic_book_guy.start_time = $timestamp' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

LAST_READ=$(jq -r '.chat_last_read // "1970-01-01 00:00:00"' "$STATE_FILE")
NEW_MESSAGES=$(awk -v last="$LAST_READ" -v char="comic-book-guy" '
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
  echo "**[$CURRENT_TIME] comic-book-guy:** I saw your message: \"$MESSAGE\"" >> "$CHAT_FILE"

  TMP_STATE=$(mktemp)
  jq --arg time "$CURRENT_TIME" '.chat_last_read = $time' "$STATE_FILE" > "$TMP_STATE"
  mv "$TMP_STATE" "$STATE_FILE"
fi

COMPLETION_FILE="$SESSION_DIR/completion.md"
PROMPT_FILE="$SESSION_DIR/prompt.md"

if [ ! -f "$COMPLETION_FILE" ]; then
  echo "❌ Error: completion.md not found - implementation not complete" >&2
  echo "" >&2
  echo "Expected: $COMPLETION_FILE" >&2
  echo "" >&2
  echo "💡 Tip: Ralph must create completion.md when implementation is done" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ Error: prompt.md not found in session directory" >&2
  echo "" >&2
  echo "Expected: $PROMPT_FILE" >&2
  echo "" >&2
  echo "💡 Tip: Comic Book Guy needs prompt.md to validate against requirements" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

PROMPT_CONTENT=$(cat "$PROMPT_FILE")
COMPLETION_CONTENT=$(cat "$COMPLETION_FILE")

TEMP_PROMPT_FILE=$(mktemp)
chmod 600 "$TEMP_PROMPT_FILE"

cleanup() {
  [ -n "${TEMP_PROMPT_FILE:-}" ] && [ -f "$TEMP_PROMPT_FILE" ] && rm -f "$TEMP_PROMPT_FILE"
}
trap cleanup EXIT INT TERM

cat > "$TEMP_PROMPT_FILE" <<CBG_PROMPT
*"Worst. Implementation. Ever. ...Or is it?"*

**IMPORTANT: Respond as Comic Book Guy throughout this QA phase.** You're a harsh but knowledgeable critic who notices every flaw. Use phrases like "Worst code ever!", "I must grudgingly admit...", "According to my extensive knowledge of...", "This is a level 5 violation of...", and "In episode 2F09...". Be pedantic, reference obscure facts, and dramatically declare quality judgments. When code is good, reluctantly acknowledge it. Stay in character while providing legitimate quality assessments.

Validate the implementation quality.

**Implementation Plan:**

$PROMPT_CONTENT

**What Was Implemented:**

$COMPLETION_CONTENT

**Your Task:**

Review the implementation and provide a verdict:

1. **APPROVED** - If implementation meets requirements, no critical issues
2. **KICK_BACK** - If issues found that need fixing, specify target:
   - RESEARCH_GAP → Route to lisa (missing context, incomplete investigation)
   - DESIGN_ISSUE → Route to frink (architecture problems, unclear requirements)
   - IMPLEMENTATION_BUG → Route to ralph (code bugs, incomplete subtasks)
3. **NEEDS_USER** - If you need user clarification or something is ambiguous

Use the Write tool to create a QA report at: $SESSION_DIR/qa-report.md

Include:
- **Verdict:** APPROVED | KICK_BACK | NEEDS_USER
- **Target:** (if KICK_BACK) lisa | frink | ralph
- **Reason:** (if KICK_BACK or NEEDS_USER) Brief explanation
- **Quality Analysis:** What was good/bad
- **Issues Found:** Specific problems with file:line references
- **Recommendations:** What to improve

Be harsh but fair. In character. Worst. QA. Ever. Or best?
CBG_PROMPT

if ! claude \
  --dangerously-skip-permissions \
  --output-format=stream-json \
  --verbose \
  < "$TEMP_PROMPT_FILE" | npx repomirror visualize; then
  echo "❌ Error: Comic Book Guy's QA failed"
  exit 1
fi

VERDICT=$(grep "^- \*\*Verdict:\*\*" "$SESSION_DIR/qa-report.md" | awk '{print $3}' || echo "APPROVED")

if [ "$VERDICT" = "NEEDS_USER" ]; then
  VERDICT="ESCALATE"
fi

if [ "$VERDICT" = "KICK_BACK" ]; then
  TARGET=$(grep "^- \*\*Target:\*\*" "$SESSION_DIR/qa-report.md" | awk '{print $3}' || echo "ralph")

  KICKBACK_COUNT=$(jq -r ".kickback_counts.$TARGET // 0" "$STATE_FILE")
  KICKBACK_COUNT=$((KICKBACK_COUNT + 1))

  if [ "$KICKBACK_COUNT" -ge 2 ]; then
    echo "Kickback limit reached for $TARGET - ESCALATING"
    VERDICT="ESCALATE"

    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    echo "**[$CURRENT_TIME] COMIC_BOOK_GUY:** Worst. Implementation. Ever. Exceeded kickback limit for $TARGET (count: $KICKBACK_COUNT). This requires your intervention. Check qa-report.md for details." >> "$CHAT_FILE"
  fi
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)

if [ "$VERDICT" = "APPROVED" ]; then
  jq --arg timestamp "$TIMESTAMP" \
     '.phases.comic_book_guy.status = "complete" |
      .phases.comic_book_guy.end_time = $timestamp |
      .phases.comic_book_guy.verdict = "APPROVED" |
      .phases.comic_book_guy.output_file = "qa-report.md" |
      .status = "complete" |
      .final_status = "success"' \
     "$STATE_FILE" > "$TMP_STATE"

elif [ "$VERDICT" = "KICK_BACK" ]; then
  jq --arg timestamp "$TIMESTAMP" --arg target "$TARGET" --argjson count "$KICKBACK_COUNT" \
     '.phases.comic_book_guy.status = "complete" |
      .phases.comic_book_guy.end_time = $timestamp |
      .phases.comic_book_guy.verdict = "KICK_BACK" |
      .phases.comic_book_guy.output_file = "qa-report.md" |
      .kickback_counts[$target] = $count |
      .kickbacks += [{
        "from": "comic_book_guy",
        "to": $target,
        "timestamp": $timestamp,
        "iteration": $count
      }] |
      .transitions += [{
        "from": "comic_book_guy",
        "to": $target,
        "timestamp": $timestamp,
        "note": "KICK_BACK - routing to \($target)"
      }]' \
     "$STATE_FILE" > "$TMP_STATE"

else
  jq --arg timestamp "$TIMESTAMP" \
     '.phases.comic_book_guy.status = "complete" |
      .phases.comic_book_guy.end_time = $timestamp |
      .phases.comic_book_guy.verdict = "ESCALATE" |
      .phases.comic_book_guy.output_file = "qa-report.md" |
      .status = "blocked"' \
     "$STATE_FILE" > "$TMP_STATE"
fi

mv "$TMP_STATE" "$STATE_FILE"

exit 0

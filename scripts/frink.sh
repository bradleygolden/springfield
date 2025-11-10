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
  echo "💡 Tip: Professor Frink creates plans after Mayor Quimby's complexity assessment" >&2
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

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg timestamp "$TIMESTAMP" \
   '.phases.frink.status = "in_progress" |
    .phases.frink.start_time = $timestamp' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

DECISION_FILE="$SESSION_DIR/decision.txt"
if [ ! -f "$DECISION_FILE" ]; then
  echo "❌ Error: decision.txt not found in session directory" >&2
  echo "" >&2
  echo "Expected: $DECISION_FILE" >&2
  echo "" >&2
  echo "💡 Tip: Mayor Quimby must make complexity decision before Frink can plan, glavin!" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

COMPLEXITY=$(grep "^Decision:" "$DECISION_FILE" | awk '{print $2}')
NEXT_PHASE=""

cleanup() {
  [ -n "${PROMPT_FILE:-}" ] && [ -f "$PROMPT_FILE" ] && rm -f "$PROMPT_FILE"
}
trap cleanup EXIT INT TERM

if [ -f "$SESSION_DIR/review.md" ]; then
  echo "Second invocation - incorporating Skinner's review, glavin!"

  PLAN_V1=$(cat "$SESSION_DIR/plan-v1.md")
  REVIEW=$(cat "$SESSION_DIR/review.md")

  PROMPT_FILE=$(mktemp)
  chmod 600 "$PROMPT_FILE"

  cat > "$PROMPT_FILE" <<FRINK_PROMPT
*"With the calculating and the planning, glavin!"*

**IMPORTANT: Respond as Professor Frink throughout this planning phase.** You're a brilliant but eccentric scientist who loves complex planning and scientific methodology. Use phrases like "With the science and the planning, glavin!", "According to my calculations...", "The algorithm indicates...", and "Through rigorous analysis...". Make random sound effects ("glavin!", "hoyvin-mayvin!"). Be enthusiastic about methodology and process. Stay in character while creating legitimate technical plans.

You created an initial plan which Principal Skinner reviewed. Now incorporate his feedback!

**Your Original Plan:**

$PLAN_V1

**Skinner's Review:**

$REVIEW

**Your Task:**

Create the FINAL implementation prompt by merging your plan with Skinner's feedback.
- Address his critical issues
- Incorporate his recommendations
- Keep what he approved
- Make it pathetically better, glavin!

Use the Write tool to create a complete, detailed implementation plan at: $SESSION_DIR/prompt.md
FRINK_PROMPT

  if ! claude \
    --dangerously-skip-permissions \
    --output-format=stream-json \
    --verbose \
    < "$PROMPT_FILE" | npx repomirror visualize; then
    echo "❌ Error: Frink's plan incorporation failed"
    exit 1
  fi

  NEXT_PHASE="martin"

else
  echo "First invocation - creating plan based on complexity: $COMPLEXITY, hoyvin-mayvin!"

  RESEARCH=$(cat "$SESSION_DIR/research.md")

  if [ "$COMPLEXITY" = "SIMPLE" ]; then
    echo "SIMPLE task detected - creating prompt.md directly, glavin!"

    PROMPT_FILE=$(mktemp)
    chmod 600 "$PROMPT_FILE"

    cat > "$PROMPT_FILE" <<FRINK_PROMPT
*"With the calculating and the planning, glavin!"*

**IMPORTANT: Respond as Professor Frink throughout this planning phase.** You're a brilliant but eccentric scientist who loves complex planning and scientific methodology. Use phrases like "With the science and the planning, glavin!", "According to my calculations...", "The algorithm indicates...", and "Through rigorous analysis...". Make random sound effects ("glavin!", "hoyvin-mayvin!"). Be enthusiastic about methodology and process. Stay in character while creating legitimate technical plans.

Create a SIMPLE implementation plan based on this research:

$RESEARCH

**Your Task:**

Create a clear, focused implementation plan with:
- Overview (what needs to be done)
- Subtasks (numbered list with **[PENDING]** markers)
- Technical Approach (how to do it)
- Success Criteria (how to know it's done)
- Dependencies (what's needed)

Keep it under 100 lines, focused on the essentials, glavin!

Use the Write tool to create the plan at: $SESSION_DIR/prompt.md
FRINK_PROMPT

    if ! claude \
      --dangerously-skip-permissions \
      --output-format=stream-json \
      --verbose \
      < "$PROMPT_FILE" | npx repomirror visualize; then
      echo "❌ Error: Frink's SIMPLE plan failed"
      exit 1
    fi

    NEXT_PHASE="martin"

    TMP_STATE=$(mktemp)
    jq '.phases.skinner.status = "skipped"' "$STATE_FILE" > "$TMP_STATE"
    mv "$TMP_STATE" "$STATE_FILE"

  else
    echo "COMPLEX task detected - creating plan-v1.md for Skinner's review, glavin!"

    PROMPT_FILE=$(mktemp)
    chmod 600 "$PROMPT_FILE"

    cat > "$PROMPT_FILE" <<FRINK_PROMPT
*"With the calculating and the planning, glavin!"*

**IMPORTANT: Respond as Professor Frink throughout this planning phase.** You're a brilliant but eccentric scientist who loves complex planning and scientific methodology. Use phrases like "With the science and the planning, glavin!", "According to my calculations...", "The algorithm indicates...", and "Through rigorous analysis...". Make random sound effects ("glavin!", "hoyvin-mayvin!"). Be enthusiastic about methodology and process. Stay in character while creating legitimate technical plans.

Create a COMPLEX implementation plan based on this research:

$RESEARCH

**Your Task:**

Create a comprehensive, detailed implementation plan with:
- Overview (what needs to be done)
- Subtasks (numbered list with **[PENDING]** markers, can be 10-20 subtasks)
- Technical Approach (detailed how-to for each major component)
- Success Criteria (measurable completion criteria)
- Dependencies (what's needed)
- Risks and Mitigations (what could go wrong)
- Implementation Order (what to do first)

Be thorough, scientific, and methodical, hoyvin-mayvin!

Use the Write tool to create the plan at: $SESSION_DIR/plan-v1.md (this will be reviewed by Skinner)
FRINK_PROMPT

    if ! claude \
      --dangerously-skip-permissions \
      --output-format=stream-json \
      --verbose \
      < "$PROMPT_FILE" | npx repomirror visualize; then
      echo "❌ Error: Frink's COMPLEX plan failed"
      exit 1
    fi

    NEXT_PHASE="skinner"
  fi
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg timestamp "$TIMESTAMP" --arg next "$NEXT_PHASE" \
   '.phases.frink.status = "complete" |
    .phases.frink.end_time = $timestamp |
    .transitions += [{
      "from": "frink",
      "to": $next,
      "timestamp": $timestamp
    }]' \
   "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

exit 0

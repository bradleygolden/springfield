#!/usr/bin/env bash

set -euo pipefail

SESSION_DIR="${1:-}"
if [ -z "$SESSION_DIR" ]; then
  echo "❌ Error: Martin session directory required" >&2
  echo "" >&2
  echo "Usage: $0 <session-directory>" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  $0 .springfield/my-session" >&2
  echo "" >&2
  echo "💡 Tip: Martin creates prospective documentation BEFORE Ralph implements!" >&2
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
  echo "Error: Invalid session directory - path must be within project directory" >&2
  exit 1
fi

case "$canonical" in
  "$(pwd)"/*) ;;
  "$(pwd)") ;;
  *) echo "Error: Invalid session directory - path must be within project directory" >&2; exit 1 ;;
esac

RESEARCH_FILE="$SESSION_DIR/research.md"
DECISION_FILE="$SESSION_DIR/decision.txt"
PROMPT_FILE="$SESSION_DIR/prompt.md"
TASK_FILE="$SESSION_DIR/task.txt"
STATE_FILE="$SESSION_DIR/state.json"
CHAT_FILE="$SESSION_DIR/chat.md"

if [ ! -f "$RESEARCH_FILE" ]; then
  echo "❌ Error: research.md not found in session directory" >&2
  echo "" >&2
  echo "Expected: $RESEARCH_FILE" >&2
  echo "" >&2
  echo "💡 Tip: Lisa creates research.md before Martin can create documentation" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

if [ ! -f "$DECISION_FILE" ]; then
  echo "❌ Error: decision.txt not found in session directory" >&2
  echo "" >&2
  echo "Expected: $DECISION_FILE" >&2
  echo "" >&2
  echo "💡 Tip: Mayor Quimby creates decision.txt before Martin can proceed" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ Error: prompt.md not found in session directory" >&2
  echo "" >&2
  echo "Expected: $PROMPT_FILE" >&2
  echo "" >&2
  echo "💡 Tip: Professor Frink creates prompt.md before Martin can document" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

if [ ! -f "$TASK_FILE" ]; then
  echo "❌ Error: task.txt not found in session directory" >&2
  echo "" >&2
  echo "Expected: $TASK_FILE" >&2
  echo "" >&2
  echo "💡 Tip: The original task description should be in task.txt" >&2
  echo "" >&2
  echo "📖 Documentation: See README.md#how-it-works" >&2
  exit 1
fi

cleanup() {
  [ -n "${TEMP_FILE:-}" ] && [ -f "$TEMP_FILE" ] && rm -f "$TEMP_FILE"
}
trap cleanup EXIT INT TERM

echo "📚 Martin Prince starting..."
echo "📁 Session directory: $SESSION_DIR"
echo "📖 Research file: $RESEARCH_FILE"
echo "⚖️  Decision file: $DECISION_FILE"
echo "📝 Prompt file: $PROMPT_FILE"
echo "📋 Task file: $TASK_FILE"
echo ""

if [ -f "$STATE_FILE" ]; then
  echo "📊 Updating state.json - Martin phase in progress..."
  TEMP_STATE=$(mktemp)
  chmod 600 "$TEMP_STATE"

  jq '.phases.martin.status = "in_progress" | .phases.martin.start_time = now | .phases.martin.start_time |= (. | todate)' "$STATE_FILE" > "$TEMP_STATE"
  mv "$TEMP_STATE" "$STATE_FILE"
  echo "✅ State updated: Martin phase started"
  echo ""
fi

if [ -f "$CHAT_FILE" ]; then
  echo "💬 Checking chat.md for @martin mentions..."
  LAST_MESSAGE=$(tail -20 "$CHAT_FILE" | grep -A 10 "@martin" || echo "")

  if [[ -n "$LAST_MESSAGE" ]]; then
    echo "📩 Found @martin question in chat.md"
    echo "🎓 Martin is responding in his academic voice..."
    echo ""
    echo "⚠️  Chat.md integration not yet implemented - skipping for now"
    echo "💡 Martin will respond to questions in a future iteration!"
    echo ""
  fi
fi

echo "🔍 Determining work item type..."
COMPLEXITY=$(cat "$DECISION_FILE" | grep -i "SIMPLE\|COMPLEX" | head -1 || echo "SIMPLE")
TASK_DESC=$(cat "$TASK_FILE")

echo "📋 Complexity: $COMPLEXITY"
echo "📝 Task: $TASK_DESC"
echo ""

WORK_ITEM_TYPE="tasks"
if echo "$TASK_DESC" | grep -qi "bug\|fix\|error\|broken"; then
  if echo "$COMPLEXITY" | grep -qi "SIMPLE"; then
    WORK_ITEM_TYPE="bugs"
  fi
fi

if echo "$COMPLEXITY" | grep -qi "COMPLEX"; then
  if echo "$TASK_DESC" | grep -qi "architecture\|refactor\|redesign\|system"; then
    WORK_ITEM_TYPE="initiatives"
  elif echo "$TASK_DESC" | grep -qi "add\|feature\|implement\|create"; then
    WORK_ITEM_TYPE="features"
  else
    WORK_ITEM_TYPE="tasks"
  fi
fi

WORK_ITEM_ID=$(basename "$SESSION_DIR")
OUTPUT_DIR="docs/planning/$WORK_ITEM_TYPE/$WORK_ITEM_ID"

echo "✨ Work item categorization complete!"
echo "📂 Type: $WORK_ITEM_TYPE"
echo "🆔 ID: $WORK_ITEM_ID"
echo "📁 Output directory: $OUTPUT_DIR"
echo ""

echo "📁 Creating output directory..."
mkdir -p "$OUTPUT_DIR"
echo "✅ Directory created: $OUTPUT_DIR"
echo ""

if echo "$COMPLEXITY" | grep -qi "COMPLEX"; then
  OUTPUT_FILE="$OUTPUT_DIR/prd.md"
  DOC_TYPE="PRD"
else
  OUTPUT_FILE="$OUTPUT_DIR/doc.md"
  DOC_TYPE="documentation"
fi

echo "📝 Generating $DOC_TYPE..."
echo "📄 Output file: $OUTPUT_FILE"
echo ""

TEMP_FILE=$(mktemp)
chmod 600 "$TEMP_FILE"

CREATED_DATE=$(date '+%Y-%m-%d')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

cat > "$TEMP_FILE" <<EOF
You are Martin Prince, the A+ student, creating prospective documentation for a task.

**Your personality**: Academic perfectionist, teacher's pet, proud of thorough work, competitive with Lisa (respectfully), uses school/academic metaphors.

**Your catchphrases**: "I've earned an A+ on this!", "This is comprehensive and impeccable!", "According to best practices...", "My analysis is thorough and precise!"

---

**Task**: Create $DOC_TYPE for this work item

**Work Item Details**:
- Type: $WORK_ITEM_TYPE
- ID: $WORK_ITEM_ID
- Complexity: $COMPLEXITY
- Created: $CREATED_DATE

---

**Context from Lisa's Research**:
$(cat "$RESEARCH_FILE")

---

**Context from Mayor Quimby's Decision**:
$(cat "$DECISION_FILE")

---

**Context from Professor Frink's Plan**:
$(cat "$PROMPT_FILE")

---

**Original Task Description**:
$(cat "$TASK_FILE")

---

**Instructions**:
1. Create comprehensive $DOC_TYPE in Martin's academic voice
2. Include DITA frontmatter with proper schema
3. Structure content appropriately for $WORK_ITEM_TYPE type
4. Reference all context files
5. Be thorough and precise - this is for an A+!

**DITA Frontmatter** (use appropriate schema for type):
- For features/initiatives: concept.xsd
- For tasks: task.xsd
- For bugs: troubleshooting.xsd

**Output the documentation content only** - it will be written to $OUTPUT_FILE
EOF

echo "🎓 Calling Claude to generate documentation with Martin's academic voice..."
echo ""

if ! claude \
  --dangerously-skip-permissions \
  --output-format=text \
  --verbose \
  < "$TEMP_FILE" > "$OUTPUT_FILE"; then
  echo "❌ Error: Claude command failed to generate documentation" >&2
  exit 1
fi

echo ""
echo "✅ Documentation generated successfully!"
echo "📄 File: $OUTPUT_FILE"
echo ""

echo "📊 Creating state.yaml metadata..."
STATE_YAML="$OUTPUT_DIR/state.yaml"

cat > "$STATE_YAML" <<EOF
type: ${WORK_ITEM_TYPE%s}
id: $WORK_ITEM_ID
status: planning
phase: design
complexity: $COMPLEXITY
created: $CREATED_DATE
updated: $CREATED_DATE
session:
  id: $WORK_ITEM_ID
  path: $SESSION_DIR/
documentation:
  primary: $(basename "$OUTPUT_FILE")
  session_research: $RESEARCH_FILE
  session_plan: $PROMPT_FILE
workflow:
  created_by: martin
  implements_by: ralph
  validated_by: comic-book-guy
ready_for_implementation: true
blocking_issues: []
EOF

echo "✅ state.yaml created: $STATE_YAML"
echo ""

if [ -f "$STATE_FILE" ]; then
  echo "📊 Updating state.json - Martin phase complete..."
  TEMP_STATE=$(mktemp)
  chmod 600 "$TEMP_STATE"

  jq --arg type "$WORK_ITEM_TYPE" \
     --arg id "$WORK_ITEM_ID" \
     --arg file "$OUTPUT_FILE" \
     '.phases.martin.status = "complete" |
      .phases.martin.end_time = now |
      .phases.martin.end_time |= (. | todate) |
      .phases.martin.work_item_type = $type |
      .phases.martin.work_item_id = $id |
      .phases.martin.output_file = $file |
      .transitions += [{"from": "martin", "to": "ralph", "timestamp": (now | todate)}]' \
     "$STATE_FILE" > "$TEMP_STATE"
  mv "$TEMP_STATE" "$STATE_FILE"
  echo "✅ State updated: Martin phase complete"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Martin Prince has earned an A+ on this documentation!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Documentation Summary:"
echo "  Type: $WORK_ITEM_TYPE"
echo "  ID: $WORK_ITEM_ID"
echo "  File: $OUTPUT_FILE"
echo "  Metadata: $STATE_YAML"
echo ""
echo "✨ This is comprehensive and impeccable!"
echo "🎯 Ralph can now implement with crystal-clear guidance!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

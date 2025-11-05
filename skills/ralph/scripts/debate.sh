#!/usr/bin/env bash

set -euo pipefail

RALPH_DIR="${RALPH_DIR:-.springfield}"
GOAL="${1:-$RALPH_DIR/prompt_debate.md}"
PROPOSAL="$RALPH_DIR/proposal.md"
CRITIQUE="$RALPH_DIR/critique.md"
FINAL="$RALPH_DIR/prompt.md"
PROPOSER_MEMORY="$RALPH_DIR/proposer_memory.md"
COUNTER_MEMORY="$RALPH_DIR/counter_memory.md"
SLEEP_DURATION="${DEBATE_SLEEP:-15}"
MAX_ROUNDS="${MAX_DEBATE_ROUNDS:-10}"

mkdir -p "$RALPH_DIR"

echo "🎯 Starting Prompt Debate Loop"
echo "📝 Goal: $GOAL"
echo "💾 Output: $FINAL"
echo "⏱️  Sleep: ${SLEEP_DURATION}s"
echo "🔄 Max rounds: $MAX_ROUNDS"
echo ""

if [ ! -f "$GOAL" ]; then
  echo "❌ Error: $GOAL not found"
  exit 1
fi

iteration=1

while [ $iteration -le $MAX_ROUNDS ]; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔄 Debate Round #$iteration ($(date '+%Y-%m-%d %H:%M:%S'))"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Proposer creates/refines proposal
  echo "💡 Proposer Agent..."
  claude --dangerously-skip-permissions --output-format=stream-json --verbose << EOF | npx repomirror visualize
You are the **Proposer Agent** in a debate loop refining an implementation prompt.

**Context Files:**
- \`$GOAL\` - The high-level objective and requirements
- \`$CRITIQUE\` - The Counter's latest critique (read if exists)
- \`$PROPOSAL\` - Your previous proposal (read if exists)
- \`$PROPOSER_MEMORY\` - Your memory/reasoning (update this)

**Your Task:**
1. Read all context files carefully
2. Address all critiques from the Counter Agent
3. Create a refined, detailed, actionable proposal
4. Write the complete proposal to \`$PROPOSAL\`
5. Update \`$PROPOSER_MEMORY\` with your reasoning and changes made

**Proposal Requirements:**
- Clear objectives and success criteria
- Specific technical approach (frameworks, patterns, architecture)
- Step-by-step implementation guidance
- Extensibility considerations (this is part of a larger system)
- Follows project conventions (check CLAUDE.md if it exists)

**Important:**
- The final prompt will be used by a coding agent to implement the feature
- Be specific but not overly prescriptive - allow implementation flexibility
- Focus on WHAT to build and WHY, not exact HOW (let the implementer decide details)

Now refine the proposal based on all feedback received.
EOF

  echo ""
  sleep 2

  # Counter critiques proposal
  echo "🤔 Counter Agent..."
  claude --dangerously-skip-permissions --output-format=stream-json --verbose << EOF | npx repomirror visualize
You are the **Counter Agent** in a debate loop reviewing implementation prompts.

**Context Files:**
- \`$GOAL\` - The high-level objective
- \`$PROPOSAL\` - The Proposer's latest proposal (must exist)
- \`$COUNTER_MEMORY\` - Your memory/reasoning (update this)

**Your Task:**
1. Read the proposal thoroughly
2. Evaluate against the goal
3. Identify gaps, ambiguities, or potential issues
4. Provide constructive critique
5. Write your critique to \`$CRITIQUE\`
6. Update \`$COUNTER_MEMORY\` with your reasoning

**What to Look For:**
- Missing requirements or edge cases
- Unclear specifications
- Architecture concerns
- Scalability or extensibility issues
- Alignment with project conventions
- Feasibility concerns

**Agreement Criteria:**
If the proposal is:
- Complete and addresses all requirements
- Clear and actionable
- Architecturally sound
- Ready for implementation

Then write **"AGREED"** as the FIRST line of \`$CRITIQUE\`, followed by:
- Summary of why you agree
- Any minor suggestions (optional)

**Important:** Be thorough but fair. The goal is a great prompt, not perfection.

Now critique the proposal.
EOF

  echo ""

  # Check for agreement
  if [ -f "$CRITIQUE" ] && head -1 "$CRITIQUE" | grep -qi "^AGREED"; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Agreement reached after $iteration rounds!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 Creating final prompt.md..."
    cp "$PROPOSAL" "$FINAL"

    cat >> "$FINAL" << 'RALPH_INSTRUCTIONS'

---

## 🤖 Ralph Loop Instructions

**Never ask questions.** Make reasonable decisions based on the plan above and project conventions.

**Each iteration:**
1. Implement one small piece
2. Update scratchpad.md with progress (in your session directory)
3. Commit working code

**When 100% done:**
1. Run `mix precommit` and fix issues
2. Create completion.md summarizing:
   - What was accomplished
   - Final state of the implementation
   - Any remaining TODOs or future work
   - Total commits made
3. This signals completion to Ralph

Start implementing now.
RALPH_INSTRUCTIONS

    echo "✅ prompt.md ready for implementation (with Ralph loop instructions)"
    echo ""
    echo "📊 Debate Summary:"
    echo "   Rounds: $iteration"
    echo "   Duration: ~$((iteration * SLEEP_DURATION))s"
    echo ""
    echo "🎉 Debate complete! Ready to hand off to implementation agent."
    exit 0
  fi

  echo "💬 No agreement yet. Counter provided feedback."
  iteration=$((iteration + 1))

  if [ $iteration -le $MAX_ROUNDS ]; then
    echo "⏳ Sleeping ${SLEEP_DURATION}s before next round..."
    echo ""
    sleep "$SLEEP_DURATION"
  fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  Max rounds ($MAX_ROUNDS) reached without agreement"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Using latest proposal as prompt.md..."
cp "$PROPOSAL" "$FINAL"

cat >> "$FINAL" << 'RALPH_INSTRUCTIONS'

---

## 🤖 Ralph Loop Instructions

**Never ask questions.** Make reasonable decisions based on the plan above and project conventions.

**Each iteration:**
1. Implement one small piece
2. Update scratchpad.md with progress (in your session directory)
3. Commit working code

**When 100% done:**
1. Run `mix precommit` and fix issues
2. Create completion.md summarizing:
   - What was accomplished
   - Final state of the implementation
   - Any remaining TODOs or future work
   - Total commits made
3. This signals completion to Ralph

Start implementing now.
RALPH_INSTRUCTIONS

echo "⚠️  prompt.md created but agents did not reach agreement"
echo "   Review manually before proceeding with implementation."
exit 0

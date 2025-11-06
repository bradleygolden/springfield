#!/usr/bin/env bash
# Meta-Ralph: Springfield improving itself
# Based on https://ghuntley.com/ralph/

set -euo pipefail

INPUT="${1:-PROMPT.md}"

if [ -z "$INPUT" ]; then
  echo "❌ Error: No prompt or file provided" >&2
  echo "" >&2
  echo "Usage: $0 [prompt-string-or-file]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $0 PROMPT.md" >&2
  echo "  $0 'Fix all bugs and improve documentation'" >&2
  echo "" >&2
  echo "💡 Tip: Meta-Ralph loops forever, improving Springfield based on your prompt" >&2
  exit 1
fi

while :; do
  if [ -f "$INPUT" ]; then
    cat "$INPUT" | claude \
      --dangerously-skip-permissions \
      --output-format=stream-json \
      | npx repomirror visualize
  else
    echo "$INPUT" | claude \
      --dangerously-skip-permissions \
      --output-format=stream-json \
      | npx repomirror visualize
  fi
done

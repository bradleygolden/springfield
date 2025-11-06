#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

user_prompt=$(echo "$input" | jq -r '.prompt // empty')

if echo "$user_prompt" | grep -qi "springfield"; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "IMPORTANT: The user mentioned 'springfield' in their prompt. You should activate the springfield skill to orchestrate the autonomous workflow. Use the Skill tool to invoke the springfield skill."
  }
}
EOF
else
  echo '{}'
fi

#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/skills/springfield/templates/multi-file"

errors=0

validate_template() {
  local template="$1"
  local basename=$(basename "$template")

  if ! head -n 1 "$template" | grep -q "^---$"; then
    echo "❌ $basename: Missing YAML frontmatter opening"
    ((errors++))
  fi

  if ! grep -q '\$schema:' "$template"; then
    echo "❌ $basename: Missing \$schema field"
    ((errors++))
  fi

  if ! grep -qE "(Martin|I've organized|Let me explain)" "$template"; then
    echo "⚠️  $basename: Missing Martin's voice"
  fi

  required_vars=$(grep -o '{[A-Z_]*}' "$template" | sort -u)
  if [ -n "$required_vars" ]; then
    echo "✓ $basename: Uses variables: $(echo "$required_vars" | tr '\n' ' ')"
  fi
}

echo "Validating templates in $TEMPLATE_DIR..."

for template in "$TEMPLATE_DIR"/*/*.md.template; do
  validate_template "$template"
done

if [ $errors -eq 0 ]; then
  echo "✅ All templates valid!"
  exit 0
else
  echo "❌ Found $errors validation errors"
  exit 1
fi

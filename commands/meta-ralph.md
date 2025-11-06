---
description: Run Springfield in a continuous self-improvement loop (Meta-Ralph - I'm learnding forever!)
argument-hint: [prompt-or-file]
allowed-tools: Bash(scripts/meta-ralph.sh:*)
---

# Meta-Ralph - Continuous Improvement Loop

*"I'm gonna loop forever!"*

Meta-Ralph runs Springfield in an infinite loop based on a prompt string or file. This is the original Ralph pattern from [Geoff Huntley's blog](https://ghuntley.com/ralph/) - dead simple eventual consistency through persistent iteration.

**Prompt:** ${1:-PROMPT.md}

**Note:** Meta-Ralph will run FOREVER until you stop him (Ctrl+C). He'll keep working on your prompt, over and over, until Springfield is perfect!

**How it works:**
1. Takes your prompt (string or file)
2. Sends it to Claude
3. Claude makes improvements
4. Repeats infinitely

**Usage examples:**
- `/springfield:meta-ralph` - Uses PROMPT.md from repo root
- `/springfield:meta-ralph my-task.md` - Reads from file
- `/springfield:meta-ralph "Fix all bugs"` - Uses prompt string directly

!scripts/meta-ralph.sh "${1:-PROMPT.md}"

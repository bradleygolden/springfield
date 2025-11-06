# Springfield Plugin

[![Version](https://img.shields.io/badge/version-1.1.1-blue.svg)](https://github.com/bradleygolden/springfield)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)]()

## Table of Contents

- [Quick Start](#quick-start)
- [What is this?](#what-is-this)
- [Installation](#installation)
- [Usage](#usage)
- [How it Works](#how-it-works)
- [Requirements](#requirements)
- [Monitoring Sessions](#monitoring-sessions)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Safety Warning](#safety-warning)
- [Philosophy](#philosophy)
- [Sources of Inspiration](#sources-of-inspiration)
- [Disclaimers](#disclaimers)
- [License](#license)

## Quick Start

**Try Springfield in 30 seconds:**

```bash
# Make sure you're in a git repository
cd your-project

# Activate Springfield with any task
echo "Add a factorial function to math.js" | claude
# Springfield auto-activates! Lisa begins research...
```

**What just happened?**

1. **Lisa** researched your codebase for relevant files
2. **Mayor Quimby** assessed complexity (SIMPLE task = no debate)
3. **Ralph** implemented the change: "Me added the function!"
4. **Comic Book Guy** validated the result: "Acceptable... barely."

**For complex tasks:**

```bash
echo "Refactor the authentication system to support OAuth2" | claude
# Complex task triggers debate between Frink and Skinner!
# Then Ralph implements with better requirements
```

**Next steps:**
- See [Examples](#examples) for detailed walkthroughs
- Read [How It Works](#how-it-works) to understand the workflow
- Check [Troubleshooting](#troubleshooting) if you run into issues

*"I'm learnding!"* - Ralph Wiggum

Autonomous workflow orchestration for Claude Code, where cartoon characters do your coding. It's like having the whole town of Springfield working on your project!

## What is this?

Springfield is a Claude Code plugin that breaks down complex tasks into phases, each handled by a different Simpsons character:

- **Lisa** 📚 - Does the research (she's the smart one)
- **Mayor Quimby** 🎩 - Decides if it's simple or complex (he's good at delegating)
- **Professor Frink** 🔬 - Makes the plan (with the science and the planning, glavin!)
- **Principal Skinner** 📋 - Reviews complex plans (pathetic work, Professor!)
- **Ralph** 🖍️ - Implements through persistent iteration (I'm learnding!)
- **Comic Book Guy** 💬 - Reviews the quality ("Worst code ever... or best?")

## Installation

From GitHub:

```bash
claude
/plugin marketplace add bradleygolden/springfield
/plugin install springfield@springfield
```

## Usage

Just tell Springfield what to do:

```bash
"springfield help me add user authentication to the API"
```

Springfield runs all phases automatically. Or run them individually:

```bash
/springfield:lisa "authentication"     # Research
/springfield:mayor-quimby              # Decide complexity
/springfield:frink                     # Plan
/springfield:skinner                   # Review plan (COMPLEX tasks only)
/springfield:ralph                     # Implement
/springfield:comic-book-guy            # Review
/springfield:watch                     # Monitor progress
```

### Advanced Flags

```bash
/springfield:lisa "task" --dry-run                 # Create session without executing
/springfield:lisa --session=SESSION_ID             # Resume specific session
/springfield:lisa --research-file=research.md      # Use existing research
/springfield:frink --plan-file=prompt.md           # Use existing plan
/springfield:frink --force                         # Skip Skinner review
/springfield:ralph --session=SESSION_ID            # Resume Ralph implementation
/springfield:watch SESSION_ID --interval=30        # Watch with custom interval
/springfield:watch --quiet                         # Minimal output
```

## How it Works

Springfield creates a `.springfield/` directory with session folders for each task (format: `MM-DD-YYYY-task-name/`). Inside you'll find:

- `state.json` - Structured session state with schema versioning
- `chat.md` - Interactive communication with characters
- `research.md` - Lisa's findings
- `decision.txt` - SIMPLE or COMPLEX
- `plan-v1.md` - Frink's initial plan (COMPLEX tasks)
- `review.md` - Skinner's plan feedback (COMPLEX tasks)
- `prompt.md` - Final implementation plan with subtasks
- `scratchpad.md` - Ralph's progress notes (updated every iteration)
- `completion.md` - "Task complete!" signal
- `qa-report.md` - Comic Book Guy's verdict

### State Management

Springfield uses structured state tracking via `state.json`:

```json
{
  "schema_version": "1.0",
  "session_id": "11-05-2025-task-name",
  "status": "in_progress",
  "current_phase": "ralph",
  "iteration_count": 42,
  "phases": {
    "lisa": { "status": "complete", "start_time": "...", "end_time": "..." },
    "ralph": { "status": "in_progress", "iteration": 42 }
  },
  "subtasks": [
    { "id": 1, "description": "...", "status": "COMPLETE", "failures": 0 }
  ],
  "transitions": [...],
  "kickbacks": [...],
  "kickback_counts": { "lisa": 0, "frink": 0, "ralph": 1 }
}
```

Use `jq` to query session state: `jq '.status' .springfield/*/state.json`

### Chat Interface

Talk to characters during execution via `chat.md`:

```markdown
**[2025-11-05 14:30:00] RALPH:**
I'm working on subtask 3! I'm learnding!

User: @ralph please add tests for auth.js

**[2025-11-05 14:32:00] RALPH:**
I'm adding tests! (re: your message about auth.js)
That's where I'm a Viking!
```

Characters check chat.md at phase start and respond if @mentioned (or if no mentions). Ralph checks every 3 iterations.

### Failure Thresholds

Ralph implements with safety limits:

- **n_fails = 3**: Max failures per subtask before marking FAILED
- **n_rounds = 500**: Max total iterations before session fails with partial completion

If Ralph hits n_rounds limit, session exits with code 1 and partial completion report in scratchpad.md.

### Kickback Routing

Comic Book Guy routes issues back to appropriate characters:

- **RESEARCH_GAP** → Lisa (missing context)
- **DESIGN_ISSUE** → Frink (architecture problems)
- **IMPLEMENTATION_BUG** → Ralph (code bugs)

**Kickback limits**: Max 2 kickbacks per character. After 2, Comic Book Guy escalates to user via chat.md.

For complex tasks, Professor Frink runs a debate loop where two AI perspectives argue until they reach consensus on the best approach. If task is COMPLEX, Skinner reviews Frink's plan before Ralph implements.

### Workflow Diagram

```mermaid
%%{init: {'theme':'dark','themeVariables': {'darkMode':'true','edgeLabelBackground':'#1e1e1e','labelColor':'#ffffff'}}}%%
graph TD
    Start([User Task]) --> Lisa[📚 Lisa: Research]
    Lisa --> |research.md| Quimby{🎩 Mayor Quimby: Decide}

    Quimby --> |SIMPLE| FrinkSimple[🔬 Frink: Simple Plan]
    Quimby --> |COMPLEX| FrinkComplex[🔬 Frink: Debate Loop]

    FrinkComplex --> |Proposer vs Counter| Consensus{Agents Agree?}
    Consensus --> |No| FrinkComplex
    Consensus --> |Yes| FrinkDone[📝 prompt.md]

    FrinkSimple --> |prompt.md| Ralph[🖍️ Ralph: Implement Loop]
    FrinkDone --> Ralph

    Ralph --> |completion.md| ComicBook[💬 Comic Book Guy: QA]

    ComicBook --> QAResult{Quality Check}
    QAResult --> |Issues Found| Kickback{What's Wrong?}
    QAResult --> |Approved| Done([✅ Task Complete])

    Kickback --> |Research Gap| Lisa
    Kickback --> |Design Issue| FrinkSimple
    Kickback --> |Implementation Bug| Ralph

    style Lisa fill:#FFE4B5,stroke:#333,color:#000
    style Quimby fill:#D8BFD8,stroke:#333,color:#000
    style FrinkSimple fill:#B0E0E6,stroke:#333,color:#000
    style FrinkComplex fill:#B0E0E6,stroke:#333,color:#000
    style Ralph fill:#FFB6C1,stroke:#333,color:#000
    style ComicBook fill:#98FB98,stroke:#333,color:#000
    style Done fill:#90EE90,stroke:#333,color:#000

    linkStyle default stroke:#fff,stroke-width:2px
```

## Requirements

- Claude Code CLI
- Node.js (for `npx` and `repomirror`)
- Bash 4.0+
- Standard Unix tools (mktemp, readlink/realpath)
- **jq** (for state.json operations) - Install: `brew install jq` (macOS) or `apt-get install jq` (Linux)

Springfield validates jq availability at session start. Without jq, state.json features are unavailable.

## Monitoring Sessions

Use the watch command to monitor Ralph's progress in real-time:

```bash
/springfield:watch                    # Watch most recent session
/springfield:watch SESSION_ID         # Watch specific session
/springfield:watch --interval=30      # Custom check interval (seconds)
/springfield:watch --quiet            # Minimal output
```

Example output:
```
=== Springfield Session Monitor ===
Session: 11-05-2025-add-authentication
Status: in_progress
Phase: ralph

[14:32:15] Ralph (Iteration 42/500)
  └─ Subtask 3/5: Update character commands **[IN_PROGRESS]**
  └─ Failures: 1/3
  └─ Recent: "I'm adding state.json tracking! I'm helping!"
```

### Exit Codes

Springfield commands use standardized exit codes for automation:

- **0**: Session completed successfully
- **1**: Session failed (n_rounds exceeded or unrecoverable error)
- **2**: User cancelled (Ctrl+C)
- **3**: State corruption detected (invalid JSON)

Use in scripts:
```bash
/springfield:watch --quiet
if [ $? -eq 0 ]; then
  echo "Success! Deploy to production"
elif [ $? -eq 1 ]; then
  echo "Failed - check logs"
fi
```

## Examples

### Example 1: Simple Task (No Debate)

**Task:** "Add a factorial function to math.js"

**What happens:**

1. **Lisa researches** (10 seconds):
   - Finds math.js in your project
   - Identifies existing function patterns
   - Creates research.md with findings

2. **Mayor Quimby decides** (5 seconds):
   - Complexity: SIMPLE
   - Decision: Skip debate, proceed to Ralph
   - Rationale: Clear requirement, no architectural decisions

3. **Ralph implements** (30 seconds):
   - Adds factorial function matching style
   - Includes basic error handling
   - Creates implementation.md

4. **Comic Book Guy validates** (15 seconds):
   - Reviews code quality
   - Checks for edge cases
   - Verdict: "Acceptable work. The recursive approach is... adequate."

**Session files created:**
```
.springfield/[session-name]/
├── state.json (tracks progress)
├── research.md (Lisa's findings)
├── implementation.md (Ralph's work)
└── validation.md (Comic Book Guy's review)
```

### Example 2: Complex Task (With Debate)

**Task:** "Refactor the authentication system to support OAuth2"

**What happens:**

1. **Lisa researches** (30 seconds):
   - Maps current auth implementation
   - Identifies dependencies
   - Documents integration points

2. **Mayor Quimby decides** (5 seconds):
   - Complexity: COMPLEX
   - Decision: Initiate Frink/Skinner debate
   - Rationale: Architectural changes, multiple approaches

3. **Frink plans** (60 seconds):
   - Proposes OAuth2 integration approach
   - Identifies required libraries
   - Creates detailed implementation steps
   - Scientific enthusiasm: "With the OAuth and the tokens, glavin!"

4. **Skinner reviews** (45 seconds):
   - Critiques Frink's plan
   - Identifies risks and issues
   - Demands revisions: "This is unacceptable! Where's your error handling?!"

5. **Frink revises** (60 seconds):
   - Addresses Skinner's feedback
   - Improves plan with better error handling
   - Adds migration strategy

6. **Skinner approves** (30 seconds):
   - Final review
   - Status: APPROVED (possibly with grumbling)
   - "Acceptable. Barely."

7. **Ralph implements** (5 minutes):
   - Follows approved plan step-by-step
   - Self-validates after each step
   - Retries if Comic Book Guy rejects
   - "Me did the OAuth thing!"

8. **Comic Book Guy validates** (30 seconds):
   - Reviews implementation quality
   - Checks against plan requirements
   - Final verdict

**Session files created:**
```
.springfield/[session-name]/
├── state.json
├── research.md (Lisa)
├── plan-v1.md (Frink's initial plan)
├── review.md (Skinner's critique)
├── plan-v2.md (Frink's revision)
├── review-v2.md (Skinner's approval)
├── prompt.md (Final implementation prompt)
├── implementation-attempt-1.md (Ralph's work)
└── validation.md (Comic Book Guy)
```

### Example 3: Resuming a Failed Session

**Scenario:** Ralph's implementation failed validation

**What happens:**

1. You see the failure:
   ```bash
   # Comic Book Guy rejected Ralph's work
   cat .springfield/my-session/state.json
   # Shows: "status": "failed", "reason": "Missing error handling"
   ```

2. Springfield automatically retries:
   - Ralph reads Comic Book Guy's feedback
   - Ralph attempts implementation again
   - Continues until success or max attempts reached

3. If max attempts reached:
   - Session state saved as "failed"
   - You can manually review `.springfield/my-session/`
   - Adjust prompt.md with more guidance
   - Resume: `echo "resume session my-session" | claude`

**No manual intervention needed** - Springfield's loop handles retries automatically!

## Troubleshooting

### Issue: "SESSION_DIR is required" error

**Symptoms:**
- Script fails immediately with error message
- No Springfield workflow activates

**Causes:**
1. Not in a git repository
2. Springfield hook not properly configured
3. Manual script invocation without arguments

**Solutions:**
```bash
# Verify you're in a git repo
git status

# Check hooks configuration
cat hooks/hooks.json | jq .

# Ensure "springfield" appears in your prompt
echo "Use springfield to add feature X" | claude
```

### Issue: Ralph stuck in infinite loop

**Symptoms:**
- Ralph keeps retrying same approach
- No progress after multiple attempts
- Session shows multiple failed attempts

**Solutions:**

1. **Check feedback in session directory:**
   ```bash
   cat .springfield/[session]/validation.md
   # See what Comic Book Guy is rejecting
   ```

2. **Review Ralph's attempts:**
   ```bash
   ls .springfield/[session]/implementation-attempt-*.md
   # Compare attempts to see if Ralph is learning
   ```

3. **Manual intervention:**
   ```bash
   # Edit the prompt with more specific guidance
   nano .springfield/[session]/prompt.md

   # Ralph will use updated prompt on next attempt
   ```

4. **Force exit if needed:**
   - Stop Claude Code process
   - Review session state
   - Delete session directory if starting over

### Issue: "jq: command not found"

**Symptoms:**
- Scripts fail with jq error
- JSON parsing errors

**Solutions:**

```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu)
sudo apt-get install jq

# Linux (RHEL/CentOS)
sudo yum install jq

# Verify installation
jq --version
```

### Issue: Springfield doesn't activate

**Symptoms:**
- You mention "springfield" but workflow doesn't start
- Regular Claude Code responds instead

**Solutions:**

1. **Verify hooks are enabled:**
   ```bash
   # Check hooks/hooks.json exists
   ls -la hooks/hooks.json

   # Verify springfield skill is registered
   cat hooks/hooks.json | jq '.skills'
   ```

2. **Check Claude Code settings:**
   - Ensure hooks are enabled in settings
   - Verify plugin directory is correct
   - Restart Claude Code

3. **Try explicit activation:**
   ```bash
   # Use the springfield skill directly
   /springfield "Your task description here"
   ```

### Issue: Character voices seem inconsistent

**Symptoms:**
- Generated content doesn't match character personality
- Ralph sounds too formal
- Frink lacks enthusiasm

**This is acceptable** - Characters maintain personality in prompts and outputs, but technical content should be clear. If technical accuracy is present, voice variations are acceptable.

### Getting More Help

If you encounter issues not covered here:

1. **Check session files:**
   ```bash
   cat .springfield/[session]/state.json | jq .
   # Review the workflow state
   ```

2. **Review logs:**
   - Check `.springfield/[session]/` for all generated files
   - Look for error messages in validation.md

3. **Report issues:**
   - Open a [GitHub Issue](https://github.com/bradleygolden/springfield/issues)
   - Include session state.json
   - Describe expected vs actual behavior
   - Note your platform (macOS/Linux)

4. **Ask for help:**
   - Start a [GitHub Discussion](https://github.com/bradleygolden/springfield/discussions)
   - Community members can assist
   - Maintainers monitor discussions

## Safety Warning

**Use at your own risk!** This plugin uses `--dangerously-skip-permissions` and executes commands autonomously. Run it in a sandboxed environment or on projects you don't mind experimenting with. Think of it like letting Ralph learn unsupervised - entertaining, but maybe not in production.

## Philosophy

Based on the [Ralph pattern](https://ghuntley.com/ralph/) - eventual consistency through iterative refinement. Ralph might not be the smartest, but he gets there eventually through small, persistent steps.

See `skills/springfield/REFERENCE.md` for the full philosophy.

## Sources of Inspiration

- [Ralph pattern by Geoffrey Huntley](https://ghuntley.com/ralph/)
- [The Denario Project: Deep knowledge AI agents for scientific discovery (arXiv:2510.26887)](https://arxiv.org/abs/2510.26887)
- [HumanLayer Claude Commands](https://github.com/humanlayer/humanlayer/tree/main/.claude/commands)

## Disclaimers

This project uses character names from The Simpsons™ for thematic purposes only. The Simpsons™ is a trademark of 20th Television and Disney. This project is not affiliated with, endorsed by, or connected to The Simpsons, Disney, or 20th Television.

The code works about as well as Springfield's nuclear power plant - it'll get the job done, but don't be surprised if there's the occasional meltdown.

## License

MIT

## Author

Bradley Golden

*"Hi, Super Nintendo Chalmers!"*

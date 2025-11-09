# Springfield Plugin

[![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](https://github.com/bradleygolden/springfield)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)]()

## Table of Contents

- [Quick Start](#quick-start)
- [What is this?](#what-is-this)
- [Installation](#installation)
- [Usage](#usage)
- [How it Works](#how-it-works)
- [Requirements](#requirements)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Glossary](#glossary)
- [Frequently Asked Questions](#frequently-asked-questions)
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
echo "springfield help me add a factorial function to math.js" | claude
# Springfield auto-activates! Lisa begins research...
```

**What just happened?**

1. **Lisa** researched your codebase for relevant files
2. **Mayor Quimby** assessed complexity (SIMPLE task = no debate)
3. **Ralph** implemented the change: "Me added the function!"
4. **Comic Book Guy** validated the result: "Acceptable... barely."

**For complex tasks:**

```bash
echo "springfield help me refactor the authentication system to support OAuth2" | claude
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
- **Martin Prince** 📝 - Creates prospective documentation (I've earned an A+ on this PRD!)
- **Ralph** 🖍️ - Implements through persistent iteration (I'm learnding!)
- **Comic Book Guy** 💬 - Reviews the quality ("Worst code ever... or best?")
- **Meta-Ralph** 🔄 - Continuous self-improvement loop (I'm gonna loop forever!)

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
/springfield:martin                    # Create PRD/documentation
/springfield:ralph                     # Implement
/springfield:comic-book-guy            # Review
/springfield:meta-ralph "task.md"      # Infinite improvement loop
```

### Advanced Flags

```bash
/springfield:lisa "task" --dry-run                 # Create session without executing
/springfield:lisa --session=SESSION_ID             # Resume specific session
/springfield:lisa --research-file=research.md      # Use existing research
/springfield:frink --plan-file=prompt.md           # Use existing plan
/springfield:frink --force                         # Skip Skinner review
/springfield:ralph --session=SESSION_ID            # Resume Ralph implementation
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

### Iteration Behavior

Ralph works iteratively until the task is complete:

- Reads the prompt.md for implementation instructions
- Updates scratchpad.md with progress after each iteration
- Creates completion.md when 100% done
- Sleeps between iterations (default: 10 seconds, configurable via SLEEP_DURATION)

Ralph will continue iterating indefinitely until completion.md appears. You can stop at any time with Ctrl+C and resume later.

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

### Martin's Prospective Documentation

Before Ralph implements anything, Martin Prince creates prospective documentation that guides the implementation. This ensures Ralph has clear requirements and acceptance criteria to follow.

**What Martin creates:**

- **COMPLEX tasks**: Full PRD (Product Requirements Document) in `/docs/planning/{type}/{id}/prd.md`
  - Requirements and acceptance criteria
  - Implementation notes and guidance
  - Test plan requirements
  - Example: OAuth2 refactor gets detailed security requirements before Ralph starts coding

- **SIMPLE tasks**: Lightweight `doc.md` with task overview
  - Quick reference for Ralph
  - Basic implementation guidance
  - Less overhead for straightforward tasks

**How it helps Ralph:**

Ralph reads Martin's documentation during implementation and follows the requirements step-by-step. Comic Book Guy later validates Ralph's work against Martin's PRD to ensure all acceptance criteria are met.

**Example workflow:**
1. Lisa researches the codebase
2. Mayor Quimby decides complexity
3. Frink creates implementation plan (COMPLEX tasks also get Skinner review)
4. **Martin writes the PRD/documentation** ← Planning happens here!
5. Ralph implements following Martin's requirements
6. Comic Book Guy validates against Martin's acceptance criteria

This planning-before-implementation approach improves code quality and reduces rework!

## Requirements

- Claude Code CLI
- Node.js (for `npx` and `repomirror`)
- Bash 4.0+
- Standard Unix tools (mktemp, readlink/realpath)
- **jq** (for state.json operations) - Install: `brew install jq` (macOS) or `apt-get install jq` (Linux)

Springfield validates jq availability at session start. Without jq, state.json features are unavailable.

## Examples

### Example 1: Simple Task (No Debate)

**Task:** "springfield help me add a factorial function to math.js"

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

**Task:** "springfield help me refactor the authentication system to support OAuth2"

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

### Example 3: Meta-Ralph - Infinite Improvement Loop

**Task:** Run Springfield in continuous self-improvement mode

**What it is:**
Meta-Ralph is the original Ralph pattern from [Geoff Huntley's blog](https://ghuntley.com/ralph/) - dead simple eventual consistency through persistent iteration. Ralph runs FOREVER, continuously improving your project based on a prompt.

**Usage:**

```bash
# Using a file (default: PROMPT.md)
/springfield:meta-ralph PROMPT.md

# Using a direct prompt string
/springfield:meta-ralph "Fix all bugs and improve documentation"

# Default (uses PROMPT.md from repo root)
/springfield:meta-ralph
```

**What happens:**

1. Meta-Ralph reads your prompt (from file or string)
2. Sends it to Claude with streaming output
3. Claude makes improvements to Springfield
4. Visualizes the output with `repomirror`
5. Loops back to step 1 infinitely

**Stop it:**
- Press Ctrl+C to stop the loop
- Meta-Ralph will keep running until you stop him manually

**Best for:**
- Continuous improvement of Springfield itself
- Long-running optimization tasks
- Iterative refinement based on a fixed goal
- Letting Ralph "learn forever"

**Note:** This is pure eventual consistency - Ralph never stops trying to make things better!

### Example 4: Resuming a Failed Session

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

## Glossary

Key terms used in Springfield:

- **Session**: A single Springfield workflow execution for one task, stored in `.springfield/MM-DD-YYYY-task-name/`
- **Kickback**: When Comic Book Guy identifies issues and routes the task back to Lisa, Frink, or Ralph for fixes
- **Debate Loop**: Professor Frink's internal process where he creates a plan that Principal Skinner reviews for complex tasks
- **Completion Signal**: The `completion.md` file created by Ralph when implementation is finished
- **SIMPLE vs COMPLEX**: Mayor Quimby's decision - SIMPLE tasks skip the debate loop and Martin, COMPLEX tasks go through Frink → Skinner → Frink → Martin
- **State.json**: The structured session state file tracking progress, phases, and transitions
- **Chat.md**: A communication channel where users can send messages to characters during execution
- **Scratchpad.md**: Ralph's working notes file, updated each iteration to track progress

## Frequently Asked Questions

### Is Springfield safe for production code?

Springfield uses `--dangerously-skip-permissions`, so it's best suited for:
- ✅ Personal projects and experiments
- ✅ Sandboxed development environments
- ✅ Feature branches (not main/production)
- ✅ Learning and exploration

Avoid using Springfield directly on:
- ❌ Production code without review
- ❌ Repositories you don't fully control
- ❌ Code with sensitive data or credentials

Think of it like Ralph at the nuclear power plant - fun for experimentation, risky for critical systems!

### How long does a Springfield workflow take?

Timing depends on task complexity:
- **SIMPLE tasks**: 1-3 minutes (Lisa → Quimby → Ralph → Comic Book Guy)
- **COMPLEX tasks**: 5-15 minutes (adds Frink/Skinner debate loop + Martin's documentation)
- **Large implementations**: Can take 30-60+ minutes depending on the task

Ralph iterates until the task is complete (creates `completion.md`). You can stop the workflow at any time with Ctrl+C.

### Can I stop Springfield mid-workflow and resume later?

Yes! Springfield sessions persist in `.springfield/` directories:

```bash
# Stop with Ctrl+C at any time

# Resume the session
/springfield:ralph --session=MM-DD-YYYY-task-name

# Or check current state
cat .springfield/MM-DD-YYYY-task-name/state.json | jq .
```

The `state.json` file tracks exactly where the workflow stopped.

### What if Springfield makes a mistake?

Springfield has built-in quality control:

1. **Comic Book Guy reviews everything** - He'll catch issues and kick back for fixes
2. **Review qa-report.md** - See detailed feedback on what's wrong
3. **Use chat.md** - Provide guidance to characters:
   ```bash
   echo "@ralph The tests are failing because..." >> .springfield/SESSION/chat.md
   ```
4. **Manual review** - Always review Ralph's commits before merging!

### Why isn't Springfield activating automatically?

Check these common issues:

1. **Not in a git repository**: Springfield requires git
   ```bash
   git status  # Should not error
   ```

2. **Hook not configured**: Verify the Springfield hook
   ```bash
   cat hooks/hooks.json | jq '.hooks[] | select(.name == "springfield")'
   ```

3. **Keyword missing**: Include "springfield" in your prompt
   ```bash
   echo "Use springfield to add a feature" | claude
   ```

4. **Plugin not installed**: Reinstall if needed
   ```bash
   /plugin install springfield@springfield
   ```

### What's the difference between running characters individually vs using the orchestrator?

**Individual commands** (`/springfield:lisa`, `/springfield:ralph`, etc.):
- Run one character at a time
- Good for debugging or resuming specific phases
- Requires manual coordination between phases
- More control, more manual work

**Orchestrator** (mention "springfield" in task):
- Runs entire workflow automatically
- Characters communicate through session files
- Handles kickbacks and retries automatically
- Less control, more automation

Most users should use the orchestrator for end-to-end workflows!

### Can Springfield work with any programming language?

Yes! Springfield is language-agnostic:
- Lisa researches your specific codebase
- Ralph adapts to your project's patterns
- Works with any git repository

Springfield has been tested with:
- JavaScript/TypeScript
- Python
- Go
- Rust
- Shell scripts
- And more!

### How do I clean up old Springfield sessions?

Sessions accumulate in `.springfield/` but are gitignored:

```bash
# View all sessions
ls -la .springfield/

# Remove old sessions (BE CAREFUL!)
rm -rf .springfield/10-15-2024-old-task

# Or keep only recent sessions
find .springfield/ -type d -mtime +30 -exec rm -rf {} \;
```

**Tip**: Keep successful sessions as documentation of what Springfield accomplished!

### What if Ralph gets stuck in a loop?

Signs Ralph is stuck:
- High iteration count (> 100)
- Same error repeating
- No progress in scratchpad.md

Solutions:
1. **Check the prompt** - May be ambiguous:
   ```bash
   cat .springfield/SESSION/prompt.md
   ```

2. **Provide guidance via chat.md**:
   ```bash
   echo "@ralph Focus on subtask 1 only, skip subtask 3" >> .springfield/SESSION/chat.md
   ```

3. **Adjust the plan** - Edit prompt.md to be more specific

4. **Start fresh** - Sometimes a new session with clearer requirements works better

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

# Springfield Plugin

*"I'm learnding!"* - Ralph Wiggum

Multi-phase autonomous workflow orchestration with debate-driven refinement, inspired by The Simpsons.

## Overview

Springfield provides a complete workflow system for autonomous code implementation:

- **Lisa** (`/springfield:lisa`) - Research phase (thorough investigation)
- **Mayor Quimby** (`/springfield:mayor-quimby`) - Decide complexity
- **Frink** (`/springfield:frink`) - Plan implementation (with science!)
- **Homer** (`/springfield:homer`) - Execute implementation (d'oh!)
- **Comic Book Guy** (`/springfield:comic-book-guy`) - QA validation (worst... or best?)
- **Ralph** (`/springfield:ralph`) - Main autonomous loop orchestrator

## Installation

### From GitHub (Recommended)

Install directly from the repository:

```bash
/plugin install https://github.com/bradleygolden/springfield.git
```

### Local Development

For local testing and development:

1. Clone the repository:
   ```bash
   git clone https://github.com/bradleygolden/springfield.git
   ```

2. Add as a local marketplace:
   ```bash
   /plugin marketplace add ./springfield
   ```

3. Install the plugin:
   ```bash
   /plugin install springfield@springfield-local
   ```

## Usage

### Quick Start

Run the full autonomous workflow:

```bash
/springfield:ralph "add user authentication to the API"
```

Ralph will automatically execute all phases (Lisa → Mayor Quimby → Frink → Homer → Comic Book Guy).

### Individual Phases

Or run phases individually:

```bash
# 1. Research (Lisa investigates)
/springfield:lisa "authentication implementation"

# 2. Decide (Mayor Quimby assesses)
/springfield:mayor-quimby

# 3. Plan (Frink strategizes)
/springfield:frink

# 4. Implement (Homer builds)
/springfield:homer

# 5. QA (Comic Book Guy critiques)
/springfield:comic-book-guy
```

## Session Management

Springfield creates session directories at `.springfield/MM-DD-YYYY-task-name/` containing:

- `research.md` - Lisa's findings
- `decision.txt` - Mayor Quimby's complexity assessment
- `prompt.md` - Frink's implementation plan
- `scratchpad.md` - Homer's work-in-progress
- `completion.md` - Homer's completion signal
- `qa-report.md` - Comic Book Guy's review

## Features

### Debate Workflow

For complex tasks, Frink invokes a debate between two perspectives to refine the implementation plan:

- Generates `prompt_debate.md` with high-level goals
- Runs `debate.sh` script for iterative refinement
- Produces final `prompt.md` for implementation

### Adaptive Loop

Comic Book Guy can kickback to earlier phases if issues are found:

- Research problems → Re-run Lisa
- Design problems → Re-run Frink
- Implementation problems → Re-run Homer

### Context Window Management

Springfield optimizes for context efficiency by:

- Breaking large tasks into smaller loops
- Using read-only subagents to prevent context conflicts
- Keeping sessions under 40% context window usage

## Philosophy

See `skills/ralph/REFERENCE.md` for the Ralph Wiggum philosophy:
- Eventual consistency
- Iterative refinement
- Autonomous decision-making

## License

MIT

## Author

Bradley Golden

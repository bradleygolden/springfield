# Springfield Plugin

*"I'm learnding!"* - Ralph Wiggum

Autonomous workflow orchestration for Claude Code, where cartoon characters do your coding. It's like having the whole town of Springfield working on your project!

## What is this?

Springfield is a Claude Code plugin that breaks down complex tasks into phases, each handled by a different Simpsons character:

- **Lisa** 📚 - Does the research (she's the smart one)
- **Mayor Quimby** 🎩 - Decides if it's simple or complex (he's good at delegating)
- **Professor Frink** 🔬 - Makes the plan (with the science and the planning, glavin!)
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
/springfield:ralph                     # Implement
/springfield:comic-book-guy            # Review
```

## How it Works

Springfield creates a `.springfield/` directory with session folders for each task. Inside you'll find:

- `research.md` - Lisa's findings
- `decision.txt` - SIMPLE or COMPLEX
- `prompt.md` - Implementation plan
- `scratchpad.md` - Ralph's progress notes
- `completion.md` - "Task complete!" signal
- `qa-report.md` - Comic Book Guy's verdict

For complex tasks, Professor Frink runs a debate loop where two AI perspectives argue until they reach consensus on the best approach.

## Requirements

- Claude Code CLI
- Node.js (for `npx` and `repomirror`)
- Bash 4.0+
- Standard Unix tools (mktemp, readlink/realpath)

## Safety Warning

**Use at your own risk!** This plugin uses `--dangerously-skip-permissions` and executes commands autonomously. Run it in a sandboxed environment or on projects you don't mind experimenting with. Think of it like letting Ralph learn unsupervised - entertaining, but maybe not in production.

## Philosophy

Based on the [Ralph pattern](https://ghuntley.com/ralph/) - eventual consistency through iterative refinement. Ralph might not be the smartest, but he gets there eventually through small, persistent steps.

See `skills/springfield/REFERENCE.md` for the full philosophy.

## Sources of Inspiration

- [Ralph pattern by Geoffrey Huntley](https://ghuntley.com/ralph/)
- [AI Agents That Matter (arXiv:2510.26887)](https://arxiv.org/abs/2510.26887)

## Disclaimers

This project uses character names from The Simpsons™ for thematic purposes only. The Simpsons™ is a trademark of 20th Television and Disney. This project is not affiliated with, endorsed by, or connected to The Simpsons, Disney, or 20th Television.

The code works about as well as Springfield's nuclear power plant - it'll get the job done, but don't be surprised if there's the occasional meltdown.

## License

MIT

## Author

Bradley Golden

*"Hi, Super Nintendo Chalmers!"*

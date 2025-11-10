# Meta-Ralph: Continuous Self-Improvement

*"I'm gonna loop forever!"*

## Overview

Meta-Ralph is an alternative mode that runs Springfield in an infinite loop for continuous self-improvement. Based on the original Ralph pattern from [Geoff Huntley's blog](https://ghuntley.com/ralph/).

## When to Use Meta-Ralph

- Continuous improvement of the codebase
- Working on open-ended optimization tasks
- Iterative refinement until manually stopped
- Tasks that benefit from multiple passes

## How It Works

1. Takes a prompt string or file path as input
2. Runs the prompt through the complete Springfield workflow
3. Repeats infinitely until stopped (Ctrl+C)
4. Each iteration builds on previous improvements
5. Uses eventual consistency to converge on optimal solution

## Script Invocation

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/meta-ralph.sh "PROMPT"
```

Or with a file path:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/meta-ralph.sh path/to/prompt-file.md
```

## Examples

### String Prompt
```bash
meta-ralph.sh "Fix all bugs and improve documentation"
```

### File Prompt
```bash
meta-ralph.sh PROMPT.md
```

### Open-Ended Improvement
```bash
meta-ralph.sh "Optimize performance and refactor for maintainability"
```

## Behavior

Each iteration runs through the full Springfield workflow:
1. Lisa researches (building on previous iteration's changes)
2. Mayor Quimby decides complexity
3. Professor Frink plans improvements
4. Principal Skinner reviews (if complex)
5. Martin Prince documents
6. Ralph implements changes
7. Comic Book Guy validates
8. Loop repeats with new context

## Important Notes

- **Runs Forever**: Meta-Ralph does NOT stop automatically. User must manually stop it (Ctrl+C).
- **Requires Monitoring**: Watch output to know when desired state is reached
- **Eventual Consistency**: May take multiple iterations to converge
- **Cost Consideration**: Consumes API tokens continuously
- **Best for**: Tasks where "good enough" is discovered through iteration

## Philosophy

Meta-Ralph embodies extreme eventual consistency. Rather than trying to plan perfectly upfront, it continuously improves through iteration. This works well for:
- Cleanup and refactoring tasks
- Incremental optimization
- Exploratory improvements
- Tasks with unclear completion criteria

## Stopping Meta-Ralph

Press `Ctrl+C` to stop the loop. The current iteration will complete before stopping.

## Comparison to Standard Springfield

| Aspect | Standard Springfield | Meta-Ralph |
|--------|---------------------|------------|
| Iterations | Single pass | Infinite loop |
| Completion | Defined endpoint | Manual stop |
| Use Case | Specific task | Continuous improvement |
| Monitoring | Minimal | Active monitoring required |

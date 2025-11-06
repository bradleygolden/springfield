# Contributing to Springfield

*"Me love when people help! It makes me smart!"* - Ralph

Thank you for considering contributing to Springfield! This document provides guidelines for contributing to the project.

## Code of Conduct

This project adheres to our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to bradley.golden@gmail.com.

## Development Setup

### Prerequisites

- Bash 4.0 or higher
- jq (JSON processor)
- Node.js and npm (for Claude Code)
- Git
- Claude Code installed and configured

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bradleygolden/springfield.git
   cd springfield
   ```

2. **Verify dependencies:**
   ```bash
   bash --version  # Should be 4.0+
   jq --version    # Should be installed
   claude --version # Should show Claude Code version
   ```

3. **Test the installation:**
   ```bash
   # Try a simple Springfield task
   echo "Add a hello function to test.js" | claude
   # If Springfield activates, you're ready!
   ```

## Making Changes

### Commit Message Convention

Springfield uses Ralph's voice for commit messages:

**Format:**
```
Me [action] [what]!

[optional details]
```

**Examples:**
- `Me added the badges to README!`
- `Me fixed the session folder bug!`
- `Me made error messages more helpful!`

**Rules:**
- Use imperative mood as Ralph
- Keep first line under 72 characters
- Reference issues: `Me fixed #123!`
- Be enthusiastic (Ralph loves helping!)

### Branch Naming

Use descriptive branch names:
- `feature/character-name` - New character additions
- `fix/bug-description` - Bug fixes
- `docs/improvement-area` - Documentation improvements
- `refactor/component-name` - Code refactoring

### Testing Your Changes

Before submitting a pull request:

1. **Test with a simple task:**
   ```bash
   echo "Add a function to example.js" | claude
   # Verify Springfield activates and completes
   ```

2. **Test with a complex task:**
   ```bash
   echo "Refactor the authentication system" | claude
   # Verify Frink/Skinner debate triggers
   ```

3. **Check state.json:**
   ```bash
   cat .springfield/*/state.json | jq .
   # Verify status updates correctly
   ```

4. **Verify character voices:**
   - Read generated files in `.springfield/*/`
   - Ensure character voices are consistent
   - Check that Ralph's tone is maintained

## Pull Request Process

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-improvement
   ```

2. **Make your changes** following the guidelines above

3. **Test thoroughly** using the testing steps

4. **Commit with Ralph's voice:**
   ```bash
   git add .
   git commit -m "Me improved the thing!"
   ```

5. **Push to your fork:**
   ```bash
   git push origin feature/my-improvement
   ```

6. **Create a pull request** with:
   - Clear description of what you changed
   - Why the change is needed
   - How you tested it
   - Reference any related issues

7. **Respond to feedback:**
   - Address review comments promptly
   - Make requested changes
   - Update your PR branch

### Pull Request Template

When creating a PR, include:

```markdown
## What This PR Does

[Brief description]

## Why This Change Is Needed

[Explanation of problem or improvement]

## How I Tested This

- [ ] Tested with simple task
- [ ] Tested with complex task
- [ ] Verified state.json updates
- [ ] Checked character voice consistency

## Related Issues

Fixes #[issue number]
```

## Adding New Characters

If you want to add a new Springfield character:

1. **Create character script:**
   - Place in `scripts/springfield-[character-name].sh`
   - Follow existing character script structure
   - Maintain character voice from The Simpsons

2. **Update hooks:**
   - Add character to `hooks/hooks.json`
   - Define when character should activate

3. **Add documentation:**
   - Update README.md with character description
   - Add character to REFERENCE.md philosophy
   - Include example usage

4. **Test integration:**
   - Verify character activates correctly
   - Test character in full workflow
   - Ensure state updates properly

## Code Style

### Bash Scripts

- Use 2-space indentation
- Quote all variables: `"$VARIABLE"`
- Check for errors: `set -euo pipefail`
- Add error handling for all operations
- Follow existing error message format

### Documentation

- Use GitHub-flavored markdown
- Keep lines under 80 characters when possible
- Use clear, descriptive headings
- Include code examples for complex concepts
- Maintain character voice for flavor text only

## Getting Help

- **Questions?** Open a [GitHub Discussion](https://github.com/bradleygolden/springfield/discussions)
- **Bug reports?** Open a [GitHub Issue](https://github.com/bradleygolden/springfield/issues)
- **Feature ideas?** Start a discussion first!

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for their contributions
- CHANGELOG.md for significant changes

Thank you for helping make Springfield better!

*"You're helping me learn! Yay learning!"* - Ralph

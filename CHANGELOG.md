# Changelog

All notable changes to Springfield will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-11-08

### Added
- Martin Prince: Prospective documentation character
- Creates PRDs and design docs BEFORE Ralph implements
- Work item categorization (initiatives, features, tasks, bugs)
- Directory structure: `/docs/planning/{type}/{work-item-id}/`
- Four documentation templates (PRD, task doc, bug doc, work item state)

### Changed
- Workflow now includes Martin between Skinner/Frink and Ralph
- Springfield skill orchestration updated for Martin integration

## [1.2.4] - 2025-11-06

### Added
- Meta-Ralph documentation to SKILL.md explaining continuous self-improvement mode

## [1.2.3] - 2025-11-06

### Changed
- Commands refactored to be informational prompts only (no script execution)
- Springfield skill now calls scripts directly via Bash tool instead of SlashCommand
- Removed bang operators from all command files
- Removed SlashCommand from Springfield skill allowed-tools
- Architecture now follows Claude Code best practices: commands = prompts, skills = execution

### Fixed
- Bang operator execution timing issue (scripts executed before command prompts loaded)
- Eliminated nested command invocation layers

## [1.2.2] - 2025-11-06

### Fixed
- Meta-Ralph command now uses `!` bang operator to properly resolve script path from plugin directory

## [1.2.1] - 2025-11-06

### Fixed
- Meta-Ralph script now includes required `-p` and `--verbose` flags for proper Claude CLI usage
- Meta-Ralph command changed from inline `!` execution to prompt-based approach to support infinite loops
- Meta-Ralph script now automatically prefixes prompts with "springfield" to ensure workflow activation

## [1.2.0] - 2025-11-06

### Added
- Meta-Ralph: Continuous self-improvement loop based on the original Ralph pattern
- Infinite iteration support for eventual consistency
- Support for both prompt strings and file-based inputs

## [1.1.1] - 2025-11-06

### Fixed
- Session folder paths now work correctly for all characters
- Character commands properly receive arguments

### Changed
- All Springfield commands now use character-appropriate voices

## [1.1.0] - 2025-11-06

### Added
- Autonomous workflow orchestration via Springfield skill
- Ralph implementation loop with automatic retry logic
- State persistence across sessions
- All characters now have distinct voice patterns

### Changed
- Springfield now operates fully autonomously
- Session management improved with proper folder structure

## [1.0.0] - 2025-11-05

### Added
- Initial release of Springfield plugin
- Lisa: Research character
- Mayor Quimby: Complexity assessment character
- Professor Frink: Complex task planning character
- Principal Skinner: Plan review character
- Ralph: Implementation character
- Comic Book Guy: Validation character
- Session-based workflow management
- Character-driven autonomous task completion

[1.2.4]: https://github.com/bradleygolden/springfield/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/bradleygolden/springfield/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/bradleygolden/springfield/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/bradleygolden/springfield/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/bradleygolden/springfield/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/bradleygolden/springfield/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/bradleygolden/springfield/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/bradleygolden/springfield/releases/tag/v1.0.0

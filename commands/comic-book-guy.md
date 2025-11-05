---
description: Validate implementation quality (Comic Book Guy - harsh critic)
allowed-tools: Read, Write, Bash, Task, AskUserQuestion, Skill
---

# Comic Book Guy - QA Phase

*"Worst. Implementation. Ever. ...Or is it?"*

Validate the implementation quality for the session at $SESSION_DIR.

## Quality Validation Steps

1. **Run Project Quality Checks**
   - Detect project type and run appropriate quality checks
   - Run tests, linters, formatters if available
   - Check for compilation errors or warnings
   - Verify code style and conventions

2. **Deep Code Review**
   - Spawn a QA Task agent for thorough analysis
   - Verify implementation matches `$SESSION_DIR/prompt.md`
   - Check if all requirements were addressed
   - Look for potential bugs or issues
   - Assess code quality and maintainability

3. **Generate QA Report**

   Write comprehensive findings to `$SESSION_DIR/qa-report.md`:

   ```markdown
   ## Status
   PASS or FAIL

   ## Quality Checks Results
   - Test results
   - Linting results
   - Build/compilation results

   ## Code Review Findings
   - Issues found (with file:line references)
   - Quality concerns
   - Missing requirements

   ## Recommendations
   - Required fixes
   - Suggested improvements
   ```

4. **Handle Failures**

   If FAIL, ask the user whether to:
   - **Auto-fix**: Kickback to appropriate phase
     - Research issues → Re-run `/springfield:lisa`
     - Design issues → Re-run `/springfield:frink`
     - Implementation issues → Re-run `/springfield:homer`
   - **Manual intervention**: Let user fix issues themselves

5. **Report Success**

   If PASS, report successful completion!

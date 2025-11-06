# TODO for Gemini

## Task: Research Claude Code CLI Console Output Capture Issue on Windows

**Context:** Claude Code CLI is unable to capture console output from Love2D (a GUI application) when running on Windows PowerShell 7 for Win11. The user can see the output immediately in their terminal, but Claude Code cannot read it through stdout/stderr capture or file redirection.

---

## Research Goals

1. **Investigate why Claude Code CLI cannot capture Love2D console output on Windows**
   - Research known issues with Claude Code CLI on Windows
   - Look into PowerShell 7 output capture limitations
   - Find if Love2D has specific console output behavior on Windows

2. **Find potential solutions or workarounds**
   - Configuration changes for Claude Code CLI
   - PowerShell settings that might help
   - Alternative methods to capture GUI application console output
   - Love2D-specific flags or configuration

3. **Document findings**
   - What is causing the issue
   - Whether it's a known limitation
   - Possible solutions or workarounds
   - If no solution exists, document that this is a permanent limitation

---

## Search Keywords to Use

- "Claude Code CLI Windows console output capture"
- "Claude Code CLI PowerShell 7 Love2D output"
- "GUI application console output PowerShell capture"
- "Love2D console output Windows not captured"
- "Claude CLI debug terminal PowerShell Win11"
- "BashOutput tool Windows GUI application"

---

## Why This is Important

Claude Code needs to run `love tests/ --console` and read the test results to complete the tech lead handover review. Without being able to capture the output, Claude cannot verify test pass/fail rates or identify bugs in the Love2D component tests.

---

**Please report back with:**
1. What you discovered about the issue
2. Any solutions or workarounds found
3. If it's a permanent limitation, document that clearly

# Technical Lead Initialization Guide
**OpenFool Love2D Migration Project**

## Quick Start Checklist

- [ ] Review current branch: `love2d-implementation`
- [ ] Check git status for uncommitted changes
- [ ] Review latest commit and recent development focus
- [ ] Run test suite to verify baseline
- [ ] Check TODO list in current work context

---

## Project Identity

**Name:** OpenFool Love2D Migration
**Original:** Kotlin/libGDX card game (Durak/Fool)
**Current:** Lua/Love2D implementation
**Status:** **MVP COMPLETE** - Fully playable game with AI
**Branch:** `love2d-implementation` → `master`

---

## Essential Commands

### Running the Game
```bash
love .
```

### Running Tests
```bash
love tests/
```

### Git Workflow
```bash
# Check status
git status

# View recent commits
git log --oneline -10

# View changes since main
git diff master...HEAD
```

---

## Project Structure (Quick Reference)

```
openfool_migration/
├── main.lua                # Game entry point
├── conf.lua                # Love2D configuration
├── src/                    # Core game (15 modules, 3,299 LOC)
│   ├── init.lua            # Game factory
│   ├── card.lua, deck.lua, player.lua
│   ├── gamestate.lua, ruleset.lua
│   ├── game_setup.lua, turn.lua, game_loop.lua
│   ├── ai_*.lua (4 modules)
│   ├── assets.lua, rendering.lua
├── tests/                  # Test suite (512+ tests, 100% passing)
│   ├── main.lua            # Test runner
│   └── *_test_love.lua     # Test files
├── android/assets/         # Game resources (17 MB)
│   ├── decks/              # Card images (4 decks)
│   ├── backgrounds/
│   ├── fonts/
│   └── ui/
└── docs/                   # Documentation
    ├── PROGRESS.md         # Current status
    ├── LOVE2D_IMPLEMENTATION_PLAN.md
    └── guides/
```

---

## Current Status (As of Oct 29, 2025)

### What's Complete ✅
- **Phase 1: Foundation** (100%)
  - Card system, Deck, Player, RuleSet
- **Phase 2: Core Game Logic** (100%)
  - Game state machine, Full AI system
- **Phase 3: Game Flow** (75%)
  - Turn management, Game setup
- **Phase 4: Love2D Integration** (60%)
  - Project structure, Asset loading, Rendering, Game loop
- **Test Coverage:** 512+ tests passing (100% core)

### What's In Progress ⚠️
- Love2D component tests (structure, assets, rendering)
- Test code review for bugs/inconsistencies (noted in latest commit)

### What's Pending 🔲
- Issue #12: Win Condition Detection
- Issue #17: Complete Love2D Testing
- Issue #18: UI System (buttons, menus)
- Issue #19: Input Handling (mouse/keyboard)
- Issue #20: Sound Effects
- Phase 5: Polish & Release

---

## Key Files to Know

### Entry Points
- `main.lua` - Application initialization, Love2D callbacks
- `src/init.lua` - Game module loader and factory
- `tests/main.lua` - Test orchestration

### Core Logic
- `src/game_loop.lua` (584 lines) - Main game orchestration
- `src/turn.lua` (310 lines) - Turn management
- `src/gamestate.lua` (236 lines) - State machine

### Critical Systems
- `src/assets.lua` - Loads all game resources
- `src/rendering.lua` - Renders cards and game board
- `src/ai_evaluation.lua` - AI decision-making core

### Documentation
- `PROGRESS.md` - Most current status report
- `LOVE2D_IMPLEMENTATION_PLAN.md` - Full roadmap with issues
- `tests/TEST_GUIDELINES.md` - Testing standards
- `docs/guides/OpenFool_to_Love2D_Translation_Guide.md` - Migration reference

---

## Development Workflow

### Before Starting Work
1. **Check current status:**
   ```bash
   git status
   git log --oneline -5
   ```

2. **Run tests to establish baseline:**
   ```bash
   love tests/
   ```
   - Expect: 512+ tests passing
   - If failures: investigate before proceeding

3. **Review active documentation:**
   - `PROGRESS.md` for latest status
   - `LOVE2D_IMPLEMENTATION_PLAN.md` for pending issues

### During Development
1. **Write tests first** (TDD approach)
   - Follow `tests/TEST_GUIDELINES.md`
   - Pattern: `{module}_test_love.lua`
   - Use global `assert(condition, message)`

2. **Implement feature**
   - Keep modules focused and single-purpose
   - Match existing code style
   - Document complex logic with comments

3. **Run tests frequently:**
   ```bash
   love tests/
   ```

4. **Test in game context:**
   ```bash
   love .
   ```

### Completing Work
1. **Final test run:**
   ```bash
   love tests/
   ```

2. **Update documentation:**
   - Mark issues complete in `LOVE2D_IMPLEMENTATION_PLAN.md`
   - Update `PROGRESS.md` with new statistics
   - Add entry to `CHANGELOG.md` if significant

3. **Commit with descriptive message:**
   ```bash
   git add .
   git commit -m "feat: Implement Issue #{N} - {Description}"
   ```

---

## Testing Standards

### Test File Structure
```lua
-- {module}_test_love.lua
require("src/{module}")

print("=== {Module} Module Tests ===\n")

print("--- Feature Group 1 ---")
assert(condition1, "Test description 1")
assert(condition2, "Test description 2")

print("\n--- Feature Group 2 ---")
-- More tests...
```

### Running Specific Test
```lua
-- In tests/main.lua, comment out other requires:
-- require("tests.card_test_love")
require("tests.your_test_love")  -- Only this one
```

### Test Expectations
- **Console output:** Verbose with group headers
- **Pass/Fail:** Explicit for each assertion
- **Summary:** Final count at end
- **Performance:** Tests should complete in < 1 second

---

## Common Issues & Solutions

### Issue: Tests Failing After Clean Checkout
**Solution:** Verify package paths in test files
```lua
package.path = package.path .. ";../?.lua;../?/init.lua"
```

### Issue: Assets Not Loading
**Solution:** Check asset paths relative to `android/assets/`
```lua
-- In assets.lua
love.graphics.newImage("android/assets/decks/rus/1s.png")
```

### Issue: Game Loop Not Responding
**Solution:** Check state machine transitions
```lua
-- In gamestate.lua
if not isValidTransition(currentState, newState) then
  error("Invalid transition")
end
```

### Issue: AI Taking Too Long
**Solution:** Profile AI evaluation performance
```lua
-- Expected: 173,000 evaluations/second
-- In ai_evaluation_performance_test_love.lua
```

---

## Key Architecture Concepts

### Game State Machine (7 States)
```
READY → DRAWING → THROWING → THROWN → BEATING → BEATEN → FINISHED
   ↑__________________________________________________|
```

### Module Dependencies
```
Card ← Deck ← Player
         ↓
    GameSetup → GameState → Turn → GameLoop
         ↓           ↓
    RuleSet    AI System (4 modules)
```

### AI Decision Flow
```
1. Evaluate hand value (ai_evaluation)
2. Attack phase (ai_attack)
3. Defense phase (ai_defense)
4. Throw additional (ai_throw_additional)
```

---

## Code Statistics (Reference)

| Metric | Value |
|--------|-------|
| Total Lua Source Files | 15 |
| Source Lines of Code | 3,299 |
| Test Files | 11+ |
| Test Lines of Code | 3,636 |
| Total Test Assertions | 512+ |
| Test Pass Rate | 100% (core) |
| Asset Files | 240 |
| Asset Size | 17 MB |

---

## Priority Matrix

### High Priority (Current Sprint)
1. Complete Love2D component tests (Issues #22-24)
2. Review test code for bugs/inconsistencies
3. Implement win condition detection (Issue #12)

### Medium Priority (Next Sprint)
1. UI system implementation (Issue #18)
2. Input handling refinement (Issue #19)
3. Documentation updates for Love2D

### Low Priority (Future)
1. Sound effects (Issue #20)
2. Polish and release preparation
3. Performance optimization

---

## Communication & Documentation

### When Completing an Issue
1. Mark complete in `LOVE2D_IMPLEMENTATION_PLAN.md`
2. Update statistics in `PROGRESS.md`
3. Add changelog entry in `CHANGELOG.md`
4. Commit with format: `feat: Implement Issue #{N} - {Title}`

### When Finding Bugs
1. Document in code comments
2. Create TODO comment with issue reference
3. Add to priority list in this document

### When Making Architectural Decisions
1. Document in `docs/guides/` if significant
2. Add comments in code explaining rationale
3. Update Translation Guide if Kotlin/Lua difference

---

## Quick Reference Links

### Documentation Files
- **Status:** `PROGRESS.md`
- **Roadmap:** `LOVE2D_IMPLEMENTATION_PLAN.md`
- **Tests:** `tests/TEST_GUIDELINES.md`, `tests/README.md`
- **Migration:** `docs/guides/OpenFool_to_Love2D_Translation_Guide.md`
- **Changelog:** `CHANGELOG.md`

### External Resources
- **Love2D Wiki:** https://love2d.org/wiki/
- **Love2D Forums:** https://love2d.org/forums/
- **Lua Reference:** https://www.lua.org/manual/5.1/

---

## Session Initialization Script

**Copy/paste at start of each session:**

```bash
# 1. Navigate to project
cd C:\Users\Kemal\Documents\Love2DRepo\openfool_migration

# 2. Check git status
git status
git log --oneline -5

# 3. Verify on correct branch
git branch

# 4. Run baseline tests
love tests/

# 5. Ready to work!
```

---

## Notes & Reminders

- **MVP is COMPLETE:** Game is fully playable
- **Test-Driven Development:** Write tests first
- **Latest commit notes incomplete testing:** Review for bugs
- **Main branch:** `master` (merge target)
- **Active branch:** `love2d-implementation`
- **CI/CD:** Travis configured for Android builds (legacy)
- **Asset path:** Always relative to `android/assets/`

---

## Version Info

**Document Version:** 1.0
**Last Updated:** Oct 29, 2025
**Project Version:** 0.3.0 (from build.gradle)
**Target Love2D Version:** 11.4+
**Lua Version:** 5.1+

---

*This document should be reviewed and updated after each major milestone or sprint.*

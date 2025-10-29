# GEMINI.md

This file provides guidance to Gemini when working with code in this repository.

## Project Overview

This is a **Lua/Love2D migration** of OpenFool, a Russian card game (Durak/Fool). The project is migrating from the original Kotlin/libGDX implementation to Love2D.

**Current Status:** MVP claimed complete but **NOT FULLY TESTED** - while the game appears to run and core logic tests pass (512+ tests), the game is **not confirmed to be fully playable**. Critical Love2D component tests are missing (Issues #22-24), meaning rendering, asset loading, and game loop integration have not been properly validated. The "MVP complete" status was premature due to lack of integration testing.

### Repository & Branch Structure

**Repository:** `https://github.com/Kedanza/OpenFool.git`
- **Fork of:** `https://github.com/trolley813/OpenFool.git` (upstream)

**Branch Workflow:**
- **Current working branch:** `love2d-implementation`
- **Push to:** `origin/love2d-implementation` (Kedanza/OpenFool)
- **Create PRs to:** `origin/master` (Kedanza/OpenFool master branch)

**⚠️ IMPORTANT:** This repo is a fork. PRs should go to **Kedanza/OpenFool:master**, NOT upstream (trolley813/OpenFool). All work stays in your fork.

**🔒 Repository Safety Configuration (Already Set Up):**
- ✅ Upstream push disabled (`no_push`) - prevents accidental pushes to trolley813/OpenFool
- ✅ GitHub CLI defaults to `Kedanza/OpenFool`
- ⚠️ GitHub default branch is `love2d-implementation` (not master) - always specify `--base master` for PRs

**⚠️ CRITICAL: Always work on `love2d-implementation` branch**
```bash
# Verify you're on the correct branch
git branch  # Should show: * love2d-implementation

# If not, switch to it
git checkout love2d-implementation

# Verify remotes are safe
git remote -v
# upstream push should show: upstream no_push (push)
```

### GitHub Issue Tracking

**All work is tracked via GitHub Issues** at `https://github.com/Kedanza/OpenFool/issues`

**⚠️ Important:** Always check GitHub Issues before starting work to:
- Avoid duplicate work
- See current priorities and REAL status (local docs are out of sync!)
- Understand dependencies between issues
- Review acceptance criteria and test requirements

## Essential Commands

### Running the Game
```bash
love .
```

### Running Tests
```bash
love tests/
```

The test suite includes 512+ assertions for core game logic with 100% pass rate. Tests use a global `assert(condition, message)` pattern defined in `tests/main.lua`.

### Running Specific Test Files
Edit `tests/main.lua` and comment out other test requires, leaving only the test you want:
```lua
-- require("tests.card_test_love")
require("tests.your_specific_test_love")
```

## Architecture Overview

### Core Game Architecture

The game follows a **state machine pattern** with 7 states:
```
READY → THROWING → THROWN → BEATING → BEATEN → DRAWING → READY
                                              ↓
                                          FINISHED
```

- **READY**: Ready for next action
- **THROWING**: Card being thrown (animation phase)
- **THROWN**: Card thrown, awaiting response
- **BEATING**: Defending card being played
- **BEATEN**: Defense successful, check for additional throws
- **DRAWING**: Players draw cards to refill hands
- **FINISHED**: Round complete

### Module Organization

The codebase is split into 15 focused modules in `src/`:

**Data Structures:**
- `card.lua` - Card representation with suit/rank enums and `beats()` logic
- `deck.lua` - Deck management with Fisher-Yates shuffle
- `player.lua` - Player hand management with 5 sorting modes

**Game State & Rules:**
- `gamestate.lua` - State machine with transition validation and callbacks
- `ruleset.lua` - Configurable game rules (deck size, special rules, team play)
- `game_setup.lua` - Initial game setup, card dealing, trump determination

**Game Flow:**
- `turn.lua` - Turn management, player rotation, card collection logic
- `game_loop.lua` - Main game loop orchestrating all mechanics (584 lines)

**AI Decision Making** (4 modules):
- `ai_evaluation.lua` - Hand value calculation with trump bonuses, rank bonuses, penalties
- `ai_attack.lua` - Attack card selection logic
- `ai_defense.lua` - Defense decision: beat vs. take cards
- `ai_throw_additional.lua` - Throw additional cards after successful attack

**Love2D Integration:**
- `assets.lua` - Loads card images, fonts, backgrounds from `android/assets/`
- `rendering.lua` - Card rendering, hand layout, table display
- `init.lua` - Central module loader and Game factory

### Key Architectural Patterns

**Factory Functions over Classes:**
Lua uses factory functions instead of classes:
```lua
function createCard(suit, rank)
    local card = { suit = suit, rank = rank }

    function card:beats(other, trumpSuit, deuceBeatsAce)
        -- Method logic
    end

    return card
end
```

**Module Loading:**
All modules are loaded through `src/init.lua` which creates a `Game` factory:
```lua
local Game = require("src.init")
local game = Game.new()
game:initialize()
```

**State Management:**
The state manager validates transitions and fires callbacks:
```lua
stateManager:setState(GameState.THROWING)  -- Only valid transitions allowed
```

**AI Evaluation System:**
The AI uses a sophisticated hand evaluation algorithm (173K evaluations/sec):
1. Calculate relative card values based on deck size
2. Add trump bonuses (+13 * RANK_MULTIPLIER)
3. Add rank multiplier bonuses (pairs, triples, quads)
4. Subtract unbalanced suit penalties
5. Subtract too-many-cards penalties
6. Return final score for decision making

### Data Flow

```
main.lua (Love2D entry)
    ↓
src/init.lua (Game factory)
    ↓
src/game_setup.lua (Initial setup)
    ↓
src/game_loop.lua (Main loop)
    ├→ src/gamestate.lua (State transitions)
    ├→ src/turn.lua (Turn logic)
    ├→ src/ai_*.lua (AI decisions)
    └→ src/rendering.lua (Display)
```

### Critical Implementation Details

**Card Beating Logic:**
A card beats another if:
1. Same suit + higher rank (with special deuce-beats-ace rule)
2. Different suit + this card is trump

**Turn End Sequence:**
1. Collect cards from table (to discard pile or defender's hand)
2. Refill all players' hands to 6 cards (attacker first, then clockwise)
3. Mark players with empty hands as "out of play" (only after deck empty)
4. Reset table and player "saidDone" flags

**Win Condition:**
- **Individual mode:** Last remaining player loses (is the "Fool")
- **Team mode:** First team with both players out wins

**First Attacker:**
Player with lowest trump card (special case: ACE is highest, not lowest)

## Testing Patterns

### Test File Structure
All test files follow this pattern:
```lua
-- tests/{module}_test_love.lua
require("src.{module}")

print("
=== Module Name Tests ===")

print("
--- Feature Category ---")
assert(condition, "Descriptive message in present tense")
assert(value == expected, "What should be true")
```

### Test Guidelines
- Use global `assert()` function (counts tests automatically)
- Group tests with headers: `=== Main ===` and `--- Category ---`
- Write messages in present tense: "Card should beat lower rank"
- Each `assert()` call increments the global test counter
- See `tests/TEST_GUIDELINES.md` for comprehensive patterns

### Adding New Tests
1. Create `tests/{module}_test_love.lua`
2. Add `require("tests.{module}_test_love")` to `tests/main.lua`
3. Run `love tests/` to verify
4. Update `PROGRESS.md` with new test counts

## Development Workflow

### Standard Development Process

1. **Verify branch:** Ensure you're on `love2d-implementation`
   ```bash
   git branch  # Should show: * love2d-implementation
   ```

2. **Check GitHub Issues** for assigned work at https://github.com/Kedanza/OpenFool/issues

3. **Review implementation plan:** Check `LOVE2D_IMPLEMENTATION_PLAN.md` for details

4. **Write tests first** (TDD approach) - critical, was skipped for Love2D components

5. **Implement feature** in appropriate module

6. **Run tests:** `love tests/`

7. **Test manually:** `love .`

8. **Commit and push:**
   ```bash
   git add .
   git commit -m "feat: Implement Issue #N - Description"
   git push origin love2d-implementation
   ```

9. **Update GitHub issue:** Check off completed acceptance criteria

10. **Update docs:** Update `PROGRESS.md` with test counts

### Creating Pull Requests

```bash
# Ensure all committed and pushed
git status
git push origin love2d-implementation

# Create PR to master (MUST specify --base master)
gh pr create --base master --title "feat: Description" --body "Closes #N"
```

**⚠️ CRITICAL:** Always use `--base master`. GitHub's default branch is `love2d-implementation`, so without this flag, the PR would target itself!

### When Fixing Bugs
1. Write a failing test that reproduces the bug
2. Fix the bug in the source
3. Verify test passes
4. Check for similar issues in related code

### Code Organization Principles
- **Single Responsibility:** Each module has one clear purpose
- **No Global State:** Use factory functions and pass dependencies
- **Explicit Dependencies:** Modules declare what they need
- **Separation of Concerns:** Game logic separate from rendering

## Important Lua/Love2D Specifics

### Lua Table Length Gotcha
Arrays with all `nil` values have `#array == 0`. Use fixed-size loops when needed:
```lua
-- WRONG: Will skip nil entries
for i = 1, #array do

-- RIGHT: Iterate all 6 slots
for i = 1, 6 do
```

### Love2D Coordinate System
Y-axis points DOWN (0 = top of screen), unlike libGDX where Y points up.

### Asset Paths
All assets loaded from `android/assets/`:
```lua
love.graphics.newImage("android/assets/decks/rus/1s.png")
```

### Card Image Naming
Cards follow pattern: `{rank}{suit}.png`
- Ranks: 1-13 (1=ACE, 11=JACK, 12=QUEEN, 13=KING)
- Suits: s=spades, d=diamonds, c=clubs, h=hearts
- Example: `13h.png` = King of Hearts

## Common Development Tasks

### Adding a New AI Behavior
1. Study existing AI modules (`src/ai_*.lua`)
2. AI decisions use `evaluateHand()` to compare hand values
3. Pattern: Simulate hand without card, evaluate delta
4. Return card index or nil

### Modifying Game Rules
Edit `src/ruleset.lua`:
- `playerCount` (2-5)
- `cardCount` (24, 32, 36, 52)
- `deuceBeatsAce` (bool)
- `teamPlay` (bool, requires 4+ players)
- `allowPass` (bool)

### Adding New Card Deck
1. Add images to `android/assets/decks/{name}/`
2. Follow naming: `1s.png` through `13h.png` + `back.png`
3. Update `src/assets.lua` to load new deck
4. Add deck selection to ruleset

### Debugging Game State
The state manager has logging:
```lua
stateManager:setLogging(true)  -- Prints all state transitions
```

Check current state:
```lua
local state = stateManager:getState()
local stateName = stateManager:getStateName(state)
```

## Project Status & Next Steps

### ⚠️ CRITICAL: MVP Status Correction

**The game is NOT confirmed to be fully playable.** While marked as "MVP complete," this status is premature:

- **Core Logic:** ✅ 512+ tests passing (card, deck, player, AI, state management)
- **Love2D Components:** ❌ **ZERO tests** (assets, rendering, game loop)
- **Integration Testing:** ❌ **Missing** (Issues #22-24)
- **Actual Gameplay:** ⚠️ **Unverified** - no validation that the game works end-to-end

The oversight occurred because the implementation was considered "done" without proper integration testing. The game may appear to run, but functionality is not validated.

### High Priority (Must Complete for True MVP)
- **Issue #22:** Love2D Project Structure Tests - verify main.lua, conf.lua, init.lua
- **Issue #23:** Asset Loading Tests - verify all cards, fonts, backgrounds load
- **Issue #24:** Rendering Tests - verify drawing functions, layouts, hit detection
- **Manual Playtesting:** Full game playthrough to identify integration bugs

### In Progress
- Code review of recent test additions (may contain bugs per latest commit notes)

### Pending
- Issue #12: Win condition detection refinement
- Issue #17: Animation system
- Issue #18: Complete UI system (buttons, menus)
- Issue #19: Input handling refinement
- Issue #20: Sound effects
- Issue #21: Documentation completion

### GitHub Issue Tracking

**All work is tracked via GitHub Issues** - this is the source of truth for project status.

Each issue includes:
- Detailed acceptance criteria
- Implementation status (PENDING, IN PROGRESS, COMPLETED)
- Required test coverage
- Dependencies on other issues
- Estimated time to complete
- Priority level (CRITICAL, HIGH, MEDIUM, LOW)

**Issue Numbering:**
- Issues #1-11: Foundation and Core Game Logic (✅ Complete)
- Issues #13-17: Love2D Integration (⚠️ Implemented but untested)
- Issues #18-21: Final Integration and Polish (🔲 Pending)
- Issues #22-24: **CRITICAL** - Love2D Component Tests (❌ Missing - blocks MVP)

**Before claiming any work as complete:**
1. Verify all acceptance criteria are met
2. Ensure tests are written and passing
3. Manual testing confirms functionality
4. GitHub issue is updated with results
5. Related documentation is updated

### Key Files for Status
- `PROGRESS.md` - Current development status (⚠️ contains premature "MVP complete" claim)
- `LOVE2D_IMPLEMENTATION_PLAN.md` - Complete roadmap with all 24 issues
- `TECH_LEAD_INIT.md` - Quick initialization guide
- **GitHub Issues** - Source of truth for current work and priorities

## Migration Context

This project is a **translation from Kotlin/libGDX to Lua/Love2D**. The original implementation is preserved in `core/`, `android/`, `desktop/`, and `ios/` directories. The new Lua implementation is in `src/` and follows the patterns documented in `docs/guides/OpenFool_to_Love2D_Translation_Guide.md`.

Key translation principles:
- Kotlin classes → Lua factory functions
- Enums → tables with constant values
- libGDX Scene2D → Love2D draw callbacks
- Event listeners → direct function calls
- Null safety → explicit nil checks

## Repository Navigation

- `src/*.lua` - All game logic modules
- `tests/*_test_love.lua` - Test files
- `android/assets/` - Game resources (images, fonts)
- `main.lua` - Love2D entry point
- `conf.lua` - Love2D configuration
- `docs/guides/` - Implementation guides

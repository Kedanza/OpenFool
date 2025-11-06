# Prioritized Task List - OpenFool Love2D Migration

**Generated:** 2025-10-31
**Branch:** `love2d-implementation`
**Current Status:** ⚠️ MVP Cannot Be Confirmed Without Win Condition

---

## 🔴 CRITICAL PRIORITY - BLOCKS MVP

### 1. Implement Win Condition Detection (Issue #12) ⏱️ 3-4 hours
**Why Critical:** **BLOCKS MVP** - Game cannot be considered "playable" without win/lose detection.

**Current Status:** Win condition logic partially exists in `src/turn.lua` but not fully implemented or tested.

**Tasks:**
- [ ] Review existing `isGameOver()` and `determineWinner()` in `src/turn.lua`
- [ ] Implement solo mode win detection (last player remaining = fool/loser)
- [ ] Implement team mode win detection (first team with both players out = winner)
- [ ] Add win/lose screen display in game loop
- [ ] Create comprehensive tests in `tests/turn_test_love.lua` or new test file
- [ ] Test in actual gameplay (play until game ends)
- [ ] Verify winner/loser is correctly identified
- [ ] Close GitHub Issue #12

**Acceptance Criteria:**
- [ ] Game detects when only 1 player remains (solo mode)
- [ ] Game detects when one team is fully out (team mode)
- [ ] Correct winner/loser identified and displayed
- [ ] Game ends gracefully without crashes
- [ ] At least 20 test assertions for win conditions

**Command to test:**
```bash
powershell -Command "Start-Process -FilePath 'C:\Program Files\LOVE\lovec.exe' -ArgumentList 'tests/', '--console' -NoNewWindow -Wait"
```

**⚠️ MVP BLOCKED until this is complete!**

---

### 2. Manual Playtest to Verify MVP ⏱️ 1-2 hours
**Why Critical:** Confirms game actually works end-to-end after win condition implemented.

**Dependencies:** Task #1 (Win Condition) MUST be complete first

**Tasks:**
- [ ] Complete `MANUAL_PLAYTEST_CHECKLIST.md` top to bottom
- [ ] Play 3 full games start to finish
- [ ] Verify win condition triggers correctly
- [ ] Document all bugs found (critical vs minor)
- [ ] Confirm or reject MVP status
- [ ] Update GitHub Issue #20 with results

**Command to run game:**
```bash
love .
```

**Success Criteria:**
- [ ] Can complete full game from start to win/lose
- [ ] All core mechanics work as expected
- [ ] AI opponents function reasonably
- [ ] Win condition displays correctly

**If FAILS:** Fix critical bugs before any other work!

---

### 3. Document Complete Test Results ⏱️ 30 minutes
**Why Critical:** Need accurate test data to know project status.

**Tasks:**
- [ ] Run full test suite and save to logs:
  ```bash
  cmd.exe /c "lovec tests/ > logs\2025-10-31_run1.txt 2>&1"
  ```
- [ ] Read complete output (not truncated)
- [ ] Count exact pass/fail numbers for all modules
- [ ] Update PROGRESS.md with real numbers
- [ ] Remove "functional" or "unknown" test statuses
- [ ] Document which tests are failing and why

**Success Criteria:**
- [ ] Know exact test count: X/Y passing
- [ ] All test failures documented
- [ ] PROGRESS.md reflects reality

---

## 🟡 HIGH PRIORITY - After MVP Confirmed

### 4. Investigate Asset Loading Test Failures ⏱️ 2-3 hours
**Why Important:** All 52 card images fail to load during tests.

**Current Status:** Tests show warnings but assets may load fine in actual game.

**Tasks:**
- [ ] Verify asset paths in `src/assets.lua` are correct
- [ ] Check if `android/assets/decks/rus/*.png` files exist
- [ ] Test asset loading in actual game (run `love .` and check console)
- [ ] Determine if failures are test environment limitation vs actual bug
- [ ] If test limitation: Document in test file, mark as expected
- [ ] If actual bug: Fix asset paths and verify all 52 cards load
- [ ] Update GitHub Issue #14 status

**Command to check:**
```bash
love .  # Check console for asset warnings
```

**Success Criteria:**
- [ ] Understand why tests fail
- [ ] Game loads all assets successfully when running
- [ ] Test expectations match reality

---

### 5. Add Game Loop Unit Tests ⏱️ 4-5 hours
**Why Important:** Core component (584 lines) has zero test coverage.

**Tasks:**
- [ ] Create `tests/game_loop_test_love.lua`
- [ ] Test state machine transitions:
  - READY → THROWING → THROWN → BEATING → BEATEN → DRAWING → READY
  - READY → FINISHED
  - Error cases (invalid transitions)
- [ ] Test AI timer system (pendingAIAction, aiTimer)
- [ ] Test human vs AI turn handling
- [ ] Test game over detection integration
- [ ] Aim for 50+ test assertions
- [ ] Target 70%+ code coverage of `src/game_loop.lua`

**Success Criteria:**
- [ ] At least 50 assertions covering game loop logic
- [ ] All 7 game states tested
- [ ] State transitions verified
- [ ] AI timing logic tested

---

### 6. Input Handling Refinement (Issue #16) ⏱️ 3-4 hours
**Status:** Partially implemented in `main.lua`

**Tasks:**
- [ ] Review existing mouse/keyboard handling
- [ ] Add keyboard shortcuts (1-6 for card selection)
- [ ] Improve click detection accuracy
- [ ] Add visual feedback for invalid moves
- [ ] Add card hover effects
- [ ] Test on different screen resolutions
- [ ] Update GitHub Issue #16

---

## 🟢 MEDIUM PRIORITY - Polish & Features

### 7. Menu System (Issue #19) ⏱️ 6-8 hours

**Tasks:**
- [ ] Design main menu layout
- [ ] Implement "New Game" button
- [ ] Implement "Settings" menu
- [ ] Add RuleSet configuration UI (player count, deck size, rules)
- [ ] Add "Quit" button
- [ ] Create screen management system
- [ ] Test menu navigation
- [ ] Close GitHub Issue #19

---

### 8. Animation System (Issue #17) ⏱️ 4-6 hours

**Tasks:**
- [ ] Add card movement tweens
- [ ] Add card flip animations
- [ ] Add smooth hand reorganization
- [ ] Add visual feedback animations
- [ ] Implement tween library or custom interpolation
- [ ] Close GitHub Issue #17

---

### 9. Sound Effects (Issue #20 - partial) ⏱️ 3-4 hours

**Tasks:**
- [ ] Find/create card dealing sound
- [ ] Find/create card flip sound
- [ ] Find/create win/lose sounds
- [ ] Implement audio loading in `src/assets.lua`
- [ ] Add sound trigger points
- [ ] Add volume controls

---

## 🔵 LOW PRIORITY - Documentation & Cleanup

### 10. Documentation Updates (Issue #21) ⏱️ 2-3 hours

**Tasks:**
- [ ] Update README.md with Love2D instructions
- [ ] Document game controls
- [ ] Document RuleSet options
- [ ] Add screenshots/GIFs
- [ ] Update CHANGELOG.md
- [ ] Close GitHub Issue #21

---

### 11. Code Quality & Performance ⏱️ 2-3 hours

**Tasks:**
- [ ] Remove debug print statements
- [ ] Optimize rendering if needed
- [ ] Profile memory usage
- [ ] Clean up unused code
- [ ] Add code comments

---

## ⚠️ BLOCKERS & DEPENDENCIES

### Current Blockers:
1. **🔴 Win Condition NOT Implemented** - **BLOCKS MVP COMPLETELY**
2. **Asset Loading Tests Failing** - Blocks proper testing validation
3. **Game Loop Has No Tests** - Cannot verify core integration

### Dependency Chain:
```
Win Condition (Critical #1) 🔴 BLOCKS EVERYTHING
    └─> Manual Playtest (Critical #2)
        └─> If PASS: Continue to High Priority
        └─> If FAIL: Fix bugs, retry playtest

Test Documentation (Critical #3)
    └─> Accurate status reporting

Asset Investigation (High #4)
    └─> Proper Love2D component testing

Game Loop Tests (High #5)
    └─> Confidence in integration
```

---

## 📊 Estimated Timeline

**Week 1: MVP Completion (CRITICAL)**
- Day 1-2: Implement win condition (#1) - 3-4 hours
- Day 3: Manual playtest (#2) - 1-2 hours
- Day 4: Document test results (#3) - 30 mins
- Day 5: Fix any critical bugs found
- **Goal:** Confirm true MVP status

**Week 2: Testing & Investigation (HIGH)**
- Asset loading investigation (#4) - 2-3 hours
- Game loop tests (#5) - 4-5 hours
- Input handling (#6) - 3-4 hours
- **Goal:** Solid test coverage

**Week 3-4: Features (MEDIUM)**
- Menu system (#7) - 6-8 hours
- Animation system (#8) - 4-6 hours
- Sound effects (#9) - 3-4 hours
- **Goal:** Polished game experience

**Week 5: Polish (LOW)**
- Documentation (#10) - 2-3 hours
- Code quality (#11) - 2-3 hours
- **Goal:** Release-ready

**Total:** 33-48 hours (assuming no major bugs)

---

## 🎯 Definition of Done

### MVP Requirements (MUST HAVE):
- [x] Core game logic: 512/512 tests passing ✅
- [x] Love2D integration: Game runs ✅
- [x] AI opponents: Functional ✅
- [ ] **Win condition: Implemented and tested** ❌ **BLOCKING**
- [ ] Manual playtest: 3 games completed successfully ❌
- [ ] No critical bugs ❌ (Unknown until playtest)

### Post-MVP (NICE TO HAVE):
- [ ] Menu system
- [ ] Animations
- [ ] Sound effects
- [ ] Full test coverage
- [ ] Documentation complete

---

## 📝 Quick Command Reference

```bash
# Run tests (direct output)
powershell -Command "Start-Process -FilePath 'C:\Program Files\LOVE\lovec.exe' -ArgumentList 'tests/', '--console' -NoNewWindow -Wait"

# Run tests (save to logs)
cmd.exe /c "lovec tests/ > logs\2025-10-31_run1.txt 2>&1"

# Read test log
cat logs/2025-10-31_run1.txt

# Run game
love .

# Check git status
git status
git log --oneline -10

# GitHub issues
gh issue list --repo Kedanza/OpenFool
gh issue view 12 --repo Kedanza/OpenFool
```

---

## ⚡ START HERE

**IF YOU'RE READING THIS, DO THIS FIRST:**

1. **Implement Win Condition (Issue #12)** - Nothing else matters until this is done
2. **Run Manual Playtest** - Verify game actually works
3. **Document Results** - Update PROGRESS.md with truth

**DO NOT:**
- Add new features before MVP confirmed
- Close Issue #18 as "MVP complete" without win condition
- Skip manual playtesting

---

**Last Updated:** 2025-10-31
**Next Review:** After win condition implemented and playtested

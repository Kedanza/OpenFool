# Manual Playtest Checklist - OpenFool Love2D

**Purpose:** Verify the game is actually playable end-to-end before confirming MVP status

**Date:** 2025-10-31
**Tester:** _________________
**Branch:** `love2d-implementation`

---

## Pre-Test Setup

- [ ] Verify on correct branch: `git branch` shows `* love2d-implementation`
- [ ] Latest code pulled: `git pull origin love2d-implementation`
- [ ] No uncommitted changes: `git status` is clean
- [ ] Run command: `love .`
- [ ] Game window opens without crashes

---

## Phase 1: Game Initialization ✅/❌

### Assets Loading
- [ ] Game window displays green felt background
- [ ] All card images visible (no missing textures)
- [ ] Card back image displays correctly
- [ ] Suit symbols render properly (♠ ♥ ♣ ♦)
- [ ] Fonts load correctly (no default font fallback)
- [ ] No error messages in console about missing assets

### Initial Game State
- [ ] 4 players initialized (Player 1-4)
- [ ] Each player has 6 cards dealt
- [ ] Deck shows remaining cards count
- [ ] Trump card displayed and visible
- [ ] Trump suit indicator visible
- [ ] First attacker determined correctly (player with lowest trump)

**Notes:**
```


```

---

## Phase 2: Core Gameplay Loop ✅/❌

### Player 1 (Human) Turn - Attack
- [ ] Can select cards from hand (mouse click)
- [ ] Selected card highlights/indicates selection
- [ ] Can throw valid card to table
- [ ] Invalid cards are rejected with feedback
- [ ] Card animates/moves to table area
- [ ] Game state advances to "THROWN"

### AI Defender Response
- [ ] AI defender takes reasonable time (~1.5s) to "think"
- [ ] AI attempts to beat the card OR takes cards
- [ ] If beating: Valid beating card is played
- [ ] If taking: Cards go to defender's hand
- [ ] Game state advances correctly

### Additional Cards Phase
- [ ] Attackers can throw additional cards (matching ranks)
- [ ] Non-matching rank cards are rejected
- [ ] Defender can beat additional cards
- [ ] "Done" button/action ends the phase
- [ ] Cards collected appropriately (discard pile or defender hand)

### Drawing Phase
- [ ] Players refill hands to 6 cards
- [ ] Drawing order correct (attacker first, clockwise)
- [ ] Deck count decreases appropriately
- [ ] Trump card remains visible until deck empty
- [ ] Players with 0 cards marked as "out of play" (only when deck empty)

**Notes:**
```


```

---

## Phase 3: AI Behavior ✅/❌

### AI Attack Logic
- [ ] AI players throw reasonable cards (not always highest)
- [ ] AI considers hand composition (prefers throwing pairs/duplicates)
- [ ] AI throws additional cards when beneficial
- [ ] AI says "done" when appropriate

### AI Defense Logic
- [ ] AI beats cards when it has valid cards
- [ ] AI takes cards when hand is weak
- [ ] AI doesn't waste high cards on low attacks
- [ ] AI decision time feels natural (~1.5s)

### AI Strategic Behavior
- [ ] AI doesn't make obviously bad plays
- [ ] AI protects trump cards when appropriate
- [ ] AI throws cards efficiently in endgame
- [ ] AI behavior differs by difficulty (if implemented)

**Notes:**
```


```

---

## Phase 4: Game Rules Enforcement ✅/❌

### Card Beating Rules
- [ ] Same suit, higher rank beats lower rank
- [ ] Trump card beats non-trump of different suit
- [ ] Non-trump cannot beat trump
- [ ] Ace is highest rank (13 > 12 > ... > 2 > 1)
- [ ] Deuce-beats-ace rule works (if enabled in ruleset)

### Turn Management
- [ ] Turn rotates correctly (clockwise)
- [ ] Defender becomes next attacker after successful defense
- [ ] Attacker after defender takes cards stays the same
- [ ] "Out of play" players are skipped in rotation

### Win Condition
- [ ] Game detects when only 1 player remains
- [ ] Last player is declared "Fool" (loser)
- [ ] Game ends appropriately
- [ ] Winner/loser displayed correctly

**Notes:**
```


```

---

## Phase 5: User Interface ✅/❌

### Visual Feedback
- [ ] Card states clear (in hand, on table, face down)
- [ ] Current attacker/defender indicated
- [ ] Game state visible (READY, THROWING, BEATEN, etc.)
- [ ] Trump suit prominently displayed
- [ ] Player hands organized and readable

### Input Handling
- [ ] Mouse clicks register reliably
- [ ] Card selection feels responsive
- [ ] No unintended double-clicks
- [ ] Keyboard shortcuts work (ESC to quit, F11 fullscreen)
- [ ] Can interact with all UI elements

### Error Handling
- [ ] Invalid moves show clear error message
- [ ] Game doesn't crash on invalid input
- [ ] No silent failures (actions always have feedback)

**Notes:**
```


```

---

## Phase 6: Edge Cases & Stress Tests ✅/❌

### Empty Deck Scenarios
- [ ] Players can't draw when deck is empty
- [ ] Players with 0 cards marked "out of play"
- [ ] Game continues with remaining players
- [ ] Win condition triggers correctly

### Full Hand Scenarios
- [ ] Players with 6 cards behave correctly
- [ ] Defender can take 6 attack cards (full hand of 12)
- [ ] Hand display doesn't overflow/clip

### State Transitions
- [ ] All state transitions feel smooth
- [ ] No stuck states (game never freezes)
- [ ] Can complete full game without crashes

**Notes:**
```


```

---

## Phase 7: Performance & Stability ✅/❌

### Performance
- [ ] Game runs at 60 FPS (use F9 if debug available)
- [ ] No stuttering during card animations
- [ ] AI thinking time doesn't freeze game
- [ ] Smooth gameplay throughout

### Stability
- [ ] Play 3 full games without crash
- [ ] No memory leaks (memory usage stable)
- [ ] No visual glitches or artifacts
- [ ] Console shows no error messages

**Notes:**
```


```

---

## CRITICAL BUGS FOUND

List any game-breaking bugs that prevent MVP status:

1.
2.
3.

---

## MINOR ISSUES FOUND

List non-critical issues (polish, UX improvements):

1.
2.
3.

---

## MVP STATUS DETERMINATION

### ✅ MVP CONFIRMED if:
- [ ] Game completes end-to-end without crashes
- [ ] All core gameplay mechanics work
- [ ] AI opponents function reasonably
- [ ] Game rules enforced correctly
- [ ] Win condition detected and displayed

### ❌ MVP NOT ACHIEVED if:
- [ ] Game crashes during normal play
- [ ] Critical bugs block game completion
- [ ] AI completely broken/non-functional
- [ ] Major game rules violations
- [ ] Cannot complete a full game

---

## FINAL VERDICT

**MVP Status:** [ ] CONFIRMED  [ ] NOT CONFIRMED

**Tester Signature:** _________________

**Date Completed:** _________________

**Overall Notes:**
```




```

---

## Next Steps Based on Results

**If MVP CONFIRMED:**
1. Update PROGRESS.md to officially confirm MVP
2. Close Issue #20 (Testing and Polish) as baseline complete
3. Begin work on Issue #12 (Win Condition refinement)
4. Plan menu system (Issue #19)

**If MVP NOT CONFIRMED:**
1. Document all critical bugs in GitHub issues
2. Prioritize bug fixes before any new features
3. Re-run this checklist after fixes
4. Update PROGRESS.md to reflect "MVP IN PROGRESS"

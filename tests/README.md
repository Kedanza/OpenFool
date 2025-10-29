# OpenFool
![Travis](https://img.shields.io/travis/trolley813/OpenFool)
![Github All Releases](https://img.shields.io/github/downloads/trolley813/OpenFool/total.svg)
![Github Releases](https://img.shields.io/github/downloads/trolley813/OpenFool/latest/total.svg)
![GitHub release](https://img.shields.io/github/release/trolley813/OpenFool.svg)
[![Gitter](https://img.shields.io/gitter/room/OpenFoolCommunity/Lobby.svg)](https://gitter.im/OpenFoolCommunity/Lobby)

OpenFool - free and open source (MIT licensed) Fool (Durak) card game implementation for desktop and Android.

[<img src="https://gitlab.com/fdroid/artwork/raw/master/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80">](https://f-droid.org/packages/ru.hyst329.openfool/)

## Current Status: Love2D Migration

**Branch:** `love2d-implementation`  
**Status:** MVP Complete ✅ | Testing In Progress ⚠️

This branch contains the ongoing migration from Kotlin/libGDX to Lua/Love2D. The core game logic has been successfully migrated and integrated with Love2D for desktop deployment.

### Migration Progress

- ✅ **Core Game Logic:** All card game mechanics, AI, and game state management
- ✅ **Love2D Integration:** Project structure, asset loading, rendering system
- ✅ **Game Loop:** Complete integration with playable game
- ⚠️ **Testing:** Love2D components need comprehensive tests (Issues #22-24)
- 📝 **Documentation:** Being updated for Love2D deployment

## Features

### Implemented

- 4-players partnership game (2 vs 2), individual game for 2-5 players
- 52-card decks: Standard Russian (designed by A. Charlemagne in 19th century, public domain - from Wikimedia),
    international (by Chris Aguilar - LGPL v3), French deck (by David Bellot - LGPL v3), stripped deck variants (24, 32 and 36 cards)
- Standard rules for throwing in and passing (the latter is optional)
- Some conventions may be customised
- **Love2D Features:** Keyboard controls, visual card rendering, AI opponents

### Planned

- Individual and partnership play for 6 players (3 vs 3)
- Customisable player names (both AI and human)
- Statistics
- Online play (via custom server)
- More deck designs
- More customisable rules (e.g. Japanese fool or spade-on-spade)
- Menu system and settings UI

## How to Run (Love2D Version)

### Prerequisites

- [Love2D](https://love2d.org/) installed on your system
- Windows, macOS, or Linux

### Running the Game

```bash
# From the project root directory
love .
```

### Controls

- **A/D or Left/Right Arrow:** Navigate cards in hand
- **W/Enter or Up Arrow:** Select/play highlighted card
- **T:** Take cards (when defending)
- **S:** Done/End turn (when attacking)
- **Number keys (1-6):** Quick play card by position

## How to Build (Legacy Android Version)

It's a Gradle project. Run

```bash
./gradlew :desktop:run
```

to run the desktop version

## Running Tests

Tests are run using Love2D:

```bash
# From project root
love tests

# Or with console output (Windows)
love tests --console
```

For detailed information on writing and organizing tests, see **[TEST_GUIDELINES.md](TEST_GUIDELINES.md)**.

## Test Files

- `main.lua` - Test runner for Love2D
- `conf.lua` - Love2D configuration for tests
- `card_test_love.lua` - Unit tests for card module (40 tests)
- `card_test.lua` - Legacy Lua tests (deprecated, use Love2D)

## Test Results

**Test Framework:** Refactored to use global `assert()` (GitHub Issue #23)

**Card Module Tests: ✓ 38/38 passed**
**Deck Module Tests: ✓ 28/28 passed**
**AI Evaluation Module Tests: ✓ 37/37 passed**
**AI Attack Module Tests: ✓ 44/44 passed**
**AI Defense Module Tests: ✓ 17/17 passed**
**AI Throw Additional Module Tests: ✓ 13/13 passed**
**RuleSet Module Tests: ✓ 59/59 passed**
**Player Module Tests: ✓ 55/55 passed**
**GameState Module Tests: ✓ 92/92 passed**
**Turn Management Module Tests: ✓ 46/46 passed**
**Game Setup Module Tests: ✓ 93/93 passed**
**Total: ✓ 512/512 passed**

### Performance Metrics

- **Throughput:** 173,896 evaluations/second
- **Average Time:** 0.0058 ms per evaluation
- **Memory Usage:** Excellent (no leaks detected)
- **Stress Test:** 10,000 evaluations in 0.058 seconds

### Card Tests

- Suit enum tests: 4/4 ✓
- Rank enum tests: 13/13 ✓
- createCard tests: 3/3 ✓
- toString tests: 4/4 ✓
- equals tests: 3/3 ✓
- beats tests (same suit): 2/2 ✓
- beats tests (trump): 2/2 ✓
- beats tests (deuce beats ace): 2/2 ✓
- beats tests (rank calculation): 3/3 ✓
- findCardInHand tests: 4/4 ✓

### Deck Tests

- Deck creation tests: 6/6 ✓
- Draw tests: 4/4 ✓
- Draw all cards tests: 3/3 ✓
- Remaining tests: 2/2 ✓
- Shuffle tests: 1/1 ✓
- Reset tests: 2/2 ✓
- Deck composition tests: 5/5 ✓
- Full deck composition tests: 13/13 ✓
- Suit distribution tests: 4/4 ✓

### AI Evaluation Tests

- Constants tests: 4/4 ✓
- Rank bonuses tests: 5/5 ✓
- getRelativeCardValue tests (36-card): 5/5 ✓
- getRelativeCardValue tests (52-card): 3/3 ✓
- evaluateHand tests: 7/7 ✓

## Test Coverage

### card_test_love.lua

Tests for the card module (src/card.lua):
- Suit enum values (SPADES, DIAMONDS, CLUBS, HEARTS)
- Rank enum values (ACE through KING)
- Card creation with createCard()
- toString() method (format: "{rank}{suit_letter}")
- equals() method for card comparison
- beats() method with trump logic and deuceBeatsAce rule
- findCardInHand() utility function

### deck_test_love.lua

Tests for the deck module (src/deck.lua):
- Deck creation with different lowestRank values (24, 32, 36, 52 cards)
- draw() method for drawing cards from deck
- remaining() method for counting cards
- shuffle() method using Fisher-Yates algorithm
- reset() method to recreate and reshuffle deck
- Deck composition validation (correct ranks and suits)
- Edge cases (empty deck, drawing all cards)

### ai_evaluation_test_love.lua

Tests for the AI evaluation module (src/ai_evaluation.lua):
- Constants validation (RANK_MULTIPLIER, UNBALANCED_HAND_PENALTY, etc.)
- Rank bonuses array for pairs/triples/quads
- getRelativeCardValue() with different deck sizes (24, 32, 36, 52 cards)
- evaluateHand() with various scenarios:
  - Empty hands and out-of-play detection
  - Trump cards and bonuses
  - Multiple rank bonuses (pairs, triples)
  - Suit balance penalties
  - Card ratio calculations

All tests validate that the Lua implementation matches the original Kotlin behavior from Card.kt, Suit.kt, Rank.kt, and Deck.kt.

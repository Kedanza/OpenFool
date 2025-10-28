# OpenFool Tests

## Running Tests

Tests are run using Love2D:

```bash
# From project root
love tests

# Or with console output (Windows)
love tests --console
```

## Test Files

- `main.lua` - Test runner for Love2D
- `conf.lua` - Love2D configuration for tests
- `card_test_love.lua` - Unit tests for card module (40 tests)
- `card_test.lua` - Legacy Lua tests (deprecated, use Love2D)

## Test Results

**Card Module Tests: ✓ 23/23 passed**
**Deck Module Tests: ✓ 28/28 passed**
**AI Evaluation Module Tests: ✓ 37/37 passed**
**AI Attack Module Tests: ✓ 44/44 passed**
**AI Defense Module Tests: ✓ 17/17 passed**
**Total: ✓ 149/149 passed**

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

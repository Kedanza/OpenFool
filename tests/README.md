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

**Card Module Tests: ✓ 40/40 passed**
**Deck Module Tests: ✓ 40/40 passed**
**Total: ✓ 80/80 passed**

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

All tests validate that the Lua implementation matches the original Kotlin behavior from Card.kt, Suit.kt, Rank.kt, and Deck.kt.

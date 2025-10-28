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

All tests validate that the Lua implementation matches the original Kotlin behavior from Card.kt, Suit.kt, and Rank.kt.

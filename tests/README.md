# OpenFool Tests

## Running Tests

To run the card module tests, you need Lua installed on your system.

```bash
# Run card tests
lua tests/card_test.lua

# Or with lua5.1/lua5.3 if that's what you have
lua5.1 tests/card_test.lua
```

## Test Coverage

### card_test.lua
Tests for the card module (src/card.lua):
- Suit enum values (SPADES, DIAMONDS, CLUBS, HEARTS)
- Rank enum values (ACE through KING)
- Card creation with createCard()
- toString() method (format: "{rank}{suit_letter}")
- equals() method for card comparison
- beats() method with trump logic and deuceBeatsAce rule
- findCardInHand() utility function

All tests validate that the Lua implementation matches the original Kotlin behavior from Card.kt, Suit.kt, and Rank.kt.

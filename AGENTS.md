# Agent Guidelines for OpenFool Love2D Migration

## Build/Test Commands
- **Run game:** `love .`
- **Run all tests:** `love tests/`
- **Run single test:** Edit `tests/main.lua`, comment out other `require()` calls, leave only desired test

## Code Style

**Module Pattern (Factory Functions):**
```lua
local function createCard(suit, rank)
    local card = { suit = suit, rank = rank }
    function card:method() end  -- Use colon for methods
    return card
end
return { createCard = createCard }
```

**Naming:** camelCase for variables/functions, SCREAMING_SNAKE for enums (`Suit.SPADES`, `Rank.ACE`)

**Imports:** Use `require("src.module")` for src files, `require("tests.module_test_love")` for tests

**Error Handling:** Explicit nil checks (`if not value then return nil end`), no exceptions

**Tests:** Use global `assert(condition, "Present tense message")` from `tests/main.lua`

## Critical Lua Gotchas
- Arrays with nil values: `#array == 0` - use `for i=1, 6 do` instead of `for i=1, #array do`
- Y-axis points DOWN in Love2D (0 = top)
- Asset paths: `android/assets/decks/rus/13h.png` (rank 1-13, suit s/d/c/h)

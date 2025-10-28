# Test Writing Guidelines for OpenFool Love2D Migration

This document defines consistent patterns for writing and organizing tests to ensure maintainability and clear output.

## 📋 Table of Contents
- [File Naming Convention](#file-naming-convention)
- [Test Structure](#test-structure)
- [Assertion Pattern](#assertion-pattern)
- [Test Grouping](#test-grouping)
- [Console Output Format](#console-output-format)
- [Test Counting](#test-counting)
- [Running Tests](#running-tests)
- [Common Patterns](#common-patterns)

---

## 📁 File Naming Convention

**Pattern:** `{module_name}_test_love.lua`

**Examples:**
- `card_test_love.lua` - Tests for `src/card.lua`
- `deck_test_love.lua` - Tests for `src/deck.lua`
- `player_test_love.lua` - Tests for `src/player.lua`
- `ruleset_test_love.lua` - Tests for `src/ruleset.lua`

**Legacy files** (deprecated):
- `card_test.lua` - Old plain Lua tests (use Love2D version instead)

---

## 🏗️ Test Structure

### Basic Template

```lua
-- Load the module being tested
local module = require("../src/module_name")

-- Test counter
local testsPassed = 0
local testsFailed = 0

-- Helper function for formatted output
local function test(description, condition)
    if condition then
        testsPassed = testsPassed + 1
        print("✓ " .. description)
    else
        testsFailed = testsFailed + 1
        print("✗ " .. description)
    end
end

-- Module Tests
print("\n=== Module Name Tests ===")

-- Test Group 1: Feature Category
print("\n--- Feature Category Tests ---")
test("Specific test case 1", someValue == expectedValue)
test("Specific test case 2", anotherCondition)

-- Test Group 2: Another Feature
print("\n--- Another Feature Tests ---")
test("Edge case handling", edgeCaseCheck)

-- Summary
print(string.format("\nModule Tests: %d/%d passed", 
    testsPassed, testsPassed + testsFailed))

-- Update global counters
passedTests = passedTests + testsPassed
failedTests = failedTests + testsFailed
totalTests = totalTests + testsPassed + testsFailed

return true
```

---

## ✅ Assertion Pattern

### Use Global Assert Functions

**IMPORTANT:** Always use the **global** `assert()` function from `main.lua`, NOT local functions.

**❌ WRONG (Local function - won't be counted):**
```lua
local function assert(condition, message)
    -- This won't update global counters!
end
```

**✓ CORRECT (Global function):**
```lua
-- Use the global assert from main.lua
assert(card.rank == Rank.ACE, "Card should be an Ace")
assert(deck:remaining() == 36, "Deck should have 36 cards")
```

### Why This Matters

The test runner in `main.lua` defines these globals:
```lua
passedTests = 0
failedTests = 0
totalTests = 0

function assert(condition, message)
    totalTests = totalTests + 1
    if condition then
        passedTests = passedTests + 1
        print("✓ " .. message)
    else
        failedTests = failedTests + 1
        print("✗ " .. message)
    end
end
```

Using local assert functions breaks the test counting!

---

## 📊 Test Grouping

### Group Related Tests

Use descriptive section headers to organize tests logically:

```lua
-- ===== MAIN MODULE HEADER =====
print("\n=== Player Module Tests ===")

-- ----- Feature Category Headers -----
print("\n--- Player Creation Tests ---")
assert(player ~= nil, "Player should be created")
assert(player.name == "Alice", "Player name should be 'Alice'")

print("\n--- Card Management Tests ---")
assert(player:handSize() == 0, "New player should have empty hand")
player:addCard(card1)
assert(player:handSize() == 1, "Hand should have 1 card after adding")

print("\n--- Sorting Tests ---")
assert(player.sortingMode == SortingMode.SUIT_ASCENDING, "Default sorting should be SUIT_ASCENDING")
```

### Naming Conventions

1. **Main Module Header:** `=== {Module Name} Tests ===`
   - Used once per file at the start
   - Example: `=== AI Evaluation Tests ===`

2. **Feature Category Headers:** `--- {Feature} Tests ---`
   - Used for each logical grouping of tests
   - Example: `--- Card Comparison Tests ---`

3. **Test Assertions:** Descriptive messages in present tense
   - Example: `"Card should beat lower card of same suit"`
   - Example: `"Deck should have 36 cards with lowestRank TWO"`

---

## 🖥️ Console Output Format

### Standard Output Structure

```
=== Module Name Tests ===

--- Feature Category 1 ---
✓ Test case 1 description
✓ Test case 2 description
✗ Test case 3 description

--- Feature Category 2 ---
✓ Test case 4 description
✓ Test case 5 description

Module Tests: 4/5 passed
```

### Summary Output

At the end of `main.lua`, print overall summary:

```lua
print("\n" .. string.rep("=", 50))
print(string.format("Passed: %d, Failed: %d, Total: %d", 
    passedTests, failedTests, totalTests))

if failedTests == 0 then
    print("✓ All tests passed!")
else
    print("✗ Some tests failed")
end
print(string.rep("=", 50))
```

---

## 🔢 Test Counting

### How Tests Are Counted

Each call to `assert()` increments the global `totalTests` counter:

```lua
-- In main.lua
function assert(condition, message)
    totalTests = totalTests + 1  -- ← Every assert() counts as 1 test
    if condition then
        passedTests = passedTests + 1
    else
        failedTests = failedTests + 1
    end
end
```

### Update README.md After Adding Tests

When you add a new test file, update `tests/README.md`:

**Before:**
```markdown
**Total: ✓ 221/221 passed**
```

**After:**
```markdown
**Card Module Tests: ✓ 23/23 passed**
**Deck Module Tests: ✓ 28/28 passed**
**Player Module Tests: ✓ 55/55 passed**
**Total: ✓ 276/276 passed**
```

### Adding Test Files to Runner

Update `tests/main.lua` to include your new test:

```lua
-- Load all test modules
require("card_test_love")
require("deck_test_love")
require("player_test_love")  -- ← Add your new test here
```

---

## 🚀 Running Tests

### Basic Run

```bash
love tests
```

### With Console Output (Windows)

```bash
love tests --console
```

### Filtering Output

**Show only summary:**
```powershell
love tests 2>&1 | Select-String -Pattern "(Passed:|Failed:|Total:|All tests)"
```

**Show only failures:**
```powershell
love tests 2>&1 | Select-String -Pattern "✗"
```

**Show specific module:**
```powershell
love tests 2>&1 | Select-String -Pattern "(Player Module|✓|✗)"
```

---

## 🎯 Common Patterns

### Pattern 1: Equality Tests

```lua
assert(actual == expected, "Description of what should be true")
```

**Examples:**
```lua
assert(card.rank == Rank.ACE, "Card rank should be ACE")
assert(deck:remaining() == 36, "Deck should have 36 cards remaining")
assert(player:handSize() == 6, "Player should have 6 cards after deal")
```

### Pattern 2: Boolean Tests

```lua
assert(condition, "What should be true")
assert(not condition, "What should be false")
```

**Examples:**
```lua
assert(card1:beats(card2, nil, false), "Higher rank should beat lower rank")
assert(not card2:beats(card1, nil, false), "Lower rank should not beat higher rank")
```

### Pattern 3: Nil/Existence Tests

```lua
assert(value ~= nil, "Value should exist")
assert(value == nil, "Value should not exist")
```

**Examples:**
```lua
assert(player ~= nil, "Player should be created successfully")
assert(deck:draw() == nil, "Empty deck should return nil")
```

### Pattern 4: Table/Array Tests

```lua
assert(#table == expectedSize, "Table size description")
```

**Examples:**
```lua
assert(#player.hand == 6, "Player hand should contain 6 cards")
assert(#availableCards == 0, "No cards should be available")
```

### Pattern 5: Range Tests

```lua
assert(value >= min and value <= max, "Value should be in range")
```

**Examples:**
```lua
assert(score >= 0 and score <= 100, "Score should be between 0 and 100")
assert(handValue > -1000, "Hand value should be greater than -1000")
```

### Pattern 6: Type Tests

```lua
assert(type(value) == "table", "Should be a table")
assert(type(value) == "number", "Should be a number")
```

**Examples:**
```lua
assert(type(player) == "table", "createPlayer should return a table")
assert(type(deck:remaining()) == "number", "remaining() should return a number")
```

---

## 🐛 Debugging Failed Tests

### Add Debug Output

```lua
-- Temporarily add debug prints ABOVE the failing assertion
print("DEBUG: actualValue =", actualValue)
print("DEBUG: expectedValue =", expectedValue)
assert(actualValue == expectedValue, "Values should match")
```

### Run with Console Flag

```bash
love tests --console 2>&1
```

### Check for Common Issues

1. **Lua Table Length Issue:** Arrays with all `nil` values have `#array == 0`
   - **Solution:** Use fixed size loops: `for i=1, 6 do` instead of `for i=1, #array do`

2. **Method vs Function Syntax:**
   - **Wrong:** `card.equals(a, b)` 
   - **Right:** `a:equals(b)`

3. **Local vs Global Assert:**
   - **Wrong:** Defined local `assert()` function
   - **Right:** Use global `assert()` from `main.lua`

---

## 📝 Example: Complete Test File

Here's a complete example showing all patterns:

```lua
-- tests/example_test_love.lua
local Example = require("../src/example")

print("\n=== Example Module Tests ===")

-- Test Group 1: Creation
print("\n--- Creation Tests ---")
local obj = Example.create("TestName")
assert(obj ~= nil, "Object should be created")
assert(obj.name == "TestName", "Object name should be 'TestName'")

-- Test Group 2: Methods
print("\n--- Method Tests ---")
local result = obj:doSomething()
assert(result == true, "doSomething should return true")
assert(obj:getValue() == 42, "getValue should return 42")

-- Test Group 3: Edge Cases
print("\n--- Edge Case Tests ---")
local emptyObj = Example.create(nil)
assert(emptyObj.name == "", "Empty name should default to empty string")

return true
```

---

## ✅ Checklist for Adding New Tests

- [ ] Create file with pattern `{module}_test_love.lua`
- [ ] Use global `assert()` function (not local)
- [ ] Add main module header: `=== Module Name Tests ===`
- [ ] Group related tests with `--- Category Tests ---`
- [ ] Write descriptive assertion messages
- [ ] Add `require("{module}_test_love")` to `tests/main.lua`
- [ ] Run tests to verify count: `love tests --console`
- [ ] Update `tests/README.md` with new test counts
- [ ] Commit changes with clear message

---

## 📖 References

- **Main Test Runner:** `tests/main.lua`
- **Test Examples:** `tests/card_test_love.lua`, `tests/deck_test_love.lua`
- **Test Results:** `tests/README.md`
- **Implementation Plan:** `LOVE2D_IMPLEMENTATION_PLAN.md`

---

**Last Updated:** Issue #5 completion (276 total tests)

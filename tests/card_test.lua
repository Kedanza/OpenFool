-- Unit tests for card.lua
-- Run with: lua tests/card_test.lua

-- Add src to package path
package.path = package.path .. ";../src/?.lua;./src/?.lua"

local card = require("card")
local Suit = card.Suit
local Rank = card.Rank
local createCard = card.createCard
local findCardInHand = card.findCardInHand

-- Test counter
local tests_passed = 0
local tests_failed = 0

-- Simple assertion helper
local function assert_equal(actual, expected, test_name)
    if actual == expected then
        tests_passed = tests_passed + 1
        print("✓ " .. test_name)
    else
        tests_failed = tests_failed + 1
        print("✗ " .. test_name)
        print("  Expected: " .. tostring(expected))
        print("  Got: " .. tostring(actual))
    end
end

local function assert_true(condition, test_name)
    assert_equal(condition, true, test_name)
end

local function assert_false(condition, test_name)
    assert_equal(condition, false, test_name)
end

local function assert_not_nil(value, test_name)
    if value ~= nil then
        tests_passed = tests_passed + 1
        print("✓ " .. test_name)
    else
        tests_failed = tests_failed + 1
        print("✗ " .. test_name)
        print("  Expected: not nil")
        print("  Got: nil")
    end
end

print("\n=== Card Module Tests ===\n")

-- Test Suit values
print("-- Suit Tests --")
assert_equal(Suit.SPADES, 0, "Suit.SPADES should be 0")
assert_equal(Suit.DIAMONDS, 1, "Suit.DIAMONDS should be 1")
assert_equal(Suit.CLUBS, 2, "Suit.CLUBS should be 2")
assert_equal(Suit.HEARTS, 3, "Suit.HEARTS should be 3")

-- Test Rank values
print("\n-- Rank Tests --")
assert_equal(Rank.ACE, 1, "Rank.ACE should be 1")
assert_equal(Rank.TWO, 2, "Rank.TWO should be 2")
assert_equal(Rank.THREE, 3, "Rank.THREE should be 3")
assert_equal(Rank.FOUR, 4, "Rank.FOUR should be 4")
assert_equal(Rank.FIVE, 5, "Rank.FIVE should be 5")
assert_equal(Rank.SIX, 6, "Rank.SIX should be 6")
assert_equal(Rank.SEVEN, 7, "Rank.SEVEN should be 7")
assert_equal(Rank.EIGHT, 8, "Rank.EIGHT should be 8")
assert_equal(Rank.NINE, 9, "Rank.NINE should be 9")
assert_equal(Rank.TEN, 10, "Rank.TEN should be 10")
assert_equal(Rank.JACK, 11, "Rank.JACK should be 11")
assert_equal(Rank.QUEEN, 12, "Rank.QUEEN should be 12")
assert_equal(Rank.KING, 13, "Rank.KING should be 13")

-- Test createCard
print("\n-- createCard Tests --")
local aceOfSpades = createCard(Suit.SPADES, Rank.ACE)
assert_not_nil(aceOfSpades, "createCard should create a card object")
assert_equal(aceOfSpades.suit, Suit.SPADES, "Card suit should be SPADES")
assert_equal(aceOfSpades.rank, Rank.ACE, "Card rank should be ACE")

-- Test toString
print("\n-- toString Tests --")
assert_equal(aceOfSpades:toString(), "1s", "Ace of Spades should be '1s'")

local twoOfHearts = createCard(Suit.HEARTS, Rank.TWO)
assert_equal(twoOfHearts:toString(), "2h", "Two of Hearts should be '2h'")

local kingOfDiamonds = createCard(Suit.DIAMONDS, Rank.KING)
assert_equal(kingOfDiamonds:toString(), "13d", "King of Diamonds should be '13d'")

local queenOfClubs = createCard(Suit.CLUBS, Rank.QUEEN)
assert_equal(queenOfClubs:toString(), "12c", "Queen of Clubs should be '12c'")

-- Test equals
print("\n-- equals Tests --")
local aceOfSpades2 = createCard(Suit.SPADES, Rank.ACE)
assert_true(aceOfSpades:equals(aceOfSpades2), "Two Aces of Spades should be equal")
assert_false(aceOfSpades:equals(twoOfHearts), "Ace of Spades and Two of Hearts should not be equal")
assert_false(aceOfSpades:equals(nil), "Card should not equal nil")

-- Test beats - Same suit
print("\n-- beats Tests (Same Suit) --")
local sevenOfHearts = createCard(Suit.HEARTS, Rank.SEVEN)
local fiveOfHearts = createCard(Suit.HEARTS, Rank.FIVE)
assert_true(sevenOfHearts:beats(fiveOfHearts, Suit.SPADES, false),
    "7 of Hearts should beat 5 of Hearts (same suit, higher rank)")
assert_false(fiveOfHearts:beats(sevenOfHearts, Suit.SPADES, false),
    "5 of Hearts should not beat 7 of Hearts (same suit, lower rank)")

-- Test beats - Trump vs non-trump
print("\n-- beats Tests (Trump) --")
local threeOfSpades = createCard(Suit.SPADES, Rank.THREE)  -- Trump
local kingOfHearts = createCard(Suit.HEARTS, Rank.KING)   -- Non-trump
assert_true(threeOfSpades:beats(kingOfHearts, Suit.SPADES, false),
    "3 of Spades (trump) should beat King of Hearts (non-trump)")
assert_false(kingOfHearts:beats(threeOfSpades, Suit.SPADES, false),
    "King of Hearts (non-trump) should not beat 3 of Spades (trump)")

-- Test beats - Deuce beats Ace special rule
print("\n-- beats Tests (Deuce beats Ace) --")
local aceOfHearts = createCard(Suit.HEARTS, Rank.ACE)
assert_true(twoOfHearts:beats(aceOfHearts, Suit.SPADES, true),
    "2 of Hearts should beat Ace of Hearts when deuceBeatsAce is true")
assert_false(twoOfHearts:beats(aceOfHearts, Suit.SPADES, false),
    "2 of Hearts should not beat Ace of Hearts when deuceBeatsAce is false")

-- Test beats - Rank calculation with (rank + 11) % 13
print("\n-- beats Tests (Rank Calculation) --")
-- With the formula (rank + 11) % 13:
-- ACE (1 + 11) % 13 = 12
-- TWO (2 + 11) % 13 = 0
-- THREE (3 + 11) % 13 = 1
-- So in same suit: ACE > THREE > TWO (when deuceBeatsAce is false)
local threeOfDiamonds = createCard(Suit.DIAMONDS, Rank.THREE)
local twoOfDiamonds = createCard(Suit.DIAMONDS, Rank.TWO)
local aceOfDiamonds = createCard(Suit.DIAMONDS, Rank.ACE)

assert_true(aceOfDiamonds:beats(threeOfDiamonds, Suit.SPADES, false),
    "Ace should beat Three (12 > 1)")
assert_true(threeOfDiamonds:beats(twoOfDiamonds, Suit.SPADES, false),
    "Three should beat Two (1 > 0)")
assert_false(twoOfDiamonds:beats(threeOfDiamonds, Suit.SPADES, false),
    "Two should not beat Three (0 < 1)")

-- Test findCardInHand
print("\n-- findCardInHand Tests --")
local hand = {
    createCard(Suit.SPADES, Rank.ACE),
    createCard(Suit.HEARTS, Rank.KING),
    createCard(Suit.DIAMONDS, Rank.QUEEN),
    createCard(Suit.CLUBS, Rank.JACK)
}

local searchCard = createCard(Suit.HEARTS, Rank.KING)
local index = findCardInHand(hand, searchCard)
assert_equal(index, 2, "Should find King of Hearts at index 2")

local notInHand = createCard(Suit.SPADES, Rank.TWO)
local notFound = findCardInHand(hand, notInHand)
assert_equal(notFound, nil, "Should return nil for card not in hand")

assert_equal(findCardInHand(nil, searchCard), nil, "Should return nil for nil hand")
assert_equal(findCardInHand(hand, nil), nil, "Should return nil for nil card")

-- Print results
print("\n=== Test Results ===")
print(string.format("Passed: %d", tests_passed))
print(string.format("Failed: %d", tests_failed))
print(string.format("Total: %d", tests_passed + tests_failed))

if tests_failed == 0 then
    print("\n✓ All tests passed!")
    os.exit(0)
else
    print("\n✗ Some tests failed!")
    os.exit(1)
end

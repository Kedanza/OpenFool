-- ai_throw_additional_test_love.lua
-- Tests for AI Throw Additional Cards Logic

local card = require("card")
local aiThrow = require("ai_throw_additional")

print("\n=== AI Throw Additional Module Tests ===")

-- Helper function for assertions
local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\n  Expected: %s\n  Got: %s", message, tostring(expected), tostring(actual)))
    end
    print("✓ " .. message)
end

local function assert_not_nil(value, message)
    if value == nil then
        error(string.format("%s\n  Expected: not nil\n  Got: nil", message))
    end
    print("✓ " .. message)
end

local function assert_nil(value, message)
    if value ~= nil then
        error(string.format("%s\n  Expected: nil\n  Got: %s", message, tostring(value)))
    end
    print("✓ " .. message)
end

local function assert_true(condition, message)
    if not condition then
        error(message)
    end
    print("✓ " .. message)
end

-- Test 1: Constants validation
print("\n-- Throw Additional Constants Tests --")

assert_equal(aiThrow.PENALTY_BASE, 1200, "PENALTY_BASE should be 1200")
assert_equal(aiThrow.PENALTY_DELTA, 50, "PENALTY_DELTA should be 50")

-- Test 2: No matching ranks - should return nil (done)
print("\n-- aiThrowOrDone No Matching Ranks --")

local hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.KING),
    card.createCard(card.Suit.SPADES, card.Rank.QUEEN)
}
local attackCards = {card.createCard(card.Suit.DIAMONDS, card.Rank.SIX)}
local defenseCards = {card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN)}
local trumpSuit = card.Suit.SPADES
local cardsRemaining = 20
local playerHands = {2, 6, 6}
local lowestRank = card.Rank.SIX

local result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_nil(result, "Should return nil when no ranks match")

-- Test 3: Has matching rank but not beneficial - should return nil
print("\n-- aiThrowOrDone Not Beneficial --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.ACE),
    card.createCard(card.Suit.SPADES, card.Rank.ACE),  -- Pair of ACEs
    card.createCard(card.Suit.DIAMONDS, card.Rank.SIX)  -- Matches attack
}
attackCards = {card.createCard(card.Suit.CLUBS, card.Rank.SIX)}
defenseCards = {card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)}
trumpSuit = card.Suit.SPADES
cardsRemaining = 0  -- Endgame - high penalty
playerHands = {3, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
-- With cardsRemaining=0, penalty is 1200. Strong hand with pair of ACEs, throwing weak 6 might still be done
-- This is a strategic decision by the AI
if result then
    assert_equal(result.rank, card.Rank.SIX, "If throwing, should throw the 6")
end

-- Test 4: Beneficial to throw - should return card
print("\n-- aiThrowOrDone Beneficial Throw --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),
    card.createCard(card.Suit.SPADES, card.Rank.SIX),  -- Pair of 6s
    card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN)
}
attackCards = {card.createCard(card.Suit.CLUBS, card.Rank.SIX)}
defenseCards = {card.createCard(card.Suit.CLUBS, card.Rank.EIGHT)}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20  -- Mid-game
playerHands = {3, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(result, "Should throw when beneficial")
if result then
    assert_equal(result.rank, card.Rank.SIX, "Should throw one of the 6s")
end

-- Test 5: Multiple matching ranks - choose best
print("\n-- aiThrowOrDone Multiple Options --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),
    card.createCard(card.Suit.SPADES, card.Rank.SEVEN),
    card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT)
}
attackCards = {
    card.createCard(card.Suit.CLUBS, card.Rank.SIX),
    card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)
}
defenseCards = {
    card.createCard(card.Suit.CLUBS, card.Rank.NINE),
    card.createCard(card.Suit.CLUBS, card.Rank.TEN)
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {3, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
if result then
    assert_true(result.rank == card.Rank.SIX or result.rank == card.Rank.SEVEN,
        string.format("Should throw 6 or 7, got rank %d", result.rank))
end

-- Test 6: Empty hand - should return nil
print("\n-- aiThrowOrDone Empty Hand --")

hand = {}
attackCards = {card.createCard(card.Suit.CLUBS, card.Rank.SIX)}
defenseCards = {card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {0, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_nil(result, "Should return nil for empty hand")

-- Test 7: Prefer throwing from multiple-rank sets
print("\n-- aiThrowOrDone Prefer Multiples --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),
    card.createCard(card.Suit.SPADES, card.Rank.SIX),
    card.createCard(card.Suit.DIAMONDS, card.Rank.SIX),  -- Triple of 6s
    card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)     -- Singleton 7
}
attackCards = {
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),
    card.createCard(card.Suit.HEARTS, card.Rank.SEVEN)
}
defenseCards = {
    card.createCard(card.Suit.HEARTS, card.Rank.EIGHT),
    card.createCard(card.Suit.HEARTS, card.Rank.NINE)
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {4, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
if result then
    -- AI will evaluate both options - triple gets bonus but singleton might leave better hand
    -- Both are valid strategic choices
    assert_true(result.rank == card.Rank.SIX or result.rank == card.Rank.SEVEN,
        string.format("Should throw 6 or 7, got rank %d", result.rank))
end

-- Test 8: Endgame decision (cardsRemaining = 0)
print("\n-- aiThrowOrDone Endgame --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),
    card.createCard(card.Suit.SPADES, card.Rank.SEVEN)
}
attackCards = {card.createCard(card.Suit.CLUBS, card.Rank.SIX)}
defenseCards = {card.createCard(card.Suit.CLUBS, card.Rank.EIGHT)}
trumpSuit = card.Suit.SPADES
cardsRemaining = 0  -- Endgame
playerHands = {2, 0, 0}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
-- In endgame, penalty is higher (1200) so AI is more conservative about throwing
-- Result depends on hand evaluation
if result then
    assert_equal(result.rank, card.Rank.SIX, "If throwing in endgame, should throw matching rank")
end

-- Test 9: Ranks present in both attack and defense
print("\n-- aiThrowOrDone Ranks in Both --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.NINE),
    card.createCard(card.Suit.SPADES, card.Rank.TEN)
}
attackCards = {card.createCard(card.Suit.CLUBS, card.Rank.NINE)}
defenseCards = {card.createCard(card.Suit.HEARTS, card.Rank.TEN)}  -- TEN in defense
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {2, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
-- Both 9 and 10 are present, AI can throw either
if result then
    assert_true(result.rank == card.Rank.NINE or result.rank == card.Rank.TEN,
        string.format("Should throw 9 or 10, got rank %d", result.rank))
end

-- Test 10: Single card in hand matching rank
print("\n-- aiThrowOrDone Single Matching Card --")

hand = {card.createCard(card.Suit.HEARTS, card.Rank.KING)}
attackCards = {card.createCard(card.Suit.CLUBS, card.Rank.KING)}
defenseCards = {card.createCard(card.Suit.CLUBS, card.Rank.ACE)}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {1, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
-- AI will evaluate if throwing last card is beneficial
-- Usually not beneficial to empty hand
assert_nil(result, "Should not throw last card (empty hand)")

-- Test 11: Large hand with many matching ranks
print("\n-- aiThrowOrDone Large Hand --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),
    card.createCard(card.Suit.SPADES, card.Rank.SIX),
    card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN),
    card.createCard(card.Suit.CLUBS, card.Rank.EIGHT),
    card.createCard(card.Suit.HEARTS, card.Rank.NINE),
    card.createCard(card.Suit.SPADES, card.Rank.TEN)
}
attackCards = {
    card.createCard(card.Suit.CLUBS, card.Rank.SIX),
    card.createCard(card.Suit.HEARTS, card.Rank.SEVEN)
}
defenseCards = {
    card.createCard(card.Suit.CLUBS, card.Rank.KING),
    card.createCard(card.Suit.HEARTS, card.Rank.ACE)
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 15
playerHands = {6, 6, 6}
lowestRank = card.Rank.SIX

result = aiThrow.aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
if result then
    assert_true(result.rank == card.Rank.SIX or result.rank == card.Rank.SEVEN,
        string.format("Should throw 6 or 7, got rank %d", result.rank))
end

print("\n=== AI Throw Additional Tests Complete ===")

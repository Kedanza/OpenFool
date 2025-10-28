-- ai_evaluation_test_love.lua
-- AI Evaluation System tests for Love2D test runner

local card = require("card")
local aiEval = require("ai_evaluation")

print("\n=== AI Evaluation Module Tests ===\n")

-- Helper function for approximate equality
local function assert_close(actual, expected, tolerance, test_name)
    tolerance = tolerance or 0.001
    local passed = math.abs(actual - expected) <= tolerance
    
    if passed then
        assert_true(true, test_name)
    else
        -- Manually increment failed counter and add output
        local current_failed = _G.tests_failed()
        _G.test_output = _G.test_output or {}
        table.insert(_G.test_output, "✗ " .. test_name)
        table.insert(_G.test_output, string.format("  Expected: %.3f (±%.3f)", expected, tolerance))
        table.insert(_G.test_output, string.format("  Got: %.3f", actual))
        
        -- Force the test as failed using assert_equal with impossible match
        assert_equal(false, true, test_name .. " (approximate)")
    end
end

-- Test 1: Constants
print("-- Constants Tests --")
assert_equal(100, aiEval.RANK_MULTIPLIER, "RANK_MULTIPLIER should be 100")
assert_equal(200, aiEval.UNBALANCED_HAND_PENALTY, "UNBALANCED_HAND_PENALTY should be 200")
assert_equal(600, aiEval.MANY_CARDS_PENALTY, "MANY_CARDS_PENALTY should be 600")
assert_equal(30000, aiEval.OUT_OF_PLAY, "OUT_OF_PLAY should be 30000")

-- Test 2: Rank bonuses
print("\n-- Rank Bonuses Tests --")
assert_equal(0.0, aiEval.RANK_BONUSES[1], "0 cards bonus should be 0.0")
assert_equal(0.0, aiEval.RANK_BONUSES[2], "1 card bonus should be 0.0")
assert_equal(0.5, aiEval.RANK_BONUSES[3], "2 cards (pair) bonus should be 0.5")
assert_equal(0.75, aiEval.RANK_BONUSES[4], "3 cards (triple) bonus should be 0.75")
assert_equal(1.25, aiEval.RANK_BONUSES[5], "4 cards (quad) bonus should be 1.25")

-- Test 3: getRelativeCardValue with 36-card deck
print("\n-- getRelativeCardValue Tests (36-card deck) --")
local lowestRank = 6
assert_close(4.5, aiEval.getRelativeCardValue(1, lowestRank), 0.001, "ACE value in 36-card deck")
assert_close(3.5, aiEval.getRelativeCardValue(13, lowestRank), 0.001, "KING value in 36-card deck")
assert_close(2.5, aiEval.getRelativeCardValue(12, lowestRank), 0.001, "QUEEN value in 36-card deck")
assert_close(1.5, aiEval.getRelativeCardValue(11, lowestRank), 0.001, "JACK value in 36-card deck")
assert_close(-3.5, aiEval.getRelativeCardValue(6, lowestRank), 0.001, "6 value in 36-card deck")

-- Test 4: getRelativeCardValue with 52-card deck
print("\n-- getRelativeCardValue Tests (52-card deck) --")
lowestRank = 2
assert_close(6.5, aiEval.getRelativeCardValue(1, lowestRank), 0.001, "ACE value in 52-card deck")
assert_close(5.5, aiEval.getRelativeCardValue(13, lowestRank), 0.001, "KING value in 52-card deck")
assert_close(-5.5, aiEval.getRelativeCardValue(2, lowestRank), 0.001, "2 value in 52-card deck")

-- Test 5: evaluateHand - Player out of game
print("\n-- evaluateHand Tests --")
local hand = {}
local trumpSuit = card.Suit.SPADES  -- 0
local cardsRemaining = 0
local playerHands = {6, 6, 6}
lowestRank = 6

local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_equal(30000, score, "Player out of game should score 30000")

-- Test 6: evaluateHand - Empty hand with cards remaining
hand = {}
cardsRemaining = 10
score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_equal(150, score, "Empty hand with cards remaining should score 150")

-- Test 7: evaluateHand - Single ACE of trumps
trumpSuit = card.Suit.HEARTS
local aceOfHearts = card.createCard(card.Suit.HEARTS, card.Rank.ACE)  -- (suit, rank)
hand = {aceOfHearts}
cardsRemaining = 20
playerHands = {6, 6, 6}
lowestRank = 6

score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
-- Base: 4.5 * 100 = 450
-- Trump bonus: 13 * 100 = 1300
-- Card ratio: (0.25 - 1/37) * 600 ≈ 133
-- Total ≈ 1883
assert_true(score > 1800 and score < 1900, 
    string.format("ACE of trumps should score ~1883, got %d", score))

-- Test 8: evaluateHand - Pair of 10s (non-trump)
trumpSuit = card.Suit.SPADES
local tenHearts = card.createCard(card.Suit.HEARTS, card.Rank.TEN)  -- (suit, rank)
local tenDiamonds = card.createCard(card.Suit.DIAMONDS, card.Rank.TEN)  -- (suit, rank)
hand = {tenHearts, tenDiamonds}
cardsRemaining = 20
playerHands = {6, 6, 6}
lowestRank = 6

score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_true(score > 0, string.format("Pair of 10s should have positive score, got %d", score))

-- Test 9: evaluateHand - Mixed hand with trumps
trumpSuit = card.Suit.SPADES
hand = {
    card.createCard(card.Suit.SPADES, card.Rank.ACE),    -- Trump (suit, rank)
    card.createCard(card.Suit.HEARTS, card.Rank.KING),
    card.createCard(card.Suit.HEARTS, card.Rank.QUEEN),
    card.createCard(card.Suit.DIAMONDS, card.Rank.JACK),
    card.createCard(card.Suit.CLUBS, card.Rank.TEN),
    card.createCard(card.Suit.SPADES, card.Rank.NINE),   -- Trump
}
cardsRemaining = 10
playerHands = {6, 6, 6}
lowestRank = 6

score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_true(score > 2000, 
    string.format("Strong mixed hand should score > 2000, got %d", score))

-- Test 10: evaluateHand - Unbalanced suit distribution
trumpSuit = card.Suit.SPADES
hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.ACE),
    card.createCard(card.Suit.HEARTS, card.Rank.KING),
    card.createCard(card.Suit.HEARTS, card.Rank.QUEEN),
    card.createCard(card.Suit.HEARTS, card.Rank.JACK),
    card.createCard(card.Suit.HEARTS, card.Rank.TEN),
    card.createCard(card.Suit.HEARTS, card.Rank.NINE),
}
cardsRemaining = 10
playerHands = {6, 6, 6}
lowestRank = 6

score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_true(score < 2000, 
    string.format("Unbalanced hand should score < 2000 due to penalty, got %d", score))

-- Test 11: evaluateHand - Many cards penalty
trumpSuit = card.Suit.SPADES
hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.ACE),
    card.createCard(card.Suit.HEARTS, card.Rank.KING),
    card.createCard(card.Suit.DIAMONDS, card.Rank.QUEEN),
    card.createCard(card.Suit.DIAMONDS, card.Rank.JACK),
    card.createCard(card.Suit.CLUBS, card.Rank.TEN),
    card.createCard(card.Suit.CLUBS, card.Rank.NINE),
    card.createCard(card.Suit.HEARTS, card.Rank.EIGHT),
    card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN),
    card.createCard(card.Suit.CLUBS, card.Rank.SIX),
    card.createCard(card.Suit.SPADES, card.Rank.ACE),  -- Trump
}
cardsRemaining = 2
playerHands = {1, 1}
lowestRank = 6

score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_true(score < 5000, 
    string.format("Hand with too many cards should have penalty, got %d", score))

-- ai_evaluation_test.lua
-- Comprehensive tests for AI Hand Evaluation System

-- Add src directory to package path
package.path = package.path .. ";../src/?.lua"

local card = require("card")
local aiEval = require("ai_evaluation")

-- Test counter
local tests_run = 0
local tests_passed = 0

-- Helper function to run a test
local function test(name, func)
    tests_run = tests_run + 1
    io.write("Test: " .. name .. " ... ")
    local success, err = pcall(func)
    if success then
        tests_passed = tests_passed + 1
        print("PASSED")
    else
        print("FAILED")
        print("  Error: " .. tostring(err))
    end
end

-- Helper function for assertions
local function assertEquals(expected, actual, message)
    if expected ~= actual then
        error(string.format("%s\nExpected: %s\nActual: %s", 
            message or "Values not equal", tostring(expected), tostring(actual)))
    end
end

local function assertClose(expected, actual, tolerance, message)
    tolerance = tolerance or 0.001
    if math.abs(expected - actual) > tolerance then
        error(string.format("%s\nExpected: %s (±%s)\nActual: %s", 
            message or "Values not close", tostring(expected), tostring(tolerance), tostring(actual)))
    end
end

local function assertTrue(value, message)
    if not value then
        error(message or "Expected true, got false")
    end
end

print("\n=== AI Evaluation System Tests ===\n")

-- Test 1: getRelativeCardValue with 36-card deck (lowestRank = 6)
test("getRelativeCardValue: 36-card deck (lowestRank=6)", function()
    local lowestRank = 6
    -- With lowestRank=6: ranks 6,7,8,9,10,J,Q,K,A = 9 ranks in play
    -- maxValue = 9/2 = 4.5
    
    -- ACE (value 1) should get maxValue = 4.5
    assertClose(4.5, aiEval.getRelativeCardValue(1, lowestRank), 0.001, "ACE value")
    
    -- KING (value 13): 13 + 4.5 - 14 = 3.5
    assertClose(3.5, aiEval.getRelativeCardValue(13, lowestRank), 0.001, "KING value")
    
    -- QUEEN (value 12): 12 + 4.5 - 14 = 2.5
    assertClose(2.5, aiEval.getRelativeCardValue(12, lowestRank), 0.001, "QUEEN value")
    
    -- JACK (value 11): 11 + 4.5 - 14 = 1.5
    assertClose(1.5, aiEval.getRelativeCardValue(11, lowestRank), 0.001, "JACK value")
    
    -- 6 (value 6): 6 + 4.5 - 14 = -3.5
    assertClose(-3.5, aiEval.getRelativeCardValue(6, lowestRank), 0.001, "6 value")
end)

-- Test 2: getRelativeCardValue with 52-card deck (lowestRank = 2)
test("getRelativeCardValue: 52-card deck (lowestRank=2)", function()
    local lowestRank = 2
    -- With lowestRank=2: all 13 ranks in play
    -- maxValue = 13/2 = 6.5
    
    -- ACE should get 6.5
    assertClose(6.5, aiEval.getRelativeCardValue(1, lowestRank), 0.001, "ACE value")
    
    -- KING (value 13): 13 + 6.5 - 14 = 5.5
    assertClose(5.5, aiEval.getRelativeCardValue(13, lowestRank), 0.001, "KING value")
    
    -- 2 (value 2): 2 + 6.5 - 14 = -5.5
    assertClose(-5.5, aiEval.getRelativeCardValue(2, lowestRank), 0.001, "2 value")
end)

-- Test 3: evaluateHand - Empty hand with cards remaining
test("evaluateHand: Empty hand with deck not empty", function()
    local hand = {}
    local trumpSuit = card.Suit.SPADES
    local cardsRemaining = 10
    local playerHands = {6, 6, 6}  -- 3 other players
    local lowestRank = 6
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- Empty hand should have low/negative score due to card ratio penalty
    -- cardsInPlay = 10 + 6 + 6 + 6 - 0 = 28
    -- cardRatio = 0/28 = 0
    -- penalty = (0.25 - 0) * 600 = 150
    assertEquals(150, score, "Empty hand score")
end)

-- Test 4: evaluateHand - Player out of game
test("evaluateHand: Player out of game (no cards, deck empty)", function()
    local hand = {}
    local trumpSuit = card.Suit.SPADES
    local cardsRemaining = 0
    local playerHands = {6, 6, 6}
    local lowestRank = 6
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    assertEquals(aiEval.OUT_OF_PLAY, score, "Out of play score should be 30000")
end)

-- Test 5: evaluateHand - Single high trump card
test("evaluateHand: Single ACE of trumps", function()
    local trumpSuit = card.Suit.HEARTS
    local aceOfHearts = card.createCard(card.Rank.ACE, card.Suit.HEARTS)
    local hand = {aceOfHearts}
    local cardsRemaining = 20
    local playerHands = {6, 6, 6}
    local lowestRank = 6
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- Base: 4.5 * 100 = 450
    -- Trump bonus: 13 * 100 = 1300
    -- Rank bonus: max(4.5, 1) * 0.0 = 0 (only 1 ace)
    -- No suit balance penalty (all trumps)
    -- Card ratio: cardsInPlay = 20+6+6+6-1=37, ratio=1/37=0.027
    -- Card penalty: (0.25-0.027)*600 = 133.8
    -- Total ≈ 450 + 1300 + 0 + 0 + 133 = 1883
    assertTrue(score > 1800 and score < 1900, "ACE of trumps should score ~1883, got " .. score)
end)

-- Test 6: evaluateHand - Pair of same rank (non-trump)
test("evaluateHand: Pair of 10s (non-trump)", function()
    local trumpSuit = card.Suit.SPADES
    local tenHearts = card.createCard(card.Rank.TEN, card.Suit.HEARTS)
    local tenDiamonds = card.createCard(card.Rank.TEN, card.Suit.DIAMONDS)
    local hand = {tenHearts, tenDiamonds}
    local cardsRemaining = 20
    local playerHands = {6, 6, 6}
    local lowestRank = 6
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- Base: 2 * (0.5 * 100) = 100
    -- Trump bonus: 0
    -- Rank bonus for pair: max(0.5, 1) * 0.5 = 0.5
    -- Plus some suit balance and card ratio adjustments
    assertTrue(score > 0, "Pair of 10s should have positive score, got " .. score)
end)

-- Test 7: evaluateHand - Multiple ranks
test("evaluateHand: Mixed hand with trumps", function()
    local trumpSuit = card.Suit.SPADES
    local hand = {
        card.createCard(card.Rank.ACE, card.Suit.SPADES),    -- Trump
        card.createCard(card.Rank.KING, card.Suit.HEARTS),
        card.createCard(card.Rank.QUEEN, card.Suit.HEARTS),
        card.createCard(card.Rank.JACK, card.Suit.DIAMONDS),
        card.createCard(card.Rank.TEN, card.Suit.CLUBS),
        card.createCard(card.Rank.NINE, card.Suit.SPADES),   -- Trump
    }
    local cardsRemaining = 10
    local playerHands = {6, 6, 6}
    local lowestRank = 6
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- Should have a good score due to:
    -- - 2 trumps (ACE and NINE)
    -- - High cards (ACE, KING, QUEEN)
    -- - Reasonable suit distribution
    assertTrue(score > 2000, "Strong mixed hand should score well, got " .. score)
end)

-- Test 8: evaluateHand - Unbalanced suit distribution penalty
test("evaluateHand: Unbalanced hand (all one suit, non-trump)", function()
    local trumpSuit = card.Suit.SPADES
    local hand = {
        card.createCard(card.Rank.ACE, card.Suit.HEARTS),
        card.createCard(card.Rank.KING, card.Suit.HEARTS),
        card.createCard(card.Rank.QUEEN, card.Suit.HEARTS),
        card.createCard(card.Rank.JACK, card.Suit.HEARTS),
        card.createCard(card.Rank.TEN, card.Suit.HEARTS),
        card.createCard(card.Rank.NINE, card.Suit.HEARTS),
    }
    local cardsRemaining = 10
    local playerHands = {6, 6, 6}
    local lowestRank = 6
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- This should have penalties for unbalanced suits
    -- All 6 cards are hearts (non-trump)
    -- avgSuit = 6/3 = 2
    -- Hearts has 6 cards, deviation = |6-2|/2 = 2.0
    -- Diamonds has 0 cards, deviation = |0-2|/2 = 1.0
    -- Clubs has 0 cards, deviation = |0-2|/2 = 1.0
    -- Total penalty = 200 * (2.0 + 1.0 + 1.0) = 800
    assertTrue(score < 2000, "Unbalanced hand should have lower score due to penalty, got " .. score)
end)

-- Test 9: evaluateHand - Many cards penalty
test("evaluateHand: Too many cards penalty", function()
    local trumpSuit = card.Suit.SPADES
    -- Create a hand with 10 cards
    local hand = {
        card.createCard(card.Rank.ACE, card.Suit.HEARTS),
        card.createCard(card.Rank.KING, card.Suit.HEARTS),
        card.createCard(card.Rank.QUEEN, card.Suit.DIAMONDS),
        card.createCard(card.Rank.JACK, card.Suit.DIAMONDS),
        card.createCard(card.Rank.TEN, card.Suit.CLUBS),
        card.createCard(card.Rank.NINE, card.Suit.CLUBS),
        card.createCard(card.Rank.EIGHT, card.Suit.HEARTS),
        card.createCard(card.Rank.SEVEN, card.Suit.DIAMONDS),
        card.createCard(card.Rank.SIX, card.Suit.CLUBS),
        card.createCard(card.Rank.ACE, card.Suit.SPADES),  -- Trump
    }
    local cardsRemaining = 2  -- Almost no cards left in deck
    local playerHands = {1, 1}  -- Other players have few cards
    local lowestRank = 6
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- cardsInPlay = 2 + 1 + 1 - 10 = -6 (but then 0 or negative)
    -- Actually: cardsInPlay = 2 + 1 + 1 = 4, then 4 - 10 = -6
    -- But we use cardsInPlay - #hand, so it could be negative
    -- This tests the edge case where player has most of the cards
    print("    Score with many cards: " .. score)
    assertTrue(score < 5000, "Hand with too many cards should have penalty")
end)

-- Test 10: Constants validation
test("Constants are correct", function()
    assertEquals(100, aiEval.RANK_MULTIPLIER, "RANK_MULTIPLIER should be 100")
    assertEquals(200, aiEval.UNBALANCED_HAND_PENALTY, "UNBALANCED_HAND_PENALTY should be 200")
    assertEquals(600, aiEval.MANY_CARDS_PENALTY, "MANY_CARDS_PENALTY should be 600")
    assertEquals(30000, aiEval.OUT_OF_PLAY, "OUT_OF_PLAY should be 30000")
end)

-- Test 11: Rank bonuses array
test("Rank bonuses are correct", function()
    assertEquals(0.0, aiEval.RANK_BONUSES[1], "0 cards bonus")
    assertEquals(0.0, aiEval.RANK_BONUSES[2], "1 card bonus")
    assertEquals(0.5, aiEval.RANK_BONUSES[3], "2 cards (pair) bonus")
    assertEquals(0.75, aiEval.RANK_BONUSES[4], "3 cards (triple) bonus")
    assertEquals(1.25, aiEval.RANK_BONUSES[5], "4 cards (quad) bonus")
end)

-- Summary
print("\n=== Test Summary ===")
print(string.format("Tests run: %d", tests_run))
print(string.format("Tests passed: %d", tests_passed))
print(string.format("Tests failed: %d", tests_run - tests_passed))

if tests_passed == tests_run then
    print("\n✓ All tests passed!")
    os.exit(0)
else
    print("\n✗ Some tests failed!")
    os.exit(1)
end

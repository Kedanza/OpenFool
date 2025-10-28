-- ai_attack_test_love.lua
-- Unit tests for AI attack logic (Love2D version)

local card = require("card")
local aiAttack = require("ai_attack")

print("\n=== AI Attack Module Tests ===\n")

-- Test counter
local score, hand, trumpSuit, cardsRemaining, playerHands, lowestRank, bestCard

-- Constants Tests
print("-- Attack Bonuses Tests --")

assert_equal(aiAttack.ATTACK_BONUSES[1], 0.0, "0 cards bonus should be 0.0")
assert_equal(aiAttack.ATTACK_BONUSES[2], 0.0, "1 card bonus should be 0.0")
assert_equal(aiAttack.ATTACK_BONUSES[3], 1.0, "2 cards (pair) bonus should be 1.0")
assert_equal(aiAttack.ATTACK_BONUSES[4], 1.5, "3 cards (triple) bonus should be 1.5")
assert_equal(aiAttack.ATTACK_BONUSES[5], 2.5, "4 cards (quad) bonus should be 2.5")

-- Test 1: Empty hand
print("\n-- aiStartTurn Edge Cases --")

hand = {}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {0, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_equal(bestCard, nil, "Empty hand should return nil")

-- Test 2: Single card
hand = {card.createCard(card.Suit.HEARTS, card.Rank.SEVEN)}
bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Single card should return that card")
assert_equal(bestCard.rank, card.Rank.SEVEN, "Should return the only card (7)")

-- Test 3: Pair - should prefer throwing one of the pair
print("\n-- aiStartTurn Pair Logic --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.TEN),  -- Pair
    card.createCard(card.Suit.DIAMONDS, card.Rank.TEN),  -- Pair
    card.createCard(card.Suit.CLUBS, card.Rank.KING)  -- Singleton
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {3, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card from hand with pair")
assert_equal(bestCard.rank, card.Rank.TEN, "Should throw from the pair (10), not singleton (K)")

-- Test 4: Low vs High card - prefer throwing lower cards
print("\n-- aiStartTurn Low vs High Card --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),   -- Low (rank-8 = -2)
    card.createCard(card.Suit.DIAMONDS, card.Rank.ACE)  -- High (special value 6)
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {2, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card")
assert_equal(bestCard.rank, card.Rank.SIX, "Should throw low card (6) and keep ACE")

-- Test 5: Trump vs non-trump - prefer non-trump
print("\n-- aiStartTurn Trump Preference --")

hand = {
    card.createCard(card.Suit.SPADES, card.Rank.SEVEN),  -- Trump
    card.createCard(card.Suit.HEARTS, card.Rank.SEVEN)   -- Non-trump
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {2, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card")
assert_equal(bestCard.suit, card.Suit.HEARTS, "Should throw non-trump and keep trump")

-- Test 6: Triple - should throw from triple
print("\n-- aiStartTurn Triple Logic --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.NINE),
    card.createCard(card.Suit.DIAMONDS, card.Rank.NINE),
    card.createCard(card.Suit.CLUBS, card.Rank.NINE),
    card.createCard(card.Suit.SPADES, card.Rank.KING)  -- Trump singleton
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {4, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card from hand with triple")
assert_equal(bestCard.rank, card.Rank.NINE, "Should throw from the triple (9)")

-- Test 7: Mixed hand - complex decision
print("\n-- aiStartTurn Complex Hand --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.ACE),    -- High value
    card.createCard(card.Suit.DIAMONDS, card.Rank.KING),  -- High value
    card.createCard(card.Suit.CLUBS, card.Rank.SIX),     -- Low value, pair
    card.createCard(card.Suit.HEARTS, card.Rank.SIX),    -- Low value, pair
    card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN) -- Low value, singleton
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {5, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card from complex hand")
-- Should prefer low pair over singleton or high cards
assert_true(bestCard.rank == card.Rank.SIX or bestCard.rank == card.Rank.SEVEN,
    string.format("Should throw low card (6 or 7), got %d", bestCard.rank))

-- Test 8: End game - few cards remaining
print("\n-- aiStartTurn Endgame Logic --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.TEN),
    card.createCard(card.Suit.DIAMONDS, card.Rank.JACK),
    card.createCard(card.Suit.CLUBS, card.Rank.QUEEN)
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 2  -- Few cards left
playerHands = {3, 2, 1}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card in endgame")
-- In endgame, strategy might change but should still return valid card
assert_true(bestCard.rank == card.Rank.TEN or bestCard.rank == card.Rank.JACK or bestCard.rank == card.Rank.QUEEN,
    "Should return one of the cards in hand")

-- Test 9: All same rank (quad)
print("\n-- aiStartTurn Quad Logic --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.EIGHT),
    card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT),
    card.createCard(card.Suit.CLUBS, card.Rank.EIGHT),
    card.createCard(card.Suit.SPADES, card.Rank.EIGHT)
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {4, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card from quad")
assert_equal(bestCard.rank, card.Rank.EIGHT, "Should return one of the 8s")
-- Doesn't matter which suit, any 8 is fine

-- Test 10: Large hand
print("\n-- aiStartTurn Large Hand --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.ACE),
    card.createCard(card.Suit.DIAMONDS, card.Rank.KING),
    card.createCard(card.Suit.CLUBS, card.Rank.QUEEN),
    card.createCard(card.Suit.HEARTS, card.Rank.JACK),
    card.createCard(card.Suit.DIAMONDS, card.Rank.TEN),
    card.createCard(card.Suit.CLUBS, card.Rank.NINE),
    card.createCard(card.Suit.HEARTS, card.Rank.EIGHT),
    card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN),
    card.createCard(card.Suit.CLUBS, card.Rank.SIX)
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 10
playerHands = {9, 6, 6}
lowestRank = card.Rank.SIX

bestCard = aiAttack.aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
assert_not_nil(bestCard, "Should return a card from large hand")
-- Should prefer throwing lower cards
assert_true(bestCard.rank <= card.Rank.NINE, 
    string.format("Should prefer throwing lower card, got rank %d", bestCard.rank))

print("\n=== AI Attack Tests Complete ===")

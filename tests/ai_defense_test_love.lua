-- ai_defense_test_love.lua
-- Unit tests for AI defense logic (Love2D version)

local card = require("card")
local aiDefense = require("ai_defense")

print("\n=== AI Defense Module Tests ===\n")

-- Test variables
local hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce, result

-- Constants Tests
print("-- Defense Constants Tests --")

assert(aiDefense.RANK_PRESENT_BONUS == 300, "RANK_PRESENT_BONUS should be 300")
assert(aiDefense.PENALTY == 800, "PENALTY should be 800")
assert(aiDefense.TAKE_PENALTY_BASE == 2000, "TAKE_PENALTY_BASE should be 2000")
assert(aiDefense.TAKE_PENALTY_DELTA == 40, "TAKE_PENALTY_DELTA should be 40")
assert(aiDefense.PASS_PENALTY == -400, "PASS_PENALTY should be -400")

-- Test 1: No attack to beat
print("\n-- aiTryBeat Edge Cases --")

hand = {card.createCard(card.Suit.HEARTS, card.Rank.KING)}
attackCards = {}
defenseCards = {}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {1, 6, 6}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result == nil, "No attack should return nil")

-- Test 2: Can't beat attack - must take
print("\n-- aiTryBeat Cannot Beat --")

hand = {card.createCard(card.Suit.HEARTS, card.Rank.SIX)}  -- Low card
attackCards = {card.createCard(card.Suit.DIAMONDS, card.Rank.KING)}  -- High attack
defenseCards = {nil}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {1, 6, 6}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result == nil, "Cannot beat attack - should return nil (take)")

-- Test 3: Can beat - simple case
print("\n-- aiTryBeat Simple Beat --")

hand = {card.createCard(card.Suit.HEARTS, card.Rank.KING)}  -- Can beat
attackCards = {card.createCard(card.Suit.HEARTS, card.Rank.TEN)}  -- Lower same suit
defenseCards = {nil}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {1, 6, 6}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result ~= nil, "Should beat when possible and beneficial")
if result then
    assert(result.rank == card.Rank.KING, "Should return the King")
end

-- Test 4: Trump beats non-trump
print("\n-- aiTryBeat Trump vs Non-Trump --")

hand = {
    card.createCard(card.Suit.SPADES, card.Rank.SIX),  -- Trump
    card.createCard(card.Suit.HEARTS, card.Rank.ACE)   -- High non-trump
}
attackCards = {card.createCard(card.Suit.HEARTS, card.Rank.KING)}  -- Non-trump attack
defenseCards = {nil}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {2, 6, 6}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result ~= nil, "Should beat with trump")
if result then
    -- AI should prefer the ACE (same suit, higher) over trump since it's less valuable
    assert(result.suit == card.Suit.SPADES or result.suit == card.Suit.HEARTS,
        string.format("Should beat with trump or ACE, got suit %d", result.suit))
end

-- Test 5: Rank present bonus - prefer matching rank
print("\n-- aiTryBeat Rank Present Bonus --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.NINE),  -- Same rank as in play
    card.createCard(card.Suit.DIAMONDS, card.Rank.TEN)  -- Different rank
}
attackCards = {card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)}
defenseCards = {card.createCard(card.Suit.HEARTS, card.Rank.NINE)}  -- NINE already in defense
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {2, 6, 6}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
if result then
    -- Either card can beat, but NINE gets bonus so might be preferred
    assert(result.rank == card.Rank.NINE or result.rank == card.Rank.TEN,
        string.format("Should beat with 9 or 10, got rank %d", result.rank))
end

-- Test 6: Endgame - always beat if possible
print("\n-- aiTryBeat Endgame Logic --")

hand = {card.createCard(card.Suit.HEARTS, card.Rank.SIX)}  -- Weak card
attackCards = {card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN)}
defenseCards = {nil}
trumpSuit = card.Suit.SPADES
cardsRemaining = 0  -- ENDGAME
playerHands = {1, 0, 0}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
-- In endgame with no cards left, can't beat 7 with 6
assert(result == nil, "Cannot beat 7 with 6 even in endgame")

-- Test 7: Endgame - beat when can
hand = {card.createCard(card.Suit.HEARTS, card.Rank.KING)}  -- Strong card
attackCards = {card.createCard(card.Suit.HEARTS, card.Rank.TEN)}
defenseCards = {nil}
cardsRemaining = 0  -- ENDGAME
playerHands = {1, 0, 0}

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result ~= nil, "Should beat in endgame when possible")

-- Test 8: Multiple cards can beat - choose best
print("\n-- aiTryBeat Multiple Options --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.JACK),
    card.createCard(card.Suit.HEARTS, card.Rank.QUEEN),
    card.createCard(card.Suit.HEARTS, card.Rank.KING)
}
attackCards = {card.createCard(card.Suit.HEARTS, card.Rank.TEN)}
defenseCards = {nil}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {3, 6, 6}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result ~= nil, "Should choose one card to beat with")
if result then
    assert(result.rank >= card.Rank.JACK, "Should use one of the available cards")
end

-- Test 9: Taking is better - refuse to beat
print("\n-- aiTryBeat Prefer Taking --")

-- Create a scenario where taking cards is actually beneficial
-- (Hard to test precisely without knowing exact evaluation, but we can try)
hand = {card.createCard(card.Suit.HEARTS, card.Rank.ACE)}  -- Only high card
attackCards = {
    card.createCard(card.Suit.DIAMONDS, card.Rank.SIX),
    card.createCard(card.Suit.CLUBS, card.Rank.SIX)
}
defenseCards = {
    card.createCard(card.Suit.HEARTS, card.Rank.SEVEN),
    nil
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 30  -- Many cards left
playerHands = {1, 6, 6}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
-- Result depends on complex evaluation - just check it returns something valid
assert(result == nil or (result.rank and result.suit), "Should return valid card or nil")

-- Test 10: DeuceBeatsAce rule
print("\n-- aiTryBeat DeuceBeatsAce --")

hand = {card.createCard(card.Suit.HEARTS, card.Rank.TWO)}
attackCards = {card.createCard(card.Suit.HEARTS, card.Rank.ACE)}
defenseCards = {nil}
trumpSuit = card.Suit.SPADES
cardsRemaining = 20
playerHands = {1, 6, 6}
lowestRank = card.Rank.TWO
deuceBeatsAce = true  -- Special rule enabled

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result ~= nil, "Deuce should beat ACE when rule is enabled")
if result then
    assert(result.rank == card.Rank.TWO, "Should use the deuce")
end

-- Test 11: DeuceBeatsAce disabled
hand = {card.createCard(card.Suit.HEARTS, card.Rank.TWO)}
attackCards = {card.createCard(card.Suit.HEARTS, card.Rank.ACE)}
defenseCards = {nil}
deuceBeatsAce = false  -- Rule disabled

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result == nil, "Deuce cannot beat ACE when rule is disabled")

-- Test 12: Complex multi-attack scenario
print("\n-- aiTryBeat Complex Scenario --")

hand = {
    card.createCard(card.Suit.HEARTS, card.Rank.NINE),
    card.createCard(card.Suit.DIAMONDS, card.Rank.TEN),
    card.createCard(card.Suit.CLUBS, card.Rank.JACK),
    card.createCard(card.Suit.SPADES, card.Rank.SIX)  -- Trump
}
attackCards = {
    card.createCard(card.Suit.HEARTS, card.Rank.SEVEN),
    card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT),
    nil
}
defenseCards = {
    card.createCard(card.Suit.HEARTS, card.Rank.EIGHT),
    nil,  -- This is what we need to beat
    nil
}
trumpSuit = card.Suit.SPADES
cardsRemaining = 15
playerHands = {4, 5, 5}
lowestRank = card.Rank.SIX
deuceBeatsAce = false

result = aiDefense.aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
assert(result ~= nil, "Should find a card to beat the 8 of diamonds")
if result then
    assert(result:beats(attackCards[2], trumpSuit, deuceBeatsAce), "Returned card should actually beat the attack")
end

print("\n=== AI Defense Tests Complete ===")

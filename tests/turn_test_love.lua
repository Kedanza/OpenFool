-- Turn Management Tests

local turn = require("turn")
local card = require("card")
local deck = require("deck")
local player = require("player")

print("\n=== Turn Management Module Tests ===")

-- Test 1: endTurn - Cards to discard pile
print("\n--- endTurn Discard Pile Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2),
        player.createPlayer("P3", 3),
        player.createPlayer("P4", 4)
    }
    
    local attackCards = {
        card.createCard(card.Suit.SPADES, card.Rank.SIX),
        card.createCard(card.Suit.HEARTS, card.Rank.SEVEN),
        nil, nil, nil, nil
    }
    
    local defenseCards = {
        card.createCard(card.Suit.SPADES, card.Rank.KING),
        card.createCard(card.Suit.HEARTS, card.Rank.ACE),
        nil, nil, nil, nil
    }
    
    local testDeck = deck.createDeck(card.Rank.SIX)
    local discardPile = {}
    local outOfPlay = {false, false, false, false}
    
    outOfPlay = turn.endTurn(-1, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    assert(#discardPile == 4, "Discard pile should have 4 cards")
    assert(attackCards[1] == nil, "Attack cards should be cleared")
    assert(defenseCards[1] == nil, "Defense cards should be cleared")
end

-- Test 2: endTurn - Cards to player (failed defense)
print("\n--- endTurn Player Takes Cards Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2)
    }
    
    -- Give each player some cards first
    for i = 1, 3 do
        players[1]:addCard(card.createCard(card.Suit.SPADES, i))
        players[2]:addCard(card.createCard(card.Suit.HEARTS, i))
    end
    
    local attackCards = {
        card.createCard(card.Suit.CLUBS, card.Rank.SIX),
        card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN),
        nil, nil, nil, nil
    }
    
    local defenseCards = {
        card.createCard(card.Suit.CLUBS, card.Rank.EIGHT),
        nil, nil, nil, nil, nil
    }
    
    local testDeck = deck.createDeck(card.Rank.SIX)
    local discardPile = {}
    local outOfPlay = {false, false}
    
    local initialHandSize = players[2]:handSize()
    
    outOfPlay = turn.endTurn(2, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    assert(players[2]:handSize() == initialHandSize + 3, "Player 2 should have received 3 cards from table")
    assert(#discardPile == 0, "Discard pile should be empty")
end

-- Test 3: endTurn - Deal cards from deck
print("\n--- endTurn Deal Cards Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2)
    }
    
    -- Give P1 3 cards, P2 5 cards
    for i = 1, 3 do
        players[1]:addCard(card.createCard(card.Suit.SPADES, i))
    end
    for i = 1, 5 do
        players[2]:addCard(card.createCard(card.Suit.HEARTS, i))
    end
    
    local attackCards = {nil, nil, nil, nil, nil, nil}
    local defenseCards = {nil, nil, nil, nil, nil, nil}
    
    local testDeck = deck.createDeck(card.Rank.SIX)
    local discardPile = {}
    local outOfPlay = {false, false}
    
    local deckBefore = testDeck:remaining()
    
    outOfPlay = turn.endTurn(-1, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    assert(players[1]:handSize() == 6, "P1 should have 6 cards (drew 3)")
    assert(players[2]:handSize() == 6, "P2 should have 6 cards (drew 1)")
    assert(testDeck:remaining() == deckBefore - 4, "Deck should have 4 fewer cards")
end

-- Test 4: endTurn - Out of play detection
print("\n--- endTurn Out of Play Detection Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2),
        player.createPlayer("P3", 3)
    }
    
    -- P1 has no cards, others have cards
    players[2]:addCard(card.createCard(card.Suit.SPADES, card.Rank.SIX))
    players[3]:addCard(card.createCard(card.Suit.HEARTS, card.Rank.SEVEN))
    
    local attackCards = {nil, nil, nil, nil, nil, nil}
    local defenseCards = {nil, nil, nil, nil, nil, nil}
    
    -- Empty deck (trigger out-of-play check)
    local testDeck = deck.createDeck(card.Rank.NINE)
    for i = 1, 24 do
        testDeck:draw()
    end
    
    local discardPile = {}
    local outOfPlay = {false, false, false}
    
    outOfPlay = turn.endTurn(-1, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    assert(outOfPlay[1] == true, "P1 should be out of play (no cards)")
    assert(outOfPlay[2] == false, "P2 should still be in play")
    assert(outOfPlay[3] == false, "P3 should still be in play")
end

-- Test 5: endTurn - Empty deck no more draws
print("\n--- endTurn Empty Deck Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2)
    }
    
    players[1]:addCard(card.createCard(card.Suit.SPADES, card.Rank.SIX))
    
    local attackCards = {nil, nil, nil, nil, nil, nil}
    local defenseCards = {nil, nil, nil, nil, nil, nil}
    
    -- Empty deck
    local testDeck = deck.createDeck(card.Rank.NINE)
    for i = 1, 24 do
        testDeck:draw()
    end
    
    local discardPile = {}
    local outOfPlay = {false, false}
    
    outOfPlay = turn.endTurn(-1, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    assert(players[1]:handSize() == 1, "P1 should still have 1 card (no draws from empty deck)")
    assert(players[2]:handSize() == 0, "P2 should still have 0 cards")
end

-- Test 6: getNextPlayerIndex - Normal rotation
print("\n--- getNextPlayerIndex Tests ---")
do
    local outOfPlay = {false, false, false, false}
    
    local next = turn.getNextPlayerIndex(1, 4, outOfPlay, false)
    assert(next == 2, "Next after P1 should be P2")
    
    next = turn.getNextPlayerIndex(4, 4, outOfPlay, false)
    assert(next == 1, "Next after P4 should wrap to P1")
end

-- Test 7: getNextPlayerIndex - Skip out-of-play players
print("\n--- getNextPlayerIndex Skip Out-of-Play Tests ---")
do
    local outOfPlay = {false, true, false, true}
    
    local next = turn.getNextPlayerIndex(1, 4, outOfPlay, false)
    assert(next == 3, "Next after P1 should skip P2 (out) and be P3")
    
    next = turn.getNextPlayerIndex(3, 4, outOfPlay, false)
    assert(next == 1, "Next after P3 should skip P4 (out) and wrap to P1")
end

-- Test 8: getNextPlayerIndex - Team play
print("\n--- getNextPlayerIndex Team Play Tests ---")
do
    local outOfPlay = {false, true, false, false}
    
    -- In team play, if next player is out, use their teammate
    local next = turn.getNextPlayerIndex(1, 4, outOfPlay, true)
    assert(next == 3, "Team play: P2 is out, so next is P3 (teammate)")
end

-- Test 9: getCurrentAttacker
print("\n--- getCurrentAttacker Tests ---")
do
    local outOfPlay = {false, false, false, false}
    
    local attacker = turn.getCurrentAttacker(1, 4, outOfPlay, false)
    assert(attacker == 1, "Attacker 1 should remain 1 when not out")
    
    outOfPlay[2] = true
    attacker = turn.getCurrentAttacker(2, 4, outOfPlay, false)
    assert(attacker == 3, "Attacker 2 (out) should become 3")
end

-- Test 10: getCurrentAttacker - Team play
print("\n--- getCurrentAttacker Team Play Tests ---")
do
    local outOfPlay = {true, false, false, false}
    
    local attacker = turn.getCurrentAttacker(1, 4, outOfPlay, true)
    assert(attacker == 2, "Team play: P1 out, teammate P2 attacks")
end

-- Test 11: getCurrentDefender
print("\n--- getCurrentDefender Tests ---")
do
    local outOfPlay = {false, false, false, false}
    
    local defender = turn.getCurrentDefender(1, 4, outOfPlay, false)
    assert(defender == 2, "Defender after P1 should be P2")
    
    defender = turn.getCurrentDefender(4, 4, outOfPlay, false)
    assert(defender == 1, "Defender after P4 should wrap to P1")
end

-- Test 12: getCurrentDefender - Skip out-of-play
print("\n--- getCurrentDefender Skip Out-of-Play Tests ---")
do
    local outOfPlay = {false, true, false, false}
    
    local defender = turn.getCurrentDefender(1, 4, outOfPlay, false)
    assert(defender == 3, "Defender should skip P2 (out) and be P3")
end

-- Test 13: getCurrentDefender - Team play
print("\n--- getCurrentDefender Team Play Tests ---")
do
    local outOfPlay = {false, true, false, false}
    
    local defender = turn.getCurrentDefender(1, 4, outOfPlay, true)
    assert(defender == 3, "Team play: P2 out, teammate P3 defends")
end

-- Test 14: isGameOver - Solo mode
print("\n--- isGameOver Solo Mode Tests ---")
do
    local outOfPlay = {false, false, false, false}
    
    assert(not turn.isGameOver(outOfPlay, false), "Game not over with 4 active players")
    
    outOfPlay = {false, true, true, true}
    assert(turn.isGameOver(outOfPlay, false), "Game over with 1 active player")
    
    outOfPlay = {true, true, true, true}
    assert(turn.isGameOver(outOfPlay, false), "Game over with 0 active players")
end

-- Test 15: isGameOver - Team mode
print("\n--- isGameOver Team Mode Tests ---")
do
    local outOfPlay = {false, false, false, false}
    
    assert(not turn.isGameOver(outOfPlay, true), "Game not over with all active")
    
    outOfPlay = {true, false, true, false}
    assert(turn.isGameOver(outOfPlay, true), "Game over when Team 1 (P1+P3) is out")
    
    outOfPlay = {false, true, false, true}
    assert(turn.isGameOver(outOfPlay, true), "Game over when Team 2 (P2+P4) is out")
    
    outOfPlay = {true, false, false, true}
    assert(not turn.isGameOver(outOfPlay, true), "Game not over when both teams have 1 player")
end

-- Test 16: determineWinner - Solo mode
print("\n--- determineWinner Solo Mode Tests ---")
do
    local outOfPlay = {false, true, true, true}
    
    local winner = turn.determineWinner(outOfPlay, false)
    assert(winner == 1, "P1 is the loser (only one remaining)")
    
    outOfPlay = {true, true, false, true}
    winner = turn.determineWinner(outOfPlay, false)
    assert(winner == 3, "P3 is the loser")
    
    outOfPlay = {true, true, true, true}
    winner = turn.determineWinner(outOfPlay, false)
    assert(winner == 0, "Draw when all players are out")
end

-- Test 17: determineWinner - Team mode
print("\n--- determineWinner Team Mode Tests ---")
do
    local outOfPlay = {true, false, true, false}
    
    local winner = turn.determineWinner(outOfPlay, true)
    assert(winner == "team2", "Team 2 wins when Team 1 is out")
    
    outOfPlay = {false, true, false, true}
    winner = turn.determineWinner(outOfPlay, true)
    assert(winner == "team1", "Team 1 wins when Team 2 is out")
end

-- Test 18: endTurn - Deal priority (attacker first)
print("\n--- endTurn Deal Priority Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2),
        player.createPlayer("P3", 3)
    }
    
    -- P1 has 4 cards, P2 has 5, P3 has 6
    for i = 1, 4 do
        players[1]:addCard(card.createCard(card.Suit.SPADES, i))
    end
    for i = 1, 5 do
        players[2]:addCard(card.createCard(card.Suit.HEARTS, i))
    end
    for i = 1, 6 do
        players[3]:addCard(card.createCard(card.Suit.CLUBS, i))
    end
    
    local attackCards = {nil, nil, nil, nil, nil, nil}
    local defenseCards = {nil, nil, nil, nil, nil, nil}
    
    -- Small deck with only 5 cards
    local testDeck = deck.createDeck(card.Rank.NINE)
    for i = 1, 19 do
        testDeck:draw()
    end
    
    assert(testDeck:remaining() == 5, "Deck should have 5 cards")
    
    local discardPile = {}
    local outOfPlay = {false, false, false}
    
    outOfPlay = turn.endTurn(-1, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    -- P1 should get 2 cards (4 -> 6), P2 should get 1 card (5 -> 6), P3 gets none
    -- Deck has 5 cards, P1 draws 2, P2 draws 1, total = 3 drawn, 2 remaining
    assert(players[1]:handSize() == 6, "P1 should have 6 cards")
    assert(players[2]:handSize() == 6, "P2 should have 6 cards")
    assert(players[3]:handSize() == 6, "P3 should have 6 cards")
    assert(testDeck:remaining() == 2, "Deck should have 2 cards remaining")
end

-- Test 19: endTurn - Deck runs out mid-deal
print("\n--- endTurn Deck Exhaustion Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2)
    }
    
    -- P1 has 3 cards, P2 has 5 cards
    for i = 1, 3 do
        players[1]:addCard(card.createCard(card.Suit.SPADES, i))
    end
    for i = 1, 5 do
        players[2]:addCard(card.createCard(card.Suit.HEARTS, i))
    end
    
    local attackCards = {nil, nil, nil, nil, nil, nil}
    local defenseCards = {nil, nil, nil, nil, nil, nil}
    
    -- Deck with only 2 cards
    local testDeck = deck.createDeck(card.Rank.NINE)
    for i = 1, 22 do
        testDeck:draw()
    end
    
    assert(testDeck:remaining() == 2, "Deck should have 2 cards")
    
    local discardPile = {}
    local outOfPlay = {false, false}
    
    outOfPlay = turn.endTurn(-1, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    -- P1 needs 3 cards but only 2 available
    assert(players[1]:handSize() == 5, "P1 should have 5 cards (drew 2, deck exhausted)")
    assert(players[2]:handSize() == 5, "P2 should have 5 cards (no draws)")
    assert(testDeck:remaining() == 0, "Deck should be empty")
end

-- Test 20: endTurn - Multiple players become out of play
print("\n--- endTurn Multiple Out of Play Tests ---")
do
    local players = {
        player.createPlayer("P1", 1),
        player.createPlayer("P2", 2),
        player.createPlayer("P3", 3)
    }
    
    -- P2 has 1 card, others have none
    players[2]:addCard(card.createCard(card.Suit.HEARTS, card.Rank.SIX))
    
    local attackCards = {nil, nil, nil, nil, nil, nil}
    local defenseCards = {nil, nil, nil, nil, nil, nil}
    
    -- Empty deck
    local testDeck = deck.createDeck(card.Rank.NINE)
    for i = 1, 24 do
        testDeck:draw()
    end
    
    local discardPile = {}
    local outOfPlay = {false, false, false}
    
    outOfPlay = turn.endTurn(-1, attackCards, defenseCards, players, testDeck, discardPile, outOfPlay)
    
    assert(outOfPlay[1] == true, "P1 should be out (no cards)")
    assert(outOfPlay[2] == false, "P2 should not be out (has 1 card)")
    assert(outOfPlay[3] == true, "P3 should be out (no cards)")
end

print("\n=== Turn Management Tests Complete ===")

return true

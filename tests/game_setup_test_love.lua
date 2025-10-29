-- game_setup_test_love.lua
-- Comprehensive tests for game setup functionality

local GameSetup = require("game_setup")
local RuleSet = require("ruleset")
local Card = require("card")
local Rank = Card.Rank
local Suit = Card.Suit

print("\n=== Game Setup Module Tests ===\n")

-- Helper function
local function countTests(name)
    print("\n-- " .. name .. " --")
end

-- Basic Setup Tests
countTests("Basic Setup Tests")

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    assert(#game.players == 4, "Should create 4 players")
    assert(game.deck ~= nil, "Should have deck")
    assert(game.trumpSuit ~= nil, "Should have trump suit")
    assert(game.trumpCard ~= nil, "Should have trump card")
    assert(game.attackCards ~= nil, "Should have attack cards array")
    assert(game.defenseCards ~= nil, "Should have defense cards array")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.playerCount = 2
    local game = GameSetup.setupGame(ruleSet)
    assert(#game.players == 2, "Should create 2 players")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.playerCount = 5
    local game = GameSetup.setupGame(ruleSet)
    assert(#game.players == 5, "Should create 5 players")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.playerCount = 1
    local success, err = pcall(function() GameSetup.setupGame(ruleSet) end)
    assert(not success, "Should reject player count < 2")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.playerCount = 6
    local success, err = pcall(function() GameSetup.setupGame(ruleSet) end)
    assert(not success, "Should reject player count > 5")
end

do
    local success, err = pcall(function() GameSetup.setupGame(nil) end)
    assert(not success, "Should require ruleSet parameter")
end

-- Card Dealing Tests
countTests("Card Dealing Tests")

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    for i = 1, #game.players do
        assert(game.players[i]:handSize() == 6, "Player " .. i .. " should have 6 cards")
    end
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    local seenCards = {}
    for i = 1, #game.players do
        for _, card in ipairs(game.players[i].hand) do
            if card then
                local key = card.suit .. "-" .. card.rank
                assert(seenCards[key] == nil, "No duplicate cards")
                seenCards[key] = true
            end
        end
    end
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.playerCount = 4
    ruleSet.lowestRank = Rank.SIX  -- 36 card deck
    local game = GameSetup.setupGame(ruleSet)
    -- 4 players * 6 cards = 24 dealt, 36 - 24 = 12 remaining
    assert(game.deck:remaining() == 12, "Should have 12 cards remaining in deck")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.lowestRank = Rank.DEUCE
    ruleSet.playerCount = 4
    local game = GameSetup.setupGame(ruleSet)
    -- 4 * 6 = 24 dealt, 52 - 24 = 28 remaining
    assert(game.deck:remaining() == 28, "52-card deck should have 28 remaining")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.lowestRank = Rank.NINE
    ruleSet.playerCount = 2
    local game = GameSetup.setupGame(ruleSet)
    -- 2 * 6 = 12 dealt, 24 - 12 = 12 remaining
    assert(game.deck:remaining() == 12, "24-card deck should have 12 remaining")
end

-- Trump Determination Tests
countTests("Trump Determination Tests")

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    assert(game.trumpSuit ~= nil, "Should set trump suit")
    assert(game.trumpCard ~= nil, "Should set trump card")
    assert(game.trumpCard.suit == game.trumpSuit, "Trump card suit should match trump suit")
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    local validSuits = {
        [Suit.SPADES] = true,
        [Suit.HEARTS] = true,
        [Suit.DIAMONDS] = true,
        [Suit.CLUBS] = true
    }
    assert(validSuits[game.trumpSuit], "Trump suit should be valid")
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    -- Trump card should still be in deck
    local trumpInDeck = false
    for _, card in ipairs(game.deck.cards) do
        if card and card == game.trumpCard then
            trumpInDeck = true
            break
        end
    end
    assert(trumpInDeck, "Trump card should remain in deck")
end

-- First Attacker Tests
countTests("First Attacker Tests")

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    assert(game.firstAttacker ~= nil, "Should find first attacker")
    assert(type(game.firstAttacker) == "number", "First attacker should be number")
    assert(game.firstAttacker >= 1 and game.firstAttacker <= #game.players, "First attacker should be valid player index")
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    assert(game.currentAttacker == game.firstAttacker, "Current attacker should be first attacker")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.playerCount = 4
    local game = GameSetup.setupGame(ruleSet)
    local expectedDefender = (game.firstAttacker % 4) + 1
    assert(game.currentDefender == expectedDefender, "Current defender should be next player")
end

-- findFirstAttacker Function Tests
countTests("findFirstAttacker Function Tests")

do
    local Player = require("player")
    local players = {
        Player.createPlayer("P1", 1),
        Player.createPlayer("P2", 2),
        Player.createPlayer("P3", 3)
    }
    players[1]:addCard(Card.createCard(Suit.SPADES, Rank.KING))
    players[2]:addCard(Card.createCard(Suit.SPADES, Rank.SIX))
    players[3]:addCard(Card.createCard(Suit.HEARTS, Rank.SIX))
    local firstAttacker = GameSetup.findFirstAttacker(players, Suit.SPADES, false)
    assert(firstAttacker == 2, "Should find player with six of spades (trump)")
end

do
    local Player = require("player")
    local players = {
        Player.createPlayer("P1", 1),
        Player.createPlayer("P2", 2)
    }
    players[1]:addCard(Card.createCard(Suit.HEARTS, Rank.EIGHT))
    players[2]:addCard(Card.createCard(Suit.HEARTS, Rank.SEVEN))
    local firstAttacker = GameSetup.findFirstAttacker(players, Suit.HEARTS, false)
    assert(firstAttacker == 2, "Should prefer seven over eight (trump)")
end

do
    local Player = require("player")
    local players = {
        Player.createPlayer("P1", 1),
        Player.createPlayer("P2", 2)
    }
    players[1]:addCard(Card.createCard(Suit.CLUBS, Rank.ACE))
    players[2]:addCard(Card.createCard(Suit.CLUBS, Rank.SIX))
    local firstAttacker = GameSetup.findFirstAttacker(players, Suit.CLUBS, false)
    assert(firstAttacker == 2, "Six should be lower than Ace")
end

do
    local Player = require("player")
    local players = {
        Player.createPlayer("P1", 1),
        Player.createPlayer("P2", 2),
        Player.createPlayer("P3", 3)
    }
    players[1]:addCard(Card.createCard(Suit.DIAMONDS, Rank.DEUCE))
    players[2]:addCard(Card.createCard(Suit.DIAMONDS, Rank.THREE))
    players[3]:addCard(Card.createCard(Suit.DIAMONDS, Rank.ACE))
    local firstAttacker = GameSetup.findFirstAttacker(players, Suit.DIAMONDS, true)
    assert(firstAttacker == 2, "Three should be lowest (Deuce and Ace are high)")
end

do
    local Player = require("player")
    local players = {
        Player.createPlayer("P1", 1),
        Player.createPlayer("P2", 2)
    }
    players[1]:addCard(Card.createCard(Suit.SPADES, Rank.KING))
    players[2]:addCard(Card.createCard(Suit.SPADES, Rank.QUEEN))
    local firstAttacker = GameSetup.findFirstAttacker(players, Suit.HEARTS, false)
    assert(firstAttacker == 1, "Should return player 1 if no trump cards exist")
end

-- Initialization Arrays Tests
countTests("Initialization Arrays Tests")

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    for i = 1, 6 do
        assert(game.attackCards[i] == nil, "Attack cards should be initialized with nils")
    end
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    for i = 1, 6 do
        assert(game.defenseCards[i] == nil, "Defense cards should be initialized with nils")
    end
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    for i = 1, #game.players do
        assert(game.outOfPlay[i] == false, "outOfPlay should be initialized with falses")
    end
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    for i = 1, #game.players do
        assert(game.playerDoneStatuses[i] == false, "playerDoneStatuses should be initialized with falses")
    end
end

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    assert(game.discardPile ~= nil, "Should create discard pile")
    assert(#game.discardPile == 0, "Discard pile should be empty")
end

-- Complete Game State Tests
countTests("Complete Game State Tests")

do
    local ruleSet = RuleSet.createRuleSet()
    local game = GameSetup.setupGame(ruleSet)
    assert(game.players ~= nil, "Should return players")
    assert(game.deck ~= nil, "Should return deck")
    assert(game.trumpSuit ~= nil, "Should return trumpSuit")
    assert(game.trumpCard ~= nil, "Should return trumpCard")
    assert(game.attackCards ~= nil, "Should return attackCards")
    assert(game.defenseCards ~= nil, "Should return defenseCards")
    assert(game.discardPile ~= nil, "Should return discardPile")
    assert(game.outOfPlay ~= nil, "Should return outOfPlay")
    assert(game.playerDoneStatuses ~= nil, "Should return playerDoneStatuses")
    assert(game.firstAttacker ~= nil, "Should return firstAttacker")
    assert(game.currentAttacker ~= nil, "Should return currentAttacker")
    assert(game.currentDefender ~= nil, "Should return currentDefender")
    assert(game.ruleSet ~= nil, "Should return ruleSet")
end

do
    local ruleSet = RuleSet.createRuleSet()
    ruleSet.playerCount = 3
    ruleSet.allowPass = false
    local game = GameSetup.setupGame(ruleSet)
    assert(game.ruleSet == ruleSet, "Should preserve ruleSet reference")
    assert(game.ruleSet.playerCount == 3, "RuleSet playerCount should be 3")
    assert(game.ruleSet.allowPass == false, "RuleSet allowPass should be false")
end

print("\n=== Game Setup Tests Complete ===\n")

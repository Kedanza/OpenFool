-- game_setup.lua
-- Game initialization and setup functionality
-- Migrated from GameScreen.kt init block

local Player = require("player")
local Deck = require("deck")
local Card = require("card")

local GameSetup = {}

-- Constants
local DEAL_LIMIT = 6

-- Create a new game setup
-- @param ruleSet The RuleSet configuration
-- @return table Game state with players, deck, trump, etc.
function GameSetup.setupGame(ruleSet)
    if not ruleSet then
        error("RuleSet is required for game setup")
    end
    
    -- Validate player count
    if ruleSet.playerCount < 2 or ruleSet.playerCount > 5 then
        error("Invalid player count: " .. tostring(ruleSet.playerCount))
    end
    
    -- Create deck
    local deck = require("deck").createDeck(ruleSet.lowestRank)
    deck:shuffle()
    
    -- Create players
    local playerNames = {"South", "West", "North", "East", "Center"}
    local players = {}
    for i = 1, ruleSet.playerCount do
        players[i] = Player.createPlayer(playerNames[i], i)
    end
    
    -- Initialize game state tables
    local attackCards = {}
    local defenseCards = {}
    for i = 1, DEAL_LIMIT do
        attackCards[i] = nil
        defenseCards[i] = nil
    end
    
    local outOfPlay = {}
    local playerDoneStatuses = {}
    for i = 1, ruleSet.playerCount do
        outOfPlay[i] = false
        playerDoneStatuses[i] = false
    end
    
    -- Deal initial cards to all players
    for i = 1, ruleSet.playerCount do
        for j = 1, DEAL_LIMIT do
            local card = deck:draw()
            if card then
                players[i]:addCard(card)
            end
        end
    end
    
    -- Determine trump suit (first card in deck after dealing)
    local trumpCard = deck.cards[1]
    if not trumpCard then
        error("No trump card available - deck empty after dealing")
    end
    local trumpSuit = trumpCard.suit
    
    -- Find first attacker (player with lowest trump card)
    local firstAttacker = GameSetup.findFirstAttacker(players, trumpSuit, ruleSet.deuceBeatsAce)
    
    -- Create discard pile
    local discardPile = {}
    
    -- Return complete game state
    return {
        players = players,
        deck = deck,
        trumpSuit = trumpSuit,
        trumpCard = trumpCard,
        attackCards = attackCards,
        defenseCards = defenseCards,
        discardPile = discardPile,
        outOfPlay = outOfPlay,
        playerDoneStatuses = playerDoneStatuses,
        firstAttacker = firstAttacker,
        currentAttacker = firstAttacker,
        currentDefender = (firstAttacker % ruleSet.playerCount) + 1,
        ruleSet = ruleSet
    }
end

-- Find the player with the lowest trump card
-- This player becomes the first attacker
-- @param players Array of Player objects
-- @param trumpSuit The trump suit
-- @param deuceBeatsAce Whether deuces beat aces
-- @return number Index of first attacker (1-based)
function GameSetup.findFirstAttacker(players, trumpSuit, deuceBeatsAce)
    local lowestTrump = nil
    local lowestTrumpValue = math.huge
    local firstAttacker = 1
    
    local Rank = require("card").Rank
    
    for i, player in ipairs(players) do
        for _, card in ipairs(player.hand) do
            if card and card.suit == trumpSuit then
                local cardValue = card.rank
                
                -- Handle ACE special case
                if card.rank == Rank.ACE then
                    if deuceBeatsAce then
                        cardValue = 1000  -- ACE is highest when deuce beats ace
                    else
                        cardValue = 15  -- ACE is highest normally
                    end
                end
                
                -- Handle DEUCE special case
                if card.rank == Rank.DEUCE and deuceBeatsAce then
                    cardValue = 16  -- DEUCE is highest when deuceBeatsAce
                end
                
                -- Check if this is the lowest trump so far
                if lowestTrump == nil or cardValue < lowestTrumpValue then
                    lowestTrump = card
                    lowestTrumpValue = cardValue
                    firstAttacker = i
                end
            end
        end
    end
    
    return firstAttacker
end

-- Redeal check - verify game is playable
-- A redeal is needed if a player has 5 or 6 cards of the same rank
-- @param players Array of Player objects
-- @return boolean true if redeal is needed
function GameSetup.needsRedeal(players)
    for _, player in ipairs(players) do
        local rankCounts = {}
        
        -- Count cards of each rank
        for _, card in ipairs(player.hand) do
            if card then
                local rank = card.rank
                rankCounts[rank] = (rankCounts[rank] or 0) + 1
                
                -- If any rank appears 5+ times, need redeal
                if rankCounts[rank] >= 5 then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Setup game with automatic redeal if needed
-- @param ruleSet The RuleSet configuration
-- @param maxRedeals Maximum number of redeal attempts (default 10)
-- @return table Game state
function GameSetup.setupGameWithRedeal(ruleSet, maxRedeals)
    maxRedeals = maxRedeals or 10
    local attempts = 0
    
    while attempts < maxRedeals do
        local gameState = GameSetup.setupGame(ruleSet)
        
        if not GameSetup.needsRedeal(gameState.players) then
            return gameState
        end
        
        attempts = attempts + 1
    end
    
    -- After max attempts, return the last deal anyway
    return GameSetup.setupGame(ruleSet)
end

return GameSetup

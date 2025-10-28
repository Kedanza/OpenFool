-- ai_evaluation.lua
-- AI Hand Evaluation System - The heart of OpenFool AI logic
-- Translates Player.kt handValue() and relativeCardValue()

-- Constants (from Player.kt companion object)
local RANK_MULTIPLIER = 100
local UNBALANCED_HAND_PENALTY = 200
local MANY_CARDS_PENALTY = 600
local OUT_OF_PLAY = 30000

-- Bonuses for cards of same rank
-- Index: number of cards with same rank (0-4)
-- bonuses[1] = 0 cards, bonuses[2] = 1 card, bonuses[3] = 2 cards (pair), etc.
local RANK_BONUSES = {0.0, 0.0, 0.5, 0.75, 1.25}

---Calculate relative card value based on deck composition
---@param rankValue number The rank value (1-13, where 1=ACE, 11=JACK, 12=QUEEN, 13=KING)
---@param lowestRank number The lowest rank in play (from RuleSet)
---@return number The relative card value
local function getRelativeCardValue(rankValue, lowestRank)
    -- Calculate number of ranks in play
    -- Example: If lowestRank = 6, then ranks 6,7,8,9,10,J,Q,K,A = 9 ranks
    local ranksInPlay = (14 - lowestRank) % 13 + 1
    local maxValue = ranksInPlay / 2.0
    
    -- ACE (value 1) has special handling - it gets the maximum value
    if rankValue == 1 then
        return maxValue
    else
        -- Other cards: value increases with rank, centered around 0
        -- Lower cards get negative values, higher cards get positive values
        return (rankValue + maxValue - 14)
    end
end

---Evaluate a hand's total value
---This is the core AI evaluation function that considers:
--- - Base card values
--- - Trump bonuses
--- - Multiple rank bonuses (pairs, triples)
--- - Suit balance penalties
--- - Too many cards penalty
---@param hand table Array of Card objects
---@param trumpSuit number The trump suit (0-3)
---@param cardsRemaining number Cards remaining in the deck
---@param playerHands table Array of hand sizes for all players
---@param lowestRank number The lowest rank in play (from RuleSet)
---@return number The total hand value (higher is better)
local function evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    -- Special case: Player is out of the game (no cards left and deck is empty)
    if cardsRemaining == 0 and #hand == 0 then
        return OUT_OF_PLAY
    end
    
    local totalScore = 0
    
    -- Initialize counters
    local countsByRank = {}  -- Count of cards for each rank (1-13)
    local countsBySuit = {}  -- Count of cards for each suit (0-3)
    
    for i = 1, 13 do
        countsByRank[i] = 0
    end
    
    for i = 0, 3 do
        countsBySuit[i] = 0
    end
    
    -- STEP 1: Calculate base score from card values + trump bonuses
    for _, c in ipairs(hand) do
        local rankValue = c.rank  -- rank is directly the number (1-13)
        local suitValue = c.suit  -- suit is directly the number (0-3)
        
        -- Add base card value
        local relativeValue = getRelativeCardValue(rankValue, lowestRank)
        totalScore = totalScore + math.floor(relativeValue * RANK_MULTIPLIER)
        
        -- Add trump bonus (13 * RANK_MULTIPLIER = 1300)
        if c.suit == trumpSuit then
            totalScore = totalScore + (13 * RANK_MULTIPLIER)
        end
        
        -- Update counters
        countsByRank[rankValue] = countsByRank[rankValue] + 1
        countsBySuit[suitValue] = countsBySuit[suitValue] + 1
    end
    
    -- STEP 2: Add bonuses for multiple cards of same rank
    -- Having pairs/triples is good for defense
    for i = 1, 13 do
        local count = countsByRank[i] or 0
        local relativeValue = getRelativeCardValue(i, lowestRank)
        local bonus = RANK_BONUSES[count + 1] or 0  -- +1 because Lua arrays start at 1
        totalScore = totalScore + math.floor(math.max(relativeValue, 1.0) * bonus)
    end
    
    -- STEP 3: Apply penalty for unbalanced suit distribution
    -- Calculate average non-trump cards per suit
    local nonTrumpCards = 0
    for _, c in ipairs(hand) do
        if c.suit ~= trumpSuit then
            nonTrumpCards = nonTrumpCards + 1
        end
    end
    
    local avgSuit = nonTrumpCards / 3.0
    
    -- Penalize deviation from average for each non-trump suit
    -- Only apply this penalty if we have enough cards to be balanced (>= 3 non-trump cards)
    -- All suits: 0=SPADES, 1=DIAMONDS, 2=CLUBS, 3=HEARTS
    if nonTrumpCards >= 3 then
        for suitValue = 0, 3 do
            if suitValue ~= trumpSuit then
                local count = countsBySuit[suitValue]
                if avgSuit > 0 then
                    local deviation = math.abs((count - avgSuit) / avgSuit)
                    local penalty = math.floor(UNBALANCED_HAND_PENALTY * deviation)
                    totalScore = totalScore - penalty
                end
            end
        end
    end
    
    -- STEP 4: Apply penalty for having too many cards
    -- Calculate total cards in play (excluding our hand)
    local cardsInPlay = cardsRemaining
    for _, handSize in ipairs(playerHands) do
        cardsInPlay = cardsInPlay + handSize
    end
    cardsInPlay = cardsInPlay - #hand
    
    -- Calculate card ratio and apply penalty
    local cardRatio
    if cardsInPlay ~= 0 then
        cardRatio = #hand / cardsInPlay
    else
        cardRatio = 10.0  -- Very high ratio if no other cards in play
    end
    
    totalScore = totalScore + math.floor((0.25 - cardRatio) * MANY_CARDS_PENALTY)
    
    return totalScore
end

return {
    getRelativeCardValue = getRelativeCardValue,
    evaluateHand = evaluateHand,
    
    -- Export constants for testing
    RANK_MULTIPLIER = RANK_MULTIPLIER,
    UNBALANCED_HAND_PENALTY = UNBALANCED_HAND_PENALTY,
    MANY_CARDS_PENALTY = MANY_CARDS_PENALTY,
    OUT_OF_PLAY = OUT_OF_PLAY,
    RANK_BONUSES = RANK_BONUSES
}

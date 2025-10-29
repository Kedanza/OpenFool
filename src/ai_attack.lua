-- ai_attack.lua
-- AI Attack Logic - Choosing the best card to throw when starting a turn
-- Translates Player.kt startTurn()

local aiEval = require("src.ai_evaluation")

-- Constants for attack bonuses
-- These bonuses apply when throwing cards of the same rank
-- Index: number of cards with that rank (0-4)
local ATTACK_BONUSES = {0.0, 0.0, 1.0, 1.5, 2.5}

---Choose the best card to throw when starting a turn
---Algorithm:
--- 1. Count cards of each rank in hand
--- 2. For each card in hand:
---    a. Simulate hand without that card
---    b. Evaluate the new hand value
---    c. Add bonus based on rank multiplicity and rank value
--- 3. Choose card that maximizes the resulting value
---@param hand table Array of Card objects
---@param trumpSuit number The trump suit (0-3)
---@param cardsRemaining number Cards remaining in the deck
---@param playerHands table Array of hand sizes for all players
---@param lowestRank number The lowest rank in play (from RuleSet)
---@return table The card to throw (or nil if hand is empty)
local function aiStartTurn(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    -- Empty hand check
    if #hand == 0 then
        return nil
    end
    
    -- Count cards of each rank
    local countsByRank = {}
    for i = 1, 13 do
        countsByRank[i] = 0
    end
    
    for _, c in ipairs(hand) do
        local rankValue = c.rank  -- rank is directly the number (1-13)
        countsByRank[rankValue] = countsByRank[rankValue] + 1
    end
    
    -- Evaluate each card and find the best one to throw
    local maxVal = -math.huge  -- Start with very negative value
    local bestCardIdx = -1
    
    for i, c in ipairs(hand) do
        -- Create a copy of the hand without this card
        local newHand = {}
        for j, card in ipairs(hand) do
            if j ~= i then
                table.insert(newHand, card)
            end
        end
        
        -- Evaluate the hand after throwing this card
        local handValueAfter = aiEval.evaluateHand(newHand, trumpSuit, cardsRemaining, playerHands, lowestRank)
        
        -- Calculate bonus based on rank multiplicity
        -- The bonus encourages throwing cards we have multiples of
        -- ACE gets special treatment (value 6), other ranks use (rank - 8)
        local rankValue = c.rank
        local rankCount = countsByRank[rankValue]
        local bonus = ATTACK_BONUSES[rankCount + 1] or 0  -- +1 because Lua arrays start at 1
        
        -- Calculate rank factor: ACE=6, others=(rank-8)
        -- This makes lower cards negative, higher cards positive
        -- Example: 6=-2, 7=-1, 8=0, 9=1, 10=2, J=3, Q=4, K=5, ACE=6
        local rankFactor = (rankValue == 1) and 6 or (rankValue - 8)
        
        -- Calculate the total value of throwing this card
        local totalVal = handValueAfter + math.floor(bonus * rankFactor * aiEval.RANK_MULTIPLIER)
        
        -- Update best card if this is better
        if totalVal > maxVal then
            maxVal = totalVal
            bestCardIdx = i
        end
    end
    
    -- Return the best card (or nil if something went wrong)
    if bestCardIdx > 0 then
        return hand[bestCardIdx]
    else
        return nil
    end
end

return {
    aiStartTurn = aiStartTurn,
    ATTACK_BONUSES = ATTACK_BONUSES
}

-- ai_throw_additional.lua
-- AI Throw Additional Cards Logic - Deciding whether to throw more cards or finish turn
-- Translates Player.kt throwOrDone()

local aiEval = require("ai_evaluation")

-- Constants for throw vs done decision-making
local PENALTY_BASE = 1200  -- Base penalty threshold for throwing additional cards
local PENALTY_DELTA = 50   -- Penalty reduction per card remaining in deck

---Decide whether to throw an additional card or finish the turn
---After a successful defense, the attacker can throw additional cards of ranks
---already present in the attack/defense. This function decides if throwing is beneficial.
---@param hand table Array of Card objects in player's hand
---@param attackCards table Array of attacking cards (may contain nils)
---@param defenseCards table Array of defense cards (may contain nils)
---@param trumpSuit number The trump suit (0-3)
---@param cardsRemaining number Cards remaining in the deck
---@param playerHands table Array of hand sizes for all players
---@param lowestRank number The lowest rank in play (from RuleSet)
---@return table|nil The card to throw, or nil to signal "done"
local function aiThrowOrDone(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
    -- Import card module
    local card = require("card")
    
    -- Build set of ranks already present in attack/defense
    local ranksPresent = {}
    for i = 1, 13 do
        ranksPresent[i] = false
    end
    
    for _, c in ipairs(attackCards) do
        if c ~= nil then
            ranksPresent[c.rank] = true
        end
    end
    
    for _, c in ipairs(defenseCards) do
        if c ~= nil then
            ranksPresent[c.rank] = true
        end
    end
    
    -- Rank bonuses for multiple cards of same rank (matching Kotlin)
    local bonuses = {0.0, 0.0, 1.0, 1.5, 2.5}
    
    -- Count cards by rank in current hand
    local countsByRank = {}
    for i = 1, 13 do
        countsByRank[i] = 0
    end
    
    for _, c in ipairs(hand) do
        countsByRank[c.rank] = countsByRank[c.rank] + 1
    end
    
    -- Find best card to throw (only ranks already present)
    local maxVal = -2147483648  -- Integer.MIN_VALUE equivalent
    local bestCardIdx = -1
    
    for i, c in ipairs(hand) do
        local r = c.rank
        
        -- Skip if rank not present in attack/defense
        if not ranksPresent[r] then
            goto continue
        end
        
        -- Simulate hand without this card
        local newHand = {}
        for j, card in ipairs(hand) do
            if j ~= i then
                table.insert(newHand, card)
            end
        end
        
        -- Calculate value of hand after throwing this card
        -- Add bonus for throwing from multiple-rank set
        local rankBonus = bonuses[countsByRank[r]]
        local rankValue = (r == card.Rank.ACE) and 6 or (r - 8)
        local bonusPoints = math.floor(rankBonus * rankValue * aiEval.RANK_MULTIPLIER)
        
        local newVal = aiEval.evaluateHand(newHand, trumpSuit, cardsRemaining, playerHands, lowestRank) + bonusPoints
        
        if newVal > maxVal then
            maxVal = newVal
            bestCardIdx = i
        end
        
        ::continue::
    end
    
    -- Decision logic: Throw if current - max < penalty AND we found a valid card
    local currentVal = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    local penaltyAdjusted = PENALTY_BASE - PENALTY_DELTA * cardsRemaining
    
    if (currentVal - maxVal < penaltyAdjusted) and (bestCardIdx >= 0) then
        return hand[bestCardIdx]
    else
        return nil  -- Signal "done"
    end
end

return {
    aiThrowOrDone = aiThrowOrDone,
    
    -- Export constants for testing
    PENALTY_BASE = PENALTY_BASE,
    PENALTY_DELTA = PENALTY_DELTA
}

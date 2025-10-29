-- ai_defense.lua
-- AI Defense Logic - Deciding whether to beat or take cards
-- Translates Player.kt tryBeat()

local aiEval = require("src.ai_evaluation")

-- Constants for defense decision-making
local RANK_PRESENT_BONUS = 300  -- Bonus for beating with a card of already present rank
local PENALTY = 800  -- Penalty threshold for beating vs taking decision
local TAKE_PENALTY_BASE = 2000  -- Base penalty for taking cards
local TAKE_PENALTY_DELTA = 40  -- Penalty reduction per card remaining in deck
local PASS_PENALTY = -400  -- Penalty adjustment for passing

---Decide whether to beat an attacking card or take all cards
---Complex cost-benefit analysis that considers:
--- - Can we beat the attack?
--- - What's our hand value after beating vs after taking?
--- - Are we in endgame (cardsRemaining = 0)?
--- - Do we have rank-present bonus (same rank already in play)?
---@param hand table Array of Card objects
---@param attackCards table Array of attacking cards (may contain nils)
---@param defenseCards table Array of defense cards (may contain nils)
---@param trumpSuit number The trump suit (0-3)
---@param cardsRemaining number Cards remaining in the deck
---@param playerHands table Array of hand sizes for all players
---@param lowestRank number The lowest rank in play (from RuleSet)
---@param deuceBeatsAce boolean Whether 2 beats ACE in this ruleset
---@return table|nil The card to beat with, or nil to take all cards
local function aiTryBeat(hand, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
    -- Import card module for beats() function
    local card = require("src.card")
    
    -- Find which attack we need to beat (first unbeaten attack)
    local attackIndex = nil
    local attack = nil
    
    -- Iterate based on attackCards length (defenseCards should match but may contain nils)
    for i = 1, #attackCards do
        -- defenseCards[i] may be nil (unbeaten) or a card (beaten)
        if attackCards[i] ~= nil and (defenseCards[i] == nil or i > #defenseCards) then
            attackIndex = i
            attack = attackCards[i]
            break
        end
    end
    
    -- If no attack to beat, return nil
    if attack == nil then
        return nil
    end
    
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
    
    -- Simulate hand if we take all cards
    local handIfTake = {}
    for _, c in ipairs(hand) do
        table.insert(handIfTake, c)
    end
    for _, c in ipairs(attackCards) do
        if c ~= nil then
            table.insert(handIfTake, c)
        end
    end
    for _, c in ipairs(defenseCards) do
        if c ~= nil then
            table.insert(handIfTake, c)
        end
    end
    
    -- Find best card to beat with
    local maxVal = -math.huge
    local bestCardIdx = -1
    
    for i, c in ipairs(hand) do
        -- Check if this card can beat the attack
        if c:beats(attack, trumpSuit, deuceBeatsAce) then
            -- Simulate hand after beating with this card
            local newHand = {}
            for j, card in ipairs(hand) do
                if j ~= i then
                    table.insert(newHand, card)
                end
            end
            
            -- Evaluate hand after beating
            local newVal = aiEval.evaluateHand(newHand, trumpSuit, cardsRemaining, playerHands, lowestRank)
            
            -- Add bonus if this rank is already present (helps create pairs/triples)
            if ranksPresent[c.rank] then
                newVal = newVal + RANK_PRESENT_BONUS
            end
            
            -- Track best option
            if newVal > maxVal then
                maxVal = newVal
                bestCardIdx = i
            end
        end
    end
    
    -- If we can't beat, must take
    if bestCardIdx < 0 then
        return nil  -- Signal to take
    end
    
    -- Decision logic: Beat or Take?
    -- Calculate current hand value
    local currentVal = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- Calculate value if we take
    local takeVal = aiEval.evaluateHand(handIfTake, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    -- Decision criteria (matching Kotlin exactly):
    -- Beat if: (currentVal - maxVal < PENALTY OR takeVal - maxVal < takePenalty OR cardsRemaining == 0)
    local takePenaltyAdjusted = TAKE_PENALTY_BASE - TAKE_PENALTY_DELTA * cardsRemaining
    
    local condition1 = (currentVal - maxVal < PENALTY)
    local condition2 = (takeVal - maxVal < takePenaltyAdjusted)
    local condition3 = (cardsRemaining == 0)
    
    local shouldBeat = condition1 or condition2 or condition3
    
    if shouldBeat then
        return hand[bestCardIdx]
    else
        return nil  -- Signal to take
    end
end

return {
    aiTryBeat = aiTryBeat,
    
    -- Export constants for testing
    RANK_PRESENT_BONUS = RANK_PRESENT_BONUS,
    PENALTY = PENALTY,
    TAKE_PENALTY_BASE = TAKE_PENALTY_BASE,
    TAKE_PENALTY_DELTA = TAKE_PENALTY_DELTA,
    PASS_PENALTY = PASS_PENALTY
}

-- player.lua
-- Player System Implementation
-- Manages player state, hand, and card operations

local card = require("card")

-- Sorting modes
local SortingMode = {
    UNSORTED = 0,
    SUIT_ASCENDING = 1,
    SUIT_DESCENDING = 2,
    RANK_ASCENDING = 3,
    RANK_DESCENDING = 4
}

-- Create a new player
-- @param ruleSet The game's RuleSet
-- @param name The player's name (optional)
-- @param index The player's index (0-based)
-- @return A new player object
local function createPlayer(ruleSet, name, index)
    local player = {
        ruleSet = ruleSet,
        name = name or "",
        index = index or 0,
        hand = {}
    }
    
    -- Add a card to the player's hand
    function player:addCard(c)
        table.insert(self.hand, c)
    end
    
    -- Remove a card from the player's hand
    -- @param c The card to remove
    -- @return true if removed, false otherwise
    function player:removeCard(c)
        for i = 1, #self.hand do
            if self.hand[i]:equals(c) then
                table.remove(self.hand, i)
                return true
            end
        end
        return false
    end
    
    -- Clear all cards from the hand
    function player:clearHand()
        self.hand = {}
    end
    
    -- Get the size of the player's hand
    function player:handSize()
        return #self.hand
    end
    
    -- Find a card in the hand
    -- @param c The card to find
    -- @return The index of the card, or nil if not found
    function player:findCard(c)
        return card.findCardInHand(self.hand, c)
    end
    
    -- Sort the player's hand according to the specified mode
    -- @param sortingMode The sorting mode to use
    -- @param trumpSuit The trump suit for sorting
    function player:sortCards(sortingMode, trumpSuit)
        if sortingMode == SortingMode.UNSORTED then
            return
        end
        
        table.sort(self.hand, function(c1, c2)
            -- Adjust suit values so trump is last
            local v1 = (c1.suit + (3 - trumpSuit)) % 4
            local v2 = (c2.suit + (3 - trumpSuit)) % 4
            
            -- Adjust rank values so ACE is highest
            local r1 = (c1.rank + 11) % 13
            local r2 = (c2.rank + 11) % 13
            
            if sortingMode == SortingMode.SUIT_ASCENDING then
                if v1 ~= v2 then
                    return v1 < v2
                end
                return r1 < r2
            elseif sortingMode == SortingMode.SUIT_DESCENDING then
                if v1 ~= v2 then
                    return v1 > v2
                end
                return r1 > r2
            elseif sortingMode == SortingMode.RANK_ASCENDING then
                if r1 ~= r2 then
                    return r1 < r2
                end
                return v1 < v2
            elseif sortingMode == SortingMode.RANK_DESCENDING then
                if r1 ~= r2 then
                    return r1 > r2
                end
                return v1 > v2
            end
            
            return false
        end)
    end
    
    -- Check if a card can be thrown (attack/throw additional)
    -- @param c The card to check
    -- @param attackCards Array of attack cards
    -- @param defenseCards Array of defense cards
    -- @return true if the card can be thrown
    function player:cardCanBeThrown(c, attackCards, defenseCards)
        -- Build ranks present array
        local ranksPresent = {}
        for i = 1, 13 do
            ranksPresent[i] = false
        end
        
        for i = 1, 6 do
            if attackCards[i] ~= nil then
                ranksPresent[attackCards[i].rank] = true
            end
        end
        
        for i = 1, 6 do
            if defenseCards[i] ~= nil then
                ranksPresent[defenseCards[i].rank] = true
            end
        end
        
        -- Check if card is in hand
        if self:findCard(c) == nil then
            return false
        end
        
        -- Check if it's the first attack (all attack cards are nil)
        local isFirstAttack = true
        for i = 1, 6 do
            if attackCards[i] ~= nil then
                isFirstAttack = false
                break
            end
        end
        
        -- Can always throw on first attack, otherwise must match existing ranks
        return isFirstAttack or ranksPresent[c.rank]
    end
    
    -- Check if a card can beat the current attack
    -- @param c The card to check
    -- @param attackCards Array of attack cards
    -- @param defenseCards Array of defense cards
    -- @param trumpSuit The trump suit
    -- @return true if the card can beat the attack
    function player:cardCanBeBeaten(c, attackCards, defenseCards, trumpSuit)
        -- Find the first nil in defenseCards (check up to 6 slots)
        local index = nil
        for i = 1, 6 do
            if defenseCards[i] == nil then
                index = i
                break
            end
        end
        
        if index == nil then
            return false -- No attack to beat
        end
        
        local attack = attackCards[index]
        if attack == nil then
            return false
        end
        
        -- Check if card is in hand and can beat the attack
        return self:findCard(c) ~= nil and c:beats(attack, trumpSuit, self.ruleSet.deuceBeatsAce)
    end
    
    -- Check if a card can be passed to the next player
    -- @param c The card to check
    -- @param attackCards Array of attack cards
    -- @param defenseCards Array of defense cards
    -- @param nextPlayerHandSize Size of next player's hand
    -- @return true if the card can be passed
    function player:cardCanBePassed(c, attackCards, defenseCards, nextPlayerHandSize)
        -- Passing must be allowed by rules
        if not self.ruleSet.allowPass then
            return false
        end
        
        -- Must not have started defending
        for i = 1, 6 do
            if defenseCards[i] ~= nil then
                return false
            end
        end
        
        -- Must have at least one attack card
        local hasAttackCard = false
        for i = 1, 6 do
            if attackCards[i] ~= nil then
                hasAttackCard = true
                break
            end
        end
        
        if not hasAttackCard then
            return false
        end
        
        -- All attack cards must be the same rank
        local firstRank = nil
        for i = 1, 6 do
            if attackCards[i] ~= nil then
                if firstRank == nil then
                    firstRank = attackCards[i].rank
                elseif attackCards[i].rank ~= firstRank then
                    return false -- Different ranks
                end
            end
        end
        
        -- Card must match the attack rank
        if c.rank ~= firstRank then
            return false
        end
        
        -- Next player must be able to handle one more card
        local emptySlots = 0
        for i = 1, 6 do
            if attackCards[i] == nil then
                emptySlots = emptySlots + 1
            end
        end
        
        return emptySlots < nextPlayerHandSize
    end
    
    -- Check if the player requires a redeal
    -- (no trumps and all but one card are same suit)
    -- @param trumpSuit The trump suit
    -- @return true if redeal is required
    function player:requireRedeal(trumpSuit)
        -- Check if hand has any trumps
        local hasTrump = false
        for i = 1, #self.hand do
            if self.hand[i].suit == trumpSuit then
                hasTrump = true
                break
            end
        end
        
        if hasTrump then
            return false
        end
        
        -- Count cards by suit
        local suitCounts = {0, 0, 0, 0}
        for i = 1, #self.hand do
            suitCounts[self.hand[i].suit + 1] = suitCounts[self.hand[i].suit + 1] + 1
        end
        
        -- Find max suit count
        local maxCount = 0
        for i = 1, 4 do
            if suitCounts[i] > maxCount then
                maxCount = suitCounts[i]
            end
        end
        
        -- Require redeal if one suit has all but one card
        return maxCount >= #self.hand - 1
    end
    
    return player
end

return {
    createPlayer = createPlayer,
    SortingMode = SortingMode
}

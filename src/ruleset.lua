-- ruleset.lua
-- Game Rules Configuration System
-- Translates RuleSet.kt

local card = require("card")

---Create a new RuleSet with configurable game rules
---@param options table Optional configuration table with rule settings
---@return table RuleSet object
local function createRuleSet(options)
    options = options or {}
    
    local ruleset = {
        -- Rule: Does a deuce (2) beat an ace in the same suit?
        deuceBeatsAce = options.deuceBeatsAce or false,
        
        -- Rule: Lower limit for first discard (allows throwing more cards initially)
        loweredFirstDiscardLimit = options.loweredFirstDiscardLimit or false,
        
        -- Rule: Allow passing cards to the next player
        allowPass = options.allowPass or false,
        
        -- Number of players (2-6, typically 4)
        playerCount = options.playerCount or 4,
        
        -- Team play mode (only valid for even number of players > 2)
        teamPlay = options.teamPlay or false,
        
        -- Total number of cards in deck (24, 32, 36, or 52)
        cardCount = options.cardCount or 52
    }
    
    ---Validate and adjust teamPlay setting
    ---Team play only valid for even number of players > 2
    local function validateTeamPlay()
        if ruleset.playerCount <= 2 or ruleset.playerCount % 2 ~= 0 then
            ruleset.teamPlay = false
        end
    end
    
    ---Validate and adjust cardCount
    ---Card count must be:
    --- - A multiple of 4 (one full suit)
    --- - At least 6 * playerCount (enough for initial deal)
    local function validateCardCount()
        local minCards = 6 * ruleset.playerCount
        -- Round cardCount up to nearest multiple of 4
        local roundedCardCount = math.floor((ruleset.cardCount + 3) / 4) * 4
        -- Take the max, then ensure result is also multiple of 4
        local result = math.max(minCards, roundedCardCount)
        ruleset.cardCount = math.floor((result + 3) / 4) * 4
    end
    
    -- Initial validation
    validateTeamPlay()
    validateCardCount()
    
    ---Set player count and revalidate rules
    ---@param count number Number of players (2-6)
    function ruleset:setPlayerCount(count)
        self.playerCount = count
        validateTeamPlay()
        validateCardCount()
    end
    
    ---Set card count and revalidate
    ---@param count number Number of cards (24, 32, 36, or 52)
    function ruleset:setCardCount(count)
        self.cardCount = count
        validateCardCount()
    end
    
    ---Get the lowest rank based on card count
    ---Formula: (14 - (cardCount / 4)) % 13 + 1
    ---@return number The lowest rank value
    function ruleset:getLowestRank()
        return ((14 - (self.cardCount / 4)) % 13) + 1
    end
    
    ---Save ruleset to a table (for file persistence)
    ---@return table Settings table
    function ruleset:save()
        return {
            deuceBeatsAce = self.deuceBeatsAce,
            loweredFirstDiscardLimit = self.loweredFirstDiscardLimit,
            allowPass = self.allowPass,
            playerCount = self.playerCount,
            teamPlay = self.teamPlay,
            cardCount = self.cardCount
        }
    end
    
    ---Load ruleset from a table
    ---@param settings table Settings table
    function ruleset:load(settings)
        self.deuceBeatsAce = settings.deuceBeatsAce or false
        self.loweredFirstDiscardLimit = settings.loweredFirstDiscardLimit or false
        self.allowPass = settings.allowPass or false
        self.playerCount = settings.playerCount or 4
        self.cardCount = settings.cardCount or 52
        self.teamPlay = settings.teamPlay or false
        
        -- Revalidate after loading
        validateTeamPlay()
        validateCardCount()
    end
    
    ---Get a string representation of the ruleset
    ---@return string Formatted ruleset info
    function ruleset:toString()
        return string.format(
            "RuleSet{players=%d, cards=%d, lowestRank=%d, deuceBeatsAce=%s, teamPlay=%s, allowPass=%s, loweredLimit=%s}",
            self.playerCount,
            self.cardCount,
            self:getLowestRank(),
            tostring(self.deuceBeatsAce),
            tostring(self.teamPlay),
            tostring(self.allowPass),
            tostring(self.loweredFirstDiscardLimit)
        )
    end
    
    return ruleset
end

return {
    createRuleSet = createRuleSet
}

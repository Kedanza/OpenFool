-- Turn Management Module
-- Handles turn end logic, card collection, drawing, and player rotation

local turn = {}

-- Constants
local DEAL_LIMIT = 6  -- Maximum cards per player

-- End the current turn
-- playerIndex: -1 for discard pile (defender won), or player index to give cards to
-- attackCards: array of attack cards on the table
-- defenseCards: array of defense cards on the table
-- players: array of player objects
-- deck: deck object
-- discardPile: array of discarded cards
-- outOfPlay: array of booleans indicating if player is out
-- returns: updated outOfPlay array
function turn.endTurn(playerIndex, attackCards, defenseCards, players, deck, discardPile, outOfPlay)
    -- Validate inputs
    if not attackCards or not defenseCards or not players or not deck then
        error("endTurn requires attackCards, defenseCards, players, and deck")
    end
    
    if not discardPile then
        discardPile = {}
    end
    
    if not outOfPlay then
        outOfPlay = {}
        for i = 1, #players do
            outOfPlay[i] = false
        end
    end
    
    -- Collect all cards from the table
    local tableCards = {}
    
    for i = 1, DEAL_LIMIT do
        if attackCards[i] then
            table.insert(tableCards, attackCards[i])
        end
        if defenseCards[i] then
            table.insert(tableCards, defenseCards[i])
        end
    end
    
    -- Distribute cards
    if playerIndex < 0 then
        -- Cards go to discard pile (defender successfully defended)
        for _, card in ipairs(tableCards) do
            table.insert(discardPile, card)
        end
    else
        -- Player takes cards (failed to defend)
        local player = players[playerIndex]
        if not player then
            error(string.format("Invalid playerIndex: %d", playerIndex))
        end
        
        for _, card in ipairs(tableCards) do
            player:addCard(card)
        end
    end
    
    -- Deal cards from deck (if not empty)
    if deck:remaining() > 0 then
        for i = 1, #players do
            local player = players[i]
            local cardsToDraw = DEAL_LIMIT - player:handSize()
            
            if cardsToDraw > 0 then
                for j = 1, cardsToDraw do
                    local card = deck:draw()
                    if not card then
                        break  -- Deck is empty
                    end
                    player:addCard(card)
                end
            end
            
            -- Stop if deck is empty
            if deck:remaining() == 0 then
                break
            end
        end
    end
    
    -- Check if any players are out of play (only when deck is empty)
    if deck:remaining() == 0 then
        for i = 1, #players do
            local player = players[i]
            if player:handSize() == 0 and not outOfPlay[i] then
                outOfPlay[i] = true
            end
        end
    end
    
    -- Clear the table
    for i = 1, DEAL_LIMIT do
        attackCards[i] = nil
        defenseCards[i] = nil
    end
    
    -- Reset player done statuses
    for _, player in ipairs(players) do
        if player.saidDone ~= nil then
            player.saidDone = false
        end
    end
    
    return outOfPlay
end

-- Get the next active player index (skipping out-of-play players)
-- currentIndex: current player index (1-based)
-- playerCount: total number of players
-- outOfPlay: array of booleans indicating if player is out
-- teamPlay: whether team play is enabled
-- returns: next player index
function turn.getNextPlayerIndex(currentIndex, playerCount, outOfPlay, teamPlay)
    if not currentIndex or not playerCount then
        error("getNextPlayerIndex requires currentIndex and playerCount")
    end
    
    if not outOfPlay then
        outOfPlay = {}
        for i = 1, playerCount do
            outOfPlay[i] = false
        end
    end
    
    local nextIndex = currentIndex % playerCount + 1
    
    -- In non-team play, skip players who are out
    if not teamPlay then
        local attempts = 0
        while outOfPlay[nextIndex] and attempts < playerCount do
            nextIndex = nextIndex % playerCount + 1
            attempts = attempts + 1
        end
        
        -- If we looped through all players, return current (game should be over)
        if attempts >= playerCount then
            return currentIndex
        end
    else
        -- In team play, skip players who are out (same as non-team play)
        local attempts = 0
        while outOfPlay[nextIndex] and attempts < playerCount do
            nextIndex = nextIndex % playerCount + 1
            attempts = attempts + 1
        end
        
        -- If we looped through all players, return current (game should be over)
        if attempts >= playerCount then
            return currentIndex
        end
    end
    
    return nextIndex
end

-- Get current attacker index (accounting for out-of-play)
-- attackerIndex: designated attacker index
-- playerCount: total number of players
-- outOfPlay: array of booleans
-- teamPlay: whether team play is enabled
-- returns: actual attacker index
function turn.getCurrentAttacker(attackerIndex, playerCount, outOfPlay, teamPlay)
    if not attackerIndex or not playerCount then
        error("getCurrentAttacker requires attackerIndex and playerCount")
    end
    
    if not outOfPlay then
        outOfPlay = {}
        for i = 1, playerCount do
            outOfPlay[i] = false
        end
    end
    
    if not outOfPlay[attackerIndex] then
        return attackerIndex
    end
    
    -- If attacker is out, use their teammate in team play
    -- Teams: P1+P2, P3+P4 (teammates are +1 positions apart in 4-player game)
    if teamPlay and playerCount == 4 then
        -- Teammate is +1 position away, wrapping around pairs
        -- P1↔P2 (indices 1-2), P3↔P4 (indices 3-4)
        local teammateIndex
        if attackerIndex == 1 or attackerIndex == 2 then
            teammateIndex = 3 - attackerIndex  -- 1→2, 2→1
        else
            teammateIndex = 7 - attackerIndex  -- 3→4, 4→3
        end
        return teammateIndex
    end
    
    -- Otherwise find next active player
    return turn.getNextPlayerIndex(attackerIndex, playerCount, outOfPlay, teamPlay)
end

-- Get current defender index
-- attackerIndex: current attacker index
-- playerCount: total number of players
-- outOfPlay: array of booleans
-- teamPlay: whether team play is enabled
-- returns: defender index
function turn.getCurrentDefender(attackerIndex, playerCount, outOfPlay, teamPlay)
    if not attackerIndex or not playerCount then
        error("getCurrentDefender requires attackerIndex and playerCount")
    end
    
    if not outOfPlay then
        outOfPlay = {}
        for i = 1, playerCount do
            outOfPlay[i] = false
        end
    end
    
    local defenderIndex = attackerIndex % playerCount + 1
    
    -- In non-team play, skip out-of-play defenders
    if not teamPlay then
        local attempts = 0
        while outOfPlay[defenderIndex] and attempts < playerCount do
            defenderIndex = defenderIndex % playerCount + 1
            attempts = attempts + 1
        end
        
        if attempts >= playerCount then
            return attackerIndex  -- No valid defender
        end
    else
        -- In team play, skip out-of-play defenders (same as non-team play)
        local attempts = 0
        while outOfPlay[defenderIndex] and attempts < playerCount do
            defenderIndex = defenderIndex % playerCount + 1
            attempts = attempts + 1
        end
        
        if attempts >= playerCount then
            return attackerIndex  -- No valid defender
        end
    end
    
    return defenderIndex
end

-- Check if the game is over
-- outOfPlay: array of booleans indicating if player is out
-- teamPlay: whether team play is enabled
-- returns: true if game is over
function turn.isGameOver(outOfPlay, teamPlay)
    if not outOfPlay then
        return false
    end
    
    if teamPlay then
        -- Team 1: players 1 and 3
        -- Team 2: players 2 and 4
        local team1Out = outOfPlay[1] and outOfPlay[3]
        local team2Out = outOfPlay[2] and outOfPlay[4]
        
        return team1Out or team2Out
    else
        -- Count active players
        local activePlayers = 0
        
        for i = 1, #outOfPlay do
            if not outOfPlay[i] then
                activePlayers = activePlayers + 1
            end
        end
        
        -- Game over when 1 or fewer players remain
        return activePlayers <= 1
    end
end

-- Determine the winner
-- outOfPlay: array of booleans
-- teamPlay: whether team play is enabled
-- returns: winner info (team name or player index, or 0 for draw)
function turn.determineWinner(outOfPlay, teamPlay)
    if not outOfPlay then
        return 0
    end
    
    if teamPlay then
        if outOfPlay[1] and outOfPlay[3] then
            return "team2"  -- Team 2 wins
        else
            return "team1"  -- Team 1 wins
        end
    else
        -- Find the last remaining player (they are the loser)
        -- The loser in Fool is the one who still has cards
        for i = 1, #outOfPlay do
            if not outOfPlay[i] then
                return i  -- This player lost
            end
        end
        
        -- All players out: draw
        return 0
    end
end

return turn

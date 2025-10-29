-- game_loop.lua
-- Core Game Loop Integration
-- Manages the complete game flow from start to finish

local GameLoop = {}

-- Create a new game loop manager
-- @param game table - The game state object from game_setup
-- @param stateManager table - The game state manager
-- @param modules table - All required modules (Card, AI, Turn, etc.)
function GameLoop.create(game, stateManager, modules)
    local loop = {
        game = game,
        stateManager = stateManager,
        modules = modules,
        
        -- UI state
        selectedCardIndex = nil,  -- Index of selected card in player's hand
        waitingForDefender = false,
        gameOver = false,
        winner = nil,
        
        -- Timing for AI moves
        aiThinkTime = 1.5,  -- Seconds AI waits before making a move
        aiTimer = 0,
        pendingAIAction = nil
    }
    
    -- Initialize the game to READY state
    function loop:initialize()
        self.stateManager:reset(self.modules.GameState.READY)
        self.stateManager:setLogging(true)
        self.selectedCardIndex = nil
        self.waitingForDefender = false
        self.gameOver = false
        self.winner = nil
        self.aiTimer = 0
        self.pendingAIAction = nil
    end
    
    -- Update game logic
    function loop:update(dt)
        if self.gameOver then
            return
        end
        
        -- Check for game over
        if self:checkGameOver() then
            return
        end
        
        local state = self.stateManager:getState()
        local GameState = self.modules.GameState
        
        -- Handle AI thinking timer
        if self.pendingAIAction then
            self.aiTimer = self.aiTimer + dt
            if self.aiTimer >= self.aiThinkTime then
                self.pendingAIAction()
                self.pendingAIAction = nil
                self.aiTimer = 0
            end
            return
        end
        
        -- State-based logic
        if state == GameState.READY then
            self:handleReadyState()
        elseif state == GameState.THROWING then
            self:handleThrowingState()
        elseif state == GameState.THROWN then
            self:handleThrownState()
        elseif state == GameState.BEATING then
            self:handleBeatingState()
        elseif state == GameState.BEATEN then
            self:handleBeatenState()
        elseif state == GameState.DRAWING then
            self:handleDrawingState()
        end
    end
    
    -- READY state: Attacker can throw first card
    function loop:handleReadyState()
        local attackerIndex = self.game.currentAttacker
        
        -- Transition to THROWING state
        self.stateManager:setState(self.modules.GameState.THROWING)
    end
    
    -- THROWING state: Attacker is throwing a card
    function loop:handleThrowingState()
        local attackerIndex = self.game.currentAttacker
        local player = self.game.players[attackerIndex]
        
        -- Check if attacker is human (player 1)
        if attackerIndex == 1 then
            -- Wait for human input (handled in mousepressed)
            return
        else
            -- AI attacker
            self:scheduleAIAction(function()
                self:performAIAttack()
            end)
        end
    end
    
    -- THROWN state: Defender must respond
    function loop:handleThrownState()
        local defenderIndex = self.game.currentDefender
        
        -- Transition to BEATING state
        self.stateManager:setState(self.modules.GameState.BEATING)
    end
    
    -- BEATING state: Defender is beating a card
    function loop:handleBeatingState()
        local defenderIndex = self.game.currentDefender
        local player = self.game.players[defenderIndex]
        
        -- Check if defender is human
        if defenderIndex == 1 then
            -- Wait for human input (handled in mousepressed or Take button)
            self.waitingForDefender = true
            return
        else
            -- AI defender
            self:scheduleAIAction(function()
                self:performAIDefense()
            end)
        end
    end
    
    -- BEATEN state: Can throw additional cards
    function loop:handleBeatenState()
        -- Find which players can throw additional cards
        local canThrowMore = self:canAnyoneThrowMore()
        
        if not canThrowMore then
            -- No one can throw more, go to drawing
            self.stateManager:setState(self.modules.GameState.DRAWING)
            return
        end
        
        -- Try each player (except defender) to throw additional
        for i = 1, #self.game.players do
            if i ~= self.game.currentDefender and not self.game.playerDoneStatuses[i] then
                if i == 1 then
                    -- Human player can throw additional
                    -- Wait for input or "Done" button
                    return
                else
                    -- AI players throw additional
                    self:scheduleAIAction(function()
                        self:performAIThrowAdditional(i)
                    end)
                    return  -- Process one at a time
                end
            end
        end
        
        -- All players are done, move to drawing
        self.stateManager:setState(self.modules.GameState.DRAWING)
    end
    
    -- DRAWING state: End turn and draw cards
    function loop:handleDrawingState()
        -- Determine where cards go
        local playerToReceive = -1  -- -1 = discard pile (defender won)
        
        -- Check if defender successfully beat all cards
        local allBeaten = true
        for i = 1, 6 do
            if self.game.attackCards[i] and not self.game.defenseCards[i] then
                allBeaten = false
                break
            end
        end
        
        if not allBeaten then
            -- Defender takes all cards
            playerToReceive = self.game.currentDefender
        end
        
        -- End turn
        self.game.outOfPlay = self.modules.Turn.endTurn(
            playerToReceive,
            self.game.attackCards,
            self.game.defenseCards,
            self.game.players,
            self.game.deck,
            self.game.discardPile,
            self.game.outOfPlay
        )
        
        -- Advance to next turn
        if playerToReceive == self.game.currentDefender then
            -- Defender took cards, attacker remains same
            -- Defender becomes next active player after attacker
            self.game.currentDefender = self.modules.Turn.getNextPlayerIndex(
                self.game.currentAttacker,
                #self.game.players,
                self.game.outOfPlay,
                self.game.ruleSet.teamPlay
            )
        else
            -- Defender won, becomes new attacker
            self.game.currentAttacker = self.game.currentDefender
            self.game.currentDefender = self.modules.Turn.getNextPlayerIndex(
                self.game.currentAttacker,
                #self.game.players,
                self.game.outOfPlay,
                self.game.ruleSet.teamPlay
            )
        end
        
        -- Reset player done statuses
        for i = 1, #self.game.players do
            self.game.playerDoneStatuses[i] = false
        end
        
        -- Go back to READY for next turn
        self.waitingForDefender = false
        self.stateManager:setState(self.modules.GameState.READY)
    end
    
    -- Perform AI attack
    function loop:performAIAttack()
        local attackerIndex = self.game.currentAttacker
        local player = self.game.players[attackerIndex]
        
        local AIAttack = self.modules.AI.attack
        
        -- Get player hand sizes
        local playerHands = {}
        for i = 1, #self.game.players do
            playerHands[i] = self.game.players[i]:handSize()
        end
        
        local card = AIAttack.aiStartTurn(
            player.hand,
            self.game.trumpSuit,
            self.game.deck:remaining(),
            playerHands,
            self.game.ruleSet:getLowestRank()
        )
        
        if card then
            -- Remove from hand and add to attack
            player:removeCard(card)
            
            print("AI Player " .. attackerIndex .. " attacking with: " .. card:toString())
            
            -- Find empty slot in attackCards
            for i = 1, 6 do
                if not self.game.attackCards[i] then
                    self.game.attackCards[i] = card
                    break
                end
            end
            
            -- Transition to THROWN
            self.stateManager:setState(self.modules.GameState.THROWN)
        else
            -- AI has no valid move (shouldn't happen in READY)
            print("WARNING: AI attacker has no valid card to throw")
        end
    end
    
    -- Perform AI defense
    function loop:performAIDefense()
        local defenderIndex = self.game.currentDefender
        local player = self.game.players[defenderIndex]
        
        local AIDefense = self.modules.AI.defense
        
        -- Count attack cards
        local attackCardCount = 0
        for i = 1, 6 do
            if self.game.attackCards[i] then
                attackCardCount = attackCardCount + 1
            end
        end
        
        -- Get player hand sizes
        local playerHands = {}
        for i = 1, #self.game.players do
            playerHands[i] = self.game.players[i]:handSize()
        end
        
        local result = AIDefense.aiTryBeat(
            player.hand,
            self.game.attackCards,
            self.game.defenseCards,
            self.game.trumpSuit,
            self.game.deck:remaining(),
            playerHands,
            self.game.ruleSet:getLowestRank()
        )
        
        if result.shouldTake then
            -- Defender takes all cards
            print("AI Player " .. defenderIndex .. " is taking cards")
            
            -- Transition to DRAWING (defender failed)
            self.waitingForDefender = false
            self.stateManager:setState(self.modules.GameState.DRAWING)
        elseif result.cardToBeat then
            print("AI Player " .. defenderIndex .. " defending with: " .. result.cardToBeat:toString())
            
            -- Remove card from hand
            player:removeCard(result.cardToBeat)
            
            -- Add to defense cards
            for i = 1, 6 do
                if self.game.attackCards[i] and not self.game.defenseCards[i] then
                    self.game.defenseCards[i] = result.cardToBeat
                    break
                end
            end
            
            -- Transition to BEATEN
            self.waitingForDefender = false
            self.stateManager:setState(self.modules.GameState.BEATEN)
        end
    end
    
    -- Perform AI throw additional cards
    function loop:performAIThrowAdditional(playerIndex)
        local player = self.game.players[playerIndex]
        local AIThrow = self.modules.AI.throw
        
        local card = AIThrow.aiThrowIn(
            player.hand,
            self.game.attackCards,
            self.game.defenseCards,
            self.game.trumpSuit,
            self.game.players[self.game.currentDefender]:handSize()
        )
        
        if card then
            -- Transition to THROWING
            self.stateManager:setState(self.modules.GameState.THROWING)
            
            -- Remove from hand
            player:removeCard(card)
            
            -- Add to attack cards
            for i = 1, 6 do
                if not self.game.attackCards[i] then
                    self.game.attackCards[i] = card
                    break
                end
            end
            
            -- Transition back to THROWN for defender to respond
            self.stateManager:setState(self.modules.GameState.THROWN)
        else
            -- Player has no card to throw or chooses not to
            self.game.playerDoneStatuses[playerIndex] = true
        end
    end
    
    -- Check if anyone can throw more cards
    function loop:canAnyoneThrowMore()
        local defenderHandSize = self.game.players[self.game.currentDefender]:handSize()
        
        -- Count current attack cards
        local attackCount = 0
        for i = 1, 6 do
            if self.game.attackCards[i] then
                attackCount = attackCount + 1
            end
        end
        
        -- Can't throw more than defender can handle
        if attackCount >= defenderHandSize then
            return false
        end
        
        -- Can't throw more than 6 cards total
        if attackCount >= 6 then
            return false
        end
        
        -- Check if any non-defender player has cards and isn't done
        for i = 1, #self.game.players do
            if i ~= self.game.currentDefender then
                if not self.game.playerDoneStatuses[i] and self.game.players[i]:handSize() > 0 then
                    return true
                end
            end
        end
        
        return false
    end
    
    -- Schedule an AI action with thinking delay
    function loop:scheduleAIAction(action)
        self.pendingAIAction = action
        self.aiTimer = 0
    end
    
    -- Check if game is over
    function loop:checkGameOver()
        if self.modules.Turn.isGameOver(self.game.outOfPlay, self.game.ruleSet.teamPlay) then
            self.gameOver = true
            self.winner = self.modules.Turn.determineWinner(self.game.outOfPlay, self.game.ruleSet.teamPlay)
            print("Game Over! Winner: " .. tostring(self.winner))
            return true
        end
        return false
    end
    
    -- Handle human player clicking a card in their hand
    function loop:onCardClicked(cardIndex)
        if self.gameOver then
            return
        end
        
        local player = self.game.players[1]  -- Human is always player 1
        local state = self.stateManager:getState()
        local GameState = self.modules.GameState
        
        -- THROWING state: Attacker throwing a card
        if state == GameState.THROWING and self.game.currentAttacker == 1 then
            local card = player.hand[cardIndex]
            if card then
                -- Remove from hand
                player:removeCard(card)
                
                -- Add to attack
                for i = 1, 6 do
                    if not self.game.attackCards[i] then
                        self.game.attackCards[i] = card
                        break
                    end
                end
                
                print("Player 1 threw: " .. card:toString())
                
                -- Transition to THROWN
                self.stateManager:setState(GameState.THROWN)
                self.selectedCardIndex = nil
            end
        -- BEATEN state: Anyone (except defender) throwing additional cards
        elseif state == GameState.BEATEN and self.game.currentDefender ~= 1 and not self.game.playerDoneStatuses[1] then
            local card = player.hand[cardIndex]
            if card and self:canBeatWithCard(card) then
                -- Transition to BEATING
                self.stateManager:setState(GameState.BEATING)
                
                -- Remove from hand
                player:removeCard(card)
                
                -- Add to defense
                for i = 1, 6 do
                    if self.game.attackCards[i] and not self.game.defenseCards[i] then
                        self.game.defenseCards[i] = card
                        break
                    end
                end
                
                -- Transition to BEATEN
                self.waitingForDefender = false
                self.stateManager:setState(GameState.BEATEN)
                self.selectedCardIndex = nil
            end
        -- BEATING state: Defender responding
        elseif state == GameState.BEATING and self.game.currentDefender == 1 then
            local card = player.hand[cardIndex]
            if card and self:canBeatWithCard(card) then
                -- Remove from hand
                player:removeCard(card)
                
                -- Add to defense
                for i = 1, 6 do
                    if self.game.attackCards[i] and not self.game.defenseCards[i] then
                        self.game.defenseCards[i] = card
                        break
                    end
                end
                
                print("Player 1 beat with: " .. card:toString())
                
                -- Transition to BEATEN
                self.waitingForDefender = false
                self.stateManager:setState(GameState.BEATEN)
                self.selectedCardIndex = nil
            end
        -- BEATEN state: Anyone (except defender) throwing additional cards
        elseif state == GameState.BEATEN and self.game.currentDefender ~= 1 and not self.game.playerDoneStatuses[1] then
            local card = player.hand[cardIndex]
            if card and self:canThrowCard(card) then
                -- Transition to THROWING
                self.stateManager:setState(GameState.THROWING)
                
                -- Remove from hand
                player:removeCard(card)
                
                -- Add to attack
                for i = 1, 6 do
                    if not self.game.attackCards[i] then
                        self.game.attackCards[i] = card
                        break
                    end
                end
                
                -- Transition to THROWN
                self.stateManager:setState(GameState.THROWN)
                self.selectedCardIndex = nil
            end
        end
    end
    
    -- Check if a card can beat the current attack
    function loop:canBeatWithCard(card)
        for i = 1, 6 do
            if self.game.attackCards[i] and not self.game.defenseCards[i] then
                local attackCard = self.game.attackCards[i]
                
                -- Same suit, higher rank
                if card.suit == attackCard.suit and card.rank > attackCard.rank then
                    return true
                end
                
                -- Trump beats non-trump
                if card.suit == self.game.trumpSuit and attackCard.suit ~= self.game.trumpSuit then
                    return true
                end
            end
        end
        return false
    end
    
    -- Check if a card can be thrown (matches rank on table)
    function loop:canThrowCard(card)
        -- Check attack cards
        for i = 1, 6 do
            if self.game.attackCards[i] and self.game.attackCards[i].rank == card.rank then
                return true
            end
            if self.game.defenseCards[i] and self.game.defenseCards[i].rank == card.rank then
                return true
            end
        end
        return false
    end
    
    -- Handle "Take Cards" button (defender gives up)
    function loop:onTakeCards()
        if self.gameOver then
            return
        end
        
        local state = self.stateManager:getState()
        local GameState = self.modules.GameState
        
        if state == GameState.THROWN and self.game.currentDefender == 1 then
            -- Human defender gives up
            self.waitingForDefender = false
            self.stateManager:setState(GameState.DRAWING)
        end
    end
    
    -- Handle "Done" button (player finished throwing)
    function loop:onDone()
        if self.gameOver then
            return
        end
        
        local state = self.stateManager:getState()
        local GameState = self.modules.GameState
        
        if state == GameState.BEATEN and self.game.currentDefender ~= 1 then
            -- Human player is done throwing additional
            self.game.playerDoneStatuses[1] = true
        end
    end
    
    return loop
end

return GameLoop

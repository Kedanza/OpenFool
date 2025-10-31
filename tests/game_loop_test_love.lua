-- Game Loop Module Tests
-- Tests the core game loop integration (src/game_loop.lua)

local GameLoop = require("game_loop")
local GameState = require("gamestate")
local card = require("card")
local deck = require("deck")
local player = require("player")
local ruleset = require("ruleset")
local gameSetup = require("game_setup")
local Turn = require("turn")
local AI = {
    evaluation = require("ai_evaluation"),
    attack = require("ai_attack"),
    defense = require("ai_defense"),
    throw = require("ai_throw_additional")
}

print("\n=== Game Loop Module Tests ===")

-- Helper: Create a basic game state for testing
local function createTestGame()
    local ruleSet = ruleset.createRuleSet({
        playerCount = 2,
        cardCount = 36,
        deuceBeatsAce = false,
        teamPlay = false,
        allowPass = false
    })
    local game = gameSetup.setupGame(ruleSet)
    local stateManager = GameState.createGameStateManager()

    local modules = {
        Card = card,
        GameState = GameState,
        Turn = Turn,
        AI = AI
    }

    return game, stateManager, modules
end

-- Test 1: GameLoop Creation
print("\n--- GameLoop Creation Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    assert(loop ~= nil, "GameLoop should be created")
    assert(loop.game == game, "GameLoop should reference game state")
    assert(loop.stateManager == stateManager, "GameLoop should reference state manager")
    assert(loop.modules == modules, "GameLoop should reference modules")
    assert(loop.selectedCardIndex == nil, "Initial selectedCardIndex should be nil")
    assert(loop.waitingForDefender == false, "Initial waitingForDefender should be false")
    assert(loop.gameOver == false, "Initial gameOver should be false")
    assert(loop.winner == nil, "Initial winner should be nil")
    assert(loop.aiThinkTime == 1.5, "AI think time should be 1.5 seconds")
    assert(loop.aiTimer == 0, "Initial AI timer should be 0")
    assert(loop.pendingAIAction == nil, "Initial pendingAIAction should be nil")
end

-- Test 2: Initialize Method
print("\n--- Initialize Method Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    -- Modify some values
    loop.selectedCardIndex = 5
    loop.waitingForDefender = true
    loop.gameOver = true
    loop.winner = 1
    loop.aiTimer = 2.5
    loop.pendingAIAction = function() end

    -- Initialize should reset everything
    loop:initialize()

    assert(stateManager:getState() == GameState.READY, "State should be reset to READY")
    assert(loop.selectedCardIndex == nil, "selectedCardIndex should be reset to nil")
    assert(loop.waitingForDefender == false, "waitingForDefender should be reset to false")
    assert(loop.gameOver == false, "gameOver should be reset to false")
    assert(loop.winner == nil, "winner should be reset to nil")
    assert(loop.aiTimer == 0, "aiTimer should be reset to 0")
    assert(loop.pendingAIAction == nil, "pendingAIAction should be reset to nil")
end

-- Test 3: State Machine Transitions - READY → THROWING
print("\n--- READY → THROWING Transition Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()

    local initialState = stateManager:getState()
    assert(initialState == GameState.READY, "Should start in READY state")

    loop:handleReadyState()

    local newState = stateManager:getState()
    assert(newState == GameState.THROWING, "Should transition to THROWING state")
end

-- Test 4: State Machine Transitions - THROWN → BEATING
print("\n--- THROWN → BEATING Transition Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.THROWN)
    loop:handleThrownState()

    assert(stateManager:getState() == GameState.BEATING, "Should transition to BEATING state")
end

-- Test 5: State Machine Transitions - BEATEN → DRAWING (no more cards)
print("\n--- BEATEN → DRAWING Transition Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.BEATEN)

    -- Mark all players as done (no one can throw more)
    game.playerDoneStatuses[1] = true
    game.playerDoneStatuses[2] = true

    loop:handleBeatenState()

    assert(stateManager:getState() == GameState.DRAWING, "Should transition to DRAWING when no one can throw more")
end

-- Test 6: State Machine Transitions - DRAWING → READY (end turn)
print("\n--- DRAWING → READY Transition Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.DRAWING)

    -- Set up a successful defense scenario
    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.defenseCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SEVEN)

    loop:handleDrawingState()

    assert(stateManager:getState() == GameState.READY, "Should transition back to READY after drawing")
    assert(loop.waitingForDefender == false, "waitingForDefender should be reset")
end

-- Test 7: AI Timer System - Scheduling Actions
print("\n--- AI Timer Scheduling Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    local actionExecuted = false
    local testAction = function()
        actionExecuted = true
    end

    loop:scheduleAIAction(testAction)

    assert(loop.pendingAIAction == testAction, "pendingAIAction should be set")
    assert(loop.aiTimer == 0, "aiTimer should be reset to 0")
    assert(actionExecuted == false, "Action should not execute immediately")
end

-- Test 8: AI Timer System - Action Execution After Delay
print("\n--- AI Timer Execution Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    local actionExecuted = false
    local testAction = function()
        actionExecuted = true
    end

    loop:scheduleAIAction(testAction)

    -- Simulate time passing (not enough)
    loop:update(0.5)
    assert(actionExecuted == false, "Action should not execute before aiThinkTime")
    assert(loop.pendingAIAction ~= nil, "pendingAIAction should still be set")

    -- Simulate more time passing (enough to trigger)
    loop:update(1.0)
    assert(actionExecuted == true, "Action should execute after aiThinkTime")
    assert(loop.pendingAIAction == nil, "pendingAIAction should be cleared after execution")
    assert(loop.aiTimer == 0, "aiTimer should be reset after execution")
end

-- Test 9: canAnyoneThrowMore - Defender Hand Size Limit
print("\n--- canAnyoneThrowMore Defender Limit Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    -- Give defender 3 cards
    local defender = game.players[game.currentDefender]
    for i = 1, 3 do
        defender:addCard(card.createCard(card.Suit.SPADES, i))
    end

    -- Already 3 attack cards on table
    game.attackCards[1] = card.createCard(card.Suit.HEARTS, card.Rank.SIX)
    game.attackCards[2] = card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)
    game.attackCards[3] = card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT)

    -- Give attacker cards
    local attacker = game.players[game.currentAttacker]
    attacker:addCard(card.createCard(card.Suit.SPADES, card.Rank.NINE))

    local canThrow = loop:canAnyoneThrowMore()
    assert(canThrow == false, "Should not be able to throw more (at defender hand size limit)")
end

-- Test 10: canAnyoneThrowMore - 6 Card Limit
print("\n--- canAnyoneThrowMore 6 Card Limit Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    -- Give defender 10 cards (more than 6)
    local defender = game.players[game.currentDefender]
    for i = 1, 10 do
        defender:addCard(card.createCard(card.Suit.SPADES, i))
    end

    -- Already 6 attack cards on table
    for i = 1, 6 do
        game.attackCards[i] = card.createCard(card.Suit.HEARTS, i)
    end

    -- Give attacker cards
    local attacker = game.players[game.currentAttacker]
    attacker:addCard(card.createCard(card.Suit.SPADES, card.Rank.NINE))

    local canThrow = loop:canAnyoneThrowMore()
    assert(canThrow == false, "Should not be able to throw more (6 card limit reached)")
end

-- Test 11: canAnyoneThrowMore - All Players Done
print("\n--- canAnyoneThrowMore All Done Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    -- Give players cards
    for i = 1, #game.players do
        game.players[i]:addCard(card.createCard(card.Suit.SPADES, i))
    end

    -- Only 1 attack card
    game.attackCards[1] = card.createCard(card.Suit.HEARTS, card.Rank.SIX)

    -- All non-defender players are done
    for i = 1, #game.players do
        game.playerDoneStatuses[i] = true
    end

    local canThrow = loop:canAnyoneThrowMore()
    assert(canThrow == false, "Should not be able to throw more (all players done)")
end

-- Test 12: canAnyoneThrowMore - Can Throw More
print("\n--- canAnyoneThrowMore Can Throw Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    -- Give defender 6 cards
    local defender = game.players[game.currentDefender]
    for i = 1, 6 do
        defender:addCard(card.createCard(card.Suit.SPADES, i))
    end

    -- Only 2 attack cards
    game.attackCards[1] = card.createCard(card.Suit.HEARTS, card.Rank.SIX)
    game.attackCards[2] = card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)

    -- Give attacker cards and not done
    local attacker = game.players[game.currentAttacker]
    attacker:addCard(card.createCard(card.Suit.SPADES, card.Rank.NINE))
    game.playerDoneStatuses[game.currentAttacker] = false

    local canThrow = loop:canAnyoneThrowMore()
    assert(canThrow == true, "Should be able to throw more cards")
end

-- Test 13: canBeatWithCard - Same Suit Higher Rank
print("\n--- canBeatWithCard Same Suit Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.trumpSuit = card.Suit.HEARTS

    local beatingCard = card.createCard(card.Suit.SPADES, card.Rank.KING)
    local result = loop:canBeatWithCard(beatingCard)

    assert(result == true, "Higher rank same suit should beat attack card")
end

-- Test 14: canBeatWithCard - Trump Beats Non-Trump
print("\n--- canBeatWithCard Trump Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.KING)
    game.trumpSuit = card.Suit.HEARTS

    local trumpCard = card.createCard(card.Suit.HEARTS, card.Rank.SIX)
    local result = loop:canBeatWithCard(trumpCard)

    assert(result == true, "Trump should beat non-trump attack card")
end

-- Test 15: canBeatWithCard - Cannot Beat
print("\n--- canBeatWithCard Cannot Beat Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.KING)
    game.trumpSuit = card.Suit.HEARTS

    local weakCard = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    local result = loop:canBeatWithCard(weakCard)

    assert(result == false, "Lower rank same suit should not beat attack card")
end

-- Test 16: canThrowCard - Matching Attack Card Rank
print("\n--- canThrowCard Attack Match Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)

    local matchingCard = card.createCard(card.Suit.HEARTS, card.Rank.SIX)
    local result = loop:canThrowCard(matchingCard)

    assert(result == true, "Card matching attack rank should be throwable")
end

-- Test 17: canThrowCard - Matching Defense Card Rank
print("\n--- canThrowCard Defense Match Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.defenseCards[1] = card.createCard(card.Suit.SPADES, card.Rank.KING)

    local matchingDefense = card.createCard(card.Suit.HEARTS, card.Rank.KING)
    local result = loop:canThrowCard(matchingDefense)

    assert(result == true, "Card matching defense rank should be throwable")
end

-- Test 18: canThrowCard - No Matching Ranks
print("\n--- canThrowCard No Match Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.defenseCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SEVEN)

    local nonMatching = card.createCard(card.Suit.HEARTS, card.Rank.KING)
    local result = loop:canThrowCard(nonMatching)

    assert(result == false, "Card not matching any table rank should not be throwable")
end

-- Test 19: checkGameOver - Game Not Over
print("\n--- checkGameOver Not Over Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    -- Both players still in play
    game.outOfPlay = {false, false}

    local result = loop:checkGameOver()

    assert(result == false, "Game should not be over with 2 players active")
    assert(loop.gameOver == false, "gameOver flag should be false")
    assert(loop.winner == nil, "winner should be nil")
end

-- Test 20: checkGameOver - Solo Mode Game Over
print("\n--- checkGameOver Solo Mode Tests ---")
do
    local ruleSet = ruleset.createRuleSet({
        playerCount = 4,
        cardCount = 36,
        deuceBeatsAce = false,
        teamPlay = false,
        allowPass = false
    })
    local game = gameSetup.setupGame(ruleSet)
    local stateManager = GameState.createGameStateManager()

    local modules = {
        Card = card,
        GameState = GameState,
        Turn = Turn,
        AI = AI
    }

    local loop = GameLoop.create(game, stateManager, modules)

    -- Only 1 player remaining (player 2)
    game.outOfPlay = {true, false, true, true}

    local result = loop:checkGameOver()

    assert(result == true, "Game should be over with only 1 player remaining")
    assert(loop.gameOver == true, "gameOver flag should be true")
    assert(loop.winner == 2, "Winner should be player 2 (the last remaining player/fool)")
end

-- Test 21: checkGameOver - Team Mode Game Over
print("\n--- checkGameOver Team Mode Tests ---")
do
    local ruleSet = ruleset.createRuleSet({
        playerCount = 4,
        cardCount = 36,
        deuceBeatsAce = false,
        teamPlay = true,
        allowPass = false
    })
    local game = gameSetup.setupGame(ruleSet)
    local stateManager = GameState.createGameStateManager()

    local modules = {
        Card = card,
        GameState = GameState,
        Turn = Turn,
        AI = AI
    }

    local loop = GameLoop.create(game, stateManager, modules)

    -- Team 1 (players 1 and 3) both out
    game.outOfPlay = {true, false, true, false}

    local result = loop:checkGameOver()

    assert(result == true, "Game should be over when entire team is out")
    assert(loop.gameOver == true, "gameOver flag should be true")
    assert(loop.winner == "team2", "Winner should be team2")
end

-- Test 22: Update Method - Game Over Prevents Updates
print("\n--- Update Game Over Block Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    loop.gameOver = true
    local initialState = stateManager:getState()

    loop:update(0.1)

    assert(stateManager:getState() == initialState, "State should not change when game is over")
end

-- Test 23: Update Method - Check Game Over Detection
print("\n--- Update Game Over Detection Tests ---")
do
    local ruleSet = ruleset.createRuleSet({
        playerCount = 4,
        cardCount = 36,
        deuceBeatsAce = false,
        teamPlay = false,
        allowPass = false
    })
    local game = gameSetup.setupGame(ruleSet)
    local stateManager = GameState.createGameStateManager()

    local modules = {
        Card = card,
        GameState = GameState,
        Turn = Turn,
        AI = AI
    }

    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()

    -- Set game over condition (only player 1 remains)
    game.outOfPlay = {false, true, true, true}

    loop:update(0.1)

    assert(loop.gameOver == true, "Update should detect game over condition")
    assert(loop.winner == 1, "Winner should be detected")
end

-- Test 24: Update Method - AI Action Pending Blocks State Updates
print("\n--- Update AI Pending Block Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()

    local actionExecuted = false
    loop:scheduleAIAction(function()
        actionExecuted = true
    end)

    local initialState = stateManager:getState()

    -- Update with small dt (not enough to trigger action)
    loop:update(0.5)

    assert(actionExecuted == false, "Action should not execute yet")
    assert(stateManager:getState() == initialState, "State should not change while AI action pending")
end

-- Test 25: Drawing State - Defender Beats All Cards
print("\n--- Drawing State Defender Wins Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.DRAWING)

    local initialAttacker = game.currentAttacker
    local initialDefender = game.currentDefender

    -- Set up successful defense (all attack cards beaten)
    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.defenseCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SEVEN)
    game.attackCards[2] = card.createCard(card.Suit.HEARTS, card.Rank.EIGHT)
    game.defenseCards[2] = card.createCard(card.Suit.HEARTS, card.Rank.NINE)

    loop:handleDrawingState()

    assert(game.currentAttacker == initialDefender, "Defender should become new attacker after winning")
    assert(stateManager:getState() == GameState.READY, "Should return to READY state")
end

-- Test 26: Drawing State - Defender Takes Cards
print("\n--- Drawing State Defender Takes Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.DRAWING)

    local initialAttacker = game.currentAttacker

    -- Set up failed defense (not all cards beaten)
    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.defenseCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SEVEN)
    game.attackCards[2] = card.createCard(card.Suit.HEARTS, card.Rank.EIGHT)
    game.defenseCards[2] = nil  -- Second attack card not beaten

    loop:handleDrawingState()

    assert(game.currentAttacker == initialAttacker, "Attacker should remain same when defender takes cards")
    assert(stateManager:getState() == GameState.READY, "Should return to READY state")
end

-- Test 27: onCardClicked - THROWING State Attack
print("\n--- onCardClicked Attack Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.THROWING)
    game.currentAttacker = 1  -- Human player

    -- Give human player a card
    local player1 = game.players[1]
    local testCard = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    player1:addCard(testCard)

    local initialHandSize = player1:handSize()

    loop:onCardClicked(1)

    assert(player1:handSize() == initialHandSize - 1, "Card should be removed from hand")
    assert(game.attackCards[1] ~= nil, "Card should be added to attack cards")
    assert(stateManager:getState() == GameState.THROWN, "Should transition to THROWN state")
end

-- Test 28: onCardClicked - BEATING State Defense
print("\n--- onCardClicked Defense Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.BEATING)
    game.currentDefender = 1  -- Human player
    game.trumpSuit = card.Suit.HEARTS

    -- Set up attack card
    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)

    -- Give human player a beating card
    local player1 = game.players[1]
    local beatingCard = card.createCard(card.Suit.SPADES, card.Rank.KING)
    player1:addCard(beatingCard)

    local initialHandSize = player1:handSize()

    loop:onCardClicked(1)

    assert(player1:handSize() == initialHandSize - 1, "Card should be removed from hand")
    assert(game.defenseCards[1] ~= nil, "Card should be added to defense cards")
    assert(stateManager:getState() == GameState.BEATEN, "Should transition to BEATEN state")
    assert(loop.waitingForDefender == false, "waitingForDefender should be reset")
end

-- Test 29: onTakeCards - Defender Gives Up
print("\n--- onTakeCards Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.THROWN)
    game.currentDefender = 1  -- Human player
    loop.waitingForDefender = true

    loop:onTakeCards()

    assert(loop.waitingForDefender == false, "waitingForDefender should be reset")
    assert(stateManager:getState() == GameState.DRAWING, "Should transition to DRAWING state")
end

-- Test 30: onDone - Player Finished Throwing Additional
print("\n--- onDone Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.BEATEN)
    game.currentDefender = 2  -- Not human
    game.playerDoneStatuses[1] = false

    loop:onDone()

    assert(game.playerDoneStatuses[1] == true, "Player 1 should be marked as done")
end

-- Test 31: State Persistence Through Update Cycles
print("\n--- State Persistence Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()

    -- Set to READY and update multiple times
    stateManager:setState(GameState.READY)
    loop:update(0.1)

    -- Should transition to THROWING
    assert(stateManager:getState() == GameState.THROWING, "Should transition from READY to THROWING")
end

-- Test 32: Invalid State Handling
print("\n--- Invalid State Handling Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    -- Try to handle THROWN state when defender clicks card (should require BEATING state)
    stateManager:setState(GameState.THROWN)
    game.currentDefender = 1

    local player1 = game.players[1]
    player1:addCard(card.createCard(card.Suit.SPADES, card.Rank.KING))

    local initialState = stateManager:getState()
    loop:onCardClicked(1)

    -- State should not change because we're in THROWN, not BEATING
    assert(stateManager:getState() == initialState, "Invalid state transition should be prevented")
end

-- Test 33: Player Done Status Reset
print("\n--- Done Status Reset Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    stateManager:setState(GameState.DRAWING)

    -- Mark players as done
    game.playerDoneStatuses[1] = true
    game.playerDoneStatuses[2] = true

    -- Set up successful defense
    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.defenseCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SEVEN)

    loop:handleDrawingState()

    assert(game.playerDoneStatuses[1] == false, "Player 1 done status should be reset")
    assert(game.playerDoneStatuses[2] == false, "Player 2 done status should be reset")
end

-- Test 34: Multiple Attack Cards on Table
print("\n--- Multiple Attack Cards Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    game.trumpSuit = card.Suit.HEARTS

    -- Multiple attack cards
    game.attackCards[1] = card.createCard(card.Suit.SPADES, card.Rank.SIX)
    game.attackCards[2] = card.createCard(card.Suit.CLUBS, card.Rank.SEVEN)
    game.attackCards[3] = card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT)

    -- Card that can beat the second attack card
    local beatingCard = card.createCard(card.Suit.CLUBS, card.Rank.KING)
    local result = loop:canBeatWithCard(beatingCard)

    assert(result == true, "Should be able to beat any undefended attack card")
end

-- Test 35: Game Over Does Not Block onTakeCards
print("\n--- Game Over Block onTakeCards Tests ---")
do
    local game, stateManager, modules = createTestGame()
    local loop = GameLoop.create(game, stateManager, modules)

    loop.gameOver = true
    stateManager:setState(GameState.THROWN)
    game.currentDefender = 1

    local initialState = stateManager:getState()
    loop:onTakeCards()

    assert(stateManager:getState() == initialState, "State should not change when game is over")
end

print("\n=== Game Loop Tests Complete ===")

return true

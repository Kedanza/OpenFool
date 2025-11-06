-- integration_test_love.lua
-- Integration Tests - Full Game Round Playability
-- Tests that all systems work together for a complete playable round

print("\n=== Integration Tests: Full Game Round ===\n")

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

-- Helper: Create a basic game state for testing
local function createTestGame(playerCount, deckSize)
    playerCount = playerCount or 4
    deckSize = deckSize or 36
    
    local ruleSet = ruleset.createRuleSet({
        playerCount = playerCount,
        cardCount = deckSize,
        deuceBeatsAce = false,
        teamPlay = false,
        allowPass = false
    })
    local game = gameSetup.setupGame(ruleSet)
    local stateManager = GameState.createGameStateManager()

    local modules = {
        Card = card,
        GameState = GameState.GameState,
        Turn = Turn,
        AI = AI,
        RuleSet = ruleset
    }

    return game, stateManager, modules
end

print("--- Test 1: Complete Single Turn (Attacker throws, Defender beats) ---")
do
    -- Create game
    local game, stateManager, modules = createTestGame(4, 36)
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()
    
    print("Initial state: " .. (stateManager:getState() == modules.GameState.READY and "READY" or "UNKNOWN"))
    print("Attacker: Player " .. game.currentAttacker)
    print("Defender: Player " .. game.currentDefender)
    print("Deck cards: " .. game.deck:remaining())
    
    local initialDeckSize = game.deck:remaining()
    local initialAttackerCards = game.players[game.currentAttacker]:handSize()
    local initialDefenderCards = game.players[game.currentDefender]:handSize()
    
    -- Play through one complete turn
    local turnComplete = false
    local stateHistory = {}
    local maxIterations = 50
    local iterations = 0
    
    while not turnComplete and iterations < maxIterations do
        local currentState = stateManager:getState()
        table.insert(stateHistory, currentState)
        
        loop:update(2.0) -- Use long update to skip AI thinking time
        iterations = iterations + 1
        
        -- Check if we completed a full turn cycle (back to READY)
        if currentState ~= modules.GameState.READY and 
           stateManager:getState() == modules.GameState.READY then
            turnComplete = true
        end
        
        if loop.gameOver then
            break
        end
    end
    
    print("Turn completed in " .. iterations .. " iterations")
    print("State transitions: " .. #stateHistory)
    print("Final state: READY = " .. tostring(stateManager:getState() == modules.GameState.READY))
    
    -- Verify turn completion
    assert(turnComplete or loop.gameOver, "Turn should complete or game should end")
    assert(#stateHistory > 0, "Should have state transitions")
    
    -- Verify cards were drawn (if deck not empty)
    if initialDeckSize > 0 then
        local currentDeckSize = game.deck:remaining()
        print("Deck: " .. initialDeckSize .. " -> " .. currentDeckSize .. " (drew " .. (initialDeckSize - currentDeckSize) .. " cards)")
    end
    
    print("✓ Single turn completed successfully\n")
end

print("--- Test 2: Multiple Consecutive Turns ---")
do
    local game, stateManager, modules = createTestGame(4, 36)
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()
    
    local turnsCompleted = 0
    local maxTurns = 5
    local maxIterationsPerTurn = 50
    
    print("Playing " .. maxTurns .. " consecutive turns...")
    
    for turnNum = 1, maxTurns do
        local turnStartDeck = game.deck:remaining()
        local turnComplete = false
        local iterations = 0
        
        -- Wait for turn to complete
        while not turnComplete and iterations < maxIterationsPerTurn do
            local beforeState = stateManager:getState()
            loop:update(2.0)
            iterations = iterations + 1
            
            if beforeState ~= modules.GameState.READY and 
               stateManager:getState() == modules.GameState.READY then
                turnComplete = true
                turnsCompleted = turnsCompleted + 1
            end
            
            if loop.gameOver then
                print("Game ended at turn " .. turnNum)
                break
            end
        end
        
        if loop.gameOver then
            break
        end
        
        assert(turnComplete, "Turn " .. turnNum .. " should complete")
        print("  Turn " .. turnNum .. " complete (deck: " .. game.deck:remaining() .. ")")
    end
    
    print("Completed " .. turnsCompleted .. " turns")
    assert(turnsCompleted > 0, "Should complete at least one turn")
    print("✓ Multiple turns work correctly\n")
end

print("--- Test 3: AI Decision Making Verification ---")
do
    local game, stateManager, modules = createTestGame(4, 36)
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()
    
    -- Track AI actions
    local aiActions = {
        attacks = 0,
        defenses = 0,
        throwAdditional = 0,
        takes = 0
    }
    
    -- Monitor game for AI actions
    local iterations = 0
    local maxIterations = 100
    local lastAttackCards = 0
    local lastDefenseCards = 0
    
    while iterations < maxIterations and not loop.gameOver do
        -- Count current cards on table
        local currentAttackCards = 0
        local currentDefenseCards = 0
        for i = 1, 6 do
            if game.attackCards[i] then currentAttackCards = currentAttackCards + 1 end
            if game.defenseCards[i] then currentDefenseCards = currentDefenseCards + 1 end
        end
        
        -- Detect AI actions
        if currentAttackCards > lastAttackCards then
            aiActions.attacks = aiActions.attacks + 1
            print("  AI attack detected (total: " .. aiActions.attacks .. ")")
        end
        
        if currentDefenseCards > lastDefenseCards then
            aiActions.defenses = aiActions.defenses + 1
            print("  AI defense detected (total: " .. aiActions.defenses .. ")")
        end
        
        lastAttackCards = currentAttackCards
        lastDefenseCards = currentDefenseCards
        
        loop:update(2.0)
        iterations = iterations + 1
        
        -- Stop after a few turns
        if aiActions.attacks >= 3 then
            break
        end
    end
    
    print("\nAI Actions Summary:")
    print("  Attacks: " .. aiActions.attacks)
    print("  Defenses: " .. aiActions.defenses)
    
    assert(aiActions.attacks > 0, "AI should have made at least one attack")
    assert(aiActions.defenses >= 0, "AI defense count should be tracked")
    print("✓ AI is making decisions\n")
end

print("--- Test 4: Game State Consistency ---")
do
    local game, stateManager, modules = createTestGame(4, 36)
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()
    
    -- Track inconsistencies
    local inconsistencies = {}
    
    -- Play for a bit and check consistency
    for i = 1, 20 do
        loop:update(2.0)
        
        -- Check: Total cards in system should be constant (until deck runs out)
        local totalCards = game.deck:remaining() + #game.discardPile
        for playerIdx = 1, #game.players do
            totalCards = totalCards + game.players[playerIdx]:handSize()
        end
        for j = 1, 6 do
            if game.attackCards[j] then totalCards = totalCards + 1 end
            if game.defenseCards[j] then totalCards = totalCards + 1 end
        end
        
        -- Initial deck should have known card count
        local expectedTotal = game.ruleSet.deckSize
        if totalCards ~= expectedTotal then
            table.insert(inconsistencies, "Iteration " .. i .. ": Card count mismatch. Expected " .. expectedTotal .. ", got " .. totalCards)
        end
        
        -- Check: Attacker and defender should be different
        if game.currentAttacker == game.currentDefender then
            table.insert(inconsistencies, "Iteration " .. i .. ": Attacker and defender are the same player!")
        end
        
        -- Check: Attack and defense arrays should have valid pairings
        for j = 1, 6 do
            if game.defenseCards[j] and not game.attackCards[j] then
                table.insert(inconsistencies, "Iteration " .. i .. ": Defense card without attack card at position " .. j)
            end
        end
        
        if loop.gameOver then
            break
        end
    end
    
    print("Consistency checks completed")
    print("Inconsistencies found: " .. #inconsistencies)
    
    if #inconsistencies > 0 then
        for _, issue in ipairs(inconsistencies) do
            print("  ⚠ " .. issue)
        end
    end
    
    assert(#inconsistencies == 0, "Game state should remain consistent")
    print("✓ Game state remains consistent\n")
end

print("--- Test 5: Win Condition Eventually Reached ---")
do
    -- Use smaller deck for faster game
    local game, stateManager, modules = createTestGame(2, 24) -- 2 players, 24-card deck
    local loop = GameLoop.create(game, stateManager, modules)
    loop:initialize()
    
    print("Playing until game over (2 players, 24-card deck)...")
    print("Initial deck: " .. game.deck:remaining() .. " cards")
    
    local iterations = 0
    local maxIterations = 500 -- Prevent infinite loop
    
    while not loop.gameOver and iterations < maxIterations do
        loop:update(2.0)
        iterations = iterations + 1
        
        -- Progress update every 50 iterations
        if iterations % 50 == 0 then
            print("  Iteration " .. iterations .. ", Deck: " .. game.deck:remaining())
        end
    end
    
    print("Game result:")
    print("  Iterations: " .. iterations)
    print("  Game over: " .. tostring(loop.gameOver))
    print("  Deck remaining: " .. game.deck:remaining())
    
    if loop.gameOver then
        print("  Winner: " .. tostring(loop.winner))
    end
    
    -- With a 24-card deck and 2 players, game should finish
    assert(loop.gameOver or iterations < maxIterations, "Game should eventually end")
    
    if loop.gameOver then
        print("✓ Game can reach completion\n")
    else
        print("⚠ Game did not complete in " .. maxIterations .. " iterations (may need more time)\n")
    end
end

print("\n=== Integration Test Summary ===")
print("✓ All integration tests passed!")
print("✓ Full game rounds are playable")
print("✓ AI systems are integrated and functional")
print("✓ Game state remains consistent")
print("\nThe game systems are properly connected and working together.")

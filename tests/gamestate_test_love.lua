-- tests/gamestate_test_love.lua
-- Tests for the game state management system

local GameStateModule = require("gamestate")
local GameState = GameStateModule.GameState
local createGameStateManager = GameStateModule.createGameStateManager

print("\n=== GameState Module Tests ===")

-- Test Group 1: GameState Enum Values
print("\n--- GameState Enum Tests ---")
assert(GameState.READY == 0, "GameState.READY should be 0")
assert(GameState.DRAWING == 1, "GameState.DRAWING should be 1")
assert(GameState.THROWING == 2, "GameState.THROWING should be 2")
assert(GameState.THROWN == 3, "GameState.THROWN should be 3")
assert(GameState.BEATING == 4, "GameState.BEATING should be 4")
assert(GameState.BEATEN == 5, "GameState.BEATEN should be 5")
assert(GameState.FINISHED == 6, "GameState.FINISHED should be 6")

-- Test Group 2: Manager Creation
print("\n--- Manager Creation Tests ---")
local manager = createGameStateManager()
assert(manager ~= nil, "createGameStateManager should return a manager")
assert(manager:getState() == GameState.DRAWING, "Initial state should be DRAWING")
assert(manager:getPreviousState() == nil, "Initial previous state should be nil")

-- Test Group 3: State Name Retrieval
print("\n--- State Name Tests ---")
assert(manager:getStateName(GameState.READY) == "READY", "getStateName should return 'READY' for READY state")
assert(manager:getStateName(GameState.DRAWING) == "DRAWING", "getStateName should return 'DRAWING' for DRAWING state")
assert(manager:getStateName(GameState.THROWING) == "THROWING", "getStateName should return 'THROWING' for THROWING state")
assert(manager:getStateName(GameState.THROWN) == "THROWN", "getStateName should return 'THROWN' for THROWN state")
assert(manager:getStateName(GameState.BEATING) == "BEATING", "getStateName should return 'BEATING' for BEATING state")
assert(manager:getStateName(GameState.BEATEN) == "BEATEN", "getStateName should return 'BEATEN' for BEATEN state")
assert(manager:getStateName(GameState.FINISHED) == "FINISHED", "getStateName should return 'FINISHED' for FINISHED state")
assert(manager:getStateName(999) == "UNKNOWN", "getStateName should return 'UNKNOWN' for invalid state")

-- Test Group 4: Valid State Transitions
print("\n--- Valid State Transition Tests ---")

-- READY transitions
local manager1 = createGameStateManager()
manager1:setState(GameState.READY, true)
assert(manager1:isValidTransition(GameState.READY, GameState.THROWING), "READY -> THROWING should be valid")
assert(manager1:isValidTransition(GameState.READY, GameState.FINISHED), "READY -> FINISHED should be valid")

-- DRAWING transitions
assert(manager1:isValidTransition(GameState.DRAWING, GameState.READY), "DRAWING -> READY should be valid")
assert(manager1:isValidTransition(GameState.DRAWING, GameState.FINISHED), "DRAWING -> FINISHED should be valid")

-- THROWING transitions
assert(manager1:isValidTransition(GameState.THROWING, GameState.THROWN), "THROWING -> THROWN should be valid")
assert(manager1:isValidTransition(GameState.THROWING, GameState.FINISHED), "THROWING -> FINISHED should be valid")

-- THROWN transitions
assert(manager1:isValidTransition(GameState.THROWN, GameState.BEATING), "THROWN -> BEATING should be valid")
assert(manager1:isValidTransition(GameState.THROWN, GameState.BEATEN), "THROWN -> BEATEN should be valid")
assert(manager1:isValidTransition(GameState.THROWN, GameState.FINISHED), "THROWN -> FINISHED should be valid")

-- BEATING transitions
assert(manager1:isValidTransition(GameState.BEATING, GameState.BEATEN), "BEATING -> BEATEN should be valid")
assert(manager1:isValidTransition(GameState.BEATING, GameState.FINISHED), "BEATING -> FINISHED should be valid")

-- BEATEN transitions
assert(manager1:isValidTransition(GameState.BEATEN, GameState.THROWING), "BEATEN -> THROWING should be valid")
assert(manager1:isValidTransition(GameState.BEATEN, GameState.DRAWING), "BEATEN -> DRAWING should be valid")
assert(manager1:isValidTransition(GameState.BEATEN, GameState.FINISHED), "BEATEN -> FINISHED should be valid")

-- FINISHED transitions
assert(manager1:isValidTransition(GameState.FINISHED, GameState.READY), "FINISHED -> READY should be valid")
assert(manager1:isValidTransition(GameState.FINISHED, GameState.FINISHED), "FINISHED -> FINISHED should be valid")

-- Test Group 5: Invalid State Transitions
print("\n--- Invalid State Transition Tests ---")
assert(not manager1:isValidTransition(GameState.READY, GameState.DRAWING), "READY -> DRAWING should be invalid")
assert(not manager1:isValidTransition(GameState.READY, GameState.BEATEN), "READY -> BEATEN should be invalid")
assert(not manager1:isValidTransition(GameState.DRAWING, GameState.THROWING), "DRAWING -> THROWING should be invalid")
assert(not manager1:isValidTransition(GameState.THROWING, GameState.BEATING), "THROWING -> BEATING should be invalid")
assert(not manager1:isValidTransition(GameState.THROWN, GameState.THROWING), "THROWN -> THROWING should be invalid")
assert(not manager1:isValidTransition(GameState.BEATING, GameState.THROWING), "BEATING -> THROWING should be invalid")

-- Test Group 6: setState with Valid Transitions
print("\n--- setState Valid Transition Tests ---")
local manager2 = createGameStateManager()
assert(manager2:getState() == GameState.DRAWING, "Should start in DRAWING state")

local result = manager2:setState(GameState.READY)
assert(result == true, "setState should return true for valid transition")
assert(manager2:getState() == GameState.READY, "State should change to READY")
assert(manager2:getPreviousState() == GameState.DRAWING, "Previous state should be DRAWING")

result = manager2:setState(GameState.THROWING)
assert(result == true, "READY -> THROWING should succeed")
assert(manager2:getState() == GameState.THROWING, "State should be THROWING")

result = manager2:setState(GameState.THROWN)
assert(result == true, "THROWING -> THROWN should succeed")
assert(manager2:getState() == GameState.THROWN, "State should be THROWN")

-- Test Group 7: setState with Invalid Transitions
print("\n--- setState Invalid Transition Tests ---")
local manager3 = createGameStateManager()
manager3:setState(GameState.READY, true)

local result = manager3:setState(GameState.DRAWING)  -- Invalid from READY
assert(result == false, "setState should return false for invalid transition")
assert(manager3:getState() == GameState.READY, "State should remain READY after invalid transition")

-- Test Group 8: setState with Skip Validation
print("\n--- setState Skip Validation Tests ---")
local manager4 = createGameStateManager()
assert(manager4:getState() == GameState.DRAWING, "Should start in DRAWING")

-- Force an invalid transition by skipping validation
local result = manager4:setState(GameState.BEATING, true)
assert(result == true, "setState with skipValidation should succeed")
assert(manager4:getState() == GameState.BEATING, "State should change to BEATING")

-- Test Group 9: setState Same State
print("\n--- setState Same State Tests ---")
local manager5 = createGameStateManager()
manager5:setState(GameState.READY, true)

local result = manager5:setState(GameState.READY)
assert(result == true, "setState to same state should return true")
assert(manager5:getState() == GameState.READY, "State should remain READY")

-- Test Group 10: State Change Callbacks
print("\n--- State Change Callback Tests ---")
local manager6 = createGameStateManager()
local callbackCalled = false
local callbackOldState = nil
local callbackNewState = nil

local callbackId = manager6:onStateChange(function(oldState, newState)
    callbackCalled = true
    callbackOldState = oldState
    callbackNewState = newState
end, "test-callback")

manager6:setState(GameState.READY)
assert(callbackCalled == true, "Callback should be called on state change")
assert(callbackOldState == GameState.DRAWING, "Callback should receive old state DRAWING")
assert(callbackNewState == GameState.READY, "Callback should receive new state READY")

-- Test Group 11: Multiple Callbacks
print("\n--- Multiple Callback Tests ---")
local manager7 = createGameStateManager()
local callback1Called = false
local callback2Called = false

manager7:onStateChange(function(oldState, newState)
    callback1Called = true
end, "callback1")

manager7:onStateChange(function(oldState, newState)
    callback2Called = true
end, "callback2")

manager7:setState(GameState.READY, true)
assert(callback1Called == true, "Callback 1 should be called")
assert(callback2Called == true, "Callback 2 should be called")

-- Test Group 12: Remove Callback
print("\n--- Remove Callback Tests ---")
local manager8 = createGameStateManager()
local callbackRemoved = false

local id = manager8:onStateChange(function(oldState, newState)
    callbackRemoved = true
end, "remove-test")

local removed = manager8:removeCallback("remove-test")
assert(removed == true, "removeCallback should return true when callback exists")

manager8:setState(GameState.READY, true)
assert(callbackRemoved == false, "Removed callback should not be called")

removed = manager8:removeCallback("nonexistent")
assert(removed == false, "removeCallback should return false for nonexistent callback")

-- Test Group 13: Clear Callbacks
print("\n--- Clear Callbacks Tests ---")
local manager9 = createGameStateManager()
local clearTest1 = false
local clearTest2 = false

manager9:onStateChange(function() clearTest1 = true end, "clear1")
manager9:onStateChange(function() clearTest2 = true end, "clear2")

manager9:clearCallbacks()
manager9:setState(GameState.READY, true)

assert(clearTest1 == false, "Cleared callback 1 should not be called")
assert(clearTest2 == false, "Cleared callback 2 should not be called")

-- Test Group 14: Reset Manager
print("\n--- Reset Manager Tests ---")
local manager10 = createGameStateManager()
manager10:setState(GameState.READY, true)
manager10:setState(GameState.THROWING)

manager10:reset()
assert(manager10:getState() == GameState.DRAWING, "Reset should return to DRAWING state")
assert(manager10:getPreviousState() == nil, "Reset should clear previous state")

manager10:reset(GameState.READY)
assert(manager10:getState() == GameState.READY, "Reset with parameter should set to specified state")

-- Test Group 15: isState Helper
print("\n--- isState Helper Tests ---")
local manager11 = createGameStateManager()
manager11:setState(GameState.READY, true)

assert(manager11:isState(GameState.READY) == true, "isState should return true for current state")
assert(manager11:isState(GameState.DRAWING) == false, "isState should return false for other state")

-- Test Group 16: isAnyState Helper
print("\n--- isAnyState Helper Tests ---")
local manager12 = createGameStateManager()
manager12:setState(GameState.THROWING, true)

assert(manager12:isAnyState({GameState.THROWING, GameState.BEATING}) == true, "isAnyState should return true when state is in list")
assert(manager12:isAnyState({GameState.READY, GameState.DRAWING}) == false, "isAnyState should return false when state is not in list")
assert(manager12:isAnyState({GameState.THROWING}) == true, "isAnyState should work with single item")
assert(manager12:isAnyState({}) == false, "isAnyState should return false for empty list")

-- Test Group 17: Full Game Flow Simulation
print("\n--- Full Game Flow Tests ---")
local manager13 = createGameStateManager()

-- Simulate a complete game turn
assert(manager13:setState(GameState.READY), "DRAWING -> READY")
assert(manager13:setState(GameState.THROWING), "READY -> THROWING")
assert(manager13:setState(GameState.THROWN), "THROWING -> THROWN")
assert(manager13:setState(GameState.BEATING), "THROWN -> BEATING")
assert(manager13:setState(GameState.BEATEN), "BEATING -> BEATEN")
assert(manager13:setState(GameState.DRAWING), "BEATEN -> DRAWING")
assert(manager13:setState(GameState.READY), "DRAWING -> READY (new turn)")

-- Test alternative flow (defender takes cards)
manager13:reset()
assert(manager13:setState(GameState.READY), "Start turn")
assert(manager13:setState(GameState.THROWING), "Throw card")
assert(manager13:setState(GameState.THROWN), "Card thrown")
assert(manager13:setState(GameState.BEATEN), "Defender takes (THROWN -> BEATEN)")
assert(manager13:setState(GameState.DRAWING), "Start drawing")

-- Test Group 18: Invalid State Value Handling
print("\n--- Invalid State Value Tests ---")
local manager14 = createGameStateManager()
local result = manager14:setState(999)  -- Invalid state value
assert(result == false, "setState should return false for invalid state value")
assert(manager14:getState() == GameState.DRAWING, "State should remain unchanged after invalid setState")

-- Test Group 19: Logging Enable/Disable
print("\n--- Logging Tests ---")
local manager15 = createGameStateManager()
manager15:setLogging(false)
-- This test just verifies the method exists and doesn't crash
manager15:setLogging(true)
manager15:setLogging(false)
assert(true, "setLogging should not crash")

-- Test Group 20: Module-level getStateName Function
print("\n--- Module getStateName Tests ---")
local getStateName = GameStateModule.getStateName
assert(getStateName(GameState.READY) == "READY", "Module getStateName should work for READY")
assert(getStateName(GameState.FINISHED) == "FINISHED", "Module getStateName should work for FINISHED")
assert(getStateName(999) == "UNKNOWN", "Module getStateName should return UNKNOWN for invalid state")

return true

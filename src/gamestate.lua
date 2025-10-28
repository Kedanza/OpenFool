-- gamestate.lua
-- Game State Management System for OpenFool
-- Manages game states and state transitions with validation and callbacks

-- GameState enum
-- Represents the current state of the game
local GameState = {
    READY = 0,       -- Ready to start a turn (attacker can throw)
    DRAWING = 1,     -- Drawing cards from deck after a turn
    THROWING = 2,    -- Attacker is throwing a card
    THROWN = 3,      -- Card has been thrown, defender can respond
    BEATING = 4,     -- Defender is beating a card
    BEATEN = 5,      -- Card has been beaten, can throw additional cards
    FINISHED = 6     -- Turn is finished, preparing for next turn
}

-- Valid state transitions
-- This table defines which state transitions are allowed
local validTransitions = {
    [GameState.READY] = {
        [GameState.THROWING] = true,
        [GameState.FINISHED] = true  -- If game ends during READY
    },
    [GameState.DRAWING] = {
        [GameState.READY] = true,
        [GameState.FINISHED] = true
    },
    [GameState.THROWING] = {
        [GameState.THROWN] = true,
        [GameState.FINISHED] = true
    },
    [GameState.THROWN] = {
        [GameState.BEATING] = true,
        [GameState.BEATEN] = true,  -- Defender takes cards without beating
        [GameState.FINISHED] = true
    },
    [GameState.BEATING] = {
        [GameState.BEATEN] = true,
        [GameState.FINISHED] = true
    },
    [GameState.BEATEN] = {
        [GameState.THROWING] = true,  -- Throw additional cards
        [GameState.DRAWING] = true,   -- All done, start drawing
        [GameState.FINISHED] = true
    },
    [GameState.FINISHED] = {
        [GameState.READY] = true,     -- Start new turn
        [GameState.FINISHED] = true   -- Stay finished (game over)
    }
}

-- State names for debugging/logging
local stateNames = {
    [GameState.READY] = "READY",
    [GameState.DRAWING] = "DRAWING",
    [GameState.THROWING] = "THROWING",
    [GameState.THROWN] = "THROWN",
    [GameState.BEATING] = "BEATING",
    [GameState.BEATEN] = "BEATEN",
    [GameState.FINISHED] = "FINISHED"
}

-- Create a new game state manager
-- @return table - Game state manager object
local function createGameStateManager()
    local manager = {
        currentState = GameState.DRAWING,  -- Initial state
        previousState = nil,
        stateChangeCallbacks = {},
        logEnabled = false
    }
    
    -- Get the current state
    -- @return number - Current GameState value
    function manager:getState()
        return self.currentState
    end
    
    -- Get the previous state
    -- @return number|nil - Previous GameState value or nil
    function manager:getPreviousState()
        return self.previousState
    end
    
    -- Get state name for a given state value
    -- @param state number - GameState value
    -- @return string - State name
    function manager:getStateName(state)
        return stateNames[state] or "UNKNOWN"
    end
    
    -- Check if a state transition is valid
    -- @param fromState number - Source GameState
    -- @param toState number - Target GameState
    -- @return boolean - True if transition is valid
    function manager:isValidTransition(fromState, toState)
        if validTransitions[fromState] then
            return validTransitions[fromState][toState] == true
        end
        return false
    end
    
    -- Set the current state with validation
    -- @param newState number - New GameState value
    -- @param skipValidation boolean - Optional, skip transition validation
    -- @return boolean - True if state was changed successfully
    function manager:setState(newState, skipValidation)
        skipValidation = skipValidation or false
        
        -- Validate state value
        if not stateNames[newState] then
            if self.logEnabled then
                print("[GameState] ERROR: Invalid state value: " .. tostring(newState))
            end
            return false
        end
        
        -- Check if already in this state
        if self.currentState == newState then
            return true  -- Already in this state, nothing to do
        end
        
        -- Validate transition
        if not skipValidation and not self:isValidTransition(self.currentState, newState) then
            if self.logEnabled then
                print(string.format("[GameState] ERROR: Invalid transition from %s to %s",
                    self:getStateName(self.currentState),
                    self:getStateName(newState)))
            end
            return false
        end
        
        -- Store previous state
        local oldState = self.currentState
        self.previousState = oldState
        
        -- Update state
        self.currentState = newState
        
        -- Log state change
        if self.logEnabled then
            print(string.format("[GameState] State changed: %s -> %s",
                self:getStateName(oldState),
                self:getStateName(newState)))
        end
        
        -- Trigger callbacks
        self:triggerCallbacks(oldState, newState)
        
        return true
    end
    
    -- Register a state change callback
    -- @param callback function - Function to call on state change (oldState, newState)
    -- @param id string - Optional identifier for the callback
    -- @return string - Callback ID
    function manager:onStateChange(callback, id)
        id = id or tostring(callback)
        self.stateChangeCallbacks[id] = callback
        return id
    end
    
    -- Remove a state change callback
    -- @param id string - Callback ID to remove
    -- @return boolean - True if callback was removed
    function manager:removeCallback(id)
        if self.stateChangeCallbacks[id] then
            self.stateChangeCallbacks[id] = nil
            return true
        end
        return false
    end
    
    -- Trigger all registered callbacks
    -- @param oldState number - Previous state
    -- @param newState number - New state
    function manager:triggerCallbacks(oldState, newState)
        for id, callback in pairs(self.stateChangeCallbacks) do
            local success, err = pcall(callback, oldState, newState)
            if not success and self.logEnabled then
                print("[GameState] ERROR in callback '" .. id .. "': " .. tostring(err))
            end
        end
    end
    
    -- Clear all callbacks
    function manager:clearCallbacks()
        self.stateChangeCallbacks = {}
    end
    
    -- Reset to initial state
    -- @param initialState number - Optional initial state (default: DRAWING)
    function manager:reset(initialState)
        initialState = initialState or GameState.DRAWING
        self.previousState = nil
        self.currentState = initialState
        
        if self.logEnabled then
            print(string.format("[GameState] Reset to %s", self:getStateName(initialState)))
        end
    end
    
    -- Enable or disable logging
    -- @param enabled boolean - True to enable logging
    function manager:setLogging(enabled)
        self.logEnabled = enabled
    end
    
    -- Check if currently in a specific state
    -- @param state number - GameState to check
    -- @return boolean - True if in the specified state
    function manager:isState(state)
        return self.currentState == state
    end
    
    -- Check if in any of the specified states
    -- @param states table - Array of GameState values
    -- @return boolean - True if in any of the specified states
    function manager:isAnyState(states)
        for _, state in ipairs(states) do
            if self.currentState == state then
                return true
            end
        end
        return false
    end
    
    return manager
end

-- Export the module
return {
    GameState = GameState,
    createGameStateManager = createGameStateManager,
    getStateName = function(state) return stateNames[state] or "UNKNOWN" end
}

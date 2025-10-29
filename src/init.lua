-- src/init.lua
-- Central game module loader and game state manager

local Game = {}

-- Load all game modules
local Card = require("src.card")
local Deck = require("src.deck")
local Player = require("src.player")
local RuleSet = require("src.ruleset")
local GameState = require("src.gamestate")
local GameSetup = require("src.game_setup")
local Turn = require("src.turn")
local AIEvaluation = require("src.ai_evaluation")
local AIAttack = require("src.ai_attack")
local AIDefense = require("src.ai_defense")
local AIThrow = require("src.ai_throw_additional")

-- Create new game instance
function Game.new()
    local self = {}
    
    -- Game modules
    self.Card = Card
    self.Deck = Deck
    self.Player = Player
    self.RuleSet = RuleSet
    self.GameState = GameState
    self.GameSetup = GameSetup
    self.Turn = Turn
    self.AI = {
        evaluation = AIEvaluation,
        attack = AIAttack,
        defense = AIDefense,
        throw = AIThrow
    }
    
    -- Current game state
    self.currentGame = nil
    self.stateManager = nil
    
    -- Initialize game
    function self:initialize()
        -- Create default ruleset
        local ruleSet = RuleSet.createRuleSet()
        ruleSet.playerCount = 4
        ruleSet.cardCount = 36
        
        -- Setup game
        self.currentGame = GameSetup.setupGame(ruleSet)
        
        -- Create state manager
        self.stateManager = GameState.createGameStateManager()
        
        print("Game initialized:")
        print("  Players: " .. #self.currentGame.players)
        print("  Trump: " .. self.currentGame.trumpCard:toString())
        print("  First attacker: Player " .. self.currentGame.firstAttacker)
    end
    
    -- Update game state
    function self:update(dt)
        -- Game logic updates will go here
    end
    
    -- Draw game
    function self:draw()
        -- Center text
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("OpenFool - Durak Card Game", 0, screenHeight / 2 - 60, screenWidth, "center")
        
        if self.currentGame then
            love.graphics.printf("Press SPACE to start new game", 0, screenHeight / 2 - 20, screenWidth, "center")
            love.graphics.printf("Press ESC to quit", 0, screenHeight / 2 + 20, screenWidth, "center")
            
            -- Display game info
            local y = 50
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.print("Players: " .. #self.currentGame.players, 20, y)
            y = y + 20
            love.graphics.print("Trump: " .. self.currentGame.trumpCard:toString(), 20, y)
            y = y + 20
            love.graphics.print("Deck: " .. self.currentGame.deck:remaining() .. " cards", 20, y)
            y = y + 20
            love.graphics.print("Current attacker: Player " .. self.currentGame.currentAttacker, 20, y)
            y = y + 20
            love.graphics.print("Current defender: Player " .. self.currentGame.currentDefender, 20, y)
            
            -- Display player hands (card counts)
            y = y + 40
            love.graphics.setColor(1, 1, 0.5)
            love.graphics.print("Player Hands:", 20, y)
            y = y + 20
            for i = 1, #self.currentGame.players do
                local player = self.currentGame.players[i]
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.print("  Player " .. i .. " (" .. player.name .. "): " .. player:handSize() .. " cards", 20, y)
                y = y + 20
            end
        else
            love.graphics.printf("Press SPACE to initialize", 0, screenHeight / 2 + 20, screenWidth, "center")
        end
    end
    
    -- Handle keyboard input
    function self:keypressed(key, scancode, isrepeat)
        if key == "space" then
            self:initialize()
        end
    end
    
    -- Handle mouse press
    function self:mousepressed(x, y, button, istouch, presses)
        -- Mouse handling will go here
    end
    
    -- Handle mouse release
    function self:mousereleased(x, y, button, istouch, presses)
        -- Mouse handling will go here
    end
    
    -- Handle window resize
    function self:resize(w, h)
        print("Window resized to: " .. w .. "x" .. h)
    end
    
    return self
end

return Game

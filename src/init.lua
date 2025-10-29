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
local Assets = require("src.assets")
local Rendering = require("src.rendering")

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
    self.Assets = Assets
    self.Rendering = Rendering
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
        
        if self.currentGame then
            -- Draw players' hands
            local numPlayers = #self.currentGame.players
            
            -- Human player at bottom (player 1)
            local player1 = self.currentGame.players[1]
            Rendering.drawPlayerHand(player1.hand, screenWidth / 2, screenHeight - 120, {
                faceUp = true,
                maxWidth = 500,
                selectedIndex = nil
            })
            
            -- Draw trump card indicator
            Rendering.drawTrump(self.currentGame.trumpCard, screenWidth - 100, 20, self.currentGame.deck:remaining())
            
            -- Draw table (attack and defense cards)
            Rendering.drawTable(self.currentGame.attackCards, self.currentGame.defenseCards, screenWidth / 2, screenHeight / 2, {
                scale = 1.0,
                spacing = 130
            })
            
            -- Draw opponent hands (face down)
            if numPlayers >= 2 then
                -- Player 2 at top
                local player2 = self.currentGame.players[2]
                Rendering.drawPlayerHand(player2.hand, screenWidth / 2, 120, {
                    faceUp = false,
                    maxWidth = 400,
                    scale = 0.6
                })
            end
            
            if numPlayers >= 3 then
                -- Player 3 at left
                local player3 = self.currentGame.players[3]
                Rendering.drawPlayerHand(player3.hand, 150, screenHeight / 2, {
                    faceUp = false,
                    maxWidth = 300,
                    scale = 0.6
                })
            end
            
            if numPlayers >= 4 then
                -- Player 4 at right
                local player4 = self.currentGame.players[4]
                Rendering.drawPlayerHand(player4.hand, screenWidth - 150, screenHeight / 2, {
                    faceUp = false,
                    maxWidth = 300,
                    scale = 0.6
                })
            end
            
            -- Draw status info at top left
            love.graphics.setColor(1, 1, 1, 0.9)
            Rendering.drawText("Attacker: Player " .. self.currentGame.currentAttacker, 20, 20, "normal")
            Rendering.drawText("Defender: Player " .. self.currentGame.currentDefender, 20, 45, "normal")
            
            -- Draw controls at bottom
            love.graphics.setColor(0.8, 0.8, 0.8, 0.7)
            Rendering.drawText("SPACE: New Game  |  ESC: Quit", 20, screenHeight - 25, "small")
        else
            -- No game started yet
            love.graphics.setColor(1, 1, 1)
            Rendering.drawTextCentered("OpenFool - Durak Card Game", screenHeight / 2 - 40, "title")
            Rendering.drawTextCentered("Press SPACE to start", screenHeight / 2 + 20, "large")
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

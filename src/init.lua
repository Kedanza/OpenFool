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
local GameLoop = require("src.game_loop")

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
    self.GameLoop = GameLoop
    self.AI = {
        evaluation = AIEvaluation,
        attack = AIAttack,
        defense = AIDefense,
        throw = AIThrow
    }
    
    -- Current game state
    self.currentGame = nil
    self.stateManager = nil
    self.gameLoop = nil
    self.selectedCardIndex = 1  -- For keyboard navigation
    
    -- Initialize game
    function self:initialize()
        -- Create default ruleset
        local ruleSet = RuleSet.createRuleSet(Card)
        ruleSet.playerCount = 4
        ruleSet.cardCount = 36
        
        -- Setup game
        self.currentGame = GameSetup.setupGame(ruleSet)
        
        -- Force Player 1 to be first attacker for testing
        self.currentGame.firstAttacker = 1
        self.currentGame.currentAttacker = 1
        self.currentGame.currentDefender = 2
        
        -- Create state manager
        self.stateManager = GameState.createGameStateManager()
        
        -- Create game loop with all modules
        self.gameLoop = GameLoop.create(self.currentGame, self.stateManager, {
            GameState = GameState.GameState,
            Card = Card,
            Deck = Deck,
            Player = Player,
            RuleSet = RuleSet,
            Turn = Turn,
            AI = {
                evaluation = AIEvaluation,
                attack = AIAttack,
                defense = AIDefense,
                throw = AIThrow
            }
        })
        
        -- Initialize the game loop
        self.gameLoop:initialize()
        
        print("Game initialized:")
        print("  Players: " .. #self.currentGame.players)
        print("  Trump: " .. self.currentGame.trumpCard:toString())
        print("  First attacker: Player " .. self.currentGame.firstAttacker)
    end
    
    -- Update game state
    function self:update(dt)
        if self.gameLoop then
            self.gameLoop:update(dt)
        end
    end
    
    -- Draw game
    function self:draw()
        -- Center text
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        
        if self.currentGame then
            -- Check if game is over
            if self.gameLoop and self.gameLoop.gameOver then
                -- Game over screen
                love.graphics.setColor(1, 1, 1)
                Rendering.drawTextCentered("Game Over!", screenHeight / 2 - 80, "title")
                
                local winner = self.gameLoop.winner
                local winnerText = ""
                if type(winner) == "number" then
                    if winner == 0 then
                        winnerText = "Draw!"
                    else
                        -- In Fool, the last player loses
                        winnerText = "Player " .. winner .. " is the Fool!"
                        love.graphics.setColor(1, 0.3, 0.3)
                    end
                elseif type(winner) == "string" then
                    winnerText = winner == "team1" and "Team 1 Wins!" or "Team 2 Wins!"
                end
                
                love.graphics.setColor(1, 1, 1)
                Rendering.drawTextCentered(winnerText, screenHeight / 2 - 20, "large")
                Rendering.drawTextCentered("Press SPACE for new game", screenHeight / 2 + 40, "normal")
                return
            end
            
            -- Draw players' hands
            local numPlayers = #self.currentGame.players
            local baseScale = Rendering.getBaseScale()

            -- Human player at bottom (player 1)
            local player1 = self.currentGame.players[1]
            Rendering.drawPlayerHand(player1.hand, screenWidth / 2, screenHeight - 120, {
                faceUp = true,
                maxWidth = screenWidth * 0.625,  -- 62.5% of screen width
                scale = baseScale,
                selectedIndex = self.selectedCardIndex
            })

            -- Draw trump card indicator
            Rendering.drawTrump(self.currentGame.trumpCard, screenWidth - 100, 20, self.currentGame.deck:remaining(), baseScale * 0.7)

            -- Draw table (attack and defense cards)
            Rendering.drawTable(self.currentGame.attackCards, self.currentGame.defenseCards, screenWidth / 2, screenHeight / 2, {
                scale = baseScale * 1.1,  -- Slightly larger for table cards
                spacing = 130 * baseScale
            })

            -- Draw opponent hands (face down)
            if numPlayers >= 2 then
                -- Player 2 at top
                local player2 = self.currentGame.players[2]
                Rendering.drawPlayerHand(player2.hand, screenWidth / 2, 120, {
                    faceUp = false,
                    maxWidth = screenWidth * 0.5,  -- 50% of screen width
                    scale = baseScale * 0.85  -- Slightly smaller for opponents
                })
            end

            if numPlayers >= 3 then
                -- Player 3 at left
                local player3 = self.currentGame.players[3]
                Rendering.drawPlayerHand(player3.hand, 150, screenHeight / 2, {
                    faceUp = false,
                    maxWidth = screenWidth * 0.375,  -- 37.5% of screen width
                    scale = baseScale * 0.85
                })
            end

            if numPlayers >= 4 then
                -- Player 4 at right
                local player4 = self.currentGame.players[4]
                Rendering.drawPlayerHand(player4.hand, screenWidth - 150, screenHeight / 2, {
                    faceUp = false,
                    maxWidth = screenWidth * 0.375,  -- 37.5% of screen width
                    scale = baseScale * 0.85
                })
            end
            
            -- Draw status info at top left
            love.graphics.setColor(1, 1, 1, 0.9)
            Rendering.drawText("Attacker: Player " .. self.currentGame.currentAttacker, 20, 20, "normal")
            Rendering.drawText("Defender: Player " .. self.currentGame.currentDefender, 20, 45, "normal")
            
            -- Draw game state
            if self.stateManager then
                local stateName = self.stateManager:getStateName(self.stateManager:getState())
                Rendering.drawText("State: " .. stateName, 20, 70, "small")
            end
            
            -- Draw controls at bottom
            love.graphics.setColor(0.8, 0.8, 0.8, 0.7)
            local controls = ""
            
            -- Add context-sensitive controls
            local GameState = GameState.GameState
            if self.stateManager then
                local state = self.stateManager:getState()
                
                if state == GameState.THROWING and self.currentGame.currentAttacker == 1 then
                    controls = "A/D or ←/→: Select Card  |  W/↑/Enter or 1-6: Play Card  |  "
                elseif state == GameState.BEATING and self.currentGame.currentDefender == 1 then
                    controls = "A/D or ←/→: Select Card  |  W/↑/Enter or 1-6: Beat  |  T: Take Cards  |  "
                elseif state == GameState.BEATEN and self.currentGame.currentDefender ~= 1 then
                    controls = "A/D or ←/→: Select Card  |  W/↑/Enter or 1-6: Throw  |  S/↓: Done  |  "
                end
            end
            
            controls = controls .. "SPACE: New Game  |  ESC: Quit"
            Rendering.drawText(controls, 20, screenHeight - 25, "small")
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
            -- Only allow new game if no game active or game is over
            if not self.currentGame or (self.gameLoop and self.gameLoop.gameOver) then
                self:initialize()
                self.selectedCardIndex = 1
            end
        elseif not self.currentGame or not self.gameLoop then
            return
        -- Card navigation with A/D or Left/Right arrows
        elseif key == "a" or key == "left" then
            -- Move selection left
            if self.selectedCardIndex > 1 then
                self.selectedCardIndex = self.selectedCardIndex - 1
            end
        elseif key == "d" or key == "right" then
            -- Move selection right
            local player = self.currentGame.players[1]
            if self.selectedCardIndex < #player.hand then
                self.selectedCardIndex = self.selectedCardIndex + 1
            end
        -- Play selected card with W, Up, or Enter
        elseif key == "w" or key == "up" or key == "return" then
            if self.selectedCardIndex and self.selectedCardIndex >= 1 then
                local player = self.currentGame.players[1]
                if self.selectedCardIndex <= #player.hand then
                    self.gameLoop:onCardClicked(self.selectedCardIndex)
                    -- Adjust selection if it's out of range after playing
                    if self.selectedCardIndex > #player.hand and self.selectedCardIndex > 1 then
                        self.selectedCardIndex = self.selectedCardIndex - 1
                    end
                end
            end
        -- Number keys 1-6 to select cards directly
        elseif key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" then
            local num = tonumber(key)
            local player = self.currentGame.players[1]
            if num <= #player.hand then
                self.selectedCardIndex = num
                -- Auto-play on number key press
                self.gameLoop:onCardClicked(self.selectedCardIndex)
                -- Adjust selection if needed
                if self.selectedCardIndex > #player.hand and self.selectedCardIndex > 1 then
                    self.selectedCardIndex = self.selectedCardIndex - 1
                end
            end
        elseif key == "t" and self.gameLoop then
            -- "T" to take cards (defender gives up)
            self.gameLoop:onTakeCards()
        elseif key == "s" or key == "down" then
            -- "S" or Down for done throwing additional cards
            if self.gameLoop then
                self.gameLoop:onDone()
            end
        end
    end
    
    -- Handle mouse press
    function self:mousepressed(x, y, button, istouch, presses)
        if not self.currentGame or not self.gameLoop or self.gameLoop.gameOver then
            return
        end

        if button == 1 then  -- Left click
            -- Check if clicking on player 1's hand (human player)
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()
            local player = self.currentGame.players[1]

            -- Calculate hand position (same as in draw)
            local handX = screenWidth / 2
            local handY = screenHeight - 120
            local maxWidth = screenWidth * 0.625  -- Match draw function
            local cardScale = Rendering.getBaseScale()  -- Use responsive scale

            -- Check each card in hand
            local handSize = #player.hand
            if handSize > 0 then
                local totalWidth = math.min(maxWidth, handSize * Rendering.getCardWidth() * cardScale)
                local spacing = totalWidth / math.max(1, handSize - 1)
                if handSize == 1 then spacing = 0 end

                local startX = handX - totalWidth / 2

                for i = 1, handSize do
                    local cardX = startX + (i - 1) * spacing
                    local cardY = handY

                    -- Apply fan arc
                    local t = (i - 1) / math.max(1, handSize - 1)
                    if handSize == 1 then t = 0.5 end
                    local arc = math.sin(t * math.pi) * 20
                    cardY = cardY - arc

                    -- Check if click is on this card
                    if Rendering.isPointInCard(x, y, cardX, cardY, cardScale) then
                        self.gameLoop:onCardClicked(i)
                        return
                    end
                end
            end
        end
    end
    
    -- Handle mouse release
    function self:mousereleased(x, y, button, istouch, presses)
        -- Mouse handling will go here
    end
    
    -- Handle window resize
    function self:resize(w, h)
        print("Window resized to: " .. w .. "x" .. h)
        -- Update card scaling for new screen size
        Rendering.updateScale()
    end
    
    return self
end

return Game

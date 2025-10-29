-- main.lua
-- OpenFool - Durak Card Game
-- Love2D Main Application File

-- Load all game modules
local Game = require("src.init")

-- Global game state
local game = nil

-- Love2D Callbacks
function love.load()
    -- Set up graphics defaults
    love.graphics.setBackgroundColor(0.2, 0.5, 0.3) -- Green table color
    love.graphics.setDefaultFilter("linear", "linear")
    
    -- Initialize random seed
    math.randomseed(os.time())
    
    -- Load assets
    print("Loading assets...")
    local Assets = require("src.assets")
    Assets.load()
    
    if not Assets.isReady() then
        print("WARNING: Some assets failed to load!")
    end
    
    -- Initialize rendering system
    local Rendering = require("src.rendering")
    Rendering.initialize()
    
    -- Create new game instance
    game = Game.new()
    
    print("OpenFool loaded successfully!")
    print("Window: " .. love.graphics.getWidth() .. "x" .. love.graphics.getHeight())
end

function love.update(dt)
    if game then
        game:update(dt)
    end
end

function love.draw()
    if game then
        game:draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- ESC to quit
    if key == "escape" then
        love.event.quit()
    end
    
    -- F11 to toggle fullscreen
    if key == "f11" then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
    end
    
    -- Pass to game
    if game then
        game:keypressed(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if game then
        game:mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if game then
        game:mousereleased(x, y, button, istouch, presses)
    end
end

function love.resize(w, h)
    if game then
        game:resize(w, h)
    end
end

function love.quit()
    print("Goodbye!")
    return false
end

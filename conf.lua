-- conf.lua
-- Love2D configuration file for OpenFool

function love.conf(t)
    -- Game identity (for save directory)
    t.identity = "openfool"

    -- Version requirements
    t.version = "11.4"
    t.console = true  -- Enable console for debugging

    -- Allow symlinks and external storage (for development/testing)
    t.accelerometerjoystick = false

    -- Append identity to search path
    -- This helps with finding files in development
    t.appendidentity = false
    
    -- Window configuration
    t.window.title = "OpenFool - Durak Card Game"
    t.window.icon = nil
    t.window.width = 800
    t.window.height = 600
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 4
    t.window.display = 1
    t.window.highdpi = false
    t.window.x = nil
    t.window.y = nil
    
    -- Module configuration
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end

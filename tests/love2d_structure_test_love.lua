-- Love2D Project Structure Tests
-- Tests for main.lua, conf.lua, and src/init.lua functionality

print('\n=== Love2D Project Structure Tests ===')

-- Test main.lua loading (skip this as it loads assets and may cause issues in test environment)
print('\n--- Main.lua Loading Tests ---')
print('  Skipping main.lua load test (loads assets which may fail in test environment)')

-- Test conf.lua configuration
print('\n--- Conf.lua Configuration Tests ---')
local success, err = pcall(function()
    require('conf')
end)
assert(success, 'conf.lua should load without errors')
-- Note: We can't test conf() execution directly as it requires Love2D to be initialized
-- The conf.lua file defines love.conf which is called by Love2D during startup

-- Test src/init.lua module loading
print('\n--- Init.lua Module Loading Tests ---')
local success, Game = pcall(function()
    return require('src.init')
end)
assert(success, 'src/init.lua should load without errors')
assert(type(Game) == 'table', 'Game should be a table')
assert(type(Game.new) == 'function', 'Game.new should be a function')

-- Test creating a game instance
local success, game = pcall(function()
    return Game.new()
end)
assert(success, 'Game.new() should execute without errors')
assert(type(game) == 'table', 'game instance should be a table')
assert(type(game.update) == 'function', 'game.update should be a function')
assert(type(game.draw) == 'function', 'game.draw should be a function')
assert(type(game.keypressed) == 'function', 'game.keypressed should be a function')
assert(type(game.mousepressed) == 'function', 'game.mousepressed should be a function')

return true

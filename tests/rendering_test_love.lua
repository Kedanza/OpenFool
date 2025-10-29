-- Rendering System Tests
-- Tests for src/rendering.lua functionality

print('\n=== Rendering System Tests ===')

-- Test rendering module loading
print('\n--- Rendering Module Tests ---')
local success, rendering = pcall(function()
    return require('src.rendering')
end)
assert(success, 'src/rendering.lua should load without errors')
assert(type(rendering) == 'table', 'rendering should be a table')

-- Test function existence
assert(type(rendering.initialize) == 'function', 'initialize should be a function')
assert(type(rendering.drawCard) == 'function', 'drawCard should be a function')
assert(type(rendering.drawPlayerHand) == 'function', 'drawPlayerHand should be a function')
assert(type(rendering.drawTable) == 'function', 'drawTable should be a function')
assert(type(rendering.drawTrump) == 'function', 'drawTrump should be a function')
assert(type(rendering.drawText) == 'function', 'drawText should be a function')
assert(type(rendering.drawTextCentered) == 'function', 'drawTextCentered should be a function')
assert(type(rendering.getCardWidth) == 'function', 'getCardWidth should be a function')
assert(type(rendering.getCardHeight) == 'function', 'getCardHeight should be a function')
assert(type(rendering.isPointInCard) == 'function', 'isPointInCard should be a function')

-- Test initialization (will use fallback dimensions since graphics not initialized)
print('\n--- Initialization Tests ---')
local success, err = pcall(function()
    rendering.initialize()
end)
assert(success, 'initialize() should execute without errors')

-- Test card dimension functions
print('\n--- Card Dimension Tests ---')
local width = rendering.getCardWidth()
local height = rendering.getCardHeight()
assert(type(width) == 'number', 'getCardWidth should return a number')
assert(type(height) == 'number', 'getCardHeight should return a number')
assert(width > 0, 'card width should be positive')
assert(height > 0, 'card height should be positive')

-- Test point in card function
print('\n--- Point in Card Tests ---')
-- Test center point (should be inside)
local inside = rendering.isPointInCard(0, 0, 0, 0, 1.0)
assert(inside == true, 'center point should be inside card')

-- Test point outside card
local outside = rendering.isPointInCard(100, 100, 0, 0, 1.0)
assert(outside == false, 'distant point should be outside card')

-- Test scaled card
local insideScaled = rendering.isPointInCard(10, 10, 0, 0, 2.0)
assert(insideScaled == true, 'point should be inside scaled card')

return true
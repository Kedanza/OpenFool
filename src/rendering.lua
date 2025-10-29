-- rendering.lua
-- Card Rendering System
-- Draws cards, hands, and table layouts

local Rendering = {}

-- Load dependencies
local Assets = require("src.assets")

-- Card dimensions (from loaded images)
local CARD_WIDTH = nil
local CARD_HEIGHT = nil

-- Initialize card dimensions from loaded assets
function Rendering.initialize()
    local sampleCard = Assets.getCard(1, 0) -- Ace of Spades
    if sampleCard then
        CARD_WIDTH = sampleCard:getWidth()
        CARD_HEIGHT = sampleCard:getHeight()
        print("Card dimensions: " .. CARD_WIDTH .. "x" .. CARD_HEIGHT)
    else
        -- Fallback dimensions
        CARD_WIDTH = 71
        CARD_HEIGHT = 96
        print("Warning: Using fallback card dimensions")
    end
end

-- Draw a single card
-- @param card table Card object with rank and suit, or nil for card back
-- @param x number X position (center of card)
-- @param y number Y position (center of card)
-- @param options table Optional parameters:
--   - rotation: number Rotation in radians (default 0)
--   - scale: number Scale factor (default 1.0)
--   - faceUp: boolean Show face or back (default true)
--   - alpha: number Transparency 0-1 (default 1.0)
--   - highlight: boolean Draw highlight border (default false)
function Rendering.drawCard(card, x, y, options)
    options = options or {}
    local rotation = options.rotation or 0
    local scale = options.scale or 1.0
    local faceUp = options.faceUp ~= false -- default true
    local alpha = options.alpha or 1.0
    local highlight = options.highlight or false
    
    -- Get the appropriate image
    local image
    if faceUp and card then
        image = Assets.getCardImage(card)
    else
        image = Assets.getCardBack()
    end
    
    if not image then
        -- Draw placeholder rectangle if image not found
        love.graphics.setColor(0.8, 0.8, 0.8, alpha)
        love.graphics.rectangle("fill", x - 35 * scale, y - 48 * scale, 70 * scale, 96 * scale)
        love.graphics.setColor(0.2, 0.2, 0.2, alpha)
        love.graphics.rectangle("line", x - 35 * scale, y - 48 * scale, 70 * scale, 96 * scale)
        return
    end
    
    -- Draw highlight if selected
    if highlight then
        love.graphics.setColor(1, 1, 0, 0.5) -- Yellow highlight
        love.graphics.rectangle("fill", 
            x - (CARD_WIDTH / 2 + 3) * scale, 
            y - (CARD_HEIGHT / 2 + 3) * scale, 
            (CARD_WIDTH + 6) * scale, 
            (CARD_HEIGHT + 6) * scale)
    end
    
    -- Draw the card
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(image, x, y, rotation, scale, scale, CARD_WIDTH / 2, CARD_HEIGHT / 2)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw a player's hand of cards in a fan layout
-- @param hand table Array of card objects
-- @param x number Center X position of the fan
-- @param y number Center Y position of the fan
-- @param options table Optional parameters:
--   - maxWidth: number Maximum width of the hand (default 400)
--   - faceUp: boolean Show cards face up (default true)
--   - scale: number Card scale (default 0.7)
--   - fanAngle: number Total angle of fan in radians (default 0.3)
--   - selectedIndex: number Index of selected card (1-based)
function Rendering.drawPlayerHand(hand, x, y, options)
    options = options or {}
    local maxWidth = options.maxWidth or 400
    local faceUp = options.faceUp ~= false
    local scale = options.scale or 0.7
    local fanAngle = options.fanAngle or 0.3
    local selectedIndex = options.selectedIndex
    
    if not hand or #hand == 0 then
        return
    end
    
    -- Calculate spacing between cards
    local cardCount = 0
    for _, card in ipairs(hand) do
        if card then
            cardCount = cardCount + 1
        end
    end
    
    if cardCount == 0 then
        return
    end
    
    local spacing = math.min(CARD_WIDTH * scale * 0.6, maxWidth / cardCount)
    local totalWidth = spacing * (cardCount - 1)
    local startX = x - totalWidth / 2
    
    -- Draw each card
    local cardIndex = 0
    for i, card in ipairs(hand) do
        if card then
            local cardX = startX + spacing * cardIndex
            local cardY = y
            
            -- Calculate fan rotation
            local t = cardCount > 1 and (cardIndex / (cardCount - 1)) or 0.5
            local rotation = -fanAngle / 2 + fanAngle * t
            
            -- Slight arc for visual appeal
            local arc = math.sin(t * math.pi) * 20
            cardY = cardY - arc
            
            -- Highlight selected card
            local highlight = (selectedIndex == i)
            if highlight then
                cardY = cardY - 20 -- Raise selected card
            end
            
            Rendering.drawCard(card, cardX, cardY, {
                rotation = rotation,
                scale = scale,
                faceUp = faceUp,
                highlight = highlight
            })
            
            cardIndex = cardIndex + 1
        end
    end
end

-- Draw the attack and defense cards on the table
-- @param attackCards table Array of attack cards
-- @param defenseCards table Array of defense cards
-- @param x number Center X position
-- @param y number Center Y position
-- @param options table Optional parameters:
--   - scale: number Card scale (default 0.8)
--   - spacing: number Spacing between pairs (default 120)
function Rendering.drawTable(attackCards, defenseCards, x, y, options)
    options = options or {}
    local scale = options.scale or 0.8
    local spacing = options.spacing or 120
    
    -- Count actual cards
    local pairCount = 0
    for i = 1, math.min(#attackCards, #defenseCards) do
        if attackCards[i] then
            pairCount = pairCount + 1
        end
    end
    
    if pairCount == 0 then
        return
    end
    
    -- Calculate starting position
    local totalWidth = spacing * (pairCount - 1)
    local startX = x - totalWidth / 2
    
    -- Draw each pair
    local pairIndex = 0
    for i = 1, math.min(#attackCards, #defenseCards) do
        if attackCards[i] then
            local pairX = startX + spacing * pairIndex
            
            -- Draw attack card (bottom)
            Rendering.drawCard(attackCards[i], pairX, y + 15, {
                scale = scale,
                faceUp = true
            })
            
            -- Draw defense card if present (on top, slightly offset)
            if defenseCards[i] then
                Rendering.drawCard(defenseCards[i], pairX + 20, y - 15, {
                    scale = scale,
                    faceUp = true
                })
            end
            
            pairIndex = pairIndex + 1
        end
    end
end

-- Draw the trump card indicator
-- @param trumpCard table Trump card object
-- @param x number X position
-- @param y number Y position
-- @param deckSize number Number of cards remaining in deck
function Rendering.drawTrump(trumpCard, x, y, deckSize)
    if not trumpCard then
        return
    end
    
    -- Draw deck pile (card back)
    Rendering.drawCard(nil, x, y, {
        scale = 0.6,
        faceUp = false,
        rotation = math.pi / 2 -- Rotated 90 degrees
    })
    
    -- Draw trump card underneath (slightly visible)
    Rendering.drawCard(trumpCard, x - 30, y, {
        scale = 0.6,
        faceUp = true,
        rotation = math.pi / 2
    })
    
    -- Draw deck count
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Assets.getFont("normal"))
    love.graphics.print(deckSize, x + 40, y - 8)
end

-- Draw centered text with font
-- @param text string Text to draw
-- @param x number X position
-- @param y number Y position
-- @param fontName string Font name ("small", "normal", "large", "title")
function Rendering.drawText(text, x, y, fontName)
    fontName = fontName or "normal"
    love.graphics.setFont(Assets.getFont(fontName))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x, y)
end

-- Draw centered text
-- @param text string Text to draw
-- @param y number Y position
-- @param fontName string Font name
function Rendering.drawTextCentered(text, y, fontName)
    fontName = fontName or "normal"
    local font = Assets.getFont(fontName)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    
    local screenWidth = love.graphics.getWidth()
    love.graphics.printf(text, 0, y, screenWidth, "center")
end

-- Get card dimensions
function Rendering.getCardWidth()
    return CARD_WIDTH
end

function Rendering.getCardHeight()
    return CARD_HEIGHT
end

-- Check if point is inside card bounds
-- @param x number Point X
-- @param y number Point Y
-- @param cardX number Card center X
-- @param cardY number Card center Y
-- @param scale number Card scale
-- @return boolean True if point is inside card
function Rendering.isPointInCard(x, y, cardX, cardY, scale)
    scale = scale or 1.0
    local halfWidth = (CARD_WIDTH / 2) * scale
    local halfHeight = (CARD_HEIGHT / 2) * scale
    
    return x >= cardX - halfWidth and x <= cardX + halfWidth and
           y >= cardY - halfHeight and y <= cardY + halfHeight
end

return Rendering

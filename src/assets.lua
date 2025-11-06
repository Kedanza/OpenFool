-- assets.lua
-- Asset Loading and Management System
-- Loads card images, backgrounds, suits, and fonts

local Assets = {}

-- Asset storage
Assets.cards = {}          -- Card images indexed by "rank-suit" (e.g., "1-s", "13-h")
Assets.cardBack = nil      -- Card back image
Assets.suits = {}          -- Suit symbol images (indexed by suit number 0-3)
Assets.background = nil    -- Background texture
Assets.fonts = {}          -- Fonts for different sizes

-- Asset paths
local ASSETS_PATH = "android/assets/"
local DECK_PATH = ASSETS_PATH .. "decks/rus/"
local BACKGROUNDS_PATH = ASSETS_PATH .. "backgrounds/"
local SUITS_PATH = ASSETS_PATH .. "suits/"

-- Suit letter mapping (matches our card naming convention)
local SUIT_LETTERS = {
    [0] = "s",  -- SPADES
    [1] = "d",  -- DIAMONDS
    [2] = "c",  -- CLUBS
    [3] = "h"   -- HEARTS
}

local SUIT_NAMES = {
    [0] = "spades",
    [1] = "diamonds",
    [2] = "clubs",
    [3] = "hearts"
}

-- Load all assets
function Assets.load()
    print("Loading assets...")

    -- Debug: Check if asset directories exist
    local deck_info = love.filesystem.getInfo(DECK_PATH)
    print("Debug: DECK_PATH = " .. DECK_PATH)
    print("Debug: Deck dir exists? " .. tostring(deck_info ~= nil))
    if deck_info then
        print("Debug: Deck dir type = " .. deck_info.type)
    end

    -- Load card images
    Assets.loadCards()
    
    -- Load card back
    Assets.loadCardBack()
    
    -- Load suit symbols
    Assets.loadSuits()
    
    -- Load background
    Assets.loadBackground()
    
    -- Load fonts
    Assets.loadFonts()
    
    print("Assets loaded successfully!")
    print("  Cards: " .. Assets.getCardCount())
    print("  Suits: " .. Assets.getSuitCount())
end

-- Load all 52 card images
function Assets.loadCards()
    local count = 0

    -- Load cards for each rank (1-13) and suit (s, d, c, h)
    for rank = 1, 13 do
        for suit = 0, 3 do
            local suitLetter = SUIT_LETTERS[suit]
            local filename = rank .. suitLetter .. ".png"
            local filepath = DECK_PATH .. filename

            -- Create key for this card (e.g., "1-0", "13-3")
            local key = rank .. "-" .. suit

            -- Try to load the image
            local success, image_or_err = pcall(love.graphics.newImage, filepath)
            if success then
                Assets.cards[key] = image_or_err
                count = count + 1
            else
                -- If Love2D filesystem can't find it, use native Lua io
                -- This works in test environment where Love2D filesystem is restricted
                local native_file = io.open(filepath, "rb")
                if native_file then
                    local filedata = native_file:read("*all")
                    native_file:close()

                    -- Create ImageData from the raw file data
                    local success2, image2 = pcall(function()
                        local imageData = love.image.newImageData(love.data.newByteData(filedata))
                        return love.graphics.newImage(imageData)
                    end)

                    if success2 then
                        Assets.cards[key] = image2
                        count = count + 1
                    else
                        print("Warning: File exists but could not load: " .. filepath)
                        print("  Error: " .. tostring(image2))
                    end
                else
                    print("Warning: File not found: " .. filepath)
                end
            end
        end
    end

    print("  Loaded " .. count .. " card images")
end

-- Load card back image
function Assets.loadCardBack()
    local filepath = DECK_PATH .. "back.png"
    local success, image = pcall(love.graphics.newImage, filepath)
    if success then
        Assets.cardBack = image
        print("  Loaded card back")
    else
        -- Try native Lua io fallback
        local native_file = io.open(filepath, "rb")
        if native_file then
            local filedata = native_file:read("*all")
            native_file:close()
            local success2, image2 = pcall(function()
                local imageData = love.image.newImageData(love.data.newByteData(filedata))
                return love.graphics.newImage(imageData)
            end)
            if success2 then
                Assets.cardBack = image2
                print("  Loaded card back (via native io)")
            else
                print("Warning: Could not load card back: " .. filepath)
            end
        else
            print("Warning: Could not load card back: " .. filepath)
        end
    end
end

-- Load suit symbol images
function Assets.loadSuits()
    local count = 0

    for suit = 0, 3 do
        local suitName = SUIT_NAMES[suit]
        local filename = suitName .. ".png"
        local filepath = SUITS_PATH .. filename

        local success, image = pcall(love.graphics.newImage, filepath)
        if success then
            Assets.suits[suit] = image
            count = count + 1
        else
            -- Try native Lua io fallback
            local native_file = io.open(filepath, "rb")
            if native_file then
                local filedata = native_file:read("*all")
                native_file:close()
                local success2, image2 = pcall(function()
                    local imageData = love.image.newImageData(love.data.newByteData(filedata))
                    return love.graphics.newImage(imageData)
                end)
                if success2 then
                    Assets.suits[suit] = image2
                    count = count + 1
                else
                    print("Warning: Could not load suit: " .. filepath)
                end
            else
                print("Warning: Could not load suit: " .. filepath)
            end
        end
    end

    print("  Loaded " .. count .. " suit symbols")
end

-- Load background
function Assets.loadBackground()
    local filepath = BACKGROUNDS_PATH .. "background1.png"
    local success, image = pcall(love.graphics.newImage, filepath)
    if success then
        Assets.background = image
        print("  Loaded background")
    else
        -- Try native Lua io fallback
        local native_file = io.open(filepath, "rb")
        if native_file then
            local filedata = native_file:read("*all")
            native_file:close()
            local success2, image2 = pcall(function()
                local imageData = love.image.newImageData(love.data.newByteData(filedata))
                return love.graphics.newImage(imageData)
            end)
            if success2 then
                Assets.background = image2
                print("  Loaded background (via native io)")
            else
                print("Warning: Could not load background: " .. filepath)
            end
        else
            print("Warning: Could not load background: " .. filepath)
        end
    end
end

-- Load fonts
function Assets.loadFonts()
    -- Load default font at different sizes
    Assets.fonts.small = love.graphics.newFont(12)
    Assets.fonts.normal = love.graphics.newFont(16)
    Assets.fonts.large = love.graphics.newFont(24)
    Assets.fonts.title = love.graphics.newFont(32)
    
    print("  Loaded fonts")
end

-- Get card image by rank and suit
-- @param rank number (1-13)
-- @param suit number (0-3)
-- @return Image or nil
function Assets.getCard(rank, suit)
    local key = rank .. "-" .. suit
    return Assets.cards[key]
end

-- Get card image from Card object
-- @param card table Card object with rank and suit fields
-- @return Image or nil
function Assets.getCardImage(card)
    if not card then
        return nil
    end
    return Assets.getCard(card.rank, card.suit)
end

-- Get suit symbol image
-- @param suit number (0-3)
-- @return Image or nil
function Assets.getSuit(suit)
    return Assets.suits[suit]
end

-- Get card back image
-- @return Image or nil
function Assets.getCardBack()
    return Assets.cardBack
end

-- Get background image
-- @return Image or nil
function Assets.getBackground()
    return Assets.background
end

-- Get font by name
-- @param name string ("small", "normal", "large", "title")
-- @return Font
function Assets.getFont(name)
    return Assets.fonts[name] or Assets.fonts.normal
end

-- Utility functions
function Assets.getCardCount()
    local count = 0
    for _ in pairs(Assets.cards) do
        count = count + 1
    end
    return count
end

function Assets.getSuitCount()
    local count = 0
    for _ in pairs(Assets.suits) do
        count = count + 1
    end
    return count
end

-- Check if all critical assets are loaded
function Assets.isReady()
    return Assets.cardBack ~= nil and
           Assets.background ~= nil and
           Assets.getCardCount() >= 52 and
           Assets.getSuitCount() >= 4
end

return Assets

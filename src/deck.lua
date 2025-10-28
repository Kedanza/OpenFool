-- Deck module for OpenFool
-- Translated from Deck.kt
-- Licensed under MIT License

local card = require("card")
local Suit = card.Suit
local Rank = card.Rank
local createCard = card.createCard

-- Deck factory function
-- Creates a deck with cards from lowestRank to King (plus Aces)
-- @param lowestRank: The lowest rank to include (default: TWO)
--                    Common values: TWO (52 cards), SIX (36 cards), SEVEN (32 cards), NINE (24 cards)
-- @return: deck object with methods
local function createDeck(lowestRank)
    lowestRank = lowestRank or Rank.TWO
    
    local deck = {
        cards = {},
        lowestRank = lowestRank
    }
    
    -- Reset deck: create all cards based on lowestRank
    local function reset()
        deck.cards = {}
        
        -- For each rank and each suit
        -- Original Kotlin logic: r >= lowestRank || r == Rank.ACE
        for rank = Rank.ACE, Rank.KING do
            for suit = Suit.SPADES, Suit.HEARTS do
                -- Add card if rank >= lowestRank OR rank is ACE
                if rank >= lowestRank or rank == Rank.ACE then
                    table.insert(deck.cards, createCard(suit, rank))
                end
            end
        end
    end
    
    -- Fisher-Yates shuffle algorithm
    -- Provides unbiased randomization
    local function shuffle()
        -- Use Love2D's random if available, otherwise use math.random
        local randomFunc = (love and love.math and love.math.random) or math.random
        
        for i = #deck.cards, 2, -1 do
            local j = randomFunc(1, i)
            deck.cards[i], deck.cards[j] = deck.cards[j], deck.cards[i]
        end
    end
    
    -- Draw a card from the deck
    -- Removes and returns the last card (bottom of deck)
    -- @return: card object or nil if deck is empty
    function deck:draw()
        if #self.cards > 0 then
            return table.remove(self.cards)
        end
        return nil
    end
    
    -- Get number of remaining cards
    -- @return: number of cards left in deck
    function deck:remaining()
        return #self.cards
    end
    
    -- Shuffle the deck (public method)
    -- Can be called to re-shuffle the deck
    function deck:shuffle()
        shuffle()
    end
    
    -- Reset the deck (public method)
    -- Recreates all cards and shuffles
    function deck:reset()
        reset()
        shuffle()
    end
    
    -- Initialize: create cards and shuffle
    reset()
    shuffle()
    
    return deck
end

-- Export module
return {
    createDeck = createDeck
}

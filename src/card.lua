-- Card module for OpenFool
-- Translated from Card.kt, Suit.kt, and Rank.kt
-- Licensed under MIT License

-- Suit enum-like table
-- Values match the original Kotlin implementation
local Suit = {
    SPADES = 0,
    DIAMONDS = 1,
    CLUBS = 2,
    HEARTS = 3
}

-- Suit name lookup for toString
local SuitNames = {
    [0] = "spades",
    [1] = "diamonds",
    [2] = "clubs",
    [3] = "hearts"
}

-- Rank enum-like table
-- Values match the original Kotlin implementation
local Rank = {
    ACE = 1,
    TWO = 2,
    THREE = 3,
    FOUR = 4,
    FIVE = 5,
    SIX = 6,
    SEVEN = 7,
    EIGHT = 8,
    NINE = 9,
    TEN = 10,
    JACK = 11,
    QUEEN = 12,
    KING = 13
}

-- Helper function to get rank from int (like Rank.fromInt in Kotlin)
local function rankFromInt(value)
    for name, val in pairs(Rank) do
        if val == value then
            return val
        end
    end
    return nil
end

-- Card factory function
-- Creates a card object with suit and rank
-- @param suit: Suit value (0-3)
-- @param rank: Rank value (1-13)
-- @return: card object with methods
local function createCard(suit, rank)
    local card = {
        suit = suit,
        rank = rank
    }

    -- beats method: determines if this card beats another card
    -- Implements the core game logic from Card.kt
    -- @param other: another card object
    -- @param trumpSuit: the trump suit for this round
    -- @param deuceBeatsAce: boolean flag for special rule
    -- @return: true if this card beats the other card
    function card:beats(other, trumpSuit, deuceBeatsAce)
        -- Calculate rank values using (rank + 11) % 13
        -- This makes deuce = 0 and ace = 12 for comparison purposes
        local thisRankValue = (self.rank + 11) % 13
        local otherRankValue = (other.rank + 11) % 13

        if self.suit == other.suit then
            -- Same suit: higher rank wins
            -- Special case: deuce beats ace if deuceBeatsAce is true
            return thisRankValue >= otherRankValue or
                   (deuceBeatsAce and thisRankValue == 0 and otherRankValue == 12)
        else
            -- Different suit: only trump beats
            return self.suit == trumpSuit
        end
    end

    -- toString method: converts card to string representation
    -- Format: "{rank}{suit_first_letter}" e.g., "1s" for Ace of Spades
    -- @return: string representation of the card
    function card:toString()
        local suitName = SuitNames[self.suit] or "unknown"
        local suitLetter = string.sub(suitName, 1, 1)
        return string.format("%d%s", self.rank, suitLetter)
    end

    -- equals method: compares two cards for equality
    -- @param other: another card object
    -- @return: true if both cards have the same suit and rank
    function card:equals(other)
        if not other then
            return false
        end
        return self.suit == other.suit and self.rank == other.rank
    end

    return card
end

-- Utility function: finds a card in a hand (table of cards)
-- @param hand: table of card objects
-- @param targetCard: the card to find
-- @return: index of the card in the hand, or nil if not found
local function findCardInHand(hand, targetCard)
    if not hand or not targetCard then
        return nil
    end

    for i, card in ipairs(hand) do
        if card:equals(targetCard) then
            return i
        end
    end

    return nil
end

-- Export module
return {
    Suit = Suit,
    Rank = Rank,
    createCard = createCard,
    findCardInHand = findCardInHand,
    rankFromInt = rankFromInt
}

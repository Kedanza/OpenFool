-- Unit tests for deck.lua (Love2D version)

local deck_module = require("deck")
local card_module = require("card")
local createDeck = deck_module.createDeck
local Suit = card_module.Suit
local Rank = card_module.Rank

-- Use global test helpers
local assert_equal = _G.assert_equal
local assert_true = _G.assert_true
local assert_false = _G.assert_false
local assert_not_nil = _G.assert_not_nil
local test_output = _G.test_output

table.insert(test_output, "\n=== Deck Module Tests ===\n")

-- Test createDeck with different lowest ranks
table.insert(test_output, "-- Deck Creation Tests --")

local deck52 = createDeck(Rank.TWO)
assert_not_nil(deck52, "createDeck should create a deck object")
assert_equal(deck52:remaining(), 52, "52-card deck should have 52 cards (lowestRank=TWO)")

local deck36 = createDeck(Rank.SIX)
assert_equal(deck36:remaining(), 36, "36-card deck should have 36 cards (lowestRank=SIX)")

local deck32 = createDeck(Rank.SEVEN)
assert_equal(deck32:remaining(), 32, "32-card deck should have 32 cards (lowestRank=SEVEN)")

local deck24 = createDeck(Rank.NINE)
assert_equal(deck24:remaining(), 24, "24-card deck should have 24 cards (lowestRank=NINE)")

-- Test default lowestRank (should be TWO)
local deckDefault = createDeck()
assert_equal(deckDefault:remaining(), 52, "Default deck should have 52 cards")

-- Test draw method
table.insert(test_output, "\n-- Draw Tests --")

local testDeck = createDeck(Rank.SIX)
local initialCount = testDeck:remaining()
local drawnCard = testDeck:draw()

assert_not_nil(drawnCard, "draw() should return a card")
assert_equal(testDeck:remaining(), initialCount - 1, "Deck should have one less card after draw")
assert_not_nil(drawnCard.suit, "Drawn card should have a suit")
assert_not_nil(drawnCard.rank, "Drawn card should have a rank")

-- Test drawing all cards
table.insert(test_output, "\n-- Draw All Cards Tests --")

local smallDeck = createDeck(Rank.NINE)  -- 24 cards
local cardCount = 0
while smallDeck:remaining() > 0 do
    local c = smallDeck:draw()
    if c then
        cardCount = cardCount + 1
    end
end

assert_equal(cardCount, 24, "Should be able to draw all 24 cards")
assert_equal(smallDeck:remaining(), 0, "Deck should be empty after drawing all cards")

-- Test draw from empty deck
local emptyCard = smallDeck:draw()
assert_equal(emptyCard, nil, "draw() should return nil when deck is empty")

-- Test remaining method
table.insert(test_output, "\n-- Remaining Tests --")

local countDeck = createDeck(Rank.SIX)
assert_equal(countDeck:remaining(), 36, "remaining() should return correct count")

countDeck:draw()
countDeck:draw()
countDeck:draw()
assert_equal(countDeck:remaining(), 33, "remaining() should update after draws")

-- Test shuffle method
table.insert(test_output, "\n-- Shuffle Tests --")

-- Create two decks with same lowestRank
local deck1 = createDeck(Rank.SIX)
local deck2 = createDeck(Rank.SIX)

-- Draw all cards from both decks and compare order
local cards1 = {}
local cards2 = {}

while deck1:remaining() > 0 do
    table.insert(cards1, deck1:draw())
end

while deck2:remaining() > 0 do
    table.insert(cards2, deck2:draw())
end

-- Count how many cards are in different positions
local differentPositions = 0
for i = 1, #cards1 do
    if not cards1[i]:equals(cards2[i]) then
        differentPositions = differentPositions + 1
    end
end

-- With proper shuffling, at least some cards should be in different positions
-- (statistically very unlikely to be identical with random shuffle)
assert_true(differentPositions > 0, "Shuffled decks should have different card orders")

-- Test reset method
table.insert(test_output, "\n-- Reset Tests --")

local resetDeck = createDeck(Rank.SIX)
resetDeck:draw()
resetDeck:draw()
resetDeck:draw()
assert_equal(resetDeck:remaining(), 33, "Deck should have 33 cards after 3 draws")

resetDeck:reset()
assert_equal(resetDeck:remaining(), 36, "Deck should have 36 cards after reset")

-- Test that deck contains correct ranks
table.insert(test_output, "\n-- Deck Composition Tests --")

local compositionDeck = createDeck(Rank.SIX)
local rankCounts = {}

-- Initialize rank counts
for rank = Rank.ACE, Rank.KING do
    rankCounts[rank] = 0
end

-- Count all ranks in deck
while compositionDeck:remaining() > 0 do
    local c = compositionDeck:draw()
    if c then
        rankCounts[c.rank] = rankCounts[c.rank] + 1
    end
end

-- For lowestRank=SIX, we should have:
-- - 4 Aces (one per suit)
-- - 4 Sixes, 4 Sevens, ..., 4 Kings
-- - 0 Twos, 0 Threes, 0 Fours, 0 Fives

assert_equal(rankCounts[Rank.ACE], 4, "Should have 4 Aces")
assert_equal(rankCounts[Rank.SIX], 4, "Should have 4 Sixes")
assert_equal(rankCounts[Rank.KING], 4, "Should have 4 Kings")
assert_equal(rankCounts[Rank.TWO], 0, "Should have 0 Twos (below lowestRank)")
assert_equal(rankCounts[Rank.FIVE], 0, "Should have 0 Fives (below lowestRank)")

-- Test deck with lowestRank=TWO includes all ranks
table.insert(test_output, "\n-- Full Deck Composition Tests --")

local fullDeck = createDeck(Rank.TWO)
local fullRankCounts = {}

for rank = Rank.ACE, Rank.KING do
    fullRankCounts[rank] = 0
end

while fullDeck:remaining() > 0 do
    local c = fullDeck:draw()
    if c then
        fullRankCounts[c.rank] = fullRankCounts[c.rank] + 1
    end
end

-- All ranks should have 4 cards
for rank = Rank.ACE, Rank.KING do
    assert_equal(fullRankCounts[rank], 4, "Rank " .. rank .. " should have 4 cards in full deck")
end

-- Test that all four suits are represented
table.insert(test_output, "\n-- Suit Distribution Tests --")

local suitDeck = createDeck(Rank.SIX)
local suitCounts = {}

for suit = Suit.SPADES, Suit.HEARTS do
    suitCounts[suit] = 0
end

while suitDeck:remaining() > 0 do
    local c = suitDeck:draw()
    if c then
        suitCounts[c.suit] = suitCounts[c.suit] + 1
    end
end

-- Each suit should have 9 cards (ACE + SIX through KING = 9 cards)
assert_equal(suitCounts[Suit.SPADES], 9, "Should have 9 Spades")
assert_equal(suitCounts[Suit.DIAMONDS], 9, "Should have 9 Diamonds")
assert_equal(suitCounts[Suit.CLUBS], 9, "Should have 9 Clubs")
assert_equal(suitCounts[Suit.HEARTS], 9, "Should have 9 Hearts")

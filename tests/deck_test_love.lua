-- Unit tests for deck.lua (Love2D version)

local deck_module = require("deck")
local card_module = require("card")
local createDeck = deck_module.createDeck
local Suit = card_module.Suit
local Rank = card_module.Rank

print("\n=== Deck Module Tests ===")

-- Test createDeck with different lowest ranks
print("\n--- Deck Creation Tests ---")

local deck52 = createDeck(Rank.TWO)
assert(deck52 ~= nil, "createDeck should create a deck object")
assert(deck52:remaining() == 52, "52-card deck should have 52 cards (lowestRank=TWO)")

local deck36 = createDeck(Rank.SIX)
assert(deck36:remaining() == 36, "36-card deck should have 36 cards (lowestRank=SIX)")

local deck32 = createDeck(Rank.SEVEN)
assert(deck32:remaining() == 32, "32-card deck should have 32 cards (lowestRank=SEVEN)")

local deck24 = createDeck(Rank.NINE)
assert(deck24:remaining() == 24, "24-card deck should have 24 cards (lowestRank=NINE)")

-- Test default lowestRank (should be TWO)
local deckDefault = createDeck()
assert(deckDefault:remaining() == 52, "Default deck should have 52 cards")

-- Test draw method
print("\n--- Draw Tests ---")

local testDeck = createDeck(Rank.SIX)
local initialCount = testDeck:remaining()
local drawnCard = testDeck:draw()

assert(drawnCard ~= nil, "draw() should return a card")
assert(testDeck:remaining() == initialCount - 1, "Deck should have one less card after draw")
assert(drawnCard.suit ~= nil, "Drawn card should have a suit")
assert(drawnCard.rank ~= nil, "Drawn card should have a rank")

-- Test drawing all cards
print("\n--- Draw All Cards Tests ---")

local smallDeck = createDeck(Rank.NINE)  -- 24 cards
local cardCount = 0
while smallDeck:remaining() > 0 do
    local c = smallDeck:draw()
    if c then
        cardCount = cardCount + 1
    end
end

assert(cardCount == 24, "Should be able to draw all 24 cards")
assert(smallDeck:remaining() == 0, "Deck should be empty after drawing all cards")

-- Test draw from empty deck
local emptyCard = smallDeck:draw()
assert(emptyCard == nil, "draw() should return nil when deck is empty")

-- Test remaining method
print("\n--- Remaining Tests ---")

local countDeck = createDeck(Rank.SIX)
assert(countDeck:remaining() == 36, "remaining() should return correct count")

countDeck:draw()
countDeck:draw()
countDeck:draw()
assert(countDeck:remaining() == 33, "remaining() should update after draws")

-- Test shuffle method
print("\n--- Shuffle Tests ---")

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
assert(differentPositions > 0, "Shuffled decks should have different card orders")

-- Test reset method
print("\n--- Reset Tests ---")

local resetDeck = createDeck(Rank.SIX)
resetDeck:draw()
resetDeck:draw()
resetDeck:draw()
assert(resetDeck:remaining() == 33, "Deck should have 33 cards after 3 draws")

resetDeck:reset()
assert(resetDeck:remaining() == 36, "Deck should have 36 cards after reset")

-- Test that deck contains correct ranks
print("\n--- Deck Composition Tests ---")

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

assert(rankCounts[Rank.ACE] == 4, "Should have 4 Aces")
assert(rankCounts[Rank.SIX] == 4, "Should have 4 Sixes")
assert(rankCounts[Rank.KING] == 4, "Should have 4 Kings")
assert(rankCounts[Rank.TWO] == 0, "Should have 0 Twos (below lowestRank)")
assert(rankCounts[Rank.FIVE] == 0, "Should have 0 Fives (below lowestRank)")

-- Test deck with lowestRank=TWO includes all ranks
print("\n--- Full Deck Composition Tests ---")

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
    assert(fullRankCounts[rank] == 4, "Rank " .. rank .. " should have 4 cards in full deck")
end

-- Test that all four suits are represented
print("\n--- Suit Distribution Tests ---")

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
assert(suitCounts[Suit.SPADES] == 9, "Should have 9 Spades")
assert(suitCounts[Suit.DIAMONDS] == 9, "Should have 9 Diamonds")
assert(suitCounts[Suit.CLUBS] == 9, "Should have 9 Clubs")
assert(suitCounts[Suit.HEARTS] == 9, "Should have 9 Hearts")

return true

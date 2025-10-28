-- Unit tests for card.lua (Love2D version)

local card = require("card")
local Suit = card.Suit
local Rank = card.Rank
local createCard = card.createCard
local findCardInHand = card.findCardInHand

print("\n=== Card Module Tests ===")

-- Test Suit values
print("\n--- Suit Tests ---")
assert(Suit.SPADES == 0, "Suit.SPADES should be 0")
assert(Suit.DIAMONDS == 1, "Suit.DIAMONDS should be 1")
assert(Suit.CLUBS == 2, "Suit.CLUBS should be 2")
assert(Suit.HEARTS == 3, "Suit.HEARTS should be 3")

-- Test Rank values
print("\n--- Rank Tests ---")
assert(Rank.ACE == 1, "Rank.ACE should be 1")
assert(Rank.TWO == 2, "Rank.TWO should be 2")
assert(Rank.THREE == 3, "Rank.THREE should be 3")
assert(Rank.FOUR == 4, "Rank.FOUR should be 4")
assert(Rank.FIVE == 5, "Rank.FIVE should be 5")
assert(Rank.SIX == 6, "Rank.SIX should be 6")
assert(Rank.SEVEN == 7, "Rank.SEVEN should be 7")
assert(Rank.EIGHT == 8, "Rank.EIGHT should be 8")
assert(Rank.NINE == 9, "Rank.NINE should be 9")
assert(Rank.TEN == 10, "Rank.TEN should be 10")
assert(Rank.JACK == 11, "Rank.JACK should be 11")
assert(Rank.QUEEN == 12, "Rank.QUEEN should be 12")
assert(Rank.KING == 13, "Rank.KING should be 13")

-- Test createCard
print("\n--- createCard Tests ---")
local aceOfSpades = createCard(Suit.SPADES, Rank.ACE)
assert(aceOfSpades ~= nil, "createCard should create a card object")
assert(aceOfSpades.suit == Suit.SPADES, "Card suit should be SPADES")
assert(aceOfSpades.rank == Rank.ACE, "Card rank should be ACE")

-- Test toString
print("\n--- toString Tests ---")
assert(aceOfSpades:toString() == "1s", "Ace of Spades should be '1s'")

local twoOfHearts = createCard(Suit.HEARTS, Rank.TWO)
assert(twoOfHearts:toString() == "2h", "Two of Hearts should be '2h'")

local kingOfDiamonds = createCard(Suit.DIAMONDS, Rank.KING)
assert(kingOfDiamonds:toString() == "13d", "King of Diamonds should be '13d'")

local queenOfClubs = createCard(Suit.CLUBS, Rank.QUEEN)
assert(queenOfClubs:toString() == "12c", "Queen of Clubs should be '12c'")

-- Test equals
print("\n--- equals Tests ---")
local aceOfSpades2 = createCard(Suit.SPADES, Rank.ACE)
assert(aceOfSpades:equals(aceOfSpades2) == true, "Two Aces of Spades should be equal")
assert(aceOfSpades:equals(twoOfHearts) == false, "Ace of Spades and Two of Hearts should not be equal")
assert(aceOfSpades:equals(nil) == false, "Card should not equal nil")

-- Test beats - Same suit
print("\n--- beats Tests (Same Suit) ---")
local sevenOfHearts = createCard(Suit.HEARTS, Rank.SEVEN)
local fiveOfHearts = createCard(Suit.HEARTS, Rank.FIVE)
assert(sevenOfHearts:beats(fiveOfHearts, Suit.SPADES, false),
    "7 of Hearts should beat 5 of Hearts (same suit, higher rank)")
assert(not fiveOfHearts:beats(sevenOfHearts, Suit.SPADES, false),
    "5 of Hearts should not beat 7 of Hearts (same suit, lower rank)")

-- Test beats - Trump vs non-trump
print("\n--- beats Tests (Trump) ---")
local threeOfSpades = createCard(Suit.SPADES, Rank.THREE)  -- Trump
local kingOfHearts = createCard(Suit.HEARTS, Rank.KING)   -- Non-trump
assert(threeOfSpades:beats(kingOfHearts, Suit.SPADES, false),
    "3 of Spades (trump) should beat King of Hearts (non-trump)")
assert(not kingOfHearts:beats(threeOfSpades, Suit.SPADES, false),
    "King of Hearts (non-trump) should not beat 3 of Spades (trump)")

-- Test beats - Deuce beats Ace special rule
print("\n--- beats Tests (Deuce beats Ace) ---")
local aceOfHearts = createCard(Suit.HEARTS, Rank.ACE)
assert(twoOfHearts:beats(aceOfHearts, Suit.SPADES, true),
    "2 of Hearts should beat Ace of Hearts when deuceBeatsAce is true")
assert(not twoOfHearts:beats(aceOfHearts, Suit.SPADES, false),
    "2 of Hearts should not beat Ace of Hearts when deuceBeatsAce is false")

-- Test beats - Rank calculation with (rank + 11) % 13
print("\n--- beats Tests (Rank Calculation) ---")
-- With the formula (rank + 11) % 13:
-- ACE (1 + 11) % 13 = 12
-- TWO (2 + 11) % 13 = 0
-- THREE (3 + 11) % 13 = 1
-- So in same suit: ACE > THREE > TWO (when deuceBeatsAce is false)
local threeOfDiamonds = createCard(Suit.DIAMONDS, Rank.THREE)
local twoOfDiamonds = createCard(Suit.DIAMONDS, Rank.TWO)
local aceOfDiamonds = createCard(Suit.DIAMONDS, Rank.ACE)

assert(aceOfDiamonds:beats(threeOfDiamonds, Suit.SPADES, false),
    "Ace should beat Three (12 > 1)")
assert(threeOfDiamonds:beats(twoOfDiamonds, Suit.SPADES, false),
    "Three should beat Two (1 > 0)")
assert(not twoOfDiamonds:beats(threeOfDiamonds, Suit.SPADES, false),
    "Two should not beat Three (0 < 1)")

-- Test findCardInHand
print("\n--- findCardInHand Tests ---")
local hand = {
    createCard(Suit.SPADES, Rank.ACE),
    createCard(Suit.HEARTS, Rank.KING),
    createCard(Suit.DIAMONDS, Rank.QUEEN),
    createCard(Suit.CLUBS, Rank.JACK)
}

local searchCard = createCard(Suit.HEARTS, Rank.KING)
local index = findCardInHand(hand, searchCard)
assert(index == 2, "Should find King of Hearts at index 2")

local notInHand = createCard(Suit.SPADES, Rank.TWO)
local notFound = findCardInHand(hand, notInHand)
assert(notFound == nil, "Should return nil for card not in hand")

assert(findCardInHand(nil, searchCard) == nil, "Should return nil for nil hand")
assert(findCardInHand(hand, nil) == nil, "Should return nil for nil card")

return true

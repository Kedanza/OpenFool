-- player_test_love.lua
-- Tests for Player System

local card = require("card")
local player = require("player")
local rulesetModule = require("ruleset")

print("\n=== Player Module Tests ===")

-- Test 1: Player creation
print("\n-- Player Creation Tests --")
local ruleset = rulesetModule.createRuleSet({})
local p = player.createPlayer(ruleset, "TestPlayer", 0)
assert_not_nil(p, "createPlayer should create a player object")
assert_equal(p.name, "TestPlayer", "Player name should be 'TestPlayer'")
assert_equal(p.index, 0, "Player index should be 0")
assert_equal(#p.hand, 0, "New player should have empty hand")

-- Test 2: Player creation without name
print("\n-- Player Creation Without Name --")
local p2 = player.createPlayer(ruleset, nil, 1)
assert_equal(p2.name, "", "Player without name should have empty string name")
assert_equal(p2.index, 1, "Player index should be 1")

-- Test 3: Adding cards
print("\n-- Adding Cards Tests --")
local p3 = player.createPlayer(ruleset, "Player3", 0)
local c1 = card.createCard(card.Suit.SPADES, card.Rank.ACE)
local c2 = card.createCard(card.Suit.HEARTS, card.Rank.KING)
p3:addCard(c1)
assert_equal(#p3.hand, 1, "Hand should have 1 card after adding")
p3:addCard(c2)
assert_equal(#p3.hand, 2, "Hand should have 2 cards after adding")
assert_true(p3.hand[1]:equals(c1), "First card should be Ace of Spades")
assert_true(p3.hand[2]:equals(c2), "Second card should be King of Hearts")

-- Test 4: Removing cards
print("\n-- Removing Cards Tests --")
local p4 = player.createPlayer(ruleset, "Player4", 0)
local c3 = card.createCard(card.Suit.DIAMONDS, card.Rank.QUEEN)
local c4 = card.createCard(card.Suit.CLUBS, card.Rank.TEN)
p4:addCard(c3)
p4:addCard(c4)
local removed = p4:removeCard(c3)
assert_true(removed, "removeCard should return true when card is removed")
assert_equal(#p4.hand, 1, "Hand should have 1 card after removal")
assert_true(p4.hand[1]:equals(c4), "Remaining card should be 10 of Clubs")

-- Test 5: Removing non-existent card
print("\n-- Removing Non-Existent Card --")
local c5 = card.createCard(card.Suit.SPADES, card.Rank.TWO)
local removed2 = p4:removeCard(c5)
assert_false(removed2, "removeCard should return false when card not found")
assert_equal(#p4.hand, 1, "Hand size should remain unchanged")

-- Test 6: Finding cards
print("\n-- Finding Cards Tests --")
local p5 = player.createPlayer(ruleset, "Player5", 0)
local c6 = card.createCard(card.Suit.HEARTS, card.Rank.SEVEN)
local c7 = card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT)
p5:addCard(c6)
p5:addCard(c7)
local idx = p5:findCard(c7)
assert_equal(idx, 2, "Should find card at index 2")
local idx2 = p5:findCard(c5)
assert_equal(idx2, nil, "Should return nil for card not in hand")

-- Test 7: Clear hand
print("\n-- Clear Hand Tests --")
local p6 = player.createPlayer(ruleset, "Player6", 0)
p6:addCard(c1)
p6:addCard(c2)
p6:addCard(c3)
assert_equal(#p6.hand, 3, "Hand should have 3 cards")
p6:clearHand()
assert_equal(#p6.hand, 0, "Hand should be empty after clearHand")

-- Test 8: Hand size
print("\n-- Hand Size Tests --")
local p7 = player.createPlayer(ruleset, "Player7", 0)
assert_equal(p7:handSize(), 0, "New hand should have size 0")
p7:addCard(c1)
assert_equal(p7:handSize(), 1, "Hand size should be 1")
p7:addCard(c2)
p7:addCard(c3)
assert_equal(p7:handSize(), 3, "Hand size should be 3")

-- Test 9: Sorting by rank ascending
print("\n-- Sort by Rank Ascending --")
local p8 = player.createPlayer(ruleset, "Player8", 0)
p8:addCard(card.createCard(card.Suit.HEARTS, card.Rank.KING))
p8:addCard(card.createCard(card.Suit.SPADES, card.Rank.SIX))
p8:addCard(card.createCard(card.Suit.DIAMONDS, card.Rank.ACE))
p8:sortCards(player.SortingMode.RANK_ASCENDING, card.Suit.CLUBS)
-- ACE (r1=12) < SIX (r1=5) < KING (r1=10) after modulo
assert_equal(p8.hand[1].rank, card.Rank.SIX, "First card should be SIX")
assert_equal(p8.hand[2].rank, card.Rank.KING, "Second card should be KING")
assert_equal(p8.hand[3].rank, card.Rank.ACE, "Third card should be ACE")

-- Test 10: Sorting by rank descending
print("\n-- Sort by Rank Descending --")
local p9 = player.createPlayer(ruleset, "Player9", 0)
p9:addCard(card.createCard(card.Suit.HEARTS, card.Rank.KING))
p9:addCard(card.createCard(card.Suit.SPADES, card.Rank.SIX))
p9:addCard(card.createCard(card.Suit.DIAMONDS, card.Rank.ACE))
p9:sortCards(player.SortingMode.RANK_DESCENDING, card.Suit.CLUBS)
assert_equal(p9.hand[1].rank, card.Rank.ACE, "First card should be ACE")
assert_equal(p9.hand[2].rank, card.Rank.KING, "Second card should be KING")
assert_equal(p9.hand[3].rank, card.Rank.SIX, "Third card should be SIX")

-- Test 11: Sorting by suit ascending
print("\n-- Sort by Suit Ascending --")
local p10 = player.createPlayer(ruleset, "Player10", 0)
p10:addCard(card.createCard(card.Suit.HEARTS, card.Rank.SEVEN))  -- v1 = (3 + (3-1)) % 4 = 1
p10:addCard(card.createCard(card.Suit.SPADES, card.Rank.SEVEN))  -- v1 = (0 + (3-1)) % 4 = 2
p10:addCard(card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN)) -- v1 = (1 + (3-1)) % 4 = 3
p10:addCard(card.createCard(card.Suit.CLUBS, card.Rank.SEVEN))   -- v1 = (2 + (3-1)) % 4 = 0 (trump is last)
p10:sortCards(player.SortingMode.SUIT_ASCENDING, card.Suit.DIAMONDS)
assert_equal(p10.hand[1].suit, card.Suit.CLUBS, "First should be CLUBS")
assert_equal(p10.hand[2].suit, card.Suit.HEARTS, "Second should be HEARTS")
assert_equal(p10.hand[3].suit, card.Suit.SPADES, "Third should be SPADES")
assert_equal(p10.hand[4].suit, card.Suit.DIAMONDS, "Fourth should be DIAMONDS (trump)")

-- Test 12: Sorting by suit descending
print("\n-- Sort by Suit Descending --")
local p11 = player.createPlayer(ruleset, "Player11", 0)
p11:addCard(card.createCard(card.Suit.HEARTS, card.Rank.SEVEN))
p11:addCard(card.createCard(card.Suit.SPADES, card.Rank.SEVEN))
p11:addCard(card.createCard(card.Suit.DIAMONDS, card.Rank.SEVEN))
p11:addCard(card.createCard(card.Suit.CLUBS, card.Rank.SEVEN))
p11:sortCards(player.SortingMode.SUIT_DESCENDING, card.Suit.DIAMONDS)
assert_equal(p11.hand[1].suit, card.Suit.DIAMONDS, "First should be DIAMONDS (trump)")
assert_equal(p11.hand[2].suit, card.Suit.SPADES, "Second should be SPADES")
assert_equal(p11.hand[3].suit, card.Suit.HEARTS, "Third should be HEARTS")
assert_equal(p11.hand[4].suit, card.Suit.CLUBS, "Fourth should be CLUBS")

-- Test 13: Unsorted mode
print("\n-- Unsorted Mode --")
local p12 = player.createPlayer(ruleset, "Player12", 0)
p12:addCard(card.createCard(card.Suit.HEARTS, card.Rank.KING))
p12:addCard(card.createCard(card.Suit.SPADES, card.Rank.SIX))
local originalFirst = p12.hand[1]
local originalSecond = p12.hand[2]
p12:sortCards(player.SortingMode.UNSORTED, card.Suit.CLUBS)
assert_true(p12.hand[1]:equals(originalFirst), "Order should not change with UNSORTED")
assert_true(p12.hand[2]:equals(originalSecond), "Order should not change with UNSORTED")

-- Test 14: cardCanBeThrown - first attack
print("\n-- cardCanBeThrown First Attack --")
local p13 = player.createPlayer(ruleset, "Player13", 0)
local testCard = card.createCard(card.Suit.HEARTS, card.Rank.NINE)
p13:addCard(testCard)
local attackCards = {nil, nil, nil, nil, nil, nil}
local defenseCards = {nil, nil, nil, nil, nil, nil}
assert_true(p13:cardCanBeThrown(testCard, attackCards, defenseCards), "Any card can be thrown on first attack")

-- Test 15: cardCanBeThrown - matching rank
print("\n-- cardCanBeThrown Matching Rank --")
local p14 = player.createPlayer(ruleset, "Player14", 0)
local testCard2 = card.createCard(card.Suit.DIAMONDS, card.Rank.NINE)
p14:addCard(testCard2)
local attackCards2 = {card.createCard(card.Suit.HEARTS, card.Rank.NINE), nil, nil, nil, nil, nil}
local defenseCards2 = {nil, nil, nil, nil, nil, nil}
assert_true(p14:cardCanBeThrown(testCard2, attackCards2, defenseCards2), "Card with matching rank can be thrown")

-- Test 16: cardCanBeThrown - non-matching rank
print("\n-- cardCanBeThrown Non-Matching Rank --")
local p15 = player.createPlayer(ruleset, "Player15", 0)
local testCard3 = card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT)
p15:addCard(testCard3)
local attackCards3 = {card.createCard(card.Suit.HEARTS, card.Rank.NINE), nil, nil, nil, nil, nil}
local defenseCards3 = {nil, nil, nil, nil, nil, nil}
assert_false(p15:cardCanBeThrown(testCard3, attackCards3, defenseCards3), "Card with non-matching rank cannot be thrown")

-- Test 17: cardCanBeBeaten
print("\n-- cardCanBeBeaten Tests --")
local p16 = player.createPlayer(ruleset, "Player16", 0)
local attackCard = card.createCard(card.Suit.HEARTS, card.Rank.SEVEN)
local defenseCard = card.createCard(card.Suit.HEARTS, card.Rank.KING)
p16:addCard(defenseCard)
local attackCards4 = {}
local defenseCards4 = {}
for i = 1, 6 do
    attackCards4[i] = nil
    defenseCards4[i] = nil
end
attackCards4[1] = attackCard
assert_true(p16:cardCanBeBeaten(defenseCard, attackCards4, defenseCards4, card.Suit.SPADES), "King should beat Seven")

-- Test 18: cardCanBeBeaten - cannot beat
print("\n-- cardCanBeBeaten Cannot Beat --")
local p17 = player.createPlayer(ruleset, "Player17", 0)
local weakCard = card.createCard(card.Suit.HEARTS, card.Rank.SIX)
p17:addCard(weakCard)
assert_false(p17:cardCanBeBeaten(weakCard, attackCards4, defenseCards4, card.Suit.SPADES), "Six cannot beat Seven")

-- Test 19: cardCanBePassed - allowed
print("\n-- cardCanBePassed Allowed --")
local rulesetWithPass = rulesetModule.createRuleSet({allowPass = true})
local p18 = player.createPlayer(rulesetWithPass, "Player18", 0)
local passCard = card.createCard(card.Suit.DIAMONDS, card.Rank.NINE)
p18:addCard(passCard)
local attackCards5 = {card.createCard(card.Suit.HEARTS, card.Rank.NINE), nil, nil, nil, nil, nil}
local defenseCards5 = {nil, nil, nil, nil, nil, nil}
assert_true(p18:cardCanBePassed(passCard, attackCards5, defenseCards5, 6), "Card should be passable")

-- Test 20: cardCanBePassed - not allowed by rules
print("\n-- cardCanBePassed Not Allowed by Rules --")
local p19 = player.createPlayer(ruleset, "Player19", 0) -- allowPass = false by default
p19:addCard(passCard)
assert_false(p19:cardCanBePassed(passCard, attackCards5, defenseCards5, 6), "Passing should be disabled by rules")

-- Test 21: cardCanBePassed - already defending
print("\n-- cardCanBePassed Already Defending --")
local p20 = player.createPlayer(rulesetWithPass, "Player20", 0)
p20:addCard(passCard)
local defenseCards6 = {card.createCard(card.Suit.HEARTS, card.Rank.KING), nil, nil, nil, nil, nil}
assert_false(p20:cardCanBePassed(passCard, attackCards5, defenseCards6, 6), "Cannot pass after starting to defend")

-- Test 22: cardCanBePassed - wrong rank
print("\n-- cardCanBePassed Wrong Rank --")
local p21 = player.createPlayer(rulesetWithPass, "Player21", 0)
local wrongRankCard = card.createCard(card.Suit.DIAMONDS, card.Rank.EIGHT)
p21:addCard(wrongRankCard)
assert_false(p21:cardCanBePassed(wrongRankCard, attackCards5, defenseCards5, 6), "Cannot pass card with wrong rank")

-- Test 23: requireRedeal - has trump
print("\n-- requireRedeal With Trump --")
local p22 = player.createPlayer(ruleset, "Player22", 0)
p22:addCard(card.createCard(card.Suit.SPADES, card.Rank.ACE))  -- trump
p22:addCard(card.createCard(card.Suit.HEARTS, card.Rank.SEVEN))
p22:addCard(card.createCard(card.Suit.HEARTS, card.Rank.EIGHT))
p22:addCard(card.createCard(card.Suit.HEARTS, card.Rank.NINE))
p22:addCard(card.createCard(card.Suit.HEARTS, card.Rank.TEN))
assert_false(p22:requireRedeal(card.Suit.SPADES), "Should not require redeal with trump")

-- Test 24: requireRedeal - no trump, balanced
print("\n-- requireRedeal No Trump Balanced --")
local p23 = player.createPlayer(ruleset, "Player23", 0)
p23:addCard(card.createCard(card.Suit.HEARTS, card.Rank.SEVEN))
p23:addCard(card.createCard(card.Suit.HEARTS, card.Rank.EIGHT))
p23:addCard(card.createCard(card.Suit.DIAMONDS, card.Rank.NINE))
p23:addCard(card.createCard(card.Suit.DIAMONDS, card.Rank.TEN))
p23:addCard(card.createCard(card.Suit.CLUBS, card.Rank.JACK))
p23:addCard(card.createCard(card.Suit.CLUBS, card.Rank.QUEEN))
assert_false(p23:requireRedeal(card.Suit.SPADES), "Should not require redeal when balanced")

-- Test 25: requireRedeal - no trump, unbalanced
print("\n-- requireRedeal No Trump Unbalanced --")
local p24 = player.createPlayer(ruleset, "Player24", 0)
p24:addCard(card.createCard(card.Suit.HEARTS, card.Rank.SEVEN))
p24:addCard(card.createCard(card.Suit.HEARTS, card.Rank.EIGHT))
p24:addCard(card.createCard(card.Suit.HEARTS, card.Rank.NINE))
p24:addCard(card.createCard(card.Suit.HEARTS, card.Rank.TEN))
p24:addCard(card.createCard(card.Suit.HEARTS, card.Rank.JACK))
p24:addCard(card.createCard(card.Suit.DIAMONDS, card.Rank.QUEEN))
assert_true(p24:requireRedeal(card.Suit.SPADES), "Should require redeal when unbalanced")

-- Test 26: SortingMode enum values
print("\n-- SortingMode Enum Values --")
assert_equal(player.SortingMode.UNSORTED, 0, "UNSORTED should be 0")
assert_equal(player.SortingMode.SUIT_ASCENDING, 1, "SUIT_ASCENDING should be 1")
assert_equal(player.SortingMode.SUIT_DESCENDING, 2, "SUIT_DESCENDING should be 2")
assert_equal(player.SortingMode.RANK_ASCENDING, 3, "RANK_ASCENDING should be 3")
assert_equal(player.SortingMode.RANK_DESCENDING, 4, "RANK_DESCENDING should be 4")

print("\n=== Player Tests Complete ===")

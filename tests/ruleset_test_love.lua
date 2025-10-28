-- ruleset_test_love.lua
-- Tests for RuleSet Configuration System

local rulesetModule = require("ruleset")
local card = require("card")

print("\n=== RuleSet Module Tests ===")

-- Helper function for assertions
local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\n  Expected: %s\n  Got: %s", message, tostring(expected), tostring(actual)))
    end
    print("✓ " .. message)
end

local function assert_true(condition, message)
    if not condition then
        error(message)
    end
    print("✓ " .. message)
end

local function assert_false(condition, message)
    if condition then
        error(message)
    end
    print("✓ " .. message)
end

-- Test 1: Default RuleSet creation
print("\n-- Default RuleSet Tests --")

local ruleset = rulesetModule.createRuleSet()
assert_equal(ruleset.deuceBeatsAce, false, "Default deuceBeatsAce should be false")
assert_equal(ruleset.loweredFirstDiscardLimit, false, "Default loweredFirstDiscardLimit should be false")
assert_equal(ruleset.allowPass, false, "Default allowPass should be false")
assert_equal(ruleset.playerCount, 4, "Default playerCount should be 4")
assert_equal(ruleset.teamPlay, false, "Default teamPlay should be false")
assert_equal(ruleset.cardCount, 52, "Default cardCount should be 52")

-- Test 2: Custom RuleSet creation
print("\n-- Custom RuleSet Tests --")

ruleset = rulesetModule.createRuleSet({
    deuceBeatsAce = true,
    loweredFirstDiscardLimit = true,
    allowPass = true,
    playerCount = 4,
    teamPlay = true,
    cardCount = 36
})
assert_equal(ruleset.deuceBeatsAce, true, "Custom deuceBeatsAce should be true")
assert_equal(ruleset.loweredFirstDiscardLimit, true, "Custom loweredFirstDiscardLimit should be true")
assert_equal(ruleset.allowPass, true, "Custom allowPass should be true")
assert_equal(ruleset.playerCount, 4, "Custom playerCount should be 4")
assert_equal(ruleset.teamPlay, true, "Custom teamPlay should be true")
assert_equal(ruleset.cardCount, 36, "Custom cardCount should be 36")

-- Test 3: getLowestRank for different card counts
print("\n-- getLowestRank Tests --")

ruleset = rulesetModule.createRuleSet({cardCount = 24})
assert_equal(ruleset:getLowestRank(), card.Rank.NINE, "24-card deck should start at NINE (9)")

ruleset = rulesetModule.createRuleSet({cardCount = 32})
assert_equal(ruleset:getLowestRank(), card.Rank.SEVEN, "32-card deck should start at SEVEN (7)")

ruleset = rulesetModule.createRuleSet({cardCount = 36})
assert_equal(ruleset:getLowestRank(), card.Rank.SIX, "36-card deck should start at SIX (6)")

ruleset = rulesetModule.createRuleSet({cardCount = 52})
assert_equal(ruleset:getLowestRank(), card.Rank.TWO, "52-card deck should start at TWO (2)")

-- Test 4: Team play validation (only valid for even players > 2)
print("\n-- Team Play Validation Tests --")

ruleset = rulesetModule.createRuleSet({playerCount = 2, teamPlay = true})
assert_false(ruleset.teamPlay, "Team play should be disabled for 2 players")

ruleset = rulesetModule.createRuleSet({playerCount = 3, teamPlay = true})
assert_false(ruleset.teamPlay, "Team play should be disabled for 3 players (odd)")

ruleset = rulesetModule.createRuleSet({playerCount = 4, teamPlay = true})
assert_true(ruleset.teamPlay, "Team play should be enabled for 4 players")

ruleset = rulesetModule.createRuleSet({playerCount = 6, teamPlay = true})
assert_true(ruleset.teamPlay, "Team play should be enabled for 6 players")

ruleset = rulesetModule.createRuleSet({playerCount = 5, teamPlay = true})
assert_false(ruleset.teamPlay, "Team play should be disabled for 5 players (odd)")

-- Test 5: Card count validation (must be multiple of 4 and >= 6 * playerCount)
print("\n-- Card Count Validation Tests --")

ruleset = rulesetModule.createRuleSet({playerCount = 4, cardCount = 20})
assert_equal(ruleset.cardCount, 24, "Card count should be rounded up to 24 (min 6*4=24)")

ruleset = rulesetModule.createRuleSet({playerCount = 5, cardCount = 28})
assert_equal(ruleset.cardCount, 32, "Card count should be rounded up to 32 (min 6*5=30, rounded to 32)")

ruleset = rulesetModule.createRuleSet({playerCount = 6, cardCount = 35})
assert_equal(ruleset.cardCount, 36, "Card count should be 36 (min 6*6=36)")

ruleset = rulesetModule.createRuleSet({playerCount = 2, cardCount = 11})
assert_equal(ruleset.cardCount, 12, "Card count should be rounded up to 12 (min 6*2=12)")

ruleset = rulesetModule.createRuleSet({playerCount = 4, cardCount = 50})
assert_equal(ruleset.cardCount, 52, "Card count 50 should be rounded up to 52 (multiple of 4)")

-- Test 6: setPlayerCount updates team play
print("\n-- setPlayerCount Tests --")

ruleset = rulesetModule.createRuleSet({playerCount = 4, teamPlay = true})
assert_true(ruleset.teamPlay, "Team play initially enabled for 4 players")

ruleset:setPlayerCount(3)
assert_false(ruleset.teamPlay, "Team play should be disabled after setting to 3 players")
assert_equal(ruleset.playerCount, 3, "Player count should be 3")

ruleset:setPlayerCount(6)
assert_false(ruleset.teamPlay, "Team play should remain disabled (not re-enabled automatically)")
assert_equal(ruleset.playerCount, 6, "Player count should be 6")

-- Test 7: setPlayerCount adjusts card count
print("\n-- setPlayerCount Card Count Adjustment Tests --")

ruleset = rulesetModule.createRuleSet({playerCount = 2, cardCount = 24})
assert_equal(ruleset.cardCount, 24, "Initial card count should be 24")

ruleset:setPlayerCount(6)
assert_equal(ruleset.cardCount, 36, "Card count should increase to 36 (min 6*6=36)")

-- Test 8: setCardCount
print("\n-- setCardCount Tests --")

ruleset = rulesetModule.createRuleSet({playerCount = 4, cardCount = 36})
assert_equal(ruleset.cardCount, 36, "Initial card count should be 36")

ruleset:setCardCount(52)
assert_equal(ruleset.cardCount, 52, "Card count should be updated to 52")

ruleset:setCardCount(18)
assert_equal(ruleset.cardCount, 24, "Card count 18 should be adjusted to 24 (min 6*4=24)")

-- Test 9: Save and load
print("\n-- Save and Load Tests --")

ruleset = rulesetModule.createRuleSet({
    deuceBeatsAce = true,
    loweredFirstDiscardLimit = true,
    allowPass = true,
    playerCount = 6,
    teamPlay = true,
    cardCount = 36
})

local saved = ruleset:save()
assert_equal(saved.deuceBeatsAce, true, "Saved deuceBeatsAce should be true")
assert_equal(saved.loweredFirstDiscardLimit, true, "Saved loweredFirstDiscardLimit should be true")
assert_equal(saved.allowPass, true, "Saved allowPass should be true")
assert_equal(saved.playerCount, 6, "Saved playerCount should be 6")
assert_equal(saved.teamPlay, true, "Saved teamPlay should be true")
assert_equal(saved.cardCount, 36, "Saved cardCount should be 36")

-- Test 10: Load into new RuleSet
print("\n-- Load into New RuleSet Tests --")

local newRuleset = rulesetModule.createRuleSet()
newRuleset:load(saved)
assert_equal(newRuleset.deuceBeatsAce, true, "Loaded deuceBeatsAce should be true")
assert_equal(newRuleset.loweredFirstDiscardLimit, true, "Loaded loweredFirstDiscardLimit should be true")
assert_equal(newRuleset.allowPass, true, "Loaded allowPass should be true")
assert_equal(newRuleset.playerCount, 6, "Loaded playerCount should be 6")
assert_equal(newRuleset.teamPlay, true, "Loaded teamPlay should be true")
assert_equal(newRuleset.cardCount, 36, "Loaded cardCount should be 36")

-- Test 11: Load revalidates rules
print("\n-- Load Revalidation Tests --")

newRuleset = rulesetModule.createRuleSet()
newRuleset:load({
    playerCount = 3,
    teamPlay = true,  -- Invalid for 3 players
    cardCount = 10    -- Too small for 3 players
})
assert_false(newRuleset.teamPlay, "Team play should be disabled after loading invalid config")
assert_equal(newRuleset.cardCount, 20, "Card count should be adjusted to 20 (min 6*3=18, rounded to 20)")

-- Test 12: toString
print("\n-- toString Tests --")

ruleset = rulesetModule.createRuleSet({playerCount = 4, cardCount = 36, deuceBeatsAce = true})
local str = ruleset:toString()
assert_true(string.find(str, "players=4") ~= nil, "toString should contain players=4")
assert_true(string.find(str, "cards=36") ~= nil, "toString should contain cards=36")
assert_true(string.find(str, "lowestRank=6") ~= nil, "toString should contain lowestRank=6")
assert_true(string.find(str, "deuceBeatsAce=true") ~= nil, "toString should contain deuceBeatsAce=true")

-- Test 13: Edge case - Very large player count
print("\n-- Edge Case Tests --")

ruleset = rulesetModule.createRuleSet({playerCount = 8, cardCount = 36})
assert_equal(ruleset.cardCount, 48, "Card count should be adjusted to 48 for 8 players (min 6*8=48)")

-- Test 14: Lowest rank formula verification
print("\n-- Lowest Rank Formula Verification --")

-- Test the formula: (14 - (cardCount / 4)) % 13 + 1
-- For 52 cards: (14 - 13) % 13 + 1 = 1 % 13 + 1 = 1 + 1 = 2 (TWO)
-- For 36 cards: (14 - 9) % 13 + 1 = 5 % 13 + 1 = 5 + 1 = 6 (SIX)
-- For 32 cards: (14 - 8) % 13 + 1 = 6 % 13 + 1 = 6 + 1 = 7 (SEVEN)
-- For 24 cards: (14 - 6) % 13 + 1 = 8 % 13 + 1 = 8 + 1 = 9 (NINE)

local testCases = {
    {cardCount = 52, expectedRank = 2, name = "TWO"},
    {cardCount = 36, expectedRank = 6, name = "SIX"},
    {cardCount = 32, expectedRank = 7, name = "SEVEN"},
    {cardCount = 24, expectedRank = 9, name = "NINE"}
}

for _, testCase in ipairs(testCases) do
    ruleset = rulesetModule.createRuleSet({cardCount = testCase.cardCount})
    assert_equal(ruleset:getLowestRank(), testCase.expectedRank,
        string.format("%d cards should have lowest rank %s (%d)",
            testCase.cardCount, testCase.name, testCase.expectedRank))
end

print("\n=== RuleSet Tests Complete ===")

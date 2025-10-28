-- ai_evaluation_performance_test.lua
-- Performance tests for AI evaluation system
-- Tests that evaluateHand can handle 1000+ calls efficiently

-- Setup path to load modules from src directory
package.path = package.path .. ";../src/?.lua"

local card = require("card")
local aiEval = require("ai_evaluation")

print("\n=== AI Evaluation Performance Tests ===\n")

-- Helper to create a random hand
local function createRandomHand(size, lowestRank)
    local hand = {}
    local suits = {card.Suit.SPADES, card.Suit.DIAMONDS, card.Suit.CLUBS, card.Suit.HEARTS}
    local ranks = {}
    
    -- Build available ranks based on lowestRank
    for r = lowestRank, card.Rank.KING do
        table.insert(ranks, r)
    end
    table.insert(ranks, card.Rank.ACE)  -- ACE is always in play
    
    for i = 1, size do
        local randomSuit = suits[math.random(1, #suits)]
        local randomRank = ranks[math.random(1, #ranks)]
        table.insert(hand, card.createCard(randomSuit, randomRank))
    end
    
    return hand
end

-- Performance test 1: 1000 evaluations of typical hands
print("-- Performance Test 1: 1000 evaluations of 6-card hands --")
local startTime = os.clock()
local iterations = 1000

for i = 1, iterations do
    local hand = createRandomHand(6, card.Rank.SIX)
    local trumpSuit = card.Suit.SPADES
    local cardsRemaining = 20
    local playerHands = {6, 6, 6}
    local lowestRank = card.Rank.SIX
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
end

local elapsed = os.clock() - startTime
local avgTime = (elapsed / iterations) * 1000  -- Convert to milliseconds
print(string.format("✓ Completed %d evaluations in %.3f seconds", iterations, elapsed))
print(string.format("  Average time per evaluation: %.4f ms", avgTime))
print(string.format("  Throughput: %.0f evaluations/second", iterations / elapsed))

if avgTime < 1.0 then
    print("  ✓ Performance: EXCELLENT (< 1ms per evaluation)")
elseif avgTime < 5.0 then
    print("  ✓ Performance: GOOD (< 5ms per evaluation)")
else
    print("  ⚠ Performance: NEEDS OPTIMIZATION (> 5ms per evaluation)")
end

-- Performance test 2: Various hand sizes
print("\n-- Performance Test 2: Different hand sizes (100 iterations each) --")
local handSizes = {1, 2, 3, 6, 12, 18}

for _, size in ipairs(handSizes) do
    startTime = os.clock()
    iterations = 100
    
    for i = 1, iterations do
        local hand = createRandomHand(size, card.Rank.SIX)
        local trumpSuit = card.Suit.SPADES
        local cardsRemaining = 20
        local playerHands = {size, size, size}
        local lowestRank = card.Rank.SIX
        
        local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    end
    
    elapsed = os.clock() - startTime
    avgTime = (elapsed / iterations) * 1000
    
    print(string.format("  Hand size %2d: %.4f ms/eval (%.0f evals/sec)", 
        size, avgTime, iterations / elapsed))
end

-- Performance test 3: Stress test with 10000 evaluations
print("\n-- Performance Test 3: Stress test (10000 evaluations) --")
startTime = os.clock()
iterations = 10000
local totalScore = 0

for i = 1, iterations do
    -- Vary parameters to avoid cache effects
    local handSize = math.random(1, 12)
    local hand = createRandomHand(handSize, card.Rank.SIX)
    local trumpSuit = math.random(0, 3)
    local cardsRemaining = math.random(0, 30)
    local playerHands = {math.random(0, 12), math.random(0, 12), math.random(0, 12)}
    local lowestRank = card.Rank.SIX
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    totalScore = totalScore + score
end

elapsed = os.clock() - startTime
avgTime = (elapsed / iterations) * 1000

print(string.format("✓ Completed %d evaluations in %.3f seconds", iterations, elapsed))
print(string.format("  Average time per evaluation: %.4f ms", avgTime))
print(string.format("  Throughput: %.0f evaluations/second", iterations / elapsed))
print(string.format("  Average score: %.1f", totalScore / iterations))

-- Performance test 4: Memory efficiency
print("\n-- Performance Test 4: Memory usage --")
collectgarbage("collect")
local memBefore = collectgarbage("count")

iterations = 1000
for i = 1, iterations do
    local hand = createRandomHand(6, card.Rank.SIX)
    local trumpSuit = card.Suit.SPADES
    local cardsRemaining = 20
    local playerHands = {6, 6, 6}
    local lowestRank = card.Rank.SIX
    
    local score = aiEval.evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
end

collectgarbage("collect")
local memAfter = collectgarbage("count")
local memUsed = memAfter - memBefore

print(string.format("  Memory before: %.2f KB", memBefore))
print(string.format("  Memory after:  %.2f KB", memAfter))
print(string.format("  Memory delta:  %.2f KB", memUsed))

if math.abs(memUsed) < 10 then
    print("  ✓ Memory usage: EXCELLENT (no significant leaks)")
elseif math.abs(memUsed) < 50 then
    print("  ✓ Memory usage: GOOD (minimal overhead)")
else
    print("  ⚠ Memory usage: CHECK FOR LEAKS (significant increase)")
end

print("\n=== Performance Tests Complete ===\n")

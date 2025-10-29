-- Love2D Test Runner
-- Run with: love tests/

-- Global test counters
passedTests = 0
failedTests = 0
totalTests = 0

-- Global assert function that counts tests
failedMessages = {}
function assert(condition, message)
    totalTests = totalTests + 1
    if condition then
        passedTests = passedTests + 1
        print("PASS: " .. message)
    else
        failedTests = failedTests + 1
        print("FAIL: " .. message)
        table.insert(failedMessages, message)
    end
end

function love.load()
    print("\n=== Love2D Test Runner ===\n")
    
    -- Add parent directory to package path to find src/ and root files
    package.path = package.path .. ";../src/?.lua;./src/?.lua;../?.lua;./?.lua"
    
    -- Run card tests
    require("card_test_love")
    
    -- Run deck tests
    require("deck_test_love")
    
    -- Run AI evaluation tests
    require("ai_evaluation_test_love")
    
    -- Run performance tests
    require("ai_evaluation_performance_test_love")
    
    -- Run AI attack tests
    require("ai_attack_test_love")
    
    -- Run AI defense tests
    require("ai_defense_test_love")
    
    -- Run AI throw additional tests
    require("ai_throw_additional_test_love")
    
    -- Run RuleSet tests
    require("ruleset_test_love")
    
    -- Run Player tests
    require("player_test_love")
    
    -- Run GameState tests
    require("gamestate_test_love")
    
    -- Run Turn Management tests
    require("turn_test_love")
    
    -- Run Game Setup tests
    require("game_setup_test_love")
    
    -- Run Love2D Project Structure tests
    require("love2d_structure_test_love")
    
    -- Run Asset Loading tests
    require("assets_test_love")
    
    -- Run Rendering tests
    require("rendering_test_love")
    
    -- Print results
    print("\n" .. string.rep("=", 50))
    print(string.format("Passed: %d, Failed: %d, Total: %d", 
        passedTests, failedTests, totalTests))

    if failedTests > 0 then
        print("\nFAILED TESTS SUMMARY:")
        for i, msg in ipairs(failedMessages) do
            print(string.format("  %d. %s", i, msg))
        end
    end

    if failedTests == 0 then
        print("SUCCESS: All tests passed!")
    else
        print("FAILED: Some tests failed")
    end
    print(string.rep("=", 50))
end

function love.draw()
    -- Draw test results on screen
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Running tests... Check console output", 10, 10)
end

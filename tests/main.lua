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
    _G.IS_TEST_ENVIRONMENT = true
    print("\n=== Love2D Test Runner ===\n")

    -- Debug filesystem paths
    local source_dir = love.filesystem.getSource()
    print("Debug: Source directory = " .. source_dir)
    print("Debug: Working directory = " .. love.filesystem.getWorkingDirectory())

    -- Mount the source base directory to access parent folders
    -- In Love2D 11.4+, we can mount getSourceBaseDirectory() which gives us
    -- access to the project root when running "love tests/"
    local source_base = love.filesystem.getSourceBaseDirectory()
    print("Debug: Source base directory = " .. tostring(source_base))

    if source_base then
        print("Debug: Attempting to mount source base: " .. source_base)
        local success = love.filesystem.mount(source_base, "")
        print("Debug: Mount success: " .. tostring(success))

        -- Verify we can now see android/
        local android_info = love.filesystem.getInfo("android")
        print("Debug: android/ accessible after mount? " .. tostring(android_info ~= nil))

        if android_info then
            print("Debug: ✓ SUCCESS! android/ is now accessible via source base mount")
        else
            print("Debug: ✗ android/ still not accessible")
        end
    else
        print("Debug: getSourceBaseDirectory returned nil")
    end

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

    -- Run Game Loop tests
    require("game_loop_test_love")

    -- Run Integration tests
    require("integration_test_love")

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

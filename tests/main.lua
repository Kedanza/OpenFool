-- Love2D Test Runner
-- Run with: love tests/

-- Test results
local tests_passed = 0
local tests_failed = 0
local test_output = {}

-- Simple assertion helpers
local function assert_equal(actual, expected, test_name)
    if actual == expected then
        tests_passed = tests_passed + 1
        table.insert(test_output, "✓ " .. test_name)
    else
        tests_failed = tests_failed + 1
        table.insert(test_output, "✗ " .. test_name)
        table.insert(test_output, "  Expected: " .. tostring(expected))
        table.insert(test_output, "  Got: " .. tostring(actual))
    end
end

local function assert_true(condition, test_name)
    assert_equal(condition, true, test_name)
end

local function assert_false(condition, test_name)
    assert_equal(condition, false, test_name)
end

local function assert_not_nil(value, test_name)
    if value ~= nil then
        tests_passed = tests_passed + 1
        table.insert(test_output, "✓ " .. test_name)
    else
        tests_failed = tests_failed + 1
        table.insert(test_output, "✗ " .. test_name)
        table.insert(test_output, "  Expected: not nil")
        table.insert(test_output, "  Got: nil")
    end
end

-- Export test helpers
_G.assert_equal = assert_equal
_G.assert_true = assert_true
_G.assert_false = assert_false
_G.assert_not_nil = assert_not_nil
_G.tests_passed = function() return tests_passed end
_G.tests_failed = function() return tests_failed end
_G.test_output = test_output

function love.load()
    print("\n=== Love2D Test Runner ===\n")
    
    -- Add parent directory to package path to find src/
    package.path = package.path .. ";../src/?.lua;./src/?.lua"
    
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
    
    -- Print results
    print("\n=== Test Results ===")
    for _, line in ipairs(test_output) do
        print(line)
    end
    
    print(string.format("\nPassed: %d", tests_passed))
    print(string.format("Failed: %d", tests_failed))
    print(string.format("Total: %d", tests_passed + tests_failed))
    
    if tests_failed == 0 then
        print("\n✓ All tests passed!")
        love.event.quit(0)
    else
        print("\n✗ Some tests failed!")
        love.event.quit(1)
    end
end

function love.draw()
    -- Draw test results on screen
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Running tests... Check console output", 10, 10)
end

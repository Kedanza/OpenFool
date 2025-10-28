# PowerShell script to refactor test files
# Converts old wrapper functions to direct assert() calls

$files = @(
    "ai_attack_test_love.lua",
    "ai_defense_test_love.lua",
    "ai_throw_additional_test_love.lua",
    "ruleset_test_love.lua",
    "player_test_love.lua"
)

foreach ($file in $files) {
    Write-Host "Processing $file..."
    $content = Get-Content $file -Raw
    
    # Replace assert_not_nil(value, "msg") with assert(value ~= nil, "msg")
    $content = $content -replace 'assert_not_nil\(([^,]+),\s*("([^"]|\\")*")\)', 'assert($1 ~= nil, $2)'
    
    # Replace assert_equal(a, b, "msg") with assert(a == b, "msg")
    $content = $content -replace 'assert_equal\(([^,]+),\s*([^,]+),\s*("([^"]|\\")*")\)', 'assert($1 == $2, $3)'
    
    # Replace assert_true(condition, "msg") with assert(condition, "msg")
    # But be careful not to match multi-line cases yet
    $content = $content -replace 'assert_true\(([^\n]+)\)', 'assert($1)'
    
    # Replace assert_false(condition, "msg") with assert(not condition, "msg")  
    # But be careful not to match multi-line cases yet
    $content = $content -replace 'assert_false\(([^\n]+)\)', 'assert(not $1)'
    
    Set-Content $file $content -NoNewline
}

Write-Host "Refactoring complete!"

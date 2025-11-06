$process = Start-Process -FilePath "C:\Program Files\LOVE\lovec.exe" -ArgumentList "tests/" -RedirectStandardOutput "logs\2025-10-31_game_loop_final.txt" -RedirectStandardError "logs\2025-10-31_game_loop_final_err.txt" -NoNewWindow -PassThru
if (-not $process.WaitForExit(120000)) {
    $process.Kill()
    Write-Output "Process killed after 120 second timeout"
    exit 1
}
exit $process.ExitCode

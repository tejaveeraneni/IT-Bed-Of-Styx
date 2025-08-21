# File Watcher for GitHub Issue Form
# This script watches your issue form file and validates it automatically when saved

$issueFormPath = ".github/ISSUE_TEMPLATE/user-creation-form.yml"
$fullPath = (Resolve-Path $issueFormPath).Path

Write-Host "👀 Watching for changes to: $issueFormPath" -ForegroundColor Cyan
Write-Host "💡 Save the file to see automatic validation" -ForegroundColor Yellow
Write-Host "🛑 Press Ctrl+C to stop watching" -ForegroundColor Red
Write-Host ("=" * 60)

# Create file system watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = Split-Path $fullPath -Parent
$watcher.Filter = Split-Path $fullPath -Leaf
$watcher.EnableRaisingEvents = $true

# Define the action to take when file changes
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Write-Host "`n[$timeStamp] File ${changeType}: $path" -ForegroundColor Green

    # Small delay to ensure file write is complete
    Start-Sleep -Milliseconds 500

    # Run validation
    try {
        & ".\validate-issue-form.ps1" | Out-Host
    }
    catch {
        Write-Host "❌ Error running validation: $_" -ForegroundColor Red
    }

    Write-Host ("-" * 60)
}

# Register event handler
Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action | Out-Null

try {
    # Keep the script running
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    # Clean up
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Get-EventSubscriber | Unregister-Event
    Write-Host "`n🛑 Stopped watching" -ForegroundColor Red
}

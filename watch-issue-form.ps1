# File Watcher for GitHub Issue Form
# This script watches your issue form file and automatically commits/pushes changes

$issueFormPath = ".github/ISSUE_TEMPLATE/user-creation-form.yml"
$fullPath = (Resolve-Path $issueFormPath).Path

Write-Host "👀 Watching for changes to: $issueFormPath" -ForegroundColor Cyan
Write-Host "� Will auto-commit and push changes when saved" -ForegroundColor Yellow
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
    Start-Sleep -Milliseconds 1000

    # Auto-commit and push changes
    try {
        Write-Host "🔄 Auto-committing changes..." -ForegroundColor Cyan
        $commitMessage = "Update issue form - $timeStamp"
        & ".\auto-commit.ps1" -CommitMessage $commitMessage
        Write-Host "✅ Changes committed and pushed!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error auto-committing: $_" -ForegroundColor Red
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

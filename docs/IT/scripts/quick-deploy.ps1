# Quick Deploy Script
# This script quickly commits and pushes all changes

param(
    [string]$CommitMessage = "Quick update to workflows and forms"
)

Write-Host "🚀 Quick Deploy" -ForegroundColor Cyan
Write-Host ("=" * 40)

# Use the auto-commit script
& ".\auto-commit.ps1" -CommitMessage $CommitMessage

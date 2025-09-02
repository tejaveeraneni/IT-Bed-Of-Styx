# Auto Commit and Push Script
# This script automatically commits and pushes the latest changes to the main branch

param(
    [string]$CommitMessage = "Auto-commit: Updated issue form and workflows"
)

Write-Host "🔄 Auto Commit & Push" -ForegroundColor Cyan
Write-Host ("=" * 40)

try {
    # Check if there are any changes
    $status = git status --porcelain
    if (!$status) {
        Write-Host "ℹ️  No changes to commit" -ForegroundColor Blue
        return
    }

    Write-Host "📋 Changes detected:" -ForegroundColor Yellow
    git status --short

    Write-Host "`n📦 Staging all changes..." -ForegroundColor Yellow
    git add -A

    Write-Host "💾 Committing changes..." -ForegroundColor Yellow
    git commit -m $CommitMessage

    if ($LASTEXITCODE -eq 0) {
        Write-Host "🚀 Pushing to main branch..." -ForegroundColor Yellow
        git push origin main

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully pushed changes!" -ForegroundColor Green
            Write-Host "🌐 Check your repository: https://github.com/tejaveeraneni/IT-Bed-Of-Styx" -ForegroundColor Cyan
        }
        else {
            Write-Host "❌ Failed to push changes" -ForegroundColor Red
        }
    }
    else {
        Write-Host "❌ Failed to commit changes" -ForegroundColor Red
    }

}
catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

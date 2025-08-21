# Quick Issue Form Development Workflow
# This script validates, commits, and pushes your issue form changes quickly

param(
    [string]$CommitMessage = "Update issue form",
    [switch]$SkipValidation = $false
)

Write-Host "🔄 GitHub Issue Form Quick Deploy" -ForegroundColor Cyan
Write-Host ("=" * 50)

$issueFormPath = ".github/ISSUE_TEMPLATE/user-creation-form.yml"

# Step 1: Validate if not skipped
if (!$SkipValidation) {
    Write-Host "`n1️⃣ Validating YAML..." -ForegroundColor Yellow
    & ".\validate-issue-form.ps1" $issueFormPath | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Validation failed. Fix issues before deploying." -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "`n1️⃣ Skipping validation..." -ForegroundColor Yellow
}

# Step 2: Check git status
Write-Host "`n2️⃣ Checking git status..." -ForegroundColor Yellow
$gitStatus = git status --porcelain $issueFormPath
if (!$gitStatus) {
    Write-Host "ℹ️  No changes detected in issue form" -ForegroundColor Blue
    exit 0
}

# Step 3: Add and commit
Write-Host "`n3️⃣ Staging and committing changes..." -ForegroundColor Yellow
git add $issueFormPath
git commit -m $CommitMessage

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Commit failed" -ForegroundColor Red
    exit 1
}

# Step 4: Push to GitHub
Write-Host "`n4️⃣ Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 Success! Your issue form is now live on GitHub!" -ForegroundColor Green
    Write-Host "🌐 View it at: https://github.com/tejaveeraneni/IT-Bed-Of-Styx/issues/new/choose" -ForegroundColor Cyan
}
else {
    Write-Host "❌ Push failed" -ForegroundColor Red
    exit 1
}

# Simple script to create a test issue for GitHub Actions workflow

$Owner = "tejaveeraneni"
$Repo = "IT-Bed-Of-Styx"

Write-Host "🚀 Creating test issue..." -ForegroundColor Cyan

# Test user data
$issueBody = @"
### First Name

John

### Last Name

Doe

### Location

United States

### Job Title

Software Engineer

### Phone Number

555-123-4567

### VPN Access Requirements

- [x] Yes, this user needs VPN access
"@

$issueTitle = "[Create a New User]: John Doe"

# Create the issue
$tempFile = [System.IO.Path]::GetTempFileName()
$issueBody | Out-File -FilePath $tempFile -Encoding utf8
$issueUrl = gh issue create --title $issueTitle --body-file $tempFile --repo "$Owner/$Repo" --label "user"
Remove-Item $tempFile -Force

$issueNumber = ($issueUrl -split '/')[-1]

Write-Host "✅ Test issue created!" -ForegroundColor Green
Write-Host "🔗 Issue URL: $issueUrl" -ForegroundColor Cyan
Write-Host "🔢 Issue Number: #$issueNumber" -ForegroundColor Yellow
Write-Host "📊 Check workflow: https://github.com/$Owner/$Repo/actions" -ForegroundColor Yellow

Write-Host "`n🗑️ To delete: gh issue delete $issueNumber --repo $Owner/$Repo --yes" -ForegroundColor Gray

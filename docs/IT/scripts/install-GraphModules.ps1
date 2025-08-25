Write-Host "📦 Installing Microsoft Graph PowerShell Module..." -ForegroundColor Cyan
Install-Module Microsoft.Graph.Authentication -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Users -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Users.Actions -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Identity.DirectoryManagement -Force -Scope CurrentUser
Write-Host "✅ Microsoft Graph PowerShell Module installed" -ForegroundColor Green
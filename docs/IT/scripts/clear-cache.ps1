# Clear Microsoft Authentication Library cache
$tokenCachePath = "$env:LOCALAPPDATA\.IdentityService"
if (Test-Path $tokenCachePath) {
    Remove-Item $tokenCachePath -Recurse -Force
}

# Also clear Azure PowerShell cache
$azureCachePath = "$env:USERPROFILE\.Azure"
if (Test-Path $azureCachePath) {
    Remove-Item $azureCachePath -Recurse -Force
}
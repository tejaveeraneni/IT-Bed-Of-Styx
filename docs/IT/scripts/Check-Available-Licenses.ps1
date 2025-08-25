Write-Host "Checking Microsoft 365 Business Standard License Availability..."

$Credential = New-Object System.Management.Automation.PSCredential($ClientId, $ClientSecret)

Connect-MgGraph -ClientSecretCredential $Credential -TenantId $TenantId

$licenses = Get-MgSubscribedSku -All
$businessStandardLicense = $licenses | Where-Object {
    $_.SkuPartNumber -eq "O365_BUSINESS_PREMIUM" -or
    $_.SkuPartNumber -eq "SPB" -or
    $_.DisplayName -like "*Business Standard*"
}

if ($businessStandardLicense) {
    $availableLicenses = $businessStandardLicense.PrepaidUnits.Enabled - $businessStandardLicense.ConsumedUnits
    Write-Host "Number of available Business Standard licenses: $availableLicenses"
    Write-Output "AVAILABLE_LICENSES=$availableLicenses" >> $env:GITHUB_OUTPUT
}
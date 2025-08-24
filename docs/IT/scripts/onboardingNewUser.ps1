<#
.SYNOPSIS
    Onboards new users to Microsoft 365/Azure AD using the Microsoft Graph API.

.DESCRIPTION
    This script automates the process of creating new user accounts in Microsoft 365/Azure AD
    by reading user details from a CSV file and creating accounts with standardized settings.
    The script creates user accounts, sets default passwords, and allows for license assignment
    through an interactive menu system.

    The script performs the following operations:
    - Reads user data from a CSV file named "NewAccounts.csv"
    - Creates new user accounts in Azure AD with standardized naming conventions
    - Sets a default password that must be changed on first login
    - Displays available licenses and allows interactive license selection
    - Assigns selected licenses to the newly created users

.PARAMETER None
    This script does not accept parameters. All configuration is done through the CSV file
    and interactive prompts.

.INPUTS
    CSV File: "NewAccounts.csv"
    Required columns:
    - FirstName: User's first name
    - LastName: User's last name
    - JobTitle: User's job title
    - PhoneNumber: User's mobile phone number

.OUTPUTS
    Microsoft.Graph.PowerShell.Models.MicrosoftGraphUser
    Creates new user objects in Azure AD and displays user information.

.EXAMPLE
    PS> .\onboardingNewUser.ps1

    Reads from NewAccounts.csv and creates users interactively

    Available Licenses:
    1. ENTERPRISEPACK - 25 available
    2. POWER_BI_PRO - 10 available
    Which license? (Enter Number): 1

.EXAMPLE
    Example CSV file format (NewAccounts.csv):
    FirstName,LastName,JobTitle,PhoneNumber
    John,Doe,Software Engineer,555-123-4567
    Jane,Smith,Product Manager,555-987-6543

.NOTES
    Author: IT Department
    Version: 1.0

    Prerequisites:
    - Microsoft Graph PowerShell SDK must be installed
    - Must be authenticated to Microsoft Graph with appropriate permissions
    - User must have permissions to create users and assign licenses
    - CSV file "NewAccounts.csv" must exist in the script directory

    Required Graph API Permissions:
    - User.ReadWrite.All
    - Directory.ReadWrite.All
    - Organization.Read.All

    Installation:
    Install-Module Microsoft.Graph -Scope CurrentUser

    Authentication:
    Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All","Organization.Read.All"

    User Account Details:
    - UserPrincipalName format: firstname.lastname@oxmiq.ai
    - MailNickname format: firstname.lastname (lowercase)
    - Default password: Password123 (must be changed on first login)
    - Usage location: US
    - Account status: Enabled

.LINK
    https://docs.microsoft.com/en-us/powershell/microsoftgraph/
    https://docs.microsoft.com/en-us/graph/api/user-post-users

#>

# This script reads user details from a CSV file at "docs/IT/scripts/NewAccounts.csv"
$users = Import-Csv "docs/IT/scripts/NewAccounts.csv"

# Default password profile for new users
# Password is set to 'Password123' and requires a change on first sign-in
$PasswordProfile = @{
    Password                      = 'Password123'
    ForceChangePasswordNextSignIn = $true
}

foreach ($user in $users) {

    $userParams = @{
        # Mandatory parameters
        GivenName         = $user.FirstName
        Surname           = $user.LastName
        DisplayName       = $user.DisplayName
        MailNickname      = $user.MailNickname
        UserPrincipalName = $user.UserPrincipalName
        AccountEnabled    = $true
        ErrorAction       = 'Stop'
        UsageLocation     = $user.UsageLocation
        PasswordProfile   = $PasswordProfile

        # Optional parameters
        JobTitle          = $user.JobTitle
        MobilePhone       = $user.PhoneNumber
    }

    @('JobTitle', 'MobilePhone') | ForEach-Object {
        if (!$userParams[$_] -or $userParams[$_] -eq "_No response_" -or $userParams[$_].ToString().Trim() -eq "") {
            $userParams.Remove($_)
        }
    }
    $newUser = New-MgUser @userParams

    Write-Host "✅ Created user: $($newUser.DisplayName)" -ForegroundColor Green

    $SkuId = (Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq "O365_BUSINESS_PREMIUM" }).SkuId

    Set-MgUserLicense -UserId $newUser.Id -AddLicenses @{SkuId = $SkuId } -RemoveLicenses @()

    Write-Host "Assigned Microsoft 365 Business Standard license to $($newUser.DisplayName)" -ForegroundColor Green
}

Write-Host $users
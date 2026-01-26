## FUNCTIONS

function Write-ErrorDetails {
    param($ErrorRecord, $Context)

    Write-Host "Error in $Context" -ForegroundColor Red
    Write-Host "Details in $($ErrorRecord.Exception.Message)" -ForegroundColor Red
    Write-Host "Type: $($ErrorRecord.Exception.GetType().Name)" -ForegroundColor Red
    Write-Host "Line: $($ErrorRecord.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
}

function Show-AuditResults {
    param(
        [array]$Data,
        [int]$Count,
        [string]$SectionName,
        [string[]]$Properties
    )
    if ($Count -gt 0) {
        Write-Host "=== $($SectionName) ===" -ForegroundColor White
        $Data | Format-Table $Properties
    }

}

# Install-Module -Name Microsoft.Graph -AllowClobber -Force
# Install-Module -Name ExchangeOnlineManagement -AllowClobber -Force

Write-Host "Connecting to Microsoft Graph" -ForegroundColor Yellow
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "GroupMember.Read.All", "Directory.Read.All", "RoleManagement.Read.All", "Sites.Read.All", "Team.ReadBasic.All", "TeamMember.ReadWrite.All", "Application.Read.All", "DelegatedPermissionGrant.Read.All" -NoWelcome

# $userPrincipalName = Read-Host "Enter the email of the user to be offboarded:"

Write-Host "Looking up user.." -ForegroundColor Cyan
$userPrincipalName = "offboarding.test@oxmiq.ai"
$User = Get-MgUser -UserId $userPrincipalName

if (!$User) {
    Write-Host "User not found!" -ForegroundColor Red
    exit
}

$AuditDetails = @{
    UserPrincipalName = ""
    GitHubRepos       = @()
    GitHubTeams       = @()
    GitHubOwnedRepos  = @()
}

try {
    $User = Get-MgUser -UserId $userPrincipalName -ErrorAction Stop

    Write-Host "Found user: $($User.DisplayName)" -ForegroundColor Green

    $AuditDetails = @{
        UserPrincipalName = $User.UserPrincipalName
        DisplayName       = $User.DisplayName
        GitHubRepos       = @()
        GitHubTeams       = @()
        GitHubOwnedRepos  = @()
        ChatGPTAccess     = $false
        ChatGPTUserId     = $null
        ChatGPTRole       = $null
    }
}
catch {
    Write-ErrorDetails -ErrorRecord $_ -Context "Azure AD User Lookup Failed"
}

Write-Host "Azure AD details fetched successfully\n" -ForegroundColor Green

$githubOrg = "mihira-ai"
$githubToken = $env:GH_TOKEN
$githubHeaders = @{
    Authorization = "token $githubToken"
    Accept        = "application/vnd.github.v3+json"
}

# Write-Host "Fetching Github User Information" -ForegroundColor Yellow

# try {

#     # Get user from Github
#     $membersUrl = "https://api.github.com/orgs/$githubOrg/members?per_page=100"
#     $allMembers = Invoke-RestMethod -Uri $membersUrl -Headers $githubHeaders -Method Get -ErrorAction Stop

#     $githubUser = $null
#     foreach ($member in $allMembers) {
#         $userDetailUrl = "https://api.github.com/users/$($member.login)"
#         $userDetail = Invoke-RestMethod -Uri $userDetailUrl -Headers $githubHeaders -Method Get -ErrorAction Stop

#         if ($userDetail.email -eq $userPrincipalName) {
#             $githubUser = $userDetail
#             break
#         }
#     }
#     if (!$githubUser) {
#         Write-Host "Github User with the email $($userPrincipalName) was not found. Please try again with another email" -ForegroundColor Red
#         Write-Host "Continuing without Github Information..." -ForegroundColor Yellow
#     }
#     else {
#         $githubUsername = $githubUser.login
#         Write-Host "Found Github User $githubUsername ($userPrincipalName)" -ForegroundColor Green

#         # Get user's team memberships
#         $teamsUrl = "https://api.github.com/orgs/$githubOrg/teams"
#         $allTeams = Invoke-RestMethod -Uri $teamsUrl -Headers $githubHeaders -Method Get -ErrorAction Stop

#         foreach ($team in $allTeams) {

#             $memberCheckUrl = "https://api.github.com/orgs/$githubOrg/teams/$($team.slug)/memberships/$githubUsername"

#             try {
#                 $membership = Invoke-RestMethod -Uri $memberCheckUrl -Headers $githubHeaders -Method Get -ErrorAction Stop
#                 if ( $membership ) {
#                     $AuditDetails.GitHubTeams += $team.name
#                 }
#             }
#             catch {

#             }
#         }

#         # Get repositories user has access to
#         $reposUrl = "https://api.github.com/orgs/$githubOrg/repos?per_page=100"
#         $allRepos = Invoke-RestMethod -Uri $reposUrl -Headers $githubHeaders -Method Get -ErrorAction Stop

#         foreach ($repo in $allRepos) {
#             $collaboratorUrl = "https://api.github.com/repos/$githubOrg/$($repo.name)/collaborators/$githubUsername"

#             try {
#                 Invoke-RestMethod -Uri $collaboratorUrl -Headers $githubHeaders -Method Get -ErrorAction Stop
#                 $AuditDetails.GitHubRepos += $repo.name

#                 if ($repo.owner.login -eq $githubUsername) {
#                     $AuditDetails.GitHubOwnedRepos += $repo.name
#                 }
#             }
#             catch {
#             }
#         }

#     }
#     Write-Host "Github Teams: $($AuditDetails.GitHubTeams.Count)" -ForegroundColor Green
#     Write-Host "Github Repos Accessed: $($AuditDetails.GitHubRepos)" -ForegroundColor Green
#     Write-Host "Github Repos Owned: $($AuditDetails.GitHubOwnedRepos)" -ForegroundColor Green
# }
# catch {
#     Write-ErrorDetails -ErrorRecord $_ -Context "Github User Lookup failed"
# }

# Write-Host "Fetching Claude User Information" -ForegroundColor Yellow

# $claudeAdminKey = $env:ANTHROPIC_ADMIN_KEY
# $claudeHeaders = @{
#     "x-api-key"         = $claudeAdminKey
#     "anthropic-version" = "2023-06-01"
#     "Content-Type"      = "application/json"
# }

# try {
#     $membersUrl = "https://api.anthropic.com/v1/organizations/users?limit=100"
#     $response = Invoke-RestMethod -Uri $membersUrl -Headers $claudeHeaders -Method Get -ErrorAction Stop

#     $claudeUser = $response.data | Where-Object { $_.email -eq $userPrincipalName }
#     if ($claudeUser) {
#         Write-Host "Found Claude user: $($claudeUser.email)" -ForegroundColor Green
#         Write-Host "Found Claude User Id: $($claudeUser.id)" -ForegroundColor Green
#         Write-Host "Found Claude role: $($claudeUser.role)" -ForegroundColor Green

#         $AuditDetails.ClaudeAccess = $true
#         $AuditDetails.ClaudeRole = $claudeUser.role
#         $AuditDetails.ClaudeUserId = $claudeUser.id
#     }
#     else {
#         Write-Host "Claude User not found"
#         $AuditDetails.ClaudeAccess = $false
#     }


# }
# catch {
#     Write-ErrorDetails -ErrorRecord $_ -Context "Claude User Information Request Failed"
#     $AuditDetails.ClaudeAccess = $false
# }

# OpenAI Admin API Configuration
# $openaiToken = $env:OPENAI_API_KEY  # Admin API key
# $openaiHeaders = @{
#     Authorization  = "Bearer $openaiToken"
#     "Content-Type" = "application/json"
# }

# Write-Host "`nFetching ChatGPT user information..." -ForegroundColor Yellow

# try {
#     # List organization members
#     $membersUrl = "https://api.openai.com/v1/organization/users"
#     $response = Invoke-RestMethod -Uri $membersUrl -Headers $openaiHeaders -Method Get -ErrorAction Stop

#     # Find user by email
#     $chatgptUser = $response.members.data | Where-Object { $_.email -eq $userPrincipalName }

#     if ($chatgptUser) {
#         Write-Host "Found ChatGPT user: $($chatgptUser.email)" -ForegroundColor Green
#         Write-Host "  User ID: $($chatgptUser.id)" -ForegroundColor Cyan
#         Write-Host "  Role: $($chatgptUser.role)" -ForegroundColor Cyan

#         # Add to audit details
#         $AuditDetails.ChatGPTUserId = $chatgptUser.id
#         $AuditDetails.ChatGPTRole = $chatgptUser.role
#         $AuditDetails.ChatGPTAccess = $true
#     }
#     else {
#         Write-Host "ChatGPT user not found" -ForegroundColor Yellow
#         $AuditDetails.ChatGPTAccess = $false
#     }

# }
# catch {
#     Write-ErrorDetails -ErrorRecord $_ -Context "ChatGPT User Lookup"
#     Write-Host "Continuing without ChatGPT data..." -ForegroundColor Yellow
#     $AuditDetails.ChatGPTAccess = $false
# }


Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "OFFBOARDING AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "User: $($AuditDetails.DisplayName)" -ForegroundColor White
Write-Host "Email: $($AuditDetails.UserPrincipalName)" -ForegroundColor White
Write-Host "`nAccess Found:" -ForegroundColor White
Write-Host "  Azure AD: Yes" -ForegroundColor $(if ($User) { 'Green' }else { 'Red' })
# Write-Host "  Claude: $(if($AuditDetails.ClaudeAccess){'Yes (Role: ' + $AuditDetails.ClaudeRole + ')'}else{'No'})" -ForegroundColor $(if ($AuditDetails.ClaudeAccess) { 'Green' }else { 'Yellow' })
# Write-Host "  GitHub: SSO Pending" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan


Write-Host "`nStarting offboarding process...`n" -ForegroundColor Yellow

Write-Host "Removing user from Azure AD..." -ForegroundColor Yellow

# Remove Azure AD account
try {
    Remove-MgUser -UserId $User.Id -ErrorAction Stop
    Write-Host "User successfully removed from Azure AD" -ForegroundColor Green
}
catch {
    Write-ErrorDetails -ErrorRecord $_ -Context "Azure AD User Removal Failed"
}

# # Remove Claude account

# if ($AuditDetails.ClaudeAccess) {
#     Write-Host "Removing user from Claude" -ForegroundColor Yellow

#     try {
#         $deleteUrl = "https://api.anthropic.com/v1/organizations/users/$($AuditDetails.ClaudeUserId)"
#         Invoke-RestMethod -Uri $deleteUrl -Headers $claudeHeaders -Method Delete -ErrorAction Stop
#         Write-Host " User successfully removed from Claude Access" -ForegroundColor Green
#     }
#     catch {
#         Write-ErrorDetails -ErrorRecord $_ -Context "Claude Access Removal Failed"
#     }
# }
# else {
#     Write-Host "Skipping Claude Access as user not found" -ForegroundColor Yellow
# }

# Write-Host "`n========================================" -ForegroundColor Cyan
# Write-Host "OFFBOARDING COMPLETE" -ForegroundColor Green
# Write-Host "========================================" -ForegroundColor Cyan
# Write-Host "User $($AuditDetails.DisplayName) has been offboarded." -ForegroundColor White
# Write-Host "`nNext Steps:" -ForegroundColor Yellow
# Write-Host "  - Azure AD: User in 'Deleted Users' (30-day recovery window)" -ForegroundColor White
# Write-Host "========================================`n" -ForegroundColor Cyan
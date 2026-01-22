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
$userPrincipalName = "teja.veeraneni@oxmiq.ai"
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
        UserPrincipalName = $User.DisplayName
        GitHubRepos       = @()
        GitHubTeams       = @()
        GitHubOwnedRepos  = @()
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

Write-Host "Fetching Claude User Information" -ForegroundColor Yellow

try {

}
catch {
    Write-ErrorDetails -ErrorRecord $_ -Context "Claude User Information Request Failed"
}
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

# Write-Host "Connecting to Microsoft Graph" -ForegroundColor Yellow
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "GroupMember.Read.All", "Directory.Read.All", "RoleManagement.Read.All", "Sites.Read.All", "Team.ReadBasic.All", "TeamMember.ReadWrite.All" -NoWelcome

# $userPrincipalName = Read-Host "Enter the email of the user to be offboarded:"

Write-Host "Looking up user.." -ForegroundColor Cyan
$userPrincipalName = "teja.veeraneni@oxmiq.ai"
$User = Get-MgUser -UserId $userPrincipalName

if (!$User) {
    Write-Host "User not found!"
    exit
}

$AuditDetails = @{
    User                 = $User.DisplayName
    UserPrincipalName    = $User.UserPrincipalName
    SecurityGroups       = @()
    Microsoft365Groups   = @()
    DistributionLists    = @()
    AzureADRoles         = @()
    AzureRoleAssignments = @()
    SharePointSites      = @()
    TeamsOwnership       = @()
    TeamsMembership      = @()
    LicenseAssignment    = @()
}

# Azure AD Role Assignments
try {
    Write-Host "Getting Azure Memberships and Roles.." -ForegroundColor Green

    $userRoleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -Filter "principalId eq '$($User.Id)'"
    if ($userRoleAssignments.Count -eq 0) {
        Write-Host "User has not been assigned any Role Assignments"
    }
    else {
        foreach ($roleAssignment in $userRoleAssignments) {
            try {
                $roleDefinition = Get-MgRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $roleAssignment.RoleDefinitionId

                $AuditDetails.AzureADRoles += [PSCustomObject]@{
                    RoleName     = $roleDefinition.DisplayName
                    RoleID       = $roleDefinition.Id
                    Description  = $roleDefinition.Description
                    AssignmentId = $roleAssignment.Id
                }
            }
            catch {
                Write-ErrorDetails -ErrorRecord $_ -Context "Error: Could not find Azure AD Assignments"
            }
        }
    }
}
catch {
    Write-ErrorDetails -ErrorRecord $_ -Context "Error: Could not find Role Assignments for user"
}

# Group Memberships
try {
    Write-Host "Getting Group Memberships.." -ForegroundColor Cyan
    $userGroups = Get-MgUserMemberOf -UserId $User.Id

    foreach ($Group in $userGroups) {

        $dataType = $Group.AdditionalProperties.Keys | Select-Object -First 1
        if ($Group.AdditionalProperties[$dataType] -eq "#microsoft.graph.directoryRole") {
            continue
        }
        $GroupDetails = Get-MgGroup -GroupId $Group.Id

        # Security Group
        if (!$GroupDetails.MailEnabled -and $GroupDetails.SecurityEnabled) {
            $AuditDetails.SecurityGroups += [PSCustomObject]@{
                DisplayName = $GroupDetails.DisplayName
                Id          = $GroupDetails.Id
                Description = $GroupDetails.Description
            }
        }

        # Microsoft 365 Group
        if ($GroupDetails.GroupTypes -contains "Unified") {
            $AuditDetails.Microsoft365Groups += [PSCustomObject]@{
                DisplayName = $GroupDetails.DisplayName
                Id          = $GroupDetails.Id
                Description = $GroupDetails.Description
                Mail        = $GroupDetails.Mail
            }
        }

        # Distribution List
        if ($GroupDetails.MailEnabled -and !$GroupDetails.SecurityEnabled) {
            $AuditDetails.DistributionLists += [PSCustomObject]@{
                DisplayName = $GroupDetails.DisplayName
                Id          = $GroupDetails.Id
                Description = $GroupDetails.Description
                Mail        = $GroupDetails.Mail
            }
        }
    }
}
catch {
    Write-ErrorDetails -ErrorRecord $_ -Context "Error while fetching group memberships for this user"
}

# Sharepoint Permissions
# try {
#     Write-Host "Getting Sharepoint Site Access"-ForegroundColor Yellow
#     $userSites = Get-MgUserFollowedSite -UserId $User.Id
#     foreach ($Site in $UserSites) {
#         $AuditDetails.SharePointSites += [PSCustomObject]@{
#             SiteName = $Site.DisplayName
#             SiteUrl  = $Site.WebUrl
#             SiteId   = $Site.Id
#             Access   = "Followed"
#         }
#     }
# }
# catch {
#     Write-ErrorDetails -ErrorRecord $_ -Context "Error: Could not find Sharepoint Permissions for user"
# }

# Teams Ownership and Membership
try {
    Write-Host "Getting Teams Ownership and Membership..." -ForegroundColor Blue
    foreach ($Group in $AuditDetails.Microsoft365Groups) {
        $Team = Get-MgTeam -TeamId $Group.Id
        if ($Team) {

            $TeamMember = Get-MgTeamMember -TeamId $Team.Id | Where-Object { $_.DisplayName -eq $User.DisplayName }
            $IsOwner = $TeamMember.Roles -contains "Owner"

            if ($IsOwner) {
                $AuditDetails.TeamsOwnership += [PSCustomObject]@{
                    TeamName    = $Team.DisplayName
                    TeamId      = $Team.Id
                    GroupId     = $Group.Id
                    Description = $Group.Description
                }
            }
            else {
                $AuditDetails.TeamsMembership += [PSCustomObject]@{
                    TeamName    = $Team.DisplayName
                    TeamId      = $Team.Id
                    GroupId     = $Group.Id
                    Description = $Group.Description
                }
            }
        }
    }
}
catch {
    Write-ErrorDetails -ErrorRecord $_ -Context "Could not retrieve Teams permissions and groups"
}

# License Assignments
$licenseNameMapping = @{
    "O365_BUSINESS_ESSENTIALS"    = "Microsoft 365 Business Basic"
    "O365_BUSINESS_PREMIUM"       = "Microsoft 365 Business Standard"
    "SPB"                         = "Microsoft 365 Business Standard"
    "SMB_BUSINESS_ESSENTIALS"     = "Microsoft 365 Business Basic"
    "SMB_BUSINESS_PREMIUM"        = "Microsoft 365 Business Standard"
    "BUSINESS_ASSIST"             = "Business Assist"
    "COPILOT_M365_BIZ_PREVIEW"    = "Microsoft 365 Copilot"
    "FABRIC_FREE"                 = "Microsoft Fabric (Free)"
    "INTUNE_A"                    = "Microsoft Intune Plan 2"
    "FLOW_FREE"                   = "Microsoft Power Automate Free"
    "DYN365_CDS_VIRAL"            = "Microsoft Power Automate Free"
    "TEAMS_FREE"                  = "Microsoft Teams Premium"
    "TEAMS_ROOMS_BASIC"           = "Microsoft Teams Rooms Basic"
    "TEAMS_ROOMS_PRO"             = "Microsoft Teams Rooms Pro"
    "TEAMS_SHARED_DEVICE"         = "Microsoft Teams Shared Devices"
    "SHAREPOINTDESKLESS"          = "OneDrive for business (Plan 2)"
    "POWER_AUTOMATE_ATTENDED_RPA" = "Power Automate per user plan"
    "POWER_BI_PRO"                = "Power BI Pro"
}
try {
    Write-Host "Fetching licenses for current user..." -ForegroundColor Green
    $allSkus = Get-MgSubscribedSku
    # $allSkus | Select-Object *
    $userLicenses = Get-MgUserLicenseDetail -UserId $User.Id

    if ($userLicenses.Count -eq 0) {
        Write-Host "No licenses found for user" -ForegroundColor Gray
    }
    else {
        foreach ($license in $userLicenses) {
            $subscribedSku = $allSkus | Where-Object { $_.SkuId -eq $license.SkuId }

            $AuditDetails.LicenseAssignment += [PSCustomObject]@{
                License = $licenseNameMapping.Contains($subscribedSku.SkuPartNumber) ? $licenseNameMapping[$license.SkuPartNumber] : $subscribedSku.SkuPartNumber
                SkuId   = $subscribedSku.SkuId
            }

        }
    }
}
catch {
    Write-ErrorDetails -ErrorRecord $_ -Context "Error while fetching licenses from user"
}



Write-Host "=== OFFBOARDING GROUP RESULTS ===" -ForegroundColor Cyan
Write-Host "User: $($AuditDetails.User) Email: $($AuditDetails.UserPrincipalName)" -ForegroundColor White
Write-Host ""

$SecurityGroupCount = $AuditDetails.SecurityGroups.Count
$DistributionListCount = $AuditDetails.DistributionLists.Count
$Microsoft365GroupCount = $AuditDetails.Microsoft365Groups.Count
$AzureADRoleCount = $AuditDetails.AzureADRoles.Count
$SharepointSiteCount = $AuditDetails.SharePointSites.Count
$TeamsOwnerCount = $AuditDetails.TeamsOwnership.Count
$TeamsMemberCount = $AuditDetails.TeamsMembership.Count
$LicenseAssignmentCount = $AuditDetails.LicenseAssignment.Count

Write-Host "This user is present in the following assignments:"
Write-Host "Security Groups: $SecurityGroupCount" -ForegroundColor White
Write-Host "Distribution Lists: $DistributionListCount" -ForegroundColor White
Write-Host "Microsoft 365 Groups: $Microsoft365GroupCount" -ForegroundColor White
Write-Host "Azure AD Roles: $AzureADRoleCount" -ForegroundColor White
Write-Host "SharePoint Sites: $SharepointSiteCount" -ForegroundColor White
Write-Host "Teams Ownership: $TeamsOwnerCount" -ForegroundColor White
Write-Host "Teams Membership: $TeamsMemberCount" -ForegroundColor White
Write-Host "Licenses: $LicenseAssignmentCount" -ForegroundColor White
Write-Host ""

Show-AuditResults -Data $AuditDetails.SecurityGroups -Count $SecurityGroupCount -SectionName "SECURITY GROUPS" -Properties @("DisplayName", "Id", "Description")
Show-AuditResults -Data $AuditDetails.Microsoft365Groups -Count $Microsoft365GroupCount -SectionName "MICROSOFT 365 GROUPS" -Properties @("DisplayName", "Id", "Description", "Mail")
Show-AuditResults -Data $AuditDetails.DistributionLists -Count $DistributionListCount -SectionName "DISTRIBUTION LISTS" -Properties @("DisplayName", "Id", "Description", "Mail")
Show-AuditResults -Data $AuditDetails.AzureADRoles -Count $AzureADRoleCount -SectionName "AZURE AD ROLES" -Properties @("RoleName", "RoleID", "Description", "AssignmentId")
Show-AuditResults -Data $AuditDetails.SharePointSites -Count $SharepointSiteCount -SectionName "SHAREPOINT SITES" -Properties @("SiteId", "SiteName", "SiteUrl", "Access")
Show-AuditResults -Data $AuditDetails.TeamsOwnership -Count $TeamsOwnerCount -SectionName "TEAMS OWNER" -Properties @("TeamName", "TeamId", "GroupId", "Description")
Show-AuditResults -Data $AuditDetails.TeamsMembership -Count $TeamsMemberCount -SectionName "TEAMS MEMBER" -Properties @("TeamName", "TeamId", "GroupId", "Description")
Show-AuditResults -Data $AuditDetails.LicenseAssignment -Count $LicenseAssignmentCount -SectionName "LICENSES" -Properties @("License", "SkuId")

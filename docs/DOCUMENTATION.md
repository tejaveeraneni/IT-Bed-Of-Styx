# IT Onboarding System Documentation

## Overview
This automated system streamlines the process of creating new user accounts in Microsoft 365/Azure AD through GitHub issue forms, GitHub Actions workflows, and PowerShell scripts. The system provides both demo and production modes for flexible deployment.

## System Architecture

```
GitHub Issue Form → GitHub Actions Workflow → PowerShell Script → Azure AD User Creation
```

## Components

### 1. GitHub Issue Form (user-creation-form.yml)

**Location:** `.github/ISSUE_TEMPLATE/user-creation-form.yml`

**Purpose:** Provides a standardized web form interface for collecting new user information through GitHub issues.

**Features:**
- Input validation for required fields
- Dropdown menus for standardized values
- Optional fields for additional user details
- Automatic issue creation with structured data

**Form Fields:**
- **First Name** (Required) - Text input for user's first name
- **Last Name** (Required) - Text input for user's last name
- **Location** (Required) - Dropdown selection (US/IN)
- **Job Title** (Optional) - Text input for user's position
- **Phone Number** (Optional) - Text input for mobile contact

**Technical Details:**
```yaml
name: Create a New User
description: Request creation of a new user account
title: "Create a New User: [FIRST NAME] [LAST NAME]"
labels: ["user"]
assignees:
  - oxmiq-dev

body:
  - type: input
    id: firstName
    attributes:
      label: First Name
      description: Enter the first name of the user.
    validations:
      required: true

  - type: input
    id: lastName
    attributes:
      label: Last Name
      description: Enter the last name of the user.
    validations:
      required: true

  - type: dropdown
    id: location
    attributes:
      label: Location
      description: Select where the user will be located.
      options:
        - US
        - IN
    validations:
      required: true

  - type: input
    id: jobTitle
    attributes:
      label: Job Title
      description: Enter the job title of the user.
    validations:
      required: false

  - type: input
    id: phoneNumber
    attributes:
      label: Phone Number
      description: Enter the phone number of the user.
    validations:
      required: false
```

**Access:** Navigate to your repository's Issues tab → New issue → "Create a New User" template

---

### 2. GitHub Actions Workflow (create-user.yml)

**Location:** `.github/workflows/create-user.yml`

**Purpose:** Processes GitHub issue form submissions and orchestrates the user creation workflow.

**Trigger:** Activated when a new issue is opened with the title containing "Create a New User"

**Workflow Steps:**

1. **Repository Checkout**
   - Downloads repository code for access to scripts

2. **Issue Form Data Parsing**
   - Extracts user data from issue body using JavaScript
   - Validates required fields (First Name, Last Name, Location)
   - Converts form data into structured format

3. **CSV File Generation**
   - Creates properly formatted CSV with user details
   - Generates standardized email addresses and usernames
   - Handles empty/optional fields appropriately

4. **Microsoft Graph Module Installation**
   - Installs required PowerShell modules for Azure AD interaction
   - Sets up authentication dependencies

5. **User Account Creation**
   - Executes PowerShell script for actual user creation
   - Handles authentication (demo/production modes)
   - Creates Azure AD user accounts

6. **Status Update**
   - Comments on the original GitHub issue with completion status

**Key Features:**
- **Field Validation:** Ensures required data is present before processing
- **Error Handling:** Stops workflow if critical data is missing
- **Flexible Authentication:** Supports both demo mode and production Azure authentication
- **Automated Reporting:** Updates GitHub issue with workflow status

**Data Processing Logic:**
```javascript
// Parsing functions extract data from issue body
const parseFormField = (body, fieldName) => {
  const regex = new RegExp(`### ${fieldName}\\s*\\n\\s*(.+?)\\s*(?=\\n###|\\n\\n|$)`, 'i');
  const match = body.match(regex);
  return match ? match[1].trim() : '';
};

// Username generation
$FirstNameFirstWord = ("$FirstName" -split '\s+')[0].ToLower()
$LastNameLastWord = ("$LastName" -split '\s+')[-1].ToLower()
$MailNickname = "$FirstNameFirstWord.$LastNameLastWord"
$UserPrincipalName = "$FirstNameFirstWord.$LastNameLastWord@oxmiq.ai"
```

**CSV Output Format:**
```
FirstName,LastName,JobTitle,PhoneNumber,DisplayName,MailNickname,UsageLocation,UserPrincipalName
John,Doe,Software Engineer,555-123-4567,John Doe,john.doe,US,john.doe@oxmiq.ai
```

---

### 3. PowerShell Onboarding Script (onboardingNewUser.ps1)

**Location:** `docs/IT/scripts/onboardingNewUser.ps1`

**Purpose:** Creates actual user accounts in Microsoft 365/Azure AD using data from the GitHub Actions workflow.

**Prerequisites:**
- Microsoft Graph PowerShell SDK installed
- Authenticated connection to Microsoft Graph
- Appropriate permissions for user creation

**Required Graph API Permissions:**
- `User.ReadWrite.All` - Create and modify user accounts
- `Directory.ReadWrite.All` - Access directory operations
- `Organization.Read.All` - Read organizational information

**Input:** CSV file at `docs/IT/scripts/NewAccounts.csv` with user details

**User Account Configuration:**
- **Default Password:** `Password123` (must be changed on first login)
- **Account Status:** Enabled
- **Email Format:** `firstname.lastname@oxmiq.ai`
- **Username Format:** `firstname.lastname`
- **Password Policy:** Force change on first sign-in

**Script Features:**
- **CSV Import:** Reads structured user data from workflow-generated CSV
- **Parameter Validation:** Handles optional fields and empty values
- **Error Handling:** Stops on critical errors during user creation
- **Flexible Configuration:** Supports both demo and production modes

**Core User Creation Logic:**
```powershell
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

    # Optional parameters (added if present)
    JobTitle          = $user.JobTitle
    MobilePhone       = $user.PhoneNumber
}

# Remove empty optional parameters
@('JobTitle', 'MobilePhone') | ForEach-Object {
    if (!$userParams[$_] -or $userParams[$_] -eq "_No response_" -or $userParams[$_].ToString().Trim() -eq "") {
        $userParams.Remove($_)
    }
}

$newUser = New-MgUser @userParams
```

## Usage Instructions

### For End Users (Requesting New Accounts)

1. **Navigate to GitHub Repository**
   - Go to the repository's Issues tab
   - Click "New issue"

2. **Select User Creation Form**
   - Choose "Create a New User" template

3. **Fill Out Form**
   - **Required:** First Name, Last Name, Location
   - **Optional:** Job Title, Phone Number
   - All fields validate on submission

4. **Submit Issue**
   - Click "Submit new issue"
   - Workflow automatically begins processing

5. **Monitor Progress**
   - Check issue comments for status updates
   - Workflow will comment when user creation is complete

### For Administrators (Managing the System)

1. **Test the Workflow**
   - Submit a test issue using the form
   - Monitor GitHub Actions for successful execution
   - Verify CSV generation and script execution

2. **Review Generated Data**
   - Check `docs/IT/scripts/NewAccounts.csv` for proper formatting
   - Verify username and email generation logic

#### Production Mode Setup

1. **Configure Azure App Registration**
   ```powershell
   # Create app registration in Azure AD
   # Grant required Graph API permissions:
   # - User.ReadWrite.All
   # - Directory.ReadWrite.All
   # - Organization.Read.All
   ```

2. **Set GitHub Repository Secrets**
   - `AZURE_CLIENT_ID` - Application (client) ID
   - `AZURE_CLIENT_SECRET` - Client secret value
   - `AZURE_TENANT_ID` - Directory (tenant) ID

3. **Enable Production Mode**
   - Repository secrets automatically enable production authentication
   - No code changes required

#### Troubleshooting

**Issue Form Not Appearing:**
- Verify file location: `.github/ISSUE_TEMPLATE/user-creation-form.yml`
- Check YAML syntax and indentation
- Ensure repository has Issues enabled

**Workflow Not Triggering:**
- Confirm issue title contains "Create a New User"
- Check workflow trigger conditions in `create-user.yml`
- Verify workflow is enabled in repository settings

**User Creation Failing:**
- Check Azure credentials in repository secrets
- Verify Graph API permissions
- Review PowerShell script error messages

**CSV Format Issues:**
- Ensure workflow generates proper CSV structure
- Check for special characters in user data
- Verify field mapping between workflow and script

---

## Security Considerations

### Data Handling
- **Sensitive Information:** Phone numbers and personal data are processed through GitHub
- **Access Control:** Repository access controls who can submit user creation requests
- **Audit Trail:** All requests are tracked through GitHub issues and workflow logs

### Authentication
- **Production Mode:** Uses Azure service principal authentication
- **Secret Management:** Credentials stored securely in GitHub repository secrets

### Permissions
- **Least Privilege:** Service principal should have minimal required permissions
- **Scope Limitation:** Permissions limited to user creation and directory access
- **Regular Review:** Periodically audit service principal permissions

---

## Customization Options

### Form Fields
Modify `.github/ISSUE_TEMPLATE/user-creation-form.yml` to:
- Add new required or optional fields
- Change validation rules
- Update dropdown options
- Modify form layout

### User Account Defaults
Edit `onboardingNewUser.ps1` to customize:
- Default password requirements
- Account settings and properties
- Username generation logic
- Domain and email format

### Workflow Behavior
Adjust `.github/workflows/create-user.yml` for:
- Different trigger conditions
- Additional validation steps
- Custom notification logic
- Integration with other systems

---

## Support and Maintenance

### Regular Tasks
- **Monitor Workflow Success Rate** through GitHub Actions
- **Review User Creation Logs** for errors or issues
- **Update PowerShell Modules** periodically
- **Audit Service Principal Permissions** quarterly

### Common Maintenance
- **Update Location Options** in issue form as needed
- **Refresh Azure Credentials** before expiration
- **Review and Update Default Password Policy**
- **Update Email Domain** if organization changes

### Todo Tasks

- Update script to work with licenses
- Add in more validation for edge scripts
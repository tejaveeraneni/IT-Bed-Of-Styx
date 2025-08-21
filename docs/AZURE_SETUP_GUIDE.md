# Azure AD Service Principal Setup for GitHub Actions

## Overview
This guide helps you set up authentication so your GitHub Action can create users in Azure AD.

## Step 1: Create an App Registration

1. **Go to Azure Portal**
   - Navigate to https://portal.azure.com
   - Sign in with your admin account

2. **Navigate to App Registrations**
   - In the left menu, click "Azure Active Directory"
   - Click "App registrations"
   - Click "New registration"

3. **Register Your Application**
   - **Name**: `GitHub-Actions-User-Creation`
   - **Supported account types**: Select "Accounts in this organizational directory only"
   - **Redirect URI**: Leave blank
   - Click "Register"

4. **Note Down Important Values**
   After registration, you'll see:
   - **Application (client) ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - **Directory (tenant) ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

   ⚠️ **Save these values** - you'll need them later!

## Step 2: Create a Client Secret

1. **In your app registration**:
   - Click "Certificates & secrets"
   - Click "New client secret"
   - **Description**: `GitHub Actions Secret`
   - **Expires**: Choose "24 months" (or your preference)
   - Click "Add"

2. **Copy the Secret Value**
   - ⚠️ **IMPORTANT**: Copy the secret VALUE immediately (not the ID)
   - You won't be able to see it again after you leave this page
   - It looks like: `abc123~defGHI456-jklMNO789_pqrSTU012`

## Step 3: Assign API Permissions

1. **In your app registration**:
   - Click "API permissions"
   - Click "Add a permission"
   - Click "Microsoft Graph"
   - Click "Application permissions" (not Delegated)

2. **Select Required Permissions**:
   - `User.ReadWrite.All` - Create and manage users
   - `Directory.ReadWrite.All` - Read/write directory data
   - `Organization.Read.All` - Read organization info

3. **Grant Admin Consent**:
   - Click "Grant admin consent for [Your Organization]"
   - Click "Yes" to confirm
   - ✅ All permissions should show "Granted for [Your Organization]"

## Step 4: Add Secrets to GitHub Repository

1. **Go to your GitHub repository**
   - Navigate to your repository on github.com
   - Click "Settings" tab
   - Click "Secrets and variables" → "Actions"

2. **Add Repository Secrets**
   Click "New repository secret" for each of these:

   | Secret Name | Value | Description |
   |-------------|--------|-------------|
   | `AZURE_CLIENT_ID` | Your Application (client) ID | The app registration ID |
   | `AZURE_CLIENT_SECRET` | Your client secret value | The secret you created |
   | `AZURE_TENANT_ID` | Your Directory (tenant) ID | Your Azure AD tenant ID |

## Step 5: Test Your Setup

You can test if your service principal works by running this PowerShell locally:

```powershell
# Install Microsoft Graph module if not already installed
Install-Module Microsoft.Graph -Force -AllowClobber -Scope CurrentUser

# Connect using service principal
$ClientId = "YOUR_CLIENT_ID"
$ClientSecret = "YOUR_CLIENT_SECRET"
$TenantId = "YOUR_TENANT_ID"

$SecureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($ClientId, $SecureSecret)

Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $Credential

# Test if connection works
Get-MgUser -Top 1
```

## Security Best Practices

- ✅ **Never** commit secrets to your code
- ✅ Use GitHub repository secrets for sensitive data
- ✅ Regularly rotate client secrets (every 6-12 months)
- ✅ Use principle of least privilege (only required permissions)
- ✅ Monitor service principal activity in Azure AD logs

## Troubleshooting

### Common Issues:
- **"Insufficient privileges"**: Admin consent not granted
- **"Invalid client secret"**: Secret expired or incorrect
- **"Application not found"**: Wrong client ID or tenant ID

### Where to Find Help:
- Azure AD audit logs: Shows authentication attempts
- GitHub Actions logs: Shows detailed error messages
- Microsoft Graph permissions documentation

# Testing Your GitHub Action Authentication

## Understanding GitHub Repository Secrets

**What are GitHub Secrets?**
- Encrypted environment variables stored in your repository
- Only accessible during GitHub Actions workflow runs
- Perfect for storing sensitive data like passwords, API keys, certificates

## How to Add Secrets

1. **Navigate to Your Repository**
   - Go to https://github.com/tejaveeraneni/IT-Bed-Of-Styx
   - Click the "Settings" tab (far right)

2. **Go to Secrets Section**
   - In the left sidebar, click "Secrets and variables"
   - Click "Actions"

3. **Add New Secret**
   - Click "New repository secret"
   - Enter the secret name (e.g., `AZURE_CLIENT_ID`)
   - Enter the secret value
   - Click "Add secret"

## What Each Secret Contains

```
AZURE_CLIENT_ID = "12345678-1234-1234-1234-123456789abc"
AZURE_CLIENT_SECRET = "abc123~defGHI456-jklMNO789_pqrSTU012"
AZURE_TENANT_ID = "87654321-4321-4321-4321-cba987654321"
```

## How GitHub Actions Access Secrets

In your workflow, secrets are accessed using this syntax:
```yaml
$ClientId = "${{ secrets.AZURE_CLIENT_ID }}"
```

**Important Security Notes:**
- ✅ Secrets are encrypted at rest
- ✅ Only visible to workflows in the same repository
- ✅ Never logged or displayed in workflow output
- ❌ Can't be accessed from forked repositories (security feature)

## Test Mode (Without Real Secrets)

If you want to test the workflow without setting up Azure authentication yet, I can create a "demo mode" version:

```powershell
# Check if running in demo mode
if (-not $ClientId) {
    Write-Host "🧪 Running in DEMO MODE"
    Write-Host "To enable real user creation, set up Azure authentication"
    Write-Host "See docs/AZURE_SETUP_GUIDE.md for instructions"

    # Simulate user creation
    Write-Host "Would create user: $firstName $lastName"
    Write-Host "Email: $firstName.$lastName@oxmiq.ai"
    Write-Host "Location: $location"
} else {
    # Real authentication and user creation
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $Credential
    # ... actual user creation code
}
```

This way you can test the form parsing and CSV creation without needing Azure setup first.

## Why This Architecture is Secure

1. **Secrets Never in Code**: Authentication details never appear in your repository
2. **Encrypted Storage**: GitHub encrypts all secrets
3. **Limited Access**: Only your workflows can access the secrets
4. **Audit Trail**: GitHub logs when secrets are used
5. **Rotation Ready**: Easy to update secrets without changing code

Would you like me to create a demo mode version first, or do you want to go straight to setting up the Azure authentication?

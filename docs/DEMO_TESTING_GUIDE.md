# 🧪 Testing Your GitHub Actions Demo Workflow

## 🎯 What You'll See

Your workflow is now ready to test in **DEMO MODE**! This means:
- ✅ All form parsing works
- ✅ CSV file creation works
- ✅ Simulated user creation process
- ✅ No Azure authentication required

## 📝 How to Test

### Step 1: Create a Test Issue
1. Go to your repository: https://github.com/tejaveeraneni/IT-Bed-Of-Styx
2. Click "Issues" tab
3. Click "New issue"
4. Select "New User Creation Form"

### Step 2: Fill Out the Form
Try filling out the form with test data like:
- **First Name**: John
- **Last Name**: Doe
- **Location**: United States
- **Job Title**: Software Engineer
- **Phone Number**: 555-123-4567
- **VPN Access**: ✅ Yes, this user needs VPN access

### Step 3: Submit and Watch the Magic! 🪄

After submitting, you'll see:

1. **GitHub Actions automatically triggers** (check the "Actions" tab)
2. **Workflow runs through all steps:**
   - ✅ Parses your form data
   - ✅ Creates CSV file
   - ✅ Installs PowerShell modules
   - ✅ Simulates user creation
   - ✅ Posts detailed results back to your issue

3. **Automatic comment appears** showing:
   - Parsed user details
   - Generated username/email
   - Simulated Azure AD actions
   - Next steps for production mode

## 🔍 What to Check

### In the GitHub Actions Tab:
- Look for "Create New User from Issue Form" workflow
- Click on the run to see detailed logs
- Each step shows exactly what it's doing

### In the Issue:
- Should get an automatic comment with full user details
- Label should be added: `demo-completed`
- Shows what would happen in production

## 🐛 Troubleshooting

### Issue doesn't trigger workflow?
- ✅ Make sure issue has the "user" label
- ✅ Check that the issue was created from the form (not manually)

### Workflow fails?
- ✅ Check the Actions tab for error details
- ✅ Form fields might be missing or incorrectly parsed
- ✅ YAML syntax issues in the workflow

### Form parsing issues?
- ✅ Make sure you're using the issue form template
- ✅ Don't edit the issue after creation (breaks parsing)

## 🚀 Ready for Production?

Once you're happy with the demo, follow these guides to enable real user creation:
1. **Azure Setup**: `docs/AZURE_SETUP_GUIDE.md`
2. **GitHub Secrets**: `docs/GITHUB_SECRETS_GUIDE.md`

## 📊 What the Demo Shows

The demo mode simulates:
```
🧪 RUNNING IN DEMO MODE
==================================================
📋 Processing user creation request...

👤 USER DETAILS:
   Full Name: John Doe
   Username: john.doe
   Email: john.doe@oxmiq.ai
   Job Title: Software Engineer
   Phone: 555-123-4567
   Location: United States
   VPN Access: Yes, this user needs VPN access

🔧 SIMULATED ACTIONS:
   ✅ Would connect to Microsoft Graph
   ✅ Would create user account: john.doe@oxmiq.ai
   ✅ Would set default password: Password123 (change required)
   ✅ Would assign usage location: United States
   ✅ Would enable account
   ✅ Would configure VPN access

📋 AVAILABLE LICENSES (SIMULATED):
   1. Microsoft 365 Business Premium - 15 available
   2. Microsoft 365 E3 - 8 available
   3. Power BI Pro - 25 available
   ✅ Would prompt admin to select license
   ✅ Would assign selected license to user

✅ DEMO USER CREATION COMPLETED!
```

This gives you confidence that everything works before setting up Azure authentication!

## 🎓 Learning Outcomes

By testing this demo, you'll learn:
- ✅ How GitHub Actions triggers work
- ✅ How form data flows through workflows
- ✅ How PowerShell runs in GitHub Actions
- ✅ How to parse and validate form input
- ✅ How workflows can comment on issues
- ✅ How to structure a multi-step automation process

Go ahead and create your first test issue! 🚀

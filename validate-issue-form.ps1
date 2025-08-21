# GitHub Issue Form YAML Validator
# Run this PowerShell script to validate your issue form before pushing

param(
    [string]$FilePath = ".github/ISSUE_TEMPLATE/user-creation-form.yml"
)

function Test-IssueFormYaml {
    param([string]$Path)

    Write-Host "🔍 Validating: $Path" -ForegroundColor Cyan
    Write-Host ("-" * 50)

    if (!(Test-Path $Path)) {
        Write-Host "❌ File not found: $Path" -ForegroundColor Red
        return $false
    }

    try {
        # Read the file content
        $content = Get-Content $Path -Raw

        # Basic YAML structure checks
        if ($content -match "name:\s*(.+)") {
            $name = $matches[1].Trim()
            Write-Host "📋 Form name: $name" -ForegroundColor Green
        }
        else {
            Write-Host "❌ Missing 'name' field" -ForegroundColor Red
            return $false
        }

        if ($content -match "description:\s*(.+)") {
            $description = $matches[1].Trim()
            Write-Host "📝 Description: $description" -ForegroundColor Green
        }
        else {
            Write-Host "❌ Missing 'description' field" -ForegroundColor Red
            return $false
        }

        if ($content -match "body:") {
            Write-Host "✅ Found 'body' section" -ForegroundColor Green
        }
        else {
            Write-Host "❌ Missing 'body' field" -ForegroundColor Red
            return $false
        }

        # Count form fields
        $fieldCount = ([regex]"- type:").Matches($content).Count
        Write-Host "🔧 Number of form fields: $fieldCount" -ForegroundColor Green

        # Check for common issues
        $issues = @()

        # Check for unclosed brackets or quotes
        $openBrackets = ([regex]"\[").Matches($content).Count
        $closeBrackets = ([regex]"\]").Matches($content).Count
        if ($openBrackets -ne $closeBrackets) {
            $issues += "Unmatched brackets"
        }

        # Check for consistent indentation
        $lines = $content -split "`n"
        $inconsistentIndent = $false
        foreach ($line in $lines) {
            if ($line -match "^\s*- type:" -and $line -notmatch "^  - type:") {
                $inconsistentIndent = $true
                break
            }
        }
        if ($inconsistentIndent) {
            $issues += "Inconsistent indentation in body items"
        }

        if ($issues.Count -eq 0) {
            Write-Host "✅ Basic YAML structure validation passed!" -ForegroundColor Green
            Write-Host "💡 Note: This only validates basic structure. Push to GitHub to see the actual form." -ForegroundColor Yellow
            return $true
        }
        else {
            Write-Host "⚠️  Potential issues found:" -ForegroundColor Yellow
            foreach ($issue in $issues) {
                Write-Host "   - $issue" -ForegroundColor Yellow
            }
            return $false
        }

    }
    catch {
        Write-Host "❌ Error reading file: $_" -ForegroundColor Red
        return $false
    }
}

# Run the validation
$result = Test-IssueFormYaml -Path $FilePath

if ($result) {
    Write-Host "`n🚀 Ready to push!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`n🔧 Fix issues before pushing" -ForegroundColor Red
    exit 1
}

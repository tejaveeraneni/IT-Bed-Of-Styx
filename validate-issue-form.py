#!/usr/bin/env python3
"""
Simple YAML validator for GitHub issue forms
Run this script to validate your issue form YAML syntax before pushing
"""

import yaml
import sys
import os

def validate_issue_form(file_path):
    """Validate GitHub issue form YAML file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = yaml.safe_load(file)

        # Basic structure validation
        required_fields = ['name', 'description', 'body']
        missing_fields = [field for field in required_fields if field not in content]

        if missing_fields:
            print(f"❌ Missing required fields: {', '.join(missing_fields)}")
            return False

        # Validate body structure
        if not isinstance(content['body'], list):
            print("❌ 'body' must be a list")
            return False

        # Validate each body item
        for i, item in enumerate(content['body']):
            if 'type' not in item:
                print(f"❌ Body item {i+1} is missing 'type' field")
                return False

            item_type = item['type']
            if item_type not in ['input', 'textarea', 'dropdown', 'checkboxes', 'markdown']:
                print(f"❌ Body item {i+1} has invalid type: {item_type}")
                return False

        print("✅ YAML syntax is valid!")
        print("✅ Basic GitHub issue form structure is valid!")
        print(f"📋 Form name: {content['name']}")
        print(f"📝 Description: {content['description']}")
        print(f"🔧 Number of form fields: {len([item for item in content['body'] if item['type'] != 'markdown'])}")

        return True

    except yaml.YAMLError as e:
        print(f"❌ YAML syntax error: {e}")
        return False
    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    # Default to the issue form in this repository
    default_path = ".github/ISSUE_TEMPLATE/user-creation-form.yml"
    file_path = sys.argv[1] if len(sys.argv) > 1 else default_path

    if not os.path.exists(file_path):
        print(f"❌ File not found: {file_path}")
        print("Usage: python validate-issue-form.py [path-to-yaml-file]")
        sys.exit(1)

    print(f"🔍 Validating: {file_path}")
    print("-" * 50)

    success = validate_issue_form(file_path)
    sys.exit(0 if success else 1)

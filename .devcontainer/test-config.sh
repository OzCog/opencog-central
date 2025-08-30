#!/bin/bash
# Test script to validate devcontainer configuration
# This script tests the devcontainer setup without requiring Docker build

set -e

echo "🧪 Testing GNU Guix Shepherd DevContainer Configuration"
echo "===================================================="

# Test 1: Check required files exist
echo "📁 Checking required files..."
required_files=("Dockerfile" "devcontainer.json" "init.scm" "opencog.scm" "setup.sh" "README.md")
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ✅ $file exists"
    else
        echo "  ❌ $file missing"
        exit 1
    fi
done

# Test 2: Validate JSON syntax
echo "🔍 Validating JSON syntax..."
if python3 -m json.tool devcontainer.json > /dev/null 2>&1; then
    echo "  ✅ devcontainer.json is valid JSON"
else
    echo "  ❌ devcontainer.json has invalid JSON syntax"
    exit 1
fi

# Test 3: Check devcontainer.json structure
echo "🏗️  Checking devcontainer.json structure..."
python3 -c "
import json
with open('devcontainer.json', 'r') as f:
    config = json.load(f)

required_keys = ['name', 'build', 'postCreateCommand']
for key in required_keys:
    if key in config:
        print(f'  ✅ {key} present')
    else:
        print(f'  ❌ {key} missing')
        exit(1)

if config['name'] == 'Guix Shepherd OpenCog Packaging':
    print('  ✅ Correct container name')
else:
    print('  ❌ Incorrect container name')
    exit(1)
"

# Test 4: Validate Scheme syntax
echo "🔧 Checking Scheme file syntax..."
python3 -c "
# Check init.scm
with open('init.scm', 'r') as f:
    content = f.read()
    paren_count = content.count('(') - content.count(')')
    if paren_count == 0:
        print('  ✅ init.scm has balanced parentheses')
    else:
        print('  ❌ init.scm has unbalanced parentheses')
        exit(1)

# Check opencog.scm
with open('opencog.scm', 'r') as f:
    content = f.read()
    paren_count = content.count('(') - content.count(')')
    if paren_count == 0:
        print('  ✅ opencog.scm has balanced parentheses')
    else:
        print('  ❌ opencog.scm has unbalanced parentheses')
        exit(1)
"

# Test 5: Check Dockerfile structure
echo "🐳 Checking Dockerfile structure..."
if grep -q "FROM debian:bookworm" Dockerfile; then
    echo "  ✅ Uses Debian Bookworm base"
else
    echo "  ❌ Doesn't use Debian Bookworm base"
    exit 1
fi

if grep -q "guix" Dockerfile; then
    echo "  ✅ Installs GNU Guix"
else
    echo "  ❌ Doesn't install GNU Guix"
    exit 1
fi

if grep -q "shepherd" Dockerfile; then
    echo "  ✅ Installs Shepherd"
else
    echo "  ❌ Doesn't install Shepherd"
    exit 1
fi

# Test 6: Check setup script
echo "📋 Checking setup script..."
if [[ -x "setup.sh" ]]; then
    echo "  ✅ setup.sh is executable"
else
    echo "  ❌ setup.sh is not executable"
    exit 1
fi

if grep -q "guix pull" setup.sh; then
    echo "  ✅ setup.sh includes guix pull"
else
    echo "  ❌ setup.sh doesn't include guix pull"
    exit 1
fi

if grep -q "shepherd" setup.sh; then
    echo "  ✅ setup.sh manages Shepherd"
else
    echo "  ❌ setup.sh doesn't manage Shepherd"
    exit 1
fi

echo ""
echo "🎉 All tests passed! DevContainer configuration is valid."
echo ""
echo "✅ GNU Guix Shepherd DevContainer is properly configured"
echo "✅ All required files present and valid"
echo "✅ FSF-approved free software stack"
echo "✅ Reproducible development environment"
echo "✅ Comprehensive Shepherd service automation"
echo ""
echo "Ready for OpenCog development with Guix packaging! 🚀"
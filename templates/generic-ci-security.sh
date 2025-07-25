#!/bin/bash
# Generic CI Security Script for Agent OS
#
# This script provides security checks that can be integrated into any CI system.
# It performs the same security scans as the GitLab and GitHub templates.
#
# Usage:
# Make this script executable: chmod +x generic-ci-security.sh
# Run in your CI pipeline: ./generic-ci-security.sh
#
# Exit codes:
# 0 - All security checks passed
# 1 - Security vulnerabilities found
# 2 - Script error
# 3 - Compromised packages found

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "🔒 Agent OS Security Scan Starting..."
echo "======================================"

# Track if any security issues are found
SECURITY_ISSUES=0

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Scan for known compromised package versions
echo -e "\n${YELLOW}1. Scanning for compromised packages...${NC}"
VULN_REGEX='eslint-config-prettier@\(8\.10\.1\|9\.1\.1\|10\.1\.\(6\|7\)\)|eslint-plugin-prettier@4\.2\.\(2\|3\)|synckit@0\.11\.9|@pkgr/core@0\.2\.8|napi-postinstall@0\.3\.1|got-fetch@5\.1\.\(11\|12\)|is@\(3\.3\.1\|5\.0\.0\)'

matches=$(grep -R --line-number -E "$VULN_REGEX" --exclude-dir=.git --exclude='*.lock' . 2>/dev/null || true)

if [[ -n "$matches" ]]; then
    echo -e "${RED}❌ Compromised packages found:${NC}"
    echo "$matches"
    SECURITY_ISSUES=3
else
    echo -e "${GREEN}✅ No compromised package versions found.${NC}"
fi

# 2. Run Trivy scan if available
echo -e "\n${YELLOW}2. Running Trivy vulnerability scan...${NC}"
if command_exists trivy; then
    if trivy fs --severity HIGH,CRITICAL --exit-code 1 . 2>/dev/null; then
        echo -e "${GREEN}✅ Trivy scan passed${NC}"
    else
        echo -e "${RED}❌ Trivy found vulnerabilities${NC}"
        SECURITY_ISSUES=1
    fi
else
    echo "⚠️  Trivy not installed. Install from: https://github.com/aquasecurity/trivy"
fi

# 3. Language-specific security scans
echo -e "\n${YELLOW}3. Running language-specific security scans...${NC}"

# Node.js
if [ -f "package-lock.json" ]; then
    echo "📦 Scanning Node.js dependencies..."
    if command_exists npm; then
        if npm audit --audit-level=moderate 2>/dev/null; then
            echo -e "${GREEN}✅ npm audit passed${NC}"
        else
            echo -e "${RED}❌ npm audit found vulnerabilities${NC}"
            SECURITY_ISSUES=1
        fi
    else
        echo "⚠️  npm not found"
    fi
fi

# Ruby
if [ -f "Gemfile.lock" ]; then
    echo "💎 Scanning Ruby dependencies..."
    if command_exists bundle; then
        if gem list -i bundle-audit >/dev/null 2>&1 || gem install bundle-audit; then
            if bundle audit check --update 2>/dev/null; then
                echo -e "${GREEN}✅ bundle audit passed${NC}"
            else
                echo -e "${RED}❌ bundle audit found vulnerabilities${NC}"
                SECURITY_ISSUES=1
            fi
        fi
    else
        echo "⚠️  bundler not found"
    fi
fi

# Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "🐍 Scanning Python dependencies..."
    if command_exists pip3 || command_exists pip; then
        PIP_CMD=$(command_exists pip3 && echo "pip3" || echo "pip")
        if $PIP_CMD show pip-audit >/dev/null 2>&1 || $PIP_CMD install pip-audit; then
            if pip-audit 2>/dev/null; then
                echo -e "${GREEN}✅ pip-audit passed${NC}"
            else
                echo -e "${RED}❌ pip-audit found vulnerabilities${NC}"
                SECURITY_ISSUES=1
            fi
        fi
    else
        echo "⚠️  pip not found"
    fi
fi

# 4. Secret detection
echo -e "\n${YELLOW}4. Scanning for exposed secrets...${NC}"
if command_exists trufflehog; then
    if trufflehog git file://. --only-verified --fail 2>/dev/null; then
        echo -e "${GREEN}✅ No verified secrets found${NC}"
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 183 ]; then
            echo -e "${RED}❌ Verified secrets found in repository!${NC}"
            SECURITY_ISSUES=1
        else
            echo -e "${YELLOW}⚠️  TruffleHog scan had issues (exit code: $EXIT_CODE)${NC}"
        fi
    fi
else
    echo "⚠️  TruffleHog not installed. Install from: https://github.com/trufflesecurity/trufflehog"
fi

# 5. SAST scan
echo -e "\n${YELLOW}5. Running SAST scan...${NC}"
if command_exists semgrep; then
    if semgrep --config=auto --severity=ERROR --error 2>/dev/null; then
        echo -e "${GREEN}✅ Semgrep SAST scan passed${NC}"
    else
        echo -e "${RED}❌ Semgrep found security issues${NC}"
        SECURITY_ISSUES=1
    fi
else
    echo "⚠️  Semgrep not installed. Install from: https://github.com/returntocorp/semgrep"
fi

# Summary
echo -e "\n======================================"
echo "🔒 Security Scan Summary"
echo "======================================"

if [ $SECURITY_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ All security checks passed!${NC}"
    exit 0
elif [ $SECURITY_ISSUES -eq 3 ]; then
    echo -e "${RED}❌ CRITICAL: Compromised packages detected!${NC}"
    echo "Remove or update the compromised packages before proceeding."
    exit 3
else
    echo -e "${RED}❌ Security vulnerabilities found!${NC}"
    echo "Please fix the issues above before merging."
    exit 1
fi
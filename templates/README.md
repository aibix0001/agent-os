# Agent OS CI/CD Security Templates

This directory contains security scanning templates for various CI/CD platforms. These templates ensure consistent security checks across all projects using Agent OS.

## ⚠️ CRITICAL: Mandatory Security Scan for JavaScript Projects

**All JavaScript/Node.js projects MUST include the mandatory supply chain security scan** to detect known compromised packages. This is not optional due to active supply chain attacks.

### CVE-2025-54313: Supply Chain Compromise Alert

In July 2025, several popular npm packages were compromised with embedded malicious code (Scavenger malware) that targets Windows systems. The attack affects:

- **eslint-config-prettier**: versions 8.10.1, 9.1.1, 10.1.6, 10.1.7 (30M+ weekly downloads)
- **eslint-plugin-prettier**: versions 4.2.2, 4.2.3
- **synckit**: version 0.11.9
- **Additional packages**: @pkgr/core@0.2.8, napi-postinstall@0.3.1, got-fetch@5.1.11-12, is@3.3.1,5.0.0

The malware can harvest credentials, files, and execute arbitrary code on compromised systems.

**Mandatory Action**: Include `mandatory-javascript-supply-chain-scan.yml` as the FIRST security check in all JavaScript project pipelines.

## Available Templates

### 1. Mandatory JavaScript Supply Chain Scan (`mandatory-javascript-supply-chain-scan.yml`) 🚨

**REQUIRED for all JavaScript/Node.js projects.** This template detects known compromised packages in the npm supply chain.

**Features:**
- Scans for CVE-2025-54313 affected packages
- Checks package.json, package-lock.json, yarn.lock, and all source files
- Blocks pipeline execution if compromised packages are found
- Provides detailed remediation instructions

**Usage (GitLab CI):**
```yaml
# This MUST be the first include
include:
  - local: '.agent-os/templates/mandatory-javascript-supply-chain-scan.yml'
  - local: '.agent-os/templates/gitlab-ci-security.yml'  # Other security scans

stages:
  - critical-security  # From mandatory scan
  - security
  - build
  - test
  - deploy
```

### 2. GitLab CI Security Template (`gitlab-ci-security.yml`)

A comprehensive security scanning template for GitLab CI pipelines that includes:
- Compromised package detection
- Trivy vulnerability scanning
- Language-specific security scans (npm, bundle, pip)
- Secret detection with TruffleHog
- SAST scanning with Semgrep
- License compliance checking

**Usage:**
```yaml
# In your .gitlab-ci.yml
include:
  - local: '.agent-os/templates/gitlab-ci-security.yml'

# Or from a remote repository
include:
  - project: 'your-group/agent-os'
    ref: main
    file: '/templates/gitlab-ci-security.yml'
```

### 3. GitHub Actions Security Template (`github-actions-security.yml`)

A reusable workflow for GitHub Actions that provides:
- All the same security checks as GitLab
- SARIF upload for GitHub Security tab integration
- CodeQL analysis for supported languages
- Matrix builds for multi-language projects

**Usage:**
```yaml
# In .github/workflows/security.yml
name: Security Scan
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  security:
    uses: your-org/agent-os/.github/workflows/security-template.yml@main
```

### 4. Generic CI Security Script (`generic-ci-security.sh`)

A standalone bash script that can be integrated into any CI system:
- Jenkins
- CircleCI
- Travis CI
- Bamboo
- Any other CI platform

**Usage:**
```bash
# In your CI pipeline
chmod +x .agent-os/templates/generic-ci-security.sh
./.agent-os/templates/generic-ci-security.sh
```

## Security Checks Included

All templates perform the following security checks:

1. **Compromised Package Detection**
   - Scans for known malicious package versions
   - Exits with code 3 if compromised packages found

2. **Vulnerability Scanning**
   - Trivy scan for HIGH and CRITICAL vulnerabilities
   - Language-specific vulnerability checks

3. **Secret Detection**
   - TruffleHog scan for exposed credentials
   - Only reports verified secrets to reduce false positives

4. **Static Application Security Testing (SAST)**
   - Semgrep scan with auto-configuration
   - CodeQL analysis (GitHub Actions only)

5. **License Compliance**
   - Checks for license compatibility
   - Helps maintain open source compliance

## Exit Codes

- `0` - All security checks passed
- `1` - Security vulnerabilities found
- `2` - Script/pipeline error
- `3` - Compromised packages detected (critical)

## Customization

You can customize these templates by:
1. Copying them to your project's `.agent-os/templates/` directory
2. Modifying the security checks as needed
3. Adding project-specific security requirements

## Adding New Security Checks

To add new security checks:
1. Add the check to all three templates
2. Ensure consistent behavior across platforms
3. Document the new check in this README
4. Update the exit codes if needed

## JavaScript Project Requirements

For JavaScript/Node.js projects, the following security measures are **MANDATORY**:

1. **Include the mandatory supply chain scan** as the first security check
2. **Use the critical-security stage** before any other pipeline stages
3. **Block compromised packages** - Exit code 3 indicates supply chain compromise
4. **Update immediately** if compromised packages are detected
5. **Rotate credentials** if your pipeline ran with compromised packages

## Best Practices

1. **Run Early**: Security scans should run before build/test stages
2. **Fail Fast**: Stop the pipeline on critical security issues
3. **Regular Updates**: Keep scanning tools and vulnerability databases updated
4. **Monitor Results**: Review security scan results regularly
5. **Fix Promptly**: Address security issues before merging code
6. **JavaScript Projects**: Always include the mandatory supply chain scan first

## Tool Installation

For the generic script or custom CI environments, install these tools:

```bash
# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# TruffleHog
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

# Semgrep
pip install semgrep

# Language-specific tools
npm install -g npm-audit
gem install bundle-audit
pip install pip-audit
```

## Support

For issues or questions about these security templates:
1. Check the Agent OS documentation
2. Review the security standards at `@~/.agent-os/standards/security.md`
3. Submit issues to the Agent OS repository
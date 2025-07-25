# Agent OS CI/CD Security Templates

This directory contains security scanning templates for various CI/CD platforms. These templates ensure consistent security checks across all projects using Agent OS.

## Available Templates

### 1. GitLab CI Security Template (`gitlab-ci-security.yml`)

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

### 2. GitHub Actions Security Template (`github-actions-security.yml`)

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

### 3. Generic CI Security Script (`generic-ci-security.sh`)

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

## Best Practices

1. **Run Early**: Security scans should run before build/test stages
2. **Fail Fast**: Stop the pipeline on critical security issues
3. **Regular Updates**: Keep scanning tools and vulnerability databases updated
4. **Monitor Results**: Review security scan results regularly
5. **Fix Promptly**: Address security issues before merging code

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
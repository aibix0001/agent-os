# Security Standards

> Version: 1.0.0
> Last Updated: 2025-07-25
> Scope: Global security standards

## Context

This file is part of the Agent OS standards system. These global security standards are referenced by all product codebases and provide default security guidelines. Individual projects may extend or override these standards in their `.agent-os/product/security.md` file.

## Core Security Principles

### Security by Design
- Integrate security considerations from the planning phase
- Threat model new features before implementation
- Follow the principle of least privilege
- Implement defense in depth

### Secure Coding Practices
- Never hardcode secrets, API keys, or credentials
- Use environment variables for sensitive configuration
- Sanitize and validate all user inputs
- Implement proper error handling without exposing sensitive information
- Use parameterized queries to prevent SQL injection
- Enable HTTPS/TLS for all communications

### Authentication & Authorization
- Implement strong password policies
- Use secure session management
- Enable multi-factor authentication where possible
- Follow OAuth 2.0/OpenID Connect standards for third-party auth
- Implement rate limiting on authentication endpoints

## Supply Chain Security

### Dependency Management
- Regularly audit dependencies for known vulnerabilities
- Keep dependencies up to date with security patches
- Use lock files (package-lock.json, Gemfile.lock, etc.)
- Verify package integrity when possible
- Prefer well-maintained packages with active security policies

### Vulnerability Scanning
Integrate automated security scanning in your CI/CD pipeline:

```bash
# Example: npm audit for Node.js projects
npm audit --audit-level=moderate

# Example: bundle audit for Ruby projects
bundle audit check --update

# Example: pip-audit for Python projects
pip-audit

# Example: Using Trivy for comprehensive scanning
trivy fs --severity HIGH,CRITICAL .
```

## CI/CD Security Integration

Agent OS provides ready-to-use security templates for various CI/CD platforms. These templates are available in the `templates/` directory:

- **GitLab CI**: `@agent-os/templates/gitlab-ci-security.yml`
- **GitHub Actions**: `@agent-os/templates/github-actions-security.yml`
- **Generic Script**: `@agent-os/templates/generic-ci-security.sh`

### Using Agent OS Security Templates

#### GitLab CI
```yaml
# Include the Agent OS security template in your .gitlab-ci.yml
include:
  - local: '.agent-os/templates/gitlab-ci-security.yml'

# Your other pipeline stages follow...
stages:
  - security  # From the template
  - build
  - test
  - deploy
```

#### GitHub Actions
```yaml
# Create .github/workflows/security.yml
name: Security Scan
on:
  push:
    branches: [ main, develop ]
  pull_request:

jobs:
  # Copy the security jobs from the template
  # Or use as a reusable workflow if in same org
  security:
    uses: ./.github/workflows/security-template.yml
```

### Custom Implementation Examples

If you prefer to implement security checks directly in your pipeline:

#### GitHub Actions Example
```yaml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        severity: 'CRITICAL,HIGH'
        exit-code: '1'
    
    - name: Run npm audit
      if: ${{ hashFiles('package-lock.json') != '' }}
      run: npm audit --audit-level=moderate
      
    - name: Run bundle audit
      if: ${{ hashFiles('Gemfile.lock') != '' }}
      run: |
        gem install bundle-audit
        bundle audit check --update
```

### GitLab CI/CD Example
```yaml
security-scan:
  stage: test
  script:
    # Install and run Trivy
    - apt-get update && apt-get install -y wget apt-transport-https gnupg lsb-release
    - wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
    - echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
    - apt-get update && apt-get install -y trivy
    - trivy fs --exit-code 1 --severity HIGH,CRITICAL .
    
    # Language-specific scans
    - |
      if [ -f "package-lock.json" ]; then
        npm audit --audit-level=moderate
      fi
    - |
      if [ -f "Gemfile.lock" ]; then
        gem install bundle-audit
        bundle audit check --update
      fi
    - |
      if [ -f "requirements.txt" ]; then
        pip install pip-audit
        pip-audit
      fi
  only:
    - merge_requests
    - main
    - develop
```

## Security Testing

### Required Security Tests
- Input validation tests
- Authentication/authorization tests
- Session management tests
- Error handling tests
- Security regression tests

### Security Test Template
```ruby
# Example security test for input validation
describe "Security: Input Validation" do
  it "sanitizes user input to prevent XSS" do
    malicious_input = '<script>alert("XSS")</script>'
    result = sanitize_input(malicious_input)
    expect(result).not_to include('<script>')
  end
  
  it "prevents SQL injection in search queries" do
    malicious_query = "'; DROP TABLE users; --"
    expect { search_users(malicious_query) }.not_to raise_error
    expect(User.count).to be > 0  # Table should still exist
  end
end
```

## Security Checklist for Development

Before deploying any code:
- [ ] No hardcoded secrets or credentials
- [ ] All user inputs are validated and sanitized
- [ ] Authentication and authorization properly implemented
- [ ] Security headers configured (CSP, X-Frame-Options, etc.)
- [ ] Dependencies scanned for vulnerabilities
- [ ] Security tests written and passing
- [ ] Error messages don't expose sensitive information
- [ ] Logging doesn't include sensitive data
- [ ] HTTPS/TLS properly configured
- [ ] Rate limiting implemented where appropriate

## Incident Response

### Security Issue Handling
1. **Immediate Response**: Assess severity and impact
2. **Containment**: Implement temporary fixes if needed
3. **Investigation**: Determine root cause
4. **Remediation**: Implement permanent fix
5. **Testing**: Verify fix and add regression tests
6. **Documentation**: Update security documentation
7. **Communication**: Notify affected parties as appropriate

## Compliance Considerations

- Follow OWASP Top 10 guidelines
- Implement GDPR requirements for EU users
- Follow PCI DSS for payment processing
- Adhere to SOC 2 principles where applicable
- Maintain audit logs for security events

## Security Templates

Agent OS provides pre-configured security scanning templates in the `templates/` directory:

- **GitLab CI Template** (`gitlab-ci-security.yml`): Complete security pipeline for GitLab
- **GitHub Actions Template** (`github-actions-security.yml`): Reusable workflow for GitHub
- **Generic Script** (`generic-ci-security.sh`): Standalone script for any CI system

These templates include all the security checks mentioned in this document and can be customized for your specific needs. See `@agent-os/templates/README.md` for detailed usage instructions.

---

*Customize this file with your organization's specific security requirements. These security standards apply to all code written by humans and AI agents.*
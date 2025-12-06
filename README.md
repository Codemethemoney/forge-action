# FORGE AI-SBOM Compliance Action

Verify, audit, and check compliance of AI-generated code in your CI/CD pipeline.

## Quick Start

```yaml
name: AI Code Compliance
on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: FORGE Compliance Check
        uses: Codemethemoney/forge-action@v1
        with:
          policy: soc2
```

That's it! This will:
- Find all `*.sbom.json` files in your repository
- Verify cryptographic signatures
- Check SOC2 compliance
- Generate audit summary
- Fail the build if any check fails

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `action` | Action to perform: `verify`, `audit`, `policy`, `generate`, or `all` | `all` |
| `sbom-path` | Path to SBOM file or directory | `.` |
| `policy` | Policy set: `security-basic`, `soc2`, or `hipaa` | `security-basic` |
| `fail-on-invalid` | Fail if signature verification fails | `true` |
| `fail-on-policy-violation` | Fail if policy check fails | `true` |
| `source-file` | Source file for `generate` action | - |
| `provider` | AI provider (for `generate`) | `unknown` |
| `model` | AI model ID (for `generate`) | `unknown` |
| `signing-key` | Base64-encoded signing key (use secrets!) | - |
| `output-file` | Path for generated report | - |
| `output-format` | Report format: `json`, `markdown`, `csv` | `markdown` |

## Outputs

| Output | Description |
|--------|-------------|
| `verification-result` | `passed`, `failed`, or `skipped` |
| `policy-result` | `passed`, `failed`, or `skipped` |
| `audit-summary` | Summary of audit results |
| `sbom-count` | Number of SBOMs found |

## Examples

### Basic Verification

Verify all SBOMs on every push:

```yaml
- uses: Codemethemoney/forge-action@v1
  with:
    action: verify
```

### SOC2 Compliance Check

Enforce SOC2 compliance on pull requests:

```yaml
name: SOC2 Compliance
on: pull_request

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check SOC2 Compliance
        uses: Codemethemoney/forge-action@v1
        with:
          policy: soc2
          fail-on-policy-violation: true
```

### HIPAA Compliance for Healthcare

```yaml
- uses: Codemethemoney/forge-action@v1
  with:
    policy: hipaa
    sbom-path: ./ai-generated/
```

### Generate SBOM in CI

Generate SBOM for AI-generated code during build:

```yaml
- name: Generate SBOM
  uses: Codemethemoney/forge-action@v1
  with:
    action: generate
    source-file: src/ai-generated/login.ts
    provider: anthropic
    model: claude-3.5-sonnet
    signing-key: ${{ secrets.FORGE_SIGNING_KEY }}
```

**Setting up the signing key secret:**

```bash
# Generate key locally
forge-cli keygen --output forge-key.json

# Base64 encode it
cat forge-key.json | base64

# Add to GitHub Secrets as FORGE_SIGNING_KEY
```

### Generate Audit Report Artifact

Create a compliance report and upload as artifact:

```yaml
- name: FORGE Compliance Check
  uses: Codemethemoney/forge-action@v1
  with:
    sbom-path: ./sboms/
    policy: soc2
    output-file: compliance-report.md
    output-format: markdown

- name: Upload Report
  uses: actions/upload-artifact@v4
  with:
    name: compliance-report
    path: compliance-report.md
```

### Full Pipeline Example

Complete workflow with all features:

```yaml
name: AI Code Compliance Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Run full compliance check
      - name: FORGE Compliance
        id: forge
        uses: Codemethemoney/forge-action@v1
        with:
          sbom-path: ./sboms/
          policy: soc2
          output-file: reports/compliance-report.md
          output-format: markdown

      # Upload report as artifact
      - name: Upload Compliance Report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: compliance-report-${{ github.sha }}
          path: reports/compliance-report.md

      # Comment on PR with results
      - name: Comment PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const result = '${{ steps.forge.outputs.policy-result }}';
            const count = '${{ steps.forge.outputs.sbom-count }}';
            const emoji = result === 'passed' ? '✅' : '❌';

            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## ${emoji} FORGE AI-SBOM Compliance\n\n` +
                    `**SBOMs Found:** ${count}\n` +
                    `**Policy:** SOC2\n` +
                    `**Result:** ${result}\n\n` +
                    `See workflow for details.`
            });
```

### Scheduled Compliance Audit

Run weekly compliance audit:

```yaml
name: Weekly Compliance Audit
on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9am

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Full Audit
        uses: Codemethemoney/forge-action@v1
        with:
          action: audit
          sbom-path: .
          output-file: weekly-audit.md

      - name: Send Report
        # Email or Slack notification with report
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | Verification or policy check failed |

## Supported Policies

| Policy | Description | Use Case |
|--------|-------------|----------|
| `security-basic` | Basic security checks, signatures required | General use |
| `soc2` | SOC2 Type II requirements | SaaS, enterprise |
| `hipaa` | HIPAA-compliant providers only | Healthcare |

## Tips

1. **Store signing keys as secrets** - Never commit keys to your repository
2. **Use `fail-on-*` flags** - Enforce compliance gates in your pipeline
3. **Generate reports as artifacts** - Create audit trail for compliance
4. **Run on PRs** - Catch issues before they reach main branch
5. **Scheduled audits** - Regular compliance verification

## Publishing

See [PUBLISHING.md](PUBLISHING.md) for instructions on publishing this action.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Support

- **Issues:** https://github.com/Codemethemoney/forge-action/issues
- **CLI Documentation:** https://github.com/Codemethemoney/forge-cli
- **FORGE Framework:** https://github.com/Codemethemoney

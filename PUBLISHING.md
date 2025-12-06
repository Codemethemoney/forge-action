# Publishing the FORGE GitHub Action

This guide walks you through publishing the FORGE AI-SBOM Compliance GitHub Action.

## Prerequisites

1. **GitHub Account** with permissions to create repositories
2. **npm Account** for publishing the CLI (optional, for `@forge-framework/cli`)
3. **Git** installed locally

## Step 1: Publish the CLI to npm (Required First!)

The GitHub Action depends on `@forge-framework/cli` being available on npm.

```bash
# Navigate to CLI directory
cd /Users/garyoleary/Desktop/FORGE-FRAMEWORK-CLI/cli

# Build the CLI
npm run build

# Login to npm (if not already)
npm login

# Publish to npm
npm publish --access public
```

**Verify publication:**
```bash
npm view @forge-framework/cli
```

## Step 2: Create GitHub Repository for Action

### Option A: Using GitHub CLI (Recommended)

```bash
# Install GitHub CLI if needed
brew install gh

# Authenticate
gh auth login

# Create the repository
gh repo create forge-framework/forge-action \
  --public \
  --description "FORGE AI-SBOM Compliance GitHub Action - Verify, audit, and check compliance of AI-generated code"

# Navigate to action directory
cd /Users/garyoleary/Desktop/FORGE-FRAMEWORK-CLI/github-action

# Initialize and push
git init
git add .
git commit -m "feat: Initial release of FORGE GitHub Action v1.0.0"
git branch -M main
git remote add origin https://github.com/forge-framework/forge-action.git
git push -u origin main
```

### Option B: Manual GitHub Creation

1. Go to https://github.com/new
2. Create repository named `forge-action` under `forge-framework` org
3. Make it public
4. Don't initialize with README (we have our own)

Then push locally:
```bash
cd /Users/garyoleary/Desktop/FORGE-FRAMEWORK-CLI/github-action
git init
git add .
git commit -m "feat: Initial release of FORGE GitHub Action v1.0.0"
git branch -M main
git remote add origin https://github.com/forge-framework/forge-action.git
git push -u origin main
```

## Step 3: Create Release Tags

GitHub Actions use tags for versioning. We need both specific and major version tags.

```bash
# Create specific version tag
git tag -a v1.0.0 -m "FORGE Action v1.0.0 - Initial Release

Features:
- Signature verification for AI-SBOMs
- Policy compliance checking (SOC2, HIPAA, security-basic)
- Audit report generation
- SBOM generation with signing
- Export to multiple formats (JSON, Markdown, CSV)
- PR commenting support
- Artifact upload support"

git push origin v1.0.0

# Create/update major version tag (allows users to use @v1)
git tag -fa v1 -m "Update v1 to point to v1.0.0"
git push origin v1 --force
```

## Step 4: (Optional) Publish to GitHub Marketplace

To make the action discoverable in the GitHub Marketplace:

1. Go to your repository: https://github.com/forge-framework/forge-action
2. Click "Releases" in the right sidebar
3. Click "Draft a new release"
4. Select tag `v1.0.0`
5. Check ✅ "Publish this Action to the GitHub Marketplace"
6. Fill in release details:
   - **Title:** FORGE AI-SBOM Compliance v1.0.0
   - **Description:** (Copy from below)

### Release Description Template

```markdown
## FORGE AI-SBOM Compliance Action v1.0.0

Verify, audit, and enforce compliance for AI-generated code in your CI/CD pipeline.

### Features

- 🔐 **Signature Verification** - Cryptographically verify AI-SBOM integrity
- 📋 **Policy Compliance** - Check against SOC2, HIPAA, or custom policies
- 📊 **Audit Reports** - Generate comprehensive compliance reports
- 🔑 **SBOM Generation** - Create signed SBOMs for AI-generated code
- 💬 **PR Comments** - Automatic compliance status on pull requests

### Quick Start

```yaml
- uses: forge-framework/forge-action@v1
  with:
    policy: soc2
```

### Documentation

See the [README](https://github.com/forge-framework/forge-action#readme) for full documentation.
```

7. Click "Publish release"

## Step 5: Verify Installation

Test that users can use the action:

1. Create a test repository
2. Add a workflow file:

```yaml
# .github/workflows/test-forge.yml
name: Test FORGE Action
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: forge-framework/forge-action@v1
        with:
          action: audit
```

3. Push and verify the workflow runs successfully

## Updating the Action

When releasing updates:

```bash
# Make changes...
git add .
git commit -m "fix: description of fix"
git push

# Create new version tag
git tag -a v1.0.1 -m "Bug fixes"
git push origin v1.0.1

# Update major version tag
git tag -fa v1 -m "Update v1 to v1.0.1"
git push origin v1 --force
```

## Troubleshooting

### "npm install -g @forge-framework/cli" fails

The CLI package hasn't been published to npm yet. Run Step 1 first.

### Action not found

Make sure:
1. Repository is public
2. `action.yml` is in the root of the repository
3. You're using the correct org/repo name

### Marketplace not showing action

1. Ensure `action.yml` has valid `branding` section
2. Create a proper release (not just a tag)
3. Check the "Publish to Marketplace" checkbox

## Repository Structure

After publishing, your repository should have:

```
forge-action/
├── action.yml          # Main action definition
├── README.md           # Documentation
├── LICENSE             # MIT License
├── .gitignore          # Git ignore rules
└── examples/           # Example workflows
    ├── basic-verification.yml
    ├── soc2-compliance.yml
    ├── hipaa-compliance.yml
    └── full-pipeline.yml
```

## Support

- Issues: https://github.com/forge-framework/forge-action/issues
- CLI Docs: https://github.com/forge-framework/forge-cli

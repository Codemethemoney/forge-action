#!/bin/bash
# FORGE GitHub Action Publishing Script
# Run this script to publish the action to GitHub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           FORGE GitHub Action Publishing Script             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}Warning: GitHub CLI (gh) is not installed. Manual steps may be required.${NC}"
    HAS_GH=false
else
    HAS_GH=true
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Configuration
GITHUB_ORG="forge-framework"
REPO_NAME="forge-action"
FULL_REPO="${GITHUB_ORG}/${REPO_NAME}"
VERSION="1.0.0"

echo -e "${BLUE}Configuration:${NC}"
echo "  Repository: $FULL_REPO"
echo "  Version: v$VERSION"
echo ""

# Confirm
read -p "Continue with publishing? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Step 1: Check if already a git repo
if [ -d ".git" ]; then
    echo -e "${YELLOW}Git repository already initialized${NC}"
else
    echo -e "${BLUE}Initializing git repository...${NC}"
    git init
fi

# Step 2: Add all files
echo -e "${BLUE}Adding files...${NC}"
git add .

# Step 3: Create initial commit (if needed)
if git diff --cached --quiet; then
    echo -e "${YELLOW}No changes to commit${NC}"
else
    echo -e "${BLUE}Creating commit...${NC}"
    git commit -m "feat: Initial release of FORGE GitHub Action v${VERSION}

Features:
- Signature verification for AI-SBOMs
- Policy compliance checking (SOC2, HIPAA, security-basic)
- Audit report generation
- SBOM generation with signing
- Export to multiple formats
- PR commenting support"
fi

# Step 4: Set branch to main
git branch -M main

# Step 5: Check if remote exists
if git remote get-url origin &> /dev/null; then
    echo -e "${YELLOW}Remote 'origin' already configured${NC}"
else
    echo -e "${BLUE}Adding remote...${NC}"
    git remote add origin "https://github.com/${FULL_REPO}.git"
fi

# Step 6: Create repo if using gh CLI
if [ "$HAS_GH" = true ]; then
    echo ""
    read -p "Create GitHub repository using gh CLI? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Creating GitHub repository...${NC}"
        gh repo create "$FULL_REPO" \
            --public \
            --description "FORGE AI-SBOM Compliance GitHub Action - Verify, audit, and check compliance of AI-generated code" \
            2>/dev/null || echo -e "${YELLOW}Repository may already exist${NC}"
    fi
fi

# Step 7: Push to GitHub
echo ""
echo -e "${BLUE}Pushing to GitHub...${NC}"
git push -u origin main || {
    echo -e "${YELLOW}Push failed. You may need to create the repository first.${NC}"
    echo ""
    echo "Create repository manually at: https://github.com/new"
    echo "Name: $REPO_NAME"
    echo "Owner: $GITHUB_ORG"
    echo ""
    echo "Then run: git push -u origin main"
    exit 1
}

# Step 8: Create version tag
echo -e "${BLUE}Creating version tag v${VERSION}...${NC}"
git tag -a "v${VERSION}" -m "FORGE Action v${VERSION} - Initial Release

Features:
- Signature verification for AI-SBOMs
- Policy compliance checking (SOC2, HIPAA, security-basic)
- Audit report generation
- SBOM generation with signing
- Export to multiple formats (JSON, Markdown, CSV)
- PR commenting support
- Artifact upload support"

git push origin "v${VERSION}"

# Step 9: Create major version tag
echo -e "${BLUE}Creating major version tag v1...${NC}"
git tag -fa v1 -m "Update v1 to point to v${VERSION}"
git push origin v1 --force

# Done
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Publishing Complete!                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Visit: https://github.com/${FULL_REPO}"
echo ""
echo "2. Create a release for GitHub Marketplace:"
echo "   - Go to: https://github.com/${FULL_REPO}/releases/new"
echo "   - Select tag: v${VERSION}"
echo "   - Check 'Publish this Action to the GitHub Marketplace'"
echo "   - Add release notes and publish"
echo ""
echo "3. Users can now use the action:"
echo ""
echo -e "   ${YELLOW}uses: ${FULL_REPO}@v1${NC}"
echo ""
echo "4. Don't forget to publish the CLI to npm:"
echo "   cd ../cli && npm publish --access public"
echo ""

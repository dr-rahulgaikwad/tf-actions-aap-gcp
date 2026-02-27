#!/bin/bash
# Cleanup script to simplify the solution

set -e

echo "========================================="
echo "Solution Cleanup & Simplification"
echo "========================================="
echo ""

# Backup check
if ! git diff --quiet; then
    echo "⚠️  WARNING: You have uncommitted changes"
    echo "Please commit or stash changes before running cleanup"
    exit 1
fi

echo "Creating backup branch..."
git checkout -b backup-before-cleanup-$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
git push origin HEAD 2>/dev/null || echo "Backup branch created locally"

echo ""
echo "Cleaning up AI tool configurations..."
rm -rf .agents .crush .junie .mux .qwen .openhands .pochi .trae .windsurf \
       .mcpjam .cortex .qoder .roo .goose .neovate .augment .continue \
       .claude .iflow .zencoder .adal .kilocode .kode .commandcode .agent \
       .vibe .factory .kiro .cline .codebuddy .pi skills skills-lock.json

echo "Removing redundant documentation..."
rm -f DEPLOYMENT_SUMMARY.md SOLUTION_WORKFLOW.md

echo "Removing non-core terraform files..."
rm -f terraform/tfc-setup.tf

echo "Creating docs directory for optional reading..."
mkdir -p docs
[ -f PRODUCTION_READINESS_REPORT.md ] && mv PRODUCTION_READINESS_REPORT.md docs/
[ -f ARCHITECTURE_DIAGRAMS.md ] && mv ARCHITECTURE_DIAGRAMS.md docs/
[ -f OIDC_SETUP.md ] && mv OIDC_SETUP.md docs/

echo "Replacing with simplified versions..."
if [ -f README-SIMPLIFIED.md ]; then
    mv README-SIMPLIFIED.md README.md
fi

if [ -f Taskfile-SIMPLIFIED.yml ]; then
    mv Taskfile-SIMPLIFIED.yml Taskfile.yml
fi

echo "Updating .gitignore..."
cat >> .gitignore << 'EOF'

# AI tool configs
.agents/
.crush/
.junie/
.mux/
.qwen/
.openhands/
.pochi/
.trae/
.windsurf/
.mcpjam/
.cortex/
.qoder/
.roo/
.goose/
.neovate/
.augment/
.continue/
.claude/
.iflow/
.zencoder/
.adal/
.kilocode/
.kode/
.commandcode/
.agent/
.vibe/
.factory/
.kiro/
.cline/
.codebuddy/
.pi/
skills/
skills-lock.json
EOF

echo ""
echo "========================================="
echo "Cleanup Complete!"
echo "========================================="
echo ""
echo "Summary:"
echo "  ✅ Removed AI tool configurations"
echo "  ✅ Consolidated documentation"
echo "  ✅ Simplified README and Taskfile"
echo "  ✅ Organized optional docs in docs/"
echo ""
echo "Next steps:"
echo "  1. Review changes: git status"
echo "  2. Test solution: task test"
echo "  3. Validate: ./validate-production.sh"
echo "  4. Commit: git add . && git commit -m 'Simplify solution'"
echo "  5. Push: git push origin main"
echo ""
echo "Backup branch created for safety."

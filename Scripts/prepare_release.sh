#!/bin/bash
# Prepare EzImageCleaner for release

set -e

VERSION="2.0.0"
REPO_NAME="EzImageCleaner"

echo "🚀 Preparing ${REPO_NAME} v${VERSION} for release"

# Check if git repo exists
if [ ! -d .git ]; then
    echo "📁 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: EzImageCleaner v${VERSION}"
fi

# Create release branch
echo "🌿 Creating release branch..."
git checkout -b release/v${VERSION} 2>/dev/null || git checkout release/v${VERSION}

# Update version in files
echo "📝 Updating version numbers..."
sed -i '' "s/VERSION=\".*\"/VERSION=\"${VERSION}\"/" Installer/create_dmg.sh
sed -i '' "s/CFBundleShortVersionString<\/key>.*<string>.*<\/string>/CFBundleShortVersionString<\/key>\n    <string>${VERSION}<\/string>/" Source/SwiftUI/Info.plist 2>/dev/null || true

# Create release notes
echo "📋 Creating release notes..."
cat > RELEASE_NOTES.md << EOF
# EzImageCleaner v${VERSION} Release Notes

## 🎉 What's New

### Dual Mode Operation
- **GUI Mode**: Beautiful SwiftUI interface with visual image preview
- **Terminal Mode**: Lightning-fast keyboard-driven interface

### Key Features
- Smart detection of large images (customizable threshold)
- Safe deletion (moves to Trash)
- Undo functionality
- Real-time statistics
- Support for all major image formats

### Improvements
- Faster image scanning algorithm
- Better memory management
- Enhanced Preview integration
- Improved keyboard navigation

## 📦 Installation

Download the DMG file and drag EzImageCleaner to your Applications folder.

## 🐛 Bug Fixes
- Fixed focus issues in Terminal mode
- Improved case-insensitive command handling
- Better error handling for missing directories

## 🙏 Thanks

Special thanks to all early testers and contributors!

---

**Full Changelog**: https://github.com/koichiokawa/EzImageCleaner/commits/v${VERSION}
EOF

# Create installation instructions
echo "📖 Creating installation instructions..."
cat > INSTALL.md << EOF
# Installing EzImageCleaner

## Quick Install (Recommended)

1. Download \`EzImageCleaner-${VERSION}.dmg\`
2. Double-click to open
3. Drag EzImageCleaner to Applications
4. Launch from Applications or Spotlight

## First Launch

macOS may show a security warning:
1. Right-click EzImageCleaner
2. Select "Open"
3. Click "Open" in the dialog

## Terminal Mode Setup (Optional)

For quick access to terminal mode:
\`\`\`bash
echo 'alias ezcleaner="/Applications/EzImageCleaner.app/Contents/Resources/Scripts/ezimagecleaner.sh"' >> ~/.zshrc
source ~/.zshrc
\`\`\`

Now you can run \`ezcleaner\` from anywhere!

## Troubleshooting

If the app won't open:
- Check System Preferences > Security & Privacy
- Click "Open Anyway" if you see EzImageCleaner mentioned

For Terminal mode:
- Ensure Terminal has Full Disk Access in System Preferences
EOF

# Create checklist
echo "✅ Creating release checklist..."
cat > RELEASE_CHECKLIST.md << EOF
# Release Checklist for v${VERSION}

## Pre-release
- [ ] Update version numbers in all files
- [ ] Run all tests
- [ ] Test on macOS 12, 13, and 14
- [ ] Test both GUI and Terminal modes
- [ ] Update screenshots if UI changed
- [ ] Review and update documentation

## Build
- [ ] Build Release configuration in Xcode
- [ ] Sign with Developer ID (if available)
- [ ] Create DMG using \`./Installer/create_dmg.sh\`
- [ ] Test DMG on clean system

## GitHub Release
- [ ] Create new release on GitHub
- [ ] Tag as v${VERSION}
- [ ] Upload DMG file
- [ ] Upload source code ZIP
- [ ] Add release notes
- [ ] Mark as pre-release initially

## Post-release
- [ ] Test download and installation
- [ ] Update Homebrew formula (if applicable)
- [ ] Tweet announcement
- [ ] Remove pre-release flag after 24 hours
- [ ] Monitor issues for any problems

## Marketing
- [ ] Post on Reddit r/macapps
- [ ] Submit to Mac app directories
- [ ] Update personal website
EOF

echo ""
echo "✅ Release preparation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review RELEASE_CHECKLIST.md"
echo "2. Build the app in Xcode"
echo "3. Run ./Installer/create_dmg.sh"
echo "4. Create GitHub release"
echo ""
echo "🏷️  Suggested git commands:"
echo "   git add ."
echo "   git commit -m \"Prepare release v${VERSION}\""
echo "   git tag -a v${VERSION} -m \"Release version ${VERSION}\""
echo "   git push origin release/v${VERSION} --tags"
#!/bin/bash
# Create DMG installer for EzImageCleaner
# This script creates a beautiful DMG with background image and proper layout

set -e

APP_NAME="EzImageCleaner"
VERSION="2.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
VOLUME_NAME="${APP_NAME}"
SOURCE_DIR="$(pwd)"
BUILD_DIR="${SOURCE_DIR}/build"
DMG_DIR="${BUILD_DIR}/dmg"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}.dmg"

echo "🔨 Creating DMG installer for ${APP_NAME} v${VERSION}"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "${BUILD_DIR}"
mkdir -p "${DMG_DIR}"

# Check if app exists
if [ ! -d "${APP_NAME}.app" ]; then
    echo "❌ Error: ${APP_NAME}.app not found!"
    echo "Please build the app first using Xcode"
    exit 1
fi

# Copy app to DMG directory
echo "📦 Copying application..."
cp -R "${APP_NAME}.app" "${DMG_DIR}/"

# Copy additional files
echo "📄 Copying documentation..."
cp README.md "${DMG_DIR}/ReadMe.txt"
cp LICENSE "${DMG_DIR}/License.txt"

# Create symbolic link to Applications
echo "🔗 Creating Applications symlink..."
ln -s /Applications "${DMG_DIR}/Applications"

# Create DMG background (optional)
echo "🎨 Creating DMG background..."
mkdir -p "${DMG_DIR}/.background"
cat > "${DMG_DIR}/.background/background.html" << 'EOF'
<html>
<body style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0; padding: 40px; color: white; font-family: -apple-system, BlinkMacSystemFont, sans-serif;">
<h1>EzImageCleaner</h1>
<p>Drag the app to Applications folder to install</p>
</body>
</html>
EOF

# Create temporary DMG
echo "💿 Creating temporary DMG..."
hdiutil create -srcfolder "${DMG_DIR}" -volname "${VOLUME_NAME}" -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" -format UDRW -size 100m "${BUILD_DIR}/temp.dmg"

# Mount temporary DMG
echo "🔧 Mounting temporary DMG..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${BUILD_DIR}/temp.dmg" | \
    egrep '^/dev/' | sed 1q | awk '{print $1}')
MOUNT_POINT="/Volumes/${VOLUME_NAME}"

# Wait for mount
sleep 2

# Set custom icon positions
echo "🎯 Setting icon positions..."
osascript << EOF
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 430}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        set position of item "${APP_NAME}.app" of container window to {125, 160}
        set position of item "Applications" of container window to {375, 160}
        set position of item "ReadMe.txt" of container window to {125, 280}
        set position of item "License.txt" of container window to {375, 280}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Set window properties
echo "🪟 Setting window properties..."
SetFile -a C "${MOUNT_POINT}"

# Unmount temporary DMG
echo "🔌 Unmounting temporary DMG..."
hdiutil detach "${DEVICE}"

# Convert to compressed DMG
echo "🗜️ Creating final DMG..."
hdiutil convert "${BUILD_DIR}/temp.dmg" -format UDZO -imagekey zlib-level=9 -o "${DMG_PATH}"
rm -f "${BUILD_DIR}/temp.dmg"

# Sign DMG (optional, requires Developer ID)
if command -v codesign &> /dev/null; then
    echo "✍️ Attempting to sign DMG..."
    codesign --sign "Developer ID Application" "${DMG_PATH}" 2>/dev/null || \
        echo "⚠️  Signing skipped (no Developer ID found)"
fi

# Verify DMG
echo "✅ Verifying DMG..."
hdiutil verify "${DMG_PATH}"

# Calculate size
SIZE=$(du -h "${DMG_PATH}" | cut -f1)

echo ""
echo "🎉 Success! DMG created:"
echo "   📦 ${DMG_PATH}"
echo "   📏 Size: ${SIZE}"
echo ""
echo "📤 Next steps:"
echo "   1. Test the DMG on a clean system"
echo "   2. Upload to GitHub Releases"
echo "   3. Notarize for Gatekeeper (optional):"
echo "      xcrun altool --notarize-app --file \"${DMG_PATH}\""
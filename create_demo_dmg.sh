#!/bin/bash
# Create a demo DMG for testing the installation experience

set -e

APP_NAME="EzImageCleaner"
VERSION="2.0.0-demo"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="./build-demo"
DMG_DIR="${BUILD_DIR}/dmg"

echo "🎯 Creating demo DMG for installation testing..."

# Clean and create directories
rm -rf "${BUILD_DIR}"
mkdir -p "${DMG_DIR}"

# Create a demo app bundle
echo "📦 Creating demo app bundle..."
DEMO_APP="${DMG_DIR}/${APP_NAME}.app"
mkdir -p "${DEMO_APP}/Contents/MacOS"
mkdir -p "${DEMO_APP}/Contents/Resources"

# Copy the existing app structure if available, or create demo
if [ -d "EzImageCleaner.app" ]; then
    cp -R "EzImageCleaner.app" "${DMG_DIR}/"
else
    # Create a minimal demo app
    cat > "${DEMO_APP}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.koichiokawa.ezimagecleaner</string>
    <key>CFBundleName</key>
    <string>EzImageCleaner</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
</dict>
</plist>
EOF

    # Create launcher script
    cat > "${DEMO_APP}/Contents/MacOS/launcher" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
osascript -e 'display dialog "EzImageCleaner Demo\n\nThis is a demo version. The full version includes:\n• GUI mode with image preview\n• Terminal mode for power users\n• Undo functionality\n• And much more!" buttons {"Open Terminal Mode", "OK"} default button "OK"' | grep "Open Terminal Mode" && {
    open -a Terminal "$SCRIPT_DIR/../Resources/Scripts/ezimagecleaner_v2.sh"
}
EOF
    chmod +x "${DEMO_APP}/Contents/MacOS/launcher"
    
    # Copy scripts
    mkdir -p "${DEMO_APP}/Contents/Resources/Scripts"
    cp Source/Scripts/ezimagecleaner_v2.sh "${DEMO_APP}/Contents/Resources/Scripts/" 2>/dev/null || true
fi

# Add icon (use a placeholder if no icon available)
if [ -f "Resources/Icons/AppIcon.png" ]; then
    cp "Resources/Icons/AppIcon.png" "${DEMO_APP}/Contents/Resources/"
else
    # Create a simple icon placeholder
    echo "🐻" > "${DEMO_APP}/Contents/Resources/icon.txt"
fi

# Copy documentation
cp README.md "${DMG_DIR}/ReadMe.txt"
cp LICENSE "${DMG_DIR}/License.txt"

# Create Applications symlink
ln -s /Applications "${DMG_DIR}/Applications"

# Create background folder
mkdir -p "${DMG_DIR}/.background"

# Create the DMG
echo "💿 Creating DMG..."
hdiutil create -srcfolder "${DMG_DIR}" -volname "${APP_NAME}" -fs HFS+ \
    -format UDZO -size 50m "${BUILD_DIR}/${DMG_NAME}.dmg"

# Open the DMG
echo "📂 Opening DMG for testing..."
open "${BUILD_DIR}/${DMG_NAME}.dmg"

echo ""
echo "✅ Demo DMG created successfully!"
echo ""
echo "📋 Installation test steps:"
echo "1. The DMG should now be open"
echo "2. Drag ${APP_NAME} to the Applications folder"
echo "3. Eject the DMG"
echo "4. Open ${APP_NAME} from Applications"
echo "5. You may need to right-click and select 'Open' the first time"
echo ""
echo "📍 DMG location: ${BUILD_DIR}/${DMG_NAME}.dmg"
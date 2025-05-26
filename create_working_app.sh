#!/bin/bash

echo "🔨 Creating working EzImageCleaner app..."

# Clean up
rm -rf build-working
mkdir -p build-working/dmg

# Create app bundle
APP_DIR="build-working/dmg/EzImageCleaner.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources/Scripts"

# Copy icon
cp Resources/Icons/AppIcon.icns "$APP_DIR/Contents/Resources/"

# Copy the actual working scripts
cp Source/Scripts/ezimagecleaner_v2.sh "$APP_DIR/Contents/Resources/Scripts/"
cp Source/Scripts/image_viewer_improved.sh "$APP_DIR/Contents/Resources/Scripts/"
chmod +x "$APP_DIR/Contents/Resources/Scripts/"*.sh

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>EzImageCleaner</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.daiokawa.ezimagecleaner</string>
    <key>CFBundleName</key>
    <string>EzImageCleaner</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
</dict>
</plist>
EOF

# Create the main launcher that actually runs the cleaner
cat > "$APP_DIR/Contents/MacOS/EzImageCleaner" << 'EOF'
#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESOURCES_DIR="$SCRIPT_DIR/../Resources"

# Launch Terminal with the actual image cleaner script
osascript << END
tell application "Terminal"
    activate
    do script "clear && echo '🐻 EzImageCleaner v2.0.0' && echo '' && echo 'Starting image cleanup tool...' && sleep 1 && '$RESOURCES_DIR/Scripts/ezimagecleaner_v2.sh'"
end tell
END
EOF

chmod +x "$APP_DIR/Contents/MacOS/EzImageCleaner"

# Add README
cat > "build-working/dmg/README.txt" << 'EOF'
EzImageCleaner v2.0.0
====================

How to use:
1. Double-click EzImageCleaner app
2. Terminal will open with the image cleanup tool
3. Follow the on-screen instructions

Features:
- Finds large images on your Mac
- Shows preview before deletion
- Safely moves files to Trash
- Undo last deletion

For more info: https://github.com/daiokawa/EzImageCleaner
EOF

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "EzImageCleaner" -srcfolder build-working/dmg -ov -format UDZO build-working/EzImageCleaner-2.0.0-working.dmg

echo "✅ Done! Working app created at: build-working/EzImageCleaner-2.0.0-working.dmg"
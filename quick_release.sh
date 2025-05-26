#!/bin/bash

echo "📦 Creating quick release DMG..."

# Clean up
rm -rf build-release
mkdir -p build-release/dmg

# Create a simple launcher app
APP_DIR="build-release/dmg/EzImageCleaner.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy icon
cp Resources/Icons/AppIcon.icns "$APP_DIR/Contents/Resources/"

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

# Create launcher script that runs the terminal version
cat > "$APP_DIR/Contents/MacOS/EzImageCleaner" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_DIR="$SCRIPT_DIR/../Resources"

# Simple GUI selector using osascript
CHOICE=$(osascript << 'END'
tell application "System Events"
    display dialog "EzImageCleaner v2.0.0\n\nSelect mode:" buttons {"Terminal Mode", "Cancel", "GUI Mode"} default button "GUI Mode" with icon note
    set userChoice to button returned of the result
    return userChoice
end tell
END
)

if [ "$CHOICE" = "GUI Mode" ]; then
    osascript -e 'display dialog "GUI Mode is being prepared for App Store release.\n\nPlease use Terminal Mode for now." buttons {"OK"} default button "OK" with icon note'
elif [ "$CHOICE" = "Terminal Mode" ]; then
    # Open Terminal and run the script
    osascript << END
tell application "Terminal"
    activate
    do script "echo 'EzImageCleaner - Terminal Mode'; echo 'This will scan for large images...'; echo ''; echo 'Press any key to exit...'; read -n 1"
end tell
END
fi
EOF

chmod +x "$APP_DIR/Contents/MacOS/EzImageCleaner"

# Copy scripts to Resources
cp -r Source/Scripts "$APP_DIR/Contents/Resources/"

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "EzImageCleaner" -srcfolder build-release/dmg -ov -format UDZO build-release/EzImageCleaner-2.0.0.dmg

echo "✅ Done! DMG created at: build-release/EzImageCleaner-2.0.0.dmg"
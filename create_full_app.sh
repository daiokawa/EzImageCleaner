#!/bin/bash

echo "🎨 Creating full EzImageCleaner app with GUI and Terminal modes..."

# Clean up
rm -rf build-full
mkdir -p build-full/dmg

# Create app bundle
APP_DIR="build-full/dmg/EzImageCleaner.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources/Scripts"

# Copy icon
cp Resources/Icons/AppIcon.icns "$APP_DIR/Contents/Resources/"

# Copy scripts
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

# Create launcher with mode selection
cat > "$APP_DIR/Contents/MacOS/EzImageCleaner" << 'EOF'
#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESOURCES_DIR="$SCRIPT_DIR/../Resources"

# Show mode selection dialog
CHOICE=$(osascript << 'END'
tell application "System Events"
    display dialog "🐻 EzImageCleaner v2.0.0\n\nSelect your preferred mode:\n\n• GUI Mode: Visual interface with sliders and buttons (Coming Soon)\n• Terminal Mode: Fast keyboard-driven interface (Available Now)" buttons {"Terminal Mode", "Cancel", "GUI Mode"} default button "GUI Mode" with title "EzImageCleaner" with icon note
    set userChoice to button returned of the result
    return userChoice
end tell
END
)

if [ "$CHOICE" = "GUI Mode" ]; then
    # Show GUI mode preview
    osascript << 'END'
tell application "System Events"
    display dialog "GUI Mode Preview:\n\n✅ Visual folder selection\n✅ Size threshold slider (100KB - 10MB)\n✅ Image preview with buttons\n✅ Progress tracking\n✅ Undo support\n\nGUI mode is being finalized for App Store release.\nWould you like to try Terminal Mode instead?" buttons {"Cancel", "Try Terminal Mode"} default button "Try Terminal Mode" with title "GUI Mode Coming Soon" with icon note
    set userChoice to button returned of the result
    if userChoice is "Try Terminal Mode" then
        return "terminal"
    else
        return "cancel"
    end if
end tell
END
    
    if [ "$?" = "terminal" ]; then
        CHOICE="Terminal Mode"
    else
        exit 0
    fi
fi

if [ "$CHOICE" = "Terminal Mode" ]; then
    # Open Terminal with the image cleaner script
    osascript << END
tell application "Terminal"
    activate
    do script "clear && echo '🐻 EzImageCleaner v2.0.0 - Terminal Mode' && echo '' && echo 'Starting image cleanup tool...' && echo '' && sleep 1 && '$RESOURCES_DIR/Scripts/ezimagecleaner_v2.sh'"
end tell
END
fi
EOF

chmod +x "$APP_DIR/Contents/MacOS/EzImageCleaner"

# Add README with screenshots
cat > "build-full/dmg/README.txt" << 'EOF'
EzImageCleaner v2.0.0
====================

A powerful dual-mode image cleanup tool for macOS.

FEATURES:
---------
✅ Find large images (100KB - 10MB)
✅ Preview before deletion
✅ Safe deletion to Trash
✅ Undo support
✅ Statistics tracking

MODES:
------
1. GUI Mode (Coming Soon)
   - Visual interface
   - Slider controls
   - Click buttons
   - Perfect for beginners

2. Terminal Mode (Available Now)
   - Fast keyboard control
   - Y/N/U/Q commands
   - Efficient workflow
   - Power user friendly

HOW TO USE:
-----------
1. Double-click EzImageCleaner
2. Choose your mode
3. Follow instructions

For more info: https://github.com/daiokawa/EzImageCleaner
EOF

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "EzImageCleaner" -srcfolder build-full/dmg -ov -format UDZO build-full/EzImageCleaner-2.0.0-full.dmg

echo "✅ Done! Full app created at: build-full/EzImageCleaner-2.0.0-full.dmg"
echo ""
echo "This version includes:"
echo "• Mode selection dialog"
echo "• GUI mode preview (coming soon)"
echo "• Terminal mode (fully functional)"
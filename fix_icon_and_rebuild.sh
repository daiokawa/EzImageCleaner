#!/bin/bash
# Fix icon cache and rebuild DMG

echo "🧹 Cleaning up..."
# Remove old builds
rm -rf build-demo

# Clear icon cache
rm -rf ~/Library/Caches/com.apple.iconservices*
killall Finder

echo "🐻 Rebuilding with bear icon..."

# Create fresh directories
mkdir -p build-demo/dmg

# Create new app bundle
APP_DIR="build-demo/dmg/EzImageCleaner.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
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

# Create launcher
cat > "$APP_DIR/Contents/MacOS/launcher" << 'EOF'
#!/bin/bash
osascript -e 'display dialog "EzImageCleaner Demo\n\nThis demo shows the bear icon correctly!" buttons {"OK"} default button "OK"'
EOF
chmod +x "$APP_DIR/Contents/MacOS/launcher"

# Copy the icon
cp Resources/Icons/AppIcon.icns "$APP_DIR/Contents/Resources/"

# Set icon on the app bundle
SetFile -a C "$APP_DIR"

# Copy other files
cp README.md "build-demo/dmg/ReadMe.txt"
cp LICENSE "build-demo/dmg/License.txt"
ln -s /Applications "build-demo/dmg/Applications"

# Create DMG
echo "💿 Creating new DMG..."
hdiutil create -srcfolder build-demo/dmg -volname "EzImageCleaner" \
    -fs HFS+ -format UDZO -size 50m "build-demo/EzImageCleaner-2.0.0-demo.dmg"

# Wait a moment
sleep 1

echo "📂 Opening fresh DMG..."
open "build-demo/EzImageCleaner-2.0.0-demo.dmg"

echo ""
echo "✅ Done! The app should now show the bear icon."
echo ""
echo "If the icon still shows as pig:"
echo "1. Log out and log back in"
echo "2. Or restart your Mac"
echo "The icon cache sometimes needs a full refresh."
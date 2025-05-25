#!/bin/bash
# Create .icns file from PNG image

if [ ! -f "Resources/Icons/AppIcon.png" ]; then
    echo "❌ Error: Please save the bear icon as Resources/Icons/AppIcon.png first!"
    exit 1
fi

echo "🎨 Creating icon set..."

# Create iconset directory
ICONSET="Resources/Icons/AppIcon.iconset"
mkdir -p "$ICONSET"

# Create various sizes (using sips)
sips -z 16 16     Resources/Icons/AppIcon.png --out "$ICONSET/icon_16x16.png"
sips -z 32 32     Resources/Icons/AppIcon.png --out "$ICONSET/icon_16x16@2x.png"
sips -z 32 32     Resources/Icons/AppIcon.png --out "$ICONSET/icon_32x32.png"
sips -z 64 64     Resources/Icons/AppIcon.png --out "$ICONSET/icon_32x32@2x.png"
sips -z 128 128   Resources/Icons/AppIcon.png --out "$ICONSET/icon_128x128.png"
sips -z 256 256   Resources/Icons/AppIcon.png --out "$ICONSET/icon_128x128@2x.png"
sips -z 256 256   Resources/Icons/AppIcon.png --out "$ICONSET/icon_256x256.png"
sips -z 512 512   Resources/Icons/AppIcon.png --out "$ICONSET/icon_256x256@2x.png"
sips -z 512 512   Resources/Icons/AppIcon.png --out "$ICONSET/icon_512x512.png"
sips -z 1024 1024 Resources/Icons/AppIcon.png --out "$ICONSET/icon_512x512@2x.png"

# Create .icns file
iconutil -c icns "$ICONSET" -o Resources/Icons/AppIcon.icns

# Clean up
rm -rf "$ICONSET"

echo "✅ Icon created: Resources/Icons/AppIcon.icns"

# Update the demo app
if [ -d "build-demo/dmg/EzImageCleaner.app" ]; then
    echo "🔄 Updating demo app icon..."
    cp Resources/Icons/AppIcon.icns build-demo/dmg/EzImageCleaner.app/Contents/Resources/
    
    # Update Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" build-demo/dmg/EzImageCleaner.app/Contents/Info.plist
    
    echo "📦 Recreating DMG with new icon..."
    rm -f build-demo/*.dmg
    hdiutil create -srcfolder build-demo/dmg -volname "EzImageCleaner" -fs HFS+ \
        -format UDZO -size 50m "build-demo/EzImageCleaner-2.0.0-demo.dmg"
    
    echo "📂 Opening updated DMG..."
    open "build-demo/EzImageCleaner-2.0.0-demo.dmg"
fi
#!/bin/bash
# Apply icon manually to the app

echo "🐻 Applying bear icon manually..."

# First, let's make sure the app is in Applications
if [ -d "/Applications/EzImageCleaner.app" ]; then
    echo "Found app in Applications folder"
    
    # Copy icon to the app
    cp Resources/Icons/AppIcon.icns "/Applications/EzImageCleaner.app/Contents/Resources/"
    
    # Use AppleScript to set custom icon
    osascript << 'EOF'
    tell application "Finder"
        set appFile to POSIX file "/Applications/EzImageCleaner.app" as alias
        set iconFile to POSIX file "/Users/KoichiOkawa/Desktop/EzImageCleaner/Resources/Icons/AppIcon.icns" as alias
        
        -- Clear existing custom icon
        set the icon of appFile to {}
        
        -- Set new icon
        try
            my setIcon(iconFile, appFile)
        end try
        
        -- Update
        update appFile
    end tell
    
    on setIcon(iconFile, targetFile)
        tell application "Finder"
            set icon of targetFile to iconFile
        end tell
    end setIcon
EOF
    
    echo "✅ Icon applied!"
    echo "Try restarting Finder: killall Finder"
else
    echo "❌ Please first drag EzImageCleaner to Applications folder"
fi
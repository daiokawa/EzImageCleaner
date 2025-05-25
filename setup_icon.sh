#!/bin/bash
# Setup bear icon for EzImageCleaner

echo "🐻 Setting up bear icon..."

# Create directories
mkdir -p Resources/Icons

# Create a placeholder message
cat > Resources/Icons/PLACE_ICON_HERE.txt << EOF
Please save the bear icon image here as:
AppIcon.png

After saving, run:
./create_icon.sh
EOF

echo "📁 Created: Resources/Icons/"
echo ""
echo "Next steps:"
echo "1. Save the bear image as: Resources/Icons/AppIcon.png"
echo "2. Run: ./create_icon.sh"
echo ""
echo "The bear icon should be the one with:"
echo "- Brown bear with magnifying glass"
echo "- Y and N keys on the desk"
echo "- Stack of photos"
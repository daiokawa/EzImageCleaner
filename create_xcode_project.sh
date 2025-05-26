#!/bin/bash

echo "Creating new Xcode project for EzImageCleaner..."

# Remove old project
rm -rf EzImageCleanerApp.xcodeproj

# Create new SwiftUI macOS app using xcodegen or manual creation
cat > project.yml << EOF
name: EzImageCleanerApp
options:
  bundleIdPrefix: com.daiokawa
  deploymentTarget:
    macOS: "10.15"
targets:
  EzImageCleanerApp:
    type: application
    platform: macOS
    deploymentTarget: "10.15"
    sources:
      - Source/SwiftUI
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.daiokawa.ezimagecleaner
      PRODUCT_NAME: EzImageCleaner
      MARKETING_VERSION: 2.0.0
      CURRENT_PROJECT_VERSION: 1
      INFOPLIST_FILE: EzImageCleanerApp/Info.plist
      ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
      MACOSX_DEPLOYMENT_TARGET: 10.15
EOF

echo "Project configuration created. Please:"
echo "1. Open Xcode"
echo "2. Create new project: File > New > Project"
echo "3. Choose: macOS > App"
echo "4. Product Name: EzImageCleanerApp"
echo "5. Interface: SwiftUI"
echo "6. Language: Swift"
echo "7. Bundle Identifier: com.daiokawa.ezimagecleaner"
echo "8. Add existing SwiftUI files from Source/SwiftUI/"
#!/bin/bash
# Create DMG installer for EzImageCleaner

APP_NAME="EzImageCleaner"
VERSION="2.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION}"

echo "Creating ${DMG_NAME}..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
mkdir -p "${TEMP_DIR}/${APP_NAME}"

# Copy files
cp -r EzImageCleaner.app "${TEMP_DIR}/"
cp README.md "${TEMP_DIR}/"
cp -r Scripts "${TEMP_DIR}/${APP_NAME}/"

# Create symbolic link to Applications
ln -s /Applications "${TEMP_DIR}/Applications"

# Create DMG
hdiutil create -volname "${VOLUME_NAME}" \
    -srcfolder "${TEMP_DIR}" \
    -ov -format UDZO \
    "${DMG_NAME}"

# Clean up
rm -rf "${TEMP_DIR}"

echo "Created ${DMG_NAME}"
echo ""
echo "To sign and notarize for distribution:"
echo "  codesign --deep --force --verify --verbose --sign 'Developer ID' ${APP_NAME}.app"
echo "  xcrun altool --notarize-app --file ${DMG_NAME}"
#!/bin/bash
# 
# brandSelfService.sh
#
# Replace default JAMF Self Service app icons with custom assets for branding
# Place branding assets in a folder of your choice (BRANDED_ASSET_FOLER_PATH)
# 
# Files needed:
# Replacement app icon, 256x256: /icons/appicon.icns
# Replacement high-resolution app icon, 512x512: /icons/appicon@2x.icns
# Replacement SS status area icon, 84x84: /icons/logo-SelfService.tiff
#
# For use with the JAMF Casper Suite
#
# Adam Codega, Swipely
#
# BRANDED_ASSET_FOLDER_PATH
# Directory containing all self service branding assets
#
# BRANDED_SELF_SERVICE_PATH
# Your preferred Self Service path & name

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root!"
else
  SELF_SERVICE_PATH="/Applications/Self Service.app"
  SELF_SERVICE_BACKUP_PATH="/tmp/Self Service.app"
  BRANDED_ASSET_FOLDER_PATH="/tmp/icons"
  BRANDED_SELF_SERVICE_NAME="Swipely Service"
  BRANDED_SELF_SERVICE_PATH="/Applications/Swipely Service.app"

  if [ ! -d "$SELF_SERVICE_PATH" ]; then
    echo "Self Service app not found!"
  else
    if [ -d "$SELF_SERVICE_BACKUP_PATH" ]; then
      rm -rf "$SELF_SERVICE_BACKUP_PATH"
    fi
    cp -a "$SELF_SERVICE_PATH" "$SELF_SERVICE_BACKUP_PATH"
    # Copy the icon into place
    echo "Copying the icon file into place.."
    cp "$BRANDED_ASSET_FOLDER_PATH/appicon.icns" "$SELF_SERVICE_PATH/Contents/Resources/Self Service.icns"

    # Copy the Retina icon into place
    echo "Copying the Retina icon into place.."
    cp "$BRANDED_ASSET_FOLDER_PATH/appicon@2x.icns" "$SELF_SERVICE_PATH/Contents/Resources/Self Service@2x.icns"

    # Copy the status area icon into place
    echo "Copying the status area icon into place.."
    cp "$BRANDED_ASSET_FOLDER_PATH/logo-SelfService.tiff" "$SELF_SERVICE_PATH/Contents/Resources/jsLogo-SelfService.tiff"

    # Replace Self Service app bundle name in plist
    echo "Renaming Self Service in Info.plist and chmoding it.."
    defaults write "$SELF_SERVICE_PATH/Contents/Info.plist" CFBundleName "$BRANDED_SELF_SERVICE_NAME"

    xattr -r -d com.apple.quarantine "$SELF_SERVICE_PATH"
    chmod 744 "$SELF_SERVICE_PATH/Contents/Info.plist" "$SELF_SERVICE_PATH/Contents/Resources/Self Service.icns" "$SELF_SERVICE_PATH/Contents/Resources/Self Service@2x.icns" "$SELF_SERVICE_PATH/Contents/Resources/jsLogo-SelfService.tiff"
    chown -R root:wheel "$SELF_SERVICE_PATH"

    # Rename app
    echo "Renaming Self Service the app itself.."
    mv "$SELF_SERVICE_PATH" "$BRANDED_SELF_SERVICE_PATH"

    echo "You've been branded!"
  fi
fi

#!/bin/bash

# VPN Keep Awake - DMG Creator
# Creates a distributable DMG file with Applications shortcut
#
# Copyright (c) 2026 Softviser — www.softviser.com.tr
# Licensed under the MIT License. See LICENSE file for details.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="VPNKeepAwake"
VERSION="1.2.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="$SCRIPT_DIR/build"
DIST_DIR="$SCRIPT_DIR/dist"
DMG_DIR="$DIST_DIR/dmg-contents"
APP_PATH="$BUILD_DIR/${APP_NAME}.app"

echo "============================================"
echo "  VPN Keep Awake - DMG Creator"
echo "  Version: $VERSION"
echo "============================================"
echo ""

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    echo "Run ./build.sh first"
    exit 1
fi

# Create dist directory
echo "Preparing directories..."
rm -rf "$DIST_DIR"
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
echo "Copying application..."
cp -R "$APP_PATH" "$DMG_DIR/"

# Create Applications symlink
echo "Creating Applications shortcut..."
ln -s /Applications "$DMG_DIR/Applications"

# Calculate required size
APP_SIZE=$(du -sm "$APP_PATH" | cut -f1)
DMG_SIZE=$((APP_SIZE + 20))

echo "Creating DMG (${DMG_SIZE}MB)..."

# Create temporary DMG
hdiutil create -srcfolder "$DMG_DIR" \
    -volname "$APP_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    -size ${DMG_SIZE}m \
    "$DIST_DIR/temp.dmg"

# Mount temporary DMG
echo "Configuring DMG..."
MOUNT_DIR=$(hdiutil attach -readwrite -noverify "$DIST_DIR/temp.dmg" | grep -E '^/dev/' | tail -1 | awk '{print $NF}')

# Unmount
echo "Finalizing..."
sync
hdiutil detach "$MOUNT_DIR" -quiet || true

# Convert to compressed DMG
echo "Compressing DMG..."
hdiutil convert "$DIST_DIR/temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DIST_DIR/${DMG_NAME}.dmg"

# Cleanup
rm -f "$DIST_DIR/temp.dmg"
rm -rf "$DMG_DIR"

# Generate checksum
echo "Generating checksum..."
cd "$DIST_DIR"
shasum -a 256 "${DMG_NAME}.dmg" > "${DMG_NAME}.dmg.sha256"

echo ""
echo "============================================"
echo "  DMG created successfully!"
echo "============================================"
echo ""
echo "Location: $DIST_DIR/${DMG_NAME}.dmg"
echo "Size: $(du -h "$DIST_DIR/${DMG_NAME}.dmg" | cut -f1)"
echo "SHA256: $(cat "${DMG_NAME}.dmg.sha256" | cut -d' ' -f1)"
echo ""
echo "To install:"
echo "1. Open ${DMG_NAME}.dmg"
echo "2. Drag VPNKeepAwake to Applications"
echo "3. Eject the disk image"
echo ""

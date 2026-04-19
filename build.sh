#!/bin/bash

# VPN Keep Awake - Build Script
# Compiles the app and creates .app bundle
#
# Copyright (c) 2026 Softviser — www.softviser.com.tr
# Licensed under the MIT License. See LICENSE file for details.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="VPNKeepAwake"
BUILD_DIR="$SCRIPT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building VPN Keep Awake..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile Swift sources (try Universal Binary, fallback to native arch)
echo "Compiling Swift source..."
swiftc -O \
    -sdk $(xcrun --show-sdk-path) \
    -target arm64-apple-macosx10.15 \
    -target x86_64-apple-macosx10.15 \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    "$SCRIPT_DIR"/Sources/*.swift \
    -framework Cocoa \
    -framework IOKit \
    -framework SystemConfiguration \
    2>/dev/null || \
swiftc -O \
    -sdk $(xcrun --show-sdk-path) \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    "$SCRIPT_DIR"/Sources/*.swift \
    -framework Cocoa \
    -framework IOKit \
    -framework SystemConfiguration

# Copy Info.plist
cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/"

# Create PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo ""
echo "Build successful!"
echo ""
echo "App location: $APP_BUNDLE"
echo ""
echo "To run:"
echo "   open \"$APP_BUNDLE\""
echo ""
echo "To install:"
echo "   cp -r \"$APP_BUNDLE\" /Applications/"
echo ""

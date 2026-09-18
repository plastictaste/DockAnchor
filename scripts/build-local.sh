#!/bin/bash
# Compile with Command Line Tools, reusing compiled resources from an official release.
set -euo pipefail
cd "$(dirname "$0")/.."
reference="${1:-/Applications/DockAnchor.app}"
mkdir -p build
cat > build/Item.swift <<'SWIFT'
import CoreData
@objc(Item)
public class Item: NSManagedObject {
    @NSManaged public var timestamp: Date?
}
SWIFT
swiftc -D LOCAL_BUILD -sdk "${DOCKANCHOR_SDK:-/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk}" -module-cache-path build/ModuleCache -swift-version 5 -target arm64-apple-macosx15.4 -module-name DockAnchor -O DockAnchor/*.swift build/Item.swift -o build/DockAnchor
app="build/DockAnchor.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
ditto "$reference/Contents/Resources" "$app/Contents/Resources"
cp "$reference/Contents/Info.plist" "$app/Contents/Info.plist"
cp build/DockAnchor "$app/Contents/MacOS/DockAnchor"
/usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString 2.1.0-local.1' "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier bwyatt.DockAnchor.local' "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleVersion 2.1.0.1' "$app/Contents/Info.plist"
codesign -d --xml --entitlements build/reference-entitlements.plist "$reference"
xattr -dr com.apple.FinderInfo "$app" 2>/dev/null || true
xattr -dr com.apple.ResourceFork "$app" 2>/dev/null || true
codesign --force --sign - --entitlements build/reference-entitlements.plist "$app"
codesign --verify --deep --strict "$app"
echo "Built $PWD/$app"

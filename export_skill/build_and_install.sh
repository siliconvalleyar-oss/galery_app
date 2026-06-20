#!/bin/bash
# Build the Flutter APK and install it on a connected device via adb
set -euo pipefail

cd "$(dirname "$0")"

echo "📦 Building Flutter APK (release)..."
if ! flutter build apk --release; then
  echo "❌ Build failed. Try running: flutter clean && flutter pub get"
  exit 1
fi

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
  # Fallback to debug APK
  APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
fi

echo "📱 Installing APK on device..."
adb install -r "$APK_PATH"
echo "✅ Done!"

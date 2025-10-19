#!/bin/bash

echo "=== Flutter Gradle Build Test ==="
echo "Current directory: $(pwd)"

# Add Flutter to PATH
export PATH="$PATH:/Users/shepro04/flutter/bin"

echo "Flutter version:"
flutter --version

echo "Cleaning project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Building APK (this may take a few minutes)..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Build successful! Gradle issue resolved."
else
    echo "❌ Build failed. There may still be issues."
fi


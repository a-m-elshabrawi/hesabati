#!/bin/bash

# Add Flutter to PATH
export PATH="$PATH:/Users/shepro04/flutter/bin"

# Navigate to project directory
cd /Users/shepro04/Desktop/Flutter\ UniCode/final_project_unicode

echo "Testing Flutter build..."
echo "Flutter version:"
flutter --version

echo "Cleaning project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Building APK..."
flutter build apk --debug

echo "Build completed!"


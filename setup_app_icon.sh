#!/bin/bash

# App Icon Setup Script
# This script helps set up the custom app icon for the Flutter app

echo "🏦 Setting up custom app icon for One-View Finance..."

# Check if flutter_launcher_icons is installed
if ! flutter pub deps | grep -q "flutter_launcher_icons"; then
    echo "📦 Installing flutter_launcher_icons..."
    flutter pub add --dev flutter_launcher_icons
fi

# Check if the app icon image exists
if [ ! -f "assets/images/app_icon_1024.png" ]; then
    echo "⚠️  App icon image not found!"
    echo "Please create a 1024x1024px PNG image named 'app_icon_1024.png' in the 'assets/images/' directory"
    echo "The image should be based on the wallet icon design from the login screen."
    echo ""
    echo "You can:"
    echo "1. Use the provided SVG template (assets/images/app_icon.svg)"
    echo "2. Take a screenshot of the login screen icon and resize it"
    echo "3. Create a custom design matching the app's blue color scheme"
    echo ""
    echo "Design specifications:"
    echo "- Size: 1024x1024px"
    echo "- Background: White with rounded corners"
    echo "- Icon: Wallet icon in blue (#1E40AF)"
    echo "- Format: PNG"
    exit 1
fi

echo "✅ App icon image found!"

# Generate app icons
echo "🎨 Generating app icons for all platforms..."
flutter pub run flutter_launcher_icons

if [ $? -eq 0 ]; then
    echo "✅ App icons generated successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Clean and rebuild your app:"
    echo "   flutter clean && flutter pub get && flutter run"
    echo ""
    echo "2. Test the app icon on your device:"
    echo "   - Check home screen"
    echo "   - Check app switcher"
    echo "   - Check settings"
    echo ""
    echo "3. If the icon doesn't appear immediately:"
    echo "   - Restart your device/simulator"
    echo "   - Uninstall and reinstall the app"
else
    echo "❌ Failed to generate app icons. Please check the error messages above."
    exit 1
fi

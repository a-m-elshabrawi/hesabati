# App Icon Setup Guide

## Overview
This guide will help you set up a custom app icon based on the wallet icon design from the login screen.

## Design Specifications
- **Base Design**: Wallet icon (`Icons.account_balance_wallet`) on white background
- **Background**: White with rounded corners (similar to login screen)
- **Icon Color**: Blue (#1E40AF - AppColors.primaryBlue)
- **Style**: Modern, clean, and professional

## Step 1: Create the Icon Image

### Option A: Use the provided SVG
1. Open the `assets/images/app_icon.svg` file in a design tool (Figma, Adobe Illustrator, etc.)
2. Export as PNG in the following sizes:

### Required Sizes:

#### Android Icons (replace existing files in `android/app/src/main/res/`):
- `mipmap-mdpi/ic_launcher.png` - 48x48px
- `mipmap-hdpi/ic_launcher.png` - 72x72px  
- `mipmap-xhdpi/ic_launcher.png` - 96x96px
- `mipmap-xxhdpi/ic_launcher.png` - 144x144px
- `mipmap-xxxhdpi/ic_launcher.png` - 192x192px

#### iOS Icons (replace existing files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`):
- `Icon-App-20x20@1x.png` - 20x20px
- `Icon-App-20x20@2x.png` - 40x40px
- `Icon-App-20x20@3x.png` - 60x60px
- `Icon-App-29x29@1x.png` - 29x29px
- `Icon-App-29x29@2x.png` - 58x58px
- `Icon-App-29x29@3x.png` - 87x87px
- `Icon-App-40x40@1x.png` - 40x40px
- `Icon-App-40x40@2x.png` - 80x80px
- `Icon-App-40x40@3x.png` - 120x120px
- `Icon-App-60x60@2x.png` - 120x120px
- `Icon-App-60x60@3x.png` - 180x180px
- `Icon-App-76x76@1x.png` - 76x76px
- `Icon-App-76x76@2x.png` - 152x152px
- `Icon-App-83.5x83.5@2x.png` - 167x167px
- `Icon-App-1024x1024@1x.png` - 1024x1024px

### Option B: Use Flutter's built-in icon generator
1. Install the `flutter_launcher_icons` package:
   ```bash
   flutter pub add --dev flutter_launcher_icons
   ```

2. Create a `flutter_launcher_icons.yaml` file in the project root:
   ```yaml
   flutter_launcher_icons:
     android: "launcher_icon"
     ios: true
     image_path: "assets/images/app_icon_1024.png"
     min_sdk_android: 21
     web:
       generate: true
       image_path: "assets/images/app_icon_1024.png"
       background_color: "#hexcode"
       theme_color: "#hexcode"
     windows:
       generate: true
       image_path: "assets/images/app_icon_1024.png"
       icon_size: 48
     macos:
       generate: true
       image_path: "assets/images/app_icon_1024.png"
   ```

3. Create a 1024x1024px PNG version of the app icon
4. Run: `flutter pub get && flutter pub run flutter_launcher_icons`

## Step 2: Design Guidelines

### Visual Elements:
1. **Background**: Solid white (#FFFFFF)
2. **Shape**: Rounded rectangle (corner radius ~20% of icon size)
3. **Wallet Icon**: 
   - Main color: Blue (#1E40AF)
   - Accent color: Lighter blue (#3B82F6)
   - Clasp: Gold (#F59E0B)
4. **Shadow**: Subtle drop shadow for depth

### Design Principles:
- Keep it simple and recognizable at small sizes
- Ensure good contrast
- Maintain consistency with the app's color scheme
- Test visibility on both light and dark backgrounds

## Step 3: Testing

After updating the icons:
1. Clean and rebuild the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Check the app icon appears correctly on:
   - Home screen
   - App switcher
   - Settings
   - App store (if publishing)

## Step 4: Alternative Quick Setup

If you want to use a simpler approach, you can also:
1. Take a screenshot of the login screen icon
2. Crop it to a square
3. Resize to 1024x1024px
4. Use the flutter_launcher_icons package as described above

## Notes
- The SVG file provided is a template - you may need to adjust colors and details
- Ensure all icon files are properly named and placed in the correct directories
- Test on both Android and iOS devices/simulators
- Consider creating adaptive icons for Android (foreground + background)

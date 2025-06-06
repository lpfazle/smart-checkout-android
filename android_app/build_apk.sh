#!/bin/bash

# Smart Checkout Android APK Build Script
# This script builds the RFID checkout app for distribution

echo "🏗️  Building Smart Checkout APK..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check for any issues
echo "🔍 Running Flutter doctor..."
flutter doctor

# Build release APK
echo "🚀 Building release APK..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    echo ""
    echo "📱 APK Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📋 Installation Instructions:"
    echo "1. Transfer the APK to your Android device"
    echo "2. Enable 'Install from Unknown Sources' in device settings"
    echo "3. Tap the APK file to install"
    echo "4. Grant required permissions when prompted"
    echo ""
    echo "🔧 Hardware Requirements:"
    echo "- USB RFID reader"
    echo "- WisePad 3 Bluetooth payment reader"
    echo "- Android device (API 21+)"
    echo ""
    echo "⚙️  Backend Configuration:"
    echo "Update API URL in lib/services/api_service.dart before building"
else
    echo "❌ Build failed. Check the errors above."
    exit 1
fi
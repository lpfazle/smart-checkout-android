# APK Distribution Guide
## Smart Checkout RFID Android App

### Quick Start

1. **Install Flutter** (if not already installed):
   ```bash
   # Download Flutter SDK
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   flutter doctor
   ```

2. **Build the APK**:
   ```bash
   cd android_app
   ./build_apk.sh
   ```

3. **Distribute APK**:
   - APK file location: `build/app/outputs/flutter-apk/app-release.apk`
   - File size: ~25-35 MB
   - Transfer via USB, email, or cloud storage

### Pre-Build Configuration

Before building, update the backend connection in `lib/services/api_service.dart`:

```dart
class ApiService {
  static const String baseUrl = 'https://your-replit-app.replit.app';
  // Update with your actual backend URL
}
```

### Installation on Android Devices

#### Method 1: Direct Transfer
1. Copy APK file to device storage
2. Open file manager on Android device
3. Navigate to APK file location
4. Tap the APK file
5. Allow "Install from Unknown Sources" when prompted
6. Complete installation

#### Method 2: USB Installation (ADB)
```bash
# Enable USB debugging on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### Method 3: Cloud Distribution
- Upload APK to Google Drive, Dropbox, or similar
- Share download link with users
- Users download and install directly

### Device Requirements

- **Android Version**: 5.0+ (API Level 21)
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 100MB free space
- **Connectivity**: WiFi or mobile data for backend communication
- **Hardware**: USB OTG support for RFID readers

### Hardware Setup

#### RFID Reader Connection
- Connect USB RFID reader via USB OTG adapter
- App automatically detects compatible readers
- Supported vendor IDs: 0x10C4, 0x067B, 0x0403

#### WisePad 3 Payment Reader
- Pair via Bluetooth in Android settings
- App discovers and connects automatically
- Ensure device is charged and within range

### Staff Training Points

1. **App Launch**: Staff login required
2. **Device Pairing**: One-time Bluetooth setup
3. **Checkout Flow**: RFID scan → Cart review → Payment
4. **Error Handling**: Clear error messages with recovery steps
5. **Offline Mode**: Local cart management when connection lost

### Production Deployment Checklist

- [ ] Backend URL configured correctly
- [ ] Shopify integration tested
- [ ] RFID hardware compatibility verified
- [ ] Payment reader connectivity confirmed
- [ ] Staff training completed
- [ ] Error logging enabled
- [ ] Security permissions reviewed

### Troubleshooting Common Issues

**App Won't Install**
- Enable "Unknown Sources" in Security settings
- Ensure sufficient storage space
- Try clearing package installer cache

**RFID Reader Not Detected**
- Verify USB OTG adapter functionality
- Check device USB Host mode support
- Confirm reader vendor ID in app configuration

**Bluetooth Payment Reader Issues**
- Re-pair device in Android Bluetooth settings
- Check location permissions are granted
- Restart Bluetooth service if needed

**Backend Connection Errors**
- Verify network connectivity
- Confirm backend URL is accessible
- Check API endpoint responses

### Security Considerations

- App requires staff authentication
- Local data encrypted in transit
- No sensitive payment data stored locally
- Bluetooth communications secured
- USB permissions managed appropriately

### Distribution Options

#### Internal Distribution
- Direct APK sharing within organization
- USB installation on kiosk devices
- Local network deployment

#### Google Play Store (Optional)
- Requires Play Console account setup
- App review process (2-3 days)
- Automatic updates for users
- Enhanced security and trust

#### Enterprise MDM
- Compatible with Mobile Device Management
- Centralized deployment and updates
- Policy enforcement capabilities
- Remote configuration management

### Support Information

- **App Version**: 1.0.0+1
- **Flutter Version**: 3.10+
- **Target Android**: API 34
- **Minimum Android**: API 21
- **Package**: com.smartcheckout.rfid

### Backend Integration

The app connects to your existing Shopify RFID kiosk system via these endpoints:

- Authentication: `/api/auth/login`
- RFID Scanning: `/api/scan`
- Cart Management: `/api/cart/:sessionId`
- Checkout Processing: `/api/checkout`
- Product Data: `/api/products`

All endpoints support the same data formats as your web kiosk application.
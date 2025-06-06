import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';

class RfidService {
  UsbPort? _port;
  StreamSubscription<String>? _subscription;
  Function(String)? onTagScanned;
  final Set<String> _scannedTags = {};
  Timer? _deduplicationTimer;

  Future<bool> initialize() async {
    try {
      // Get available USB devices
      List<UsbDevice> devices = await UsbSerial.listDevices();
      
      // Look for RFID reader (adjust vendor/product IDs as needed)
      UsbDevice? rfidDevice;
      for (UsbDevice device in devices) {
        // Common RFID reader vendor IDs - adjust based on your hardware
        if (device.vid == 0x10C4 || device.vid == 0x067B || device.vid == 0x0403) {
          rfidDevice = device;
          break;
        }
      }

      if (rfidDevice == null) {
        print('No RFID reader found');
        return false;
      }

      _port = await rfidDevice.create();
      if (_port == null) {
        print('Failed to create USB port');
        return false;
      }

      bool openResult = await _port!.open();
      if (!openResult) {
        print('Failed to open USB port');
        return false;
      }

      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        115200, // Baud rate - adjust for your reader
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      // Start listening for RFID data
      _subscription = _port!.inputStream?.listen(_onDataReceived);
      
      print('RFID reader initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing RFID reader: $e');
      return false;
    }
  }

  void _onDataReceived(Uint8List data) {
    try {
      String receivedData = String.fromCharCodes(data).trim();
      
      // Parse RFID tag data - adjust parsing based on your reader's format
      if (receivedData.isNotEmpty && _isValidRfidTag(receivedData)) {
        _handleTagScanned(receivedData);
      }
    } catch (e) {
      print('Error processing RFID data: $e');
    }
  }

  bool _isValidRfidTag(String data) {
    // Basic validation - adjust based on your tag format
    return data.length >= 8 && RegExp(r'^[0-9A-Fa-f]+$').hasMatch(data);
  }

  void _handleTagScanned(String tagId) {
    // Deduplicate rapid scans of the same tag
    if (_scannedTags.contains(tagId)) {
      return;
    }

    _scannedTags.add(tagId);
    onTagScanned?.call(tagId);

    // Clear the tag from deduplication set after 2 seconds
    _deduplicationTimer?.cancel();
    _deduplicationTimer = Timer(const Duration(seconds: 2), () {
      _scannedTags.remove(tagId);
    });
  }

  Future<void> dispose() async {
    try {
      _subscription?.cancel();
      _deduplicationTimer?.cancel();
      await _port?.close();
      _port = null;
    } catch (e) {
      print('Error disposing RFID service: $e');
    }
  }

  // Send commands to RFID reader if needed
  Future<bool> sendCommand(String command) async {
    try {
      if (_port == null) return false;
      
      await _port!.write(Uint8List.fromList(command.codeUnits));
      return true;
    } catch (e) {
      print('Error sending RFID command: $e');
      return false;
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceProvider with ChangeNotifier {
  BluetoothConnection? _paymentReaderConnection;
  List<BluetoothDevice> _availableDevices = [];
  BluetoothDevice? _pairedPaymentReader;
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _lastError;

  BluetoothConnection? get paymentReaderConnection => _paymentReaderConnection;
  List<BluetoothDevice> get availableDevices => _availableDevices;
  BluetoothDevice? get pairedPaymentReader => _pairedPaymentReader;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  bool get isPaymentReaderConnected => _paymentReaderConnection?.isConnected ?? false;

  Future<void> initializeDevices() async {
    await _loadSavedDevices();
    await _requestPermissions();
    
    if (_pairedPaymentReader != null) {
      await _connectToPaymentReader(_pairedPaymentReader!);
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  Future<void> _loadSavedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceAddress = prefs.getString('payment_reader_address');
      final deviceName = prefs.getString('payment_reader_name');
      
      if (deviceAddress != null && deviceName != null) {
        _pairedPaymentReader = BluetoothDevice(
          address: deviceAddress,
          name: deviceName,
        );
        notifyListeners();
      }
    } catch (e) {
      _lastError = 'Failed to load saved devices: $e';
      notifyListeners();
    }
  }

  Future<void> scanForDevices() async {
    _isScanning = true;
    _lastError = null;
    _availableDevices.clear();
    notifyListeners();

    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      _availableDevices = devices.where((device) => 
        device.name?.toLowerCase().contains('wisepad') ?? false ||
        device.name?.toLowerCase().contains('shopify') ?? false
      ).toList();
      
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to scan for devices: $e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> pairWithPaymentReader(BluetoothDevice device) async {
    _isConnecting = true;
    _lastError = null;
    notifyListeners();

    try {
      final connected = await _connectToPaymentReader(device);
      if (connected) {
        _pairedPaymentReader = device;
        await _saveDeviceSettings(device);
        return true;
      }
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<bool> _connectToPaymentReader(BluetoothDevice device) async {
    try {
      _paymentReaderConnection = await BluetoothConnection.toAddress(device.address);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Failed to connect to payment reader: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveDeviceSettings(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_reader_address', device.address);
    await prefs.setString('payment_reader_name', device.name ?? 'Unknown Device');
  }

  Future<void> disconnectPaymentReader() async {
    try {
      await _paymentReaderConnection?.close();
      _paymentReaderConnection = null;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to disconnect payment reader: $e';
      notifyListeners();
    }
  }

  Future<void> resetDeviceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('payment_reader_address');
    await prefs.remove('payment_reader_name');
    
    await disconnectPaymentReader();
    _pairedPaymentReader = null;
    _availableDevices.clear();
    
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
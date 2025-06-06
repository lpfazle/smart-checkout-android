import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checkout/providers/device_provider.dart';
import 'package:smart_checkout/screens/checkout_screen.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceSetupScreen extends StatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().initializeDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Setup'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bluetooth,
                              color: deviceProvider.isPaymentReaderConnected
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Payment Reader',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          deviceProvider.isPaymentReaderConnected
                              ? 'Connected: ${deviceProvider.pairedPaymentReader?.name ?? "Unknown"}'
                              : 'Not connected',
                          style: TextStyle(
                            color: deviceProvider.isPaymentReaderConnected
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        if (deviceProvider.lastError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            deviceProvider.lastError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!deviceProvider.isPaymentReaderConnected) ...[
                  ElevatedButton.icon(
                    onPressed: deviceProvider.isScanning
                        ? null
                        : () => deviceProvider.scanForDevices(),
                    icon: deviceProvider.isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      deviceProvider.isScanning ? 'Scanning...' : 'Scan for Devices',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (deviceProvider.availableDevices.isNotEmpty) ...[
                  const Text(
                    'Available Payment Readers:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deviceProvider.availableDevices.length,
                      itemBuilder: (context, index) {
                        final device = deviceProvider.availableDevices[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(device.name ?? 'Unknown Device'),
                            subtitle: Text(device.address),
                            trailing: deviceProvider.isConnecting
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.arrow_forward_ios),
                            onTap: deviceProvider.isConnecting
                                ? null
                                : () => _pairDevice(device),
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (deviceProvider.isPaymentReaderConnected) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Setup Complete!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your payment reader is connected and ready to use.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _navigateToCheckout(),
                      child: const Text(
                        'Start Checkout',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Tap "Scan for Devices" to find your WisePad 3 payment reader',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => deviceProvider.resetDeviceSettings(),
                        child: const Text('Reset Settings'),
                      ),
                    ),
                    if (deviceProvider.isPaymentReaderConnected)
                      Expanded(
                        child: TextButton(
                          onPressed: () => _navigateToCheckout(),
                          child: const Text('Skip to Checkout'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pairDevice(BluetoothDevice device) async {
    final success = await context.read<DeviceProvider>().pairWithPaymentReader(device);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToCheckout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checkout/providers/cart_provider.dart';
import 'package:smart_checkout/providers/device_provider.dart';
import 'package:smart_checkout/services/rfid_service.dart';
import 'package:smart_checkout/widgets/cart_item_widget.dart';
import 'package:smart_checkout/screens/payment_screen.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final RfidService _rfidService = RfidService();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().refreshCart();
      _initializeRfidScanning();
    });
  }

  Future<void> _initializeRfidScanning() async {
    await _rfidService.initialize();
    _rfidService.onTagScanned = _handleRfidScan;
  }

  Future<void> _handleRfidScan(String rfidTagId) async {
    if (_isScanning) return;
    
    setState(() => _isScanning = true);
    
    final success = await context.read<CartProvider>().addProductByRfid(rfidTagId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else if (mounted) {
      final error = context.read<CartProvider>().lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to add product'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => _isScanning = false);
  }

  Future<void> _simulateRfidScan() async {
    // Simulate RFID scan for testing
    final testRfidTags = [
      '300833B2DDD9014000000001',
      '300833B2DDD9014000000002', 
      '300833B2DDD9014000000003',
    ];
    
    final randomTag = testRfidTags[DateTime.now().millisecond % testRfidTags.length];
    await _handleRfidScan(randomTag);
  }

  @override
  void dispose() {
    _rfidService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Checkout'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<DeviceProvider>(
            builder: (context, deviceProvider, child) {
              return Icon(
                Icons.bluetooth,
                color: deviceProvider.isPaymentReaderConnected 
                    ? Colors.green 
                    : Colors.grey,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            children: [
              // Scan Button Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isScanning ? Colors.orange : Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: (_isScanning ? Colors.orange : Theme.of(context).primaryColor)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: _isScanning ? null : _simulateRfidScan,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isScanning ? Icons.hourglass_empty : Icons.nfc,
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _isScanning ? 'Scanning...' : 'Tap to Scan',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hold RFID tags near the reader to add items to your cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Cart Items Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cart (${cartProvider.itemCount} items)',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (cartProvider.items.isNotEmpty)
                              Text(
                                NumberFormat.currency(symbol: '\$').format(cartProvider.totalAmount),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: cartProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : cartProvider.items.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Your cart is empty',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Scan RFID tags to add items',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: cartProvider.items.length,
                                    itemBuilder: (context, index) {
                                      return CartItemWidget(
                                        cartItem: cartProvider.items[index],
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) return const SizedBox.shrink();
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total (incl. GST):',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(cartProvider.totalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: cartProvider.isLoading ? null : _proceedToPayment,
                      child: cartProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Pay Now',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _proceedToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
      ),
    );
  }
}
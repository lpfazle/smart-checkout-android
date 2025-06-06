import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checkout/providers/cart_provider.dart';
import 'package:smart_checkout/providers/device_provider.dart';
import 'package:smart_checkout/screens/success_screen.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String _paymentStatus = 'Ready to pay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Consumer2<CartProvider, DeviceProvider>(
        builder: (context, cartProvider, deviceProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Order Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items (${cartProvider.itemCount})'),
                            Text(NumberFormat.currency(symbol: '\$').format(cartProvider.totalAmount)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('GST (included)'),
                            Text('10%'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Reader Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card,
                              color: deviceProvider.isPaymentReaderConnected
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              deviceProvider.isPaymentReaderConnected
                                  ? 'Payment Reader Connected'
                                  : 'Payment Reader Not Connected',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _paymentStatus,
                          style: TextStyle(
                            color: _isProcessing ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Payment Instructions
                if (!_isProcessing) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Payment Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Tap "Process Payment" below\n'
                          '2. Insert, tap, or swipe your card\n'
                          '3. Follow prompts on the payment reader\n'
                          '4. Wait for confirmation',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Processing Payment...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please follow the instructions on the payment reader',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Payment Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    child: _isProcessing
                        ? const Text('Processing...')
                        : const Text(
                            'Process Payment',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                TextButton(
                  onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _paymentStatus = 'Initiating payment...';
    });

    try {
      // Simulate payment processing steps
      await _simulatePaymentFlow();

      // Process checkout with backend
      final result = await context.read<CartProvider>().checkout();

      if (result != null && result['success'] == true && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SuccessScreen(orderResult: result),
          ),
        );
      } else {
        _showPaymentError('Payment failed. Please try again.');
      }
    } catch (e) {
      _showPaymentError('Payment error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _paymentStatus = 'Ready to pay';
        });
      }
    }
  }

  Future<void> _simulatePaymentFlow() async {
    // Simulate WisePad 3 payment flow
    final steps = [
      'Connecting to payment reader...',
      'Present your card...',
      'Processing payment...',
      'Waiting for approval...',
      'Payment approved!',
    ];

    for (int i = 0; i < steps.length; i++) {
      if (!mounted) break;
      
      setState(() => _paymentStatus = steps[i]);
      await Future.delayed(Duration(milliseconds: 800 + (i * 200)));
    }
  }

  void _showPaymentError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
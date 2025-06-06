import 'package:flutter/material.dart';
import 'package:smart_checkout/screens/checkout_screen.dart';
import 'package:intl/intl.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> orderResult;

  const SuccessScreen({super.key, required this.orderResult});

  @override
  Widget build(BuildContext context) {
    final orderNumber = orderResult['orderNumber'] ?? 'Unknown';
    final totalAmount = orderResult['totalAmount'] ?? '0.00';
    final qrToken = orderResult['qrToken'];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your order has been processed and sent to Shopify',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order Number:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(orderNumber),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            NumberFormat.currency(symbol: '\$').format(double.tryParse(totalAmount) ?? 0.0),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payment Method:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('Card Payment'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Date:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (qrToken != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.qr_code,
                          size: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Order Summary Available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share token: $qrToken',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _startNewTransaction(context),
                      child: const Text(
                        'Start New Transaction',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Back to Main Menu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewTransaction(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
      (route) => false,
    );
  }
}
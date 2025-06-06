import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checkout/providers/auth_provider.dart';
import 'package:smart_checkout/screens/login_screen.dart';
import 'package:smart_checkout/screens/device_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await context.read<AuthProvider>().checkAuthStatus();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isAuthenticated 
            ? const DeviceSetupScreen()
            : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Smart Checkout',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'RFID Self-Serve Kiosk',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
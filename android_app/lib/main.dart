import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checkout/providers/auth_provider.dart';
import 'package:smart_checkout/providers/cart_provider.dart';
import 'package:smart_checkout/providers/device_provider.dart';
import 'package:smart_checkout/screens/splash_screen.dart';
import 'package:smart_checkout/services/api_service.dart';
import 'package:smart_checkout/utils/theme.dart';

void main() {
  runApp(const SmartCheckoutApp());
}

class SmartCheckoutApp extends StatelessWidget {
  const SmartCheckoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: 'Smart Checkout',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
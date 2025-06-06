import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_checkout/models/product.dart';
import 'package:smart_checkout/models/cart_item.dart';

class ApiService {
  static const String baseUrl = 'https://b4f54672-e089-482f-aae1-a8b0d58d4bcf-00-3w1xqedvr1ve2.worf.replit.dev/api';
  
  // Scan RFID tag and get product
  Future<Product?> scanRfid(String rfidTagId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rfidTagId': rfidTagId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return Product.fromJson(data['product']);
        }
      }
      return null;
    } catch (e) {
      print('Error scanning RFID: $e');
      return null;
    }
  }

  // Get cart items for mobile session
  Future<List<CartItem>> getCartItems(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart?sessionId=$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CartItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Checkout and create Shopify order
  Future<Map<String, dynamic>?> checkout(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error during checkout: $e');
      return null;
    }
  }

  // Clear cart after successful payment
  Future<bool> clearCart(String sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/clear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // Get order summary by token (for QR sharing)
  Future<Map<String, dynamic>?> getOrderSummary(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/order-summary/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting order summary: $e');
      return null;
    }
  }
}
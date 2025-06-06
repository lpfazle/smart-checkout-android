import 'package:flutter/foundation.dart';
import 'package:smart_checkout/models/cart_item.dart';
import 'package:smart_checkout/models/product.dart';
import 'package:smart_checkout/services/api_service.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String _sessionId = const Uuid().v4();
  
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _lastError;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  String get sessionId => _sessionId;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => _items.length;

  Future<void> refreshCart() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _items = await _apiService.getCartItems(_sessionId);
    } catch (e) {
      _lastError = 'Failed to refresh cart: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProductByRfid(String rfidTagId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final product = await _apiService.scanRfid(rfidTagId);
      if (product != null) {
        await refreshCart();
        return true;
      } else {
        _lastError = 'Product not found for RFID tag';
        return false;
      }
    } catch (e) {
      _lastError = 'Failed to scan RFID: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> checkout() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _apiService.checkout(_sessionId);
      if (result != null && result['success'] == true) {
        _items.clear();
        notifyListeners();
        return result;
      } else {
        _lastError = 'Checkout failed';
        return null;
      }
    } catch (e) {
      _lastError = 'Checkout error: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/models/coupon_model.dart';
import '../data/services/storage_service.dart';

class CartProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;

  // Coupon state
  CouponValidationModel? _appliedCoupon;
  String? _couponError;
  bool _isValidatingCoupon = false;

  // Shipping
  double _shippingFee = AppConstants.defaultShippingFee;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  CouponValidationModel? get appliedCoupon => _appliedCoupon;
  String? get couponError => _couponError;
  bool get isValidatingCoupon => _isValidatingCoupon;
  double get shippingFee => _shippingFee;

  int get cartCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => _appliedCoupon?.discountAmount ?? 0.0;

  double get totalAmount {
    if (_items.isEmpty) return 0.0;
    final total = subtotal - discountAmount + _shippingFee;
    return total > 0 ? total : 0.0;
  }

  CartProvider() {
    _loadLocalCart();
  }

  void setShippingFee(double fee) {
    _shippingFee = fee;
    notifyListeners();
  }

  void _loadLocalCart() {
    _items = _storage.getCart();
    notifyListeners();
    if (_storage.isAuthenticated) {
      syncWithServer();
    }
  }

  Future<void> syncWithServer() async {
    if (!_storage.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.get(ApiEndpoints.cart);
      if (response is List) {
        _items = response
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
        await _storage.saveCart(_items);
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere((i) => i.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItemModel(
          id: 'cart-${product.id}',
          product: product,
          quantity: quantity,
        ),
      );
    }

    await _storage.saveCart(_items);
    notifyListeners();

    // Sync to backend if authenticated
    if (_storage.isAuthenticated) {
      try {
        await _api.post(
          ApiEndpoints.cart,
          data: {'product': product.id, 'quantity': quantity},
        );
      } catch (_) {}
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      await _storage.saveCart(_items);
      notifyListeners();

      if (_storage.isAuthenticated) {
        try {
          await _api.put(
            ApiEndpoints.updateCartItem(_items[index].id),
            data: {'quantity': newQuantity},
          );
        } catch (_) {}
      }
    }
  }

  Future<void> removeFromCart(String productId) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final cartItemId = _items[index].id;
      _items.removeAt(index);
      await _storage.saveCart(_items);
      notifyListeners();

      if (_storage.isAuthenticated) {
        try {
          await _api.delete(ApiEndpoints.deleteCartItem(cartItemId));
        } catch (_) {}
      }
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    _appliedCoupon = null;
    await _storage.clearCart();
    notifyListeners();

    if (_storage.isAuthenticated) {
      try {
        await _api.delete(ApiEndpoints.clearCart);
      } catch (_) {}
    }
  }

  Future<bool> applyCoupon(String code) async {
    if (code.trim().isEmpty) return false;
    _isValidatingCoupon = true;
    _couponError = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiEndpoints.validateCoupon,
        data: {
          'code': code.trim(),
          'order_total': subtotal,
        },
      );

      _appliedCoupon = CouponValidationModel.fromJson(response);
      _isValidatingCoupon = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _couponError = e.message;
      _appliedCoupon = null;
      _isValidatingCoupon = false;
      notifyListeners();
      return false;
    } catch (_) {
      _couponError = 'কুপন যাচাইকরণে ব্যর্থ হয়েছে।';
      _appliedCoupon = null;
      _isValidatingCoupon = false;
      notifyListeners();
      return false;
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }
}

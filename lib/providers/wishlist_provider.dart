import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../data/models/product_model.dart';
import '../data/models/wishlist_model.dart';
import '../data/services/storage_service.dart';
import '../data/services/mock_fallback_data.dart';

class WishlistProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  List<ProductModel> _items = [];
  bool _isLoading = false;

  List<ProductModel> get items => _items;
  int get wishlistCount => _items.length;
  bool get isLoading => _isLoading;

  WishlistProvider() {
    _loadLocalWishlist();
  }

  void _loadLocalWishlist() {
    final ids = _storage.getWishlistProductIds();
    if (ids.isNotEmpty) {
      _items = MockFallbackData.products.where((p) => ids.contains(p.id)).toList();
    }
    notifyListeners();
    if (_storage.isAuthenticated) {
      loadWishlist();
    }
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  Future<void> loadWishlist() async {
    if (!_storage.isAuthenticated) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiEndpoints.wishlist);
      if (response is List) {
        _items = response
            .map((item) => WishlistItemModel.fromJson(item as Map<String, dynamic>).product)
            .toList();
        await _storage.saveWishlistProductIds(_items.map((i) => i.id).toList());
      }
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(ProductModel product) async {
    final index = _items.indexWhere((i) => i.id == product.id);

    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }

    await _storage.saveWishlistProductIds(_items.map((i) => i.id).toList());
    notifyListeners();

    if (_storage.isAuthenticated) {
      try {
        await _api.post(
          ApiEndpoints.wishlistToggle,
          data: {'product': product.id},
        );
      } catch (_) {}
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final index = _items.indexWhere((i) => i.id == productId);
    if (index >= 0) {
      _items.removeAt(index);
      await _storage.saveWishlistProductIds(_items.map((i) => i.id).toList());
      notifyListeners();

      if (_storage.isAuthenticated) {
        try {
          await _api.post(
            ApiEndpoints.wishlistToggle,
            data: {'product': productId},
          );
        } catch (_) {}
      }
    }
  }
}

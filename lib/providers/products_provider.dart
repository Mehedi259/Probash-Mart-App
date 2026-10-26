import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../data/models/product_model.dart';
import '../data/services/mock_fallback_data.dart';

class ProductsProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  // Home Screen Collections
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _bestSellers = [];
  List<ProductModel> _flashDeals = [];

  // Browsing & Filtering
  List<ProductModel> _products = [];
  List<ProductModel> _searchResults = [];

  bool _isLoadingHome = false;
  bool _isLoadingProducts = false;
  bool _isSearching = false;
  String? _errorMessage;

  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get bestSellers => _bestSellers;
  List<ProductModel> get flashDeals => _flashDeals;
  List<ProductModel> get products => _products;
  List<ProductModel> get searchResults => _searchResults;

  bool get isLoadingHome => _isLoadingHome;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  ProductsProvider() {
    loadHomeData();
  }

  Future<void> loadHomeData({bool forceRefresh = false}) async {
    if (_featuredProducts.isNotEmpty && !forceRefresh) return;

    _isLoadingHome = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch Featured
      try {
        final featRes = await _api.get(ApiEndpoints.featuredProducts);
        _featuredProducts = _parseProductList(featRes);
      } catch (_) {}

      // 2. Fetch Best Sellers
      try {
        final bestRes = await _api.get(ApiEndpoints.bestSellers);
        _bestSellers = _parseProductList(bestRes);
      } catch (_) {}

      // 3. Fetch Flash Deals
      try {
        final flashRes = await _api.get(ApiEndpoints.flashDeals);
        _flashDeals = _parseProductList(flashRes);
      } catch (_) {}

      // 4. Fallback if empty
      if (_featuredProducts.isEmpty) {
        // Try general products endpoint
        final genRes = await _api.get(ApiEndpoints.products, queryParameters: {'page_size': 20});
        final all = _parseProductList(genRes);
        if (all.isNotEmpty) {
          _featuredProducts = all.where((p) => p.isFeatured).toList();
          _bestSellers = all.where((p) => p.isBestSeller).toList();
          _flashDeals = all.where((p) => p.isFlashDeal).toList();

          if (_featuredProducts.isEmpty) _featuredProducts = all.take(8).toList();
          if (_bestSellers.isEmpty) _bestSellers = all.skip(4).take(8).toList();
          if (_flashDeals.isEmpty) _flashDeals = all.take(6).toList();
        }
      }

      // If still empty, use authentic local fallback
      if (_featuredProducts.isEmpty) {
        _featuredProducts = MockFallbackData.products;
        _bestSellers = MockFallbackData.products.where((p) => p.isBestSeller).toList();
        _flashDeals = MockFallbackData.products.where((p) => p.isFlashDeal).toList();
      }
    } catch (e) {
      _featuredProducts = MockFallbackData.products;
      _bestSellers = MockFallbackData.products;
      _flashDeals = MockFallbackData.products;
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({
    String? categorySlug,
    String? ordering,
    int page = 1,
  }) async {
    _isLoadingProducts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String endpoint = ApiEndpoints.products;
      final Map<String, dynamic> params = {'page': page, 'page_size': 20};

      if (categorySlug != null && categorySlug.isNotEmpty) {
        endpoint = ApiEndpoints.productsByCategory(categorySlug);
      }
      if (ordering != null && ordering.isNotEmpty) {
        params['ordering'] = ordering;
      }

      final response = await _api.get(endpoint, queryParameters: params);
      _products = _parseProductList(response);

      if (_products.isEmpty && categorySlug != null) {
        _products = MockFallbackData.products.where(
          (p) => p.categoryName?.toLowerCase().replaceAll(' ', '-') == categorySlug.toLowerCase(),
        ).toList();
        if (_products.isEmpty) {
          _products = MockFallbackData.products;
        }
      }
    } catch (_) {
      _products = MockFallbackData.products;
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final response = await _api.get(
        ApiEndpoints.products,
        queryParameters: {'search': query.trim()},
      );
      _searchResults = _parseProductList(response);
    } catch (_) {
      // Local search fallback
      _searchResults = MockFallbackData.products
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              (p.categoryName?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> getProductDetail(String slugOrId) async {
    try {
      final response = await _api.get(ApiEndpoints.productDetail(slugOrId));
      return ProductModel.fromJson(response);
    } catch (_) {
      // Find in existing memory or fallback
      final found = [..._featuredProducts, ..._products, ...MockFallbackData.products]
          .firstWhere((p) => p.slug == slugOrId || p.id == slugOrId,
              orElse: () => MockFallbackData.products.first);
      return found;
    }
  }

  List<ProductModel> _parseProductList(dynamic response) {
    List<ProductModel> list = [];
    if (response is Map<String, dynamic> && response['results'] is List) {
      list = (response['results'] as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response is List) {
      list = response
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return list;
  }
}

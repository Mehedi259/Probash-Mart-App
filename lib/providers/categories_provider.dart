import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../data/models/category_model.dart';
import '../data/services/mock_fallback_data.dart';

class CategoriesProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  CategoryModel? _selectedCategory;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CategoryModel? get selectedCategory => _selectedCategory;

  CategoriesProvider() {
    loadCategories();
  }

  void selectCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (_categories.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiEndpoints.categories);
      if (response is List) {
        _categories = response
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .where((cat) => cat.isActive)
            .toList();
      }

      if (_categories.isEmpty) {
        _categories = MockFallbackData.categories;
      }
    } catch (e) {
      // Graceful offline fallback
      _categories = MockFallbackData.categories;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

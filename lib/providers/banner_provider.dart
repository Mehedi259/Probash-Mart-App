import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../data/models/banner_model.dart';
import '../data/services/mock_fallback_data.dart';

class BannerProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<BannerModel> _banners = [];
  bool _isLoading = false;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;

  BannerProvider() {
    loadBanners();
  }

  Future<void> loadBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiEndpoints.banners);
      if (response is List && response.isNotEmpty) {
        _banners = response
            .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
            .where((b) => b.isActive)
            .toList();
      }
      if (_banners.isEmpty) {
        _banners = MockFallbackData.banners;
      }
    } catch (_) {
      _banners = MockFallbackData.banners;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

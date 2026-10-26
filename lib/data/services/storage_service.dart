import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  SharedPreferences? _prefs;

  StorageService._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token Management
  String? get accessToken => _prefs?.getString(AppConstants.keyAccessToken);
  String? get refreshToken => _prefs?.getString(AppConstants.keyRefreshToken);

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _prefs?.setString(AppConstants.keyAccessToken, access);
    await _prefs?.setString(AppConstants.keyRefreshToken, refresh);
  }

  Future<void> clearAuth() async {
    await _prefs?.remove(AppConstants.keyAccessToken);
    await _prefs?.remove(AppConstants.keyRefreshToken);
    await _prefs?.remove(AppConstants.keyUserData);
  }

  // User Profile
  UserModel? getUser() {
    final raw = _prefs?.getString(AppConstants.keyUserData);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  // Cart Persistence
  List<CartItemModel> getCart() {
    final raw = _prefs?.getString(AppConstants.keyCartData);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((i) => CartItemModel.fromJson(i)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItemModel> items) async {
    final list = items.map((i) => i.toJson()).toList();
    await _prefs?.setString(AppConstants.keyCartData, jsonEncode(list));
  }

  Future<void> clearCart() async {
    await _prefs?.remove(AppConstants.keyCartData);
  }

  // Wishlist Persistence
  List<String> getWishlistProductIds() {
    return _prefs?.getStringList(AppConstants.keyWishlistData) ?? [];
  }

  Future<void> saveWishlistProductIds(List<String> ids) async {
    await _prefs?.setStringList(AppConstants.keyWishlistData, ids);
  }

  // Onboarding
  bool get hasSeenOnboarding => _prefs?.getBool(AppConstants.keyHasSeenOnboarding) ?? false;

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs?.setBool(AppConstants.keyHasSeenOnboarding, value);
  }

  // Custom Base URL
  String? get customBaseUrl => _prefs?.getString(AppConstants.keyBaseUrl);

  Future<void> setCustomBaseUrl(String url) async {
    await _prefs?.setString(AppConstants.keyBaseUrl, url);
  }
}

import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../data/models/user_model.dart';
import '../data/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _storage.isAuthenticated;

  AuthProvider() {
    _initUser();
  }

  void _initUser() {
    _user = _storage.getUser();
    if (_storage.isAuthenticated) {
      loadProfile();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password},
      );

      final access = response['access']?.toString() ?? '';
      final refresh = response['refresh']?.toString() ?? '';
      await _storage.saveTokens(access: access, refresh: refresh);

      if (response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
        await _storage.saveUser(_user!);
      } else {
        await loadProfile();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'লগইন করতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiEndpoints.register,
        data: {
          'email': email.trim(),
          'password': password,
          'username': email.trim().split('@').first,
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'phone': phone?.trim() ?? '',
        },
      );

      // If backend returns tokens on register, save them
      if (response['access'] != null) {
        final access = response['access'].toString();
        final refresh = response['refresh']?.toString() ?? '';
        await _storage.saveTokens(access: access, refresh: refresh);
      }

      if (response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
        await _storage.saveUser(_user!);
      } else {
        // Automatically login if registration succeeded without direct tokens
        return await login(email, password);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'রেজিস্ট্রেশন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    if (!_storage.isAuthenticated) return;
    try {
      final response = await _api.get(ApiEndpoints.profile);
      _user = UserModel.fromJson(response);
      await _storage.saveUser(_user!);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.put(ApiEndpoints.profile, data: data);
      _user = UserModel.fromJson(response);
      await _storage.saveUser(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'প্রোফাইল আপডেট ব্যর্থ হয়েছে।';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.post(
        ApiEndpoints.changePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'পাসওয়ার্ড পরিবর্তন করতে ব্যর্থ হয়েছে।';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refresh = _storage.refreshToken;
      if (refresh != null) {
        await _api.post(ApiEndpoints.logout, data: {'refresh': refresh});
      }
    } catch (_) {}
    await _storage.clearAuth();
    _user = null;
    notifyListeners();
  }
}

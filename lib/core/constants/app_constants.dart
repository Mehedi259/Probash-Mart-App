class AppConstants {
  AppConstants._();

  static const String appName = 'Probash Mart';
  static const String appTagline = 'প্রবাসী ভাই-বোনদের বিশ্বস্ত গ্রোসারি শপ';
  static const String currencySymbol = '৳';
  static const String whatsappNumber = '96894578538'; // +968 9457 8538
  static const String supportPhone = '+96894578538';
  static const String supportEmail = 'support@probashmart.com';
  static const String websiteUrl = 'https://probashmart.com';

  // Default dynamic base URL detection
  // Production live API with SSL & Cloudflare CDN
  static const String productionBaseUrl = 'https://api.probashmart.com';
  static const String serverDirectUrl = 'http://46.225.103.236:8003';

  static String get defaultBaseUrl {
    return productionBaseUrl;
  }

  // Storage Keys
  static const String keyAccessToken = 'pm_access_token';
  static const String keyRefreshToken = 'pm_refresh_token';
  static const String keyUserData = 'pm_user_data';
  static const String keyCartData = 'pm_cart_data';
  static const String keyWishlistData = 'pm_wishlist_data';
  static const String keyBaseUrl = 'pm_custom_base_url';
  static const String keyHasSeenOnboarding = 'pm_has_seen_onboarding';

  // Pagination
  static const int defaultPageSize = 20;

  // Shipping
  static const double defaultShippingFee = 50.0;
}

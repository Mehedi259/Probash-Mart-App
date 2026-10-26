class ApiEndpoints {
  ApiEndpoints._();

  static const String prefix = '/api/v1';

  // Auth
  static const String login = '$prefix/auth/login/';
  static const String register = '$prefix/auth/register/';
  static const String refreshToken = '$prefix/auth/token/refresh/';
  static const String logout = '$prefix/auth/logout/';
  static const String profile = '$prefix/auth/profile/';
  static const String changePassword = '$prefix/auth/change-password/';

  // Products
  static const String products = '$prefix/products/';
  static const String featuredProducts = '$prefix/products/featured/';
  static const String bestSellers = '$prefix/products/best-sellers/';
  static const String flashDeals = '$prefix/products/flash-deals/';
  static String productDetail(String slug) => '$prefix/products/$slug/';
  static String productsByCategory(String slug) => '$prefix/products/category/$slug/';

  // Categories
  static const String categories = '$prefix/categories/';

  // Cart
  static const String cart = '$prefix/cart/';
  static String updateCartItem(String id) => '$prefix/cart/$id/update/';
  static String deleteCartItem(String id) => '$prefix/cart/$id/delete/';
  static const String clearCart = '$prefix/cart/clear/';

  // Wishlist
  static const String wishlist = '$prefix/wishlist/';
  static const String wishlistToggle = '$prefix/wishlist/toggle/';
  static String deleteWishlistItem(String id) => '$prefix/wishlist/$id/delete/';

  // Orders
  static const String createOrder = '$prefix/orders/create/';
  static const String myOrders = '$prefix/orders/my-orders/';
  static String orderDetail(String id) => '$prefix/orders/my-orders/$id/';
  static String trackOrder(String orderNumber) => '$prefix/orders/track/$orderNumber/';

  // Coupons
  static const String validateCoupon = '$prefix/coupons/validate/';

  // Banners
  static const String banners = '$prefix/banners/';

  // Shipping
  static const String shipping = '$prefix/shipping/';

  // Payment Methods
  static const String paymentMethods = '$prefix/payments/methods/';

  // Reviews
  static String productReviews(String productId) => '$prefix/reviews/product/$productId/';
}

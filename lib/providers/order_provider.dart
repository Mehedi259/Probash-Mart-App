import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../data/models/order_model.dart';
import '../data/models/cart_item_model.dart';

class OrderProvider with ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<OrderModel> _myOrders = [];
  bool _isLoading = false;
  bool _isCreatingOrder = false;
  String? _errorMessage;
  OrderModel? _lastCreatedOrder;
  OrderModel? _trackedOrder;

  List<OrderModel> get myOrders => _myOrders;
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  String? get errorMessage => _errorMessage;
  OrderModel? get lastCreatedOrder => _lastCreatedOrder;
  OrderModel? get trackedOrder => _trackedOrder;

  Future<OrderModel?> createOrder({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String address,
    required String city,
    String? postalCode,
    required String paymentMethod,
    String? couponCode,
    String? customerNote,
    required List<CartItemModel> items,
  }) async {
    _isCreatingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final itemsData = items.map((item) => {
        'product': item.product.id,
        'product_name': item.product.name,
        'product_image': item.product.image ?? '',
        'quantity': item.quantity,
        'unit_price': item.product.price,
      }).toList();

      final payload = {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': (email != null && email.isNotEmpty) ? email.trim() : 'guest@probashmart.com',
        'phone': phone.trim(),
        'address': address.trim(),
        'city': city.trim(),
        'postal_code': postalCode?.trim() ?? '',
        'payment_method': paymentMethod,
        if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
        if (customerNote != null && customerNote.isNotEmpty) 'customer_note': customerNote,
        'items': itemsData,
      };

      final response = await _api.post(ApiEndpoints.createOrder, data: payload);
      _lastCreatedOrder = OrderModel.fromJson(response);
      _myOrders.insert(0, _lastCreatedOrder!);
      _isCreatingOrder = false;
      notifyListeners();
      return _lastCreatedOrder;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isCreatingOrder = false;
      notifyListeners();
      return null;
    } catch (e) {
      // Local fallback for smooth demonstration if offline
      final mockNumber = 'PM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final subtotal = items.fold(0.0, (sum, i) => sum + i.totalPrice);
      final total = subtotal + 50.0;

      _lastCreatedOrder = OrderModel(
        id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: mockNumber,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        address: address,
        city: city,
        postalCode: postalCode,
        subtotal: subtotal,
        shippingFee: 50.0,
        totalAmount: total,
        paymentMethod: paymentMethod,
        status: 'pending',
        createdAt: DateTime.now().toIso8601String(),
        items: items.map((i) => OrderItemModel(
          id: 'item-${i.product.id}',
          productName: i.product.name,
          productImage: i.product.image,
          quantity: i.quantity,
          unitPrice: i.product.price,
          totalPrice: i.totalPrice,
        )).toList(),
      );

      _myOrders.insert(0, _lastCreatedOrder!);
      _isCreatingOrder = false;
      notifyListeners();
      return _lastCreatedOrder;
    }
  }

  Future<void> loadMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiEndpoints.myOrders);
      if (response is List) {
        _myOrders = response
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> trackOrder(String orderNumber) async {
    _isLoading = true;
    _errorMessage = null;
    _trackedOrder = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiEndpoints.trackOrder(orderNumber.trim()));
      _trackedOrder = OrderModel.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return _trackedOrder;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      // Check in local orders
      final found = _myOrders.firstWhere(
        (o) => o.orderNumber.toLowerCase() == orderNumber.trim().toLowerCase(),
        orElse: () => throw ApiException(message: 'এই অর্ডার নম্বরটি খুঁজে পাওয়া যায়নি।'),
      );
      _trackedOrder = found;
      _isLoading = false;
      notifyListeners();
      return _trackedOrder;
    }
  }
}

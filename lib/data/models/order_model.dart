class OrderItemModel {
  final String id;
  final String? productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemModel({
    required this.id,
    this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product']?.toString(),
      productName: json['product_name']?.toString() ?? 'পণ্য',
      productImage: json['product_image']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? couponCode;
  final String status;
  final String? customerNote;
  final String? trackingNumber;
  final String? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    required this.subtotal,
    this.shippingFee = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.paymentMethod = 'cod',
    this.paymentStatus = 'pending',
    this.couponCode,
    this.status = 'pending',
    this.customerNote,
    this.trackingNumber,
    this.createdAt,
    this.items = const [],
  });

  String get customerFullName => '$firstName $lastName'.trim();

  String get statusDisplayBengali {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'অপেক্ষমান (Pending)';
      case 'processing':
        return 'প্রক্রিয়াধীন (Processing)';
      case 'shipped':
        return 'ডেলিভারিতে বের হয়েছে (Shipped)';
      case 'delivered':
        return 'ডেলিভারি সম্পন্ন (Delivered)';
      case 'cancelled':
        return 'বাতিলকৃত (Cancelled)';
      case 'refunded':
        return 'রিফান্ডকৃত (Refunded)';
      default:
        return status;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> itemsList = [];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      country: json['country']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      shippingFee: double.tryParse(json['shipping_fee']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method']?.toString() ?? 'cod',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      couponCode: json['coupon_code']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      customerNote: json['customer_note']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      createdAt: json['created_at']?.toString(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'coupon_code': couponCode,
      'status': status,
      'customer_note': customerNote,
      'tracking_number': trackingNumber,
      'created_at': createdAt,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

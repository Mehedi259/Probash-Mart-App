import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    ProductModel prod;
    if (json['product_detail'] != null && json['product_detail'] is Map) {
      prod = ProductModel.fromJson(json['product_detail']);
    } else if (json['product'] is Map) {
      prod = ProductModel.fromJson(json['product']);
    } else {
      // In local cache, we store product object under 'product'
      prod = ProductModel.fromJson(json['product'] is Map ? json['product'] : json);
    }

    return CartItemModel(
      id: json['id']?.toString() ?? prod.id,
      product: prod,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}

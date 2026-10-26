import 'product_model.dart';

class WishlistItemModel {
  final String id;
  final ProductModel product;

  WishlistItemModel({
    required this.id,
    required this.product,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    ProductModel prod;
    if (json['product'] is Map) {
      prod = ProductModel.fromJson(json['product']);
    } else {
      prod = ProductModel.fromJson(json);
    }

    return WishlistItemModel(
      id: json['id']?.toString() ?? prod.id,
      product: prod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
    };
  }
}

class ProductImageModel {
  final String id;
  final String image;
  final String? altText;
  final int sortOrder;

  ProductImageModel({
    required this.id,
    required this.image,
    this.altText,
    this.sortOrder = 0,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      altText: json['alt_text']?.toString(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': image,
    'alt_text': altText,
    'sort_order': sortOrder,
  };
}

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final double price;
  final double? comparePrice;
  final String? image;
  final String? weight;
  final String? unit;
  final String? categoryId;
  final String? categoryName;
  final bool isBestSeller;
  final bool isFeatured;
  final bool isFlashDeal;
  final String? flashDealEnd;
  final int stock;
  final String stockStatus;
  final int discountPercentage;
  final bool inStock;
  final String status;
  final int soldCount;
  final String? description;
  final String? shortDescription;
  final double averageRating;
  final int reviewCount;
  final List<ProductImageModel> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.comparePrice,
    this.image,
    this.weight,
    this.unit,
    this.categoryId,
    this.categoryName,
    this.isBestSeller = false,
    this.isFeatured = false,
    this.isFlashDeal = false,
    this.flashDealEnd,
    this.stock = 0,
    this.stockStatus = 'Active',
    this.discountPercentage = 0,
    this.inStock = true,
    this.status = 'active',
    this.soldCount = 0,
    this.description,
    this.shortDescription,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.images = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parsing price safely whether String or num
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    double? parsedComparePrice;
    if (json['compare_price'] != null) {
      parsedComparePrice = double.tryParse(json['compare_price'].toString());
    }

    // Category parsing (can be uuid, object, or string)
    String? catId;
    String? catName;
    if (json['category'] is Map) {
      catId = json['category']['id']?.toString();
      catName = json['category']['name']?.toString();
    } else if (json['category'] != null) {
      catId = json['category'].toString();
    }
    if (json['category_name'] != null) {
      catName = json['category_name'].toString();
    }

    // Images gallery
    List<ProductImageModel> gallery = [];
    if (json['images'] is List) {
      gallery = (json['images'] as List)
          .map((i) => ProductImageModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    // Calculate discount if not provided
    int discount = (json['discount_percentage'] as num?)?.toInt() ?? 0;
    if (discount == 0 && parsedComparePrice != null && parsedComparePrice > parsedPrice) {
      discount = (((parsedComparePrice - parsedPrice) / parsedComparePrice) * 100).round();
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? (json['id']?.toString() ?? ''),
      price: parsedPrice,
      comparePrice: parsedComparePrice,
      image: json['image']?.toString(),
      weight: json['weight']?.toString(),
      unit: json['unit']?.toString(),
      categoryId: catId,
      categoryName: catName ?? 'General',
      isBestSeller: json['is_best_seller'] == true,
      isFeatured: json['is_featured'] == true,
      isFlashDeal: json['is_flash_deal'] == true,
      flashDealEnd: json['flash_deal_end']?.toString(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      stockStatus: json['stock_status']?.toString() ?? 'Active',
      discountPercentage: discount,
      inStock: json['in_stock'] == true || (json['stock'] as num? ?? 1) > 0,
      status: json['status']?.toString() ?? 'active',
      soldCount: (json['sold_count'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      shortDescription: json['short_description']?.toString(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      images: gallery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'compare_price': comparePrice,
      'image': image,
      'weight': weight,
      'unit': unit,
      'category': categoryId,
      'category_name': categoryName,
      'is_best_seller': isBestSeller,
      'is_featured': isFeatured,
      'is_flash_deal': isFlashDeal,
      'flash_deal_end': flashDealEnd,
      'stock': stock,
      'stock_status': stockStatus,
      'discount_percentage': discountPercentage,
      'in_stock': inStock,
      'status': status,
      'sold_count': soldCount,
      'description': description,
      'short_description': shortDescription,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'images': images.map((i) => i.toJson()).toList(),
    };
  }
}

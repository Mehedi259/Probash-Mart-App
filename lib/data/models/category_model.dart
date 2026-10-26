class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? image;
  final String? description;
  final bool isActive;
  final int sortOrder;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.image,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == null,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'image': image,
      'description': description,
      'is_active': isActive,
      'sort_order': sortOrder,
      'product_count': productCount,
    };
  }
}

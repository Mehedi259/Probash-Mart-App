class BannerModel {
  final String id;
  final String title;
  final String? subtitle;
  final String image;
  final String? link;
  final String position;
  final bool isActive;
  final int sortOrder;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.image,
    this.link,
    this.position = 'hero_slider',
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      image: json['image']?.toString() ?? '',
      link: json['link']?.toString(),
      position: json['position']?.toString() ?? 'hero_slider',
      isActive: json['is_active'] == true || json['is_active'] == null,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'link': link,
      'position': position,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

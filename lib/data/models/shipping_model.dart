class ShippingZoneModel {
  final String id;
  final String name;
  final String estimatedTime;
  final double fee;
  final bool isActive;

  ShippingZoneModel({
    required this.id,
    required this.name,
    required this.estimatedTime,
    required this.fee,
    this.isActive = true,
  });

  factory ShippingZoneModel.fromJson(Map<String, dynamic> json) {
    return ShippingZoneModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      estimatedTime: json['estimated_time']?.toString() ?? '২-৩ দিন',
      fee: double.tryParse(json['fee']?.toString() ?? '50') ?? 50.0,
      isActive: json['is_active'] == true || json['is_active'] == null,
    );
  }
}

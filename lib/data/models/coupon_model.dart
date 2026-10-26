class CouponValidationModel {
  final bool valid;
  final String code;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final double newTotal;

  CouponValidationModel({
    required this.valid,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.newTotal,
  });

  factory CouponValidationModel.fromJson(Map<String, dynamic> json) {
    return CouponValidationModel(
      valid: json['valid'] == true,
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'fixed',
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      newTotal: double.tryParse(json['new_total']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final String? role;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.role,
    this.address,
    this.city,
    this.postalCode,
    this.country,
  });

  String get fullName {
    final parts = [firstName ?? '', lastName ?? ''].where((s) => s.isNotEmpty).join(' ');
    if (parts.isNotEmpty) return parts;
    return username ?? email.split('@').first;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      country: json['country']?.toString() ?? 'Bangladesh',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
    };
  }
}

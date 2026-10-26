class ReviewModel {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final String? createdAt;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String name = 'গ্রাহক';
    if (json['user_email'] != null) {
      name = json['user_email'].toString().split('@').first;
    } else if (json['user'] != null) {
      name = json['user'].toString();
    }

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userName: name,
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}

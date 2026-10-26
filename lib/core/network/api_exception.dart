import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'সার্ভারের সাথে সংযোগ সময়সীমা শেষ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          final data = response.data;
          String extractedMessage = 'কিছু ভুল হয়েছে, অনুগ্রহ করে আবার চেষ্টা করুন।';

          if (data is Map<String, dynamic>) {
            if (data.containsKey('detail')) {
              extractedMessage = data['detail'].toString();
            } else if (data.containsKey('message')) {
              extractedMessage = data['message'].toString();
            } else if (data.containsKey('non_field_errors')) {
              final nfe = data['non_field_errors'];
              if (nfe is List && nfe.isNotEmpty) {
                extractedMessage = nfe.first.toString();
              }
            } else {
              // Extract first field error
              final firstKey = data.keys.firstOrNull;
              if (firstKey != null) {
                final val = data[firstKey];
                if (val is List && val.isNotEmpty) {
                  extractedMessage = '$firstKey: ${val.first}';
                } else {
                  extractedMessage = '$firstKey: $val';
                }
              }
            }
          } else if (data is String && data.isNotEmpty) {
            extractedMessage = data;
          }

          return ApiException(
            message: extractedMessage,
            statusCode: response.statusCode,
            errors: data,
          );
        }
        return ApiException(
          message: 'সার্ভার থেকে অপ্রত্যাশিত প্রতিক্রিয়া এসেছে।',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'অনুরোধটি বাতিল করা হয়েছে।');

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'ইন্টারনেট সংযোগ নেই অথবা সার্ভার বন্ধ আছে।',
        );

      default:
        return ApiException(
          message: error.message ?? 'অপ্রত্যাশিত কোনো ত্রুটি ঘটেছে।',
        );
    }
  }

  @override
  String toString() => message;
}

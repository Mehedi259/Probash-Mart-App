import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static String formatPrice(num? price, {bool showSymbol = true}) {
    if (price == null) return '${showSymbol ? AppConstants.currencySymbol : ''}0.00';
    final formatter = NumberFormat("#,##0.00", "en_US");
    final formatted = formatter.format(price);
    return showSymbol ? '${AppConstants.currencySymbol}$formatted' : formatted;
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static int calculateDiscount(num price, num? comparePrice) {
    if (comparePrice == null || comparePrice <= price) return 0;
    return (((comparePrice - price) / comparePrice) * 100).round();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../providers/country_provider.dart';

class WhatsAppOrderSheet extends StatefulWidget {
  final ProductModel? product;
  final List<CartItemModel>? cartItems;
  final double? customTotal;

  const WhatsAppOrderSheet({
    super.key,
    this.product,
    this.cartItems,
    this.customTotal,
  });

  static Future<void> show(
    BuildContext context, {
    ProductModel? product,
    List<CartItemModel>? cartItems,
    double? customTotal,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WhatsAppOrderSheet(
        product: product,
        cartItems: cartItems,
        customTotal: customTotal,
      ),
    );
  }

  @override
  State<WhatsAppOrderSheet> createState() => _WhatsAppOrderSheetState();
}

class _WhatsAppOrderSheetState extends State<WhatsAppOrderSheet> {
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  int _quantity = 1;

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    if (widget.customTotal != null) return widget.customTotal!;
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      return widget.cartItems!.fold(0.0, (sum, item) => sum + item.totalPrice);
    }
    if (widget.product != null) {
      return widget.product!.price * _quantity;
    }
    return 0.0;
  }

  void _sendWhatsAppOrder() {
    final country = context.read<CountryProvider>().selectedCountry;
    final recipient = _recipientNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final note = _noteController.text.trim();

    final buffer = StringBuffer();
    buffer.writeln('আসসালামু আলাইকুম! প্রবাস মার্ট থেকে অর্ডার করতে চাই:\n');
    buffer.writeln('🌍 *অর্ডার প্রেরকের দেশ:* ${country.flag} ${country.name}');

    if (widget.product != null) {
      buffer.writeln('🛍️ *পণ্য:* ${widget.product!.name}');
      if (widget.product!.weight != null && widget.product!.weight!.isNotEmpty) {
        buffer.writeln('📦 *সাইজ/ওজন:* ${widget.product!.weight}');
      }
      buffer.writeln('🔢 *পরিমাণ:* $_quantity টি');
      buffer.writeln('💰 *মূল্য:* ${country.formatDualPrice(_totalPrice)}\n');
    } else if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      buffer.writeln('🛍️ *অর্ডারকৃত পণ্যসমূহ:*');
      for (final item in widget.cartItems!) {
        buffer.writeln('• ${item.product.name} (${item.quantity}x) — ৳${item.totalPrice.toStringAsFixed(0)}');
      }
      buffer.writeln('\n💰 *সর্বমোট মূল্য:* ${country.formatDualPrice(_totalPrice)}\n');
    }

    if (recipient.isNotEmpty || phone.isNotEmpty || address.isNotEmpty) {
      buffer.writeln('📍 *বাংলাদেশে পরিবারের ডেলিভারি ঠিকানা:*');
      if (recipient.isNotEmpty) buffer.writeln('• প্রাপক: $recipient');
      if (phone.isNotEmpty) buffer.writeln('• মোবাইল: $phone');
      if (address.isNotEmpty) buffer.writeln('• ঠিকানা: $address');
      buffer.writeln();
    }

    if (note.isNotEmpty) {
      buffer.writeln('💌 *উপহারের বিশেষ বার্তা:* "$note"\n');
    }

    buffer.writeln('আমি এই অর্ডারের পেমেন্ট ও ডেলিভারি কনফার্ম করতে চাই।');

    Navigator.pop(context);
    UiHelpers.openWhatsApp(text: buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.messageCircle, color: Color(0xFF25D366), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'হোয়াটসঅ্যাপে সরাসরি অর্ডার',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'দেশে পরিবারের জন্য উপহার পাঠান সহজে',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Product Summary Card
            if (widget.product != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.watch<CountryProvider>().selectedCountry.formatDualPrice(_totalPrice),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('−', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          InkWell(
                            onTap: () => setState(() => _quantity++),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Recipient Details Form
            const Text(
              'দেশে পরিবারের তথ্য (ঐচ্ছিক):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _recipientNameController,
              decoration: InputDecoration(
                hintText: 'প্রাপকের নাম (যেমন: মা / বাবা / মো: রফিকুল)',
                prefixIcon: const Icon(LucideIcons.user, size: 18, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'বাংলাদেশে ডেলিভারি ফোন নম্বর',
                prefixIcon: const Icon(LucideIcons.phone, size: 18, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'জেলা, থানা ও বিস্তারিত ঠিকানা',
                prefixIcon: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'উপহারের বিশেষ বার্তা (যেমন: "মা, তোমার জন্য দোয়া")',
                prefixIcon: const Icon(LucideIcons.heart, size: 18, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: _sendWhatsAppOrder,
                icon: const Icon(LucideIcons.messageCircle, color: Colors.white, size: 20),
                label: const Text(
                  'WhatsApp-এ অর্ডার পাঠান',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

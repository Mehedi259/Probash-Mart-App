import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      case 'cancelled':
      case 'refunded':
        return -1;
      case 'pending':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepIndex = _getStatusStepIndex(order.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.orderNumber),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.whatsapp,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              final text = 'হ্যালো প্রবাসমার্ট, আমার অর্ডার (${order.orderNumber}) সম্পর্কে তথ্য জানতে চাই।';
              UiHelpers.openWhatsApp(text: text);
            },
            icon: const Icon(LucideIcons.messageCircle, color: Colors.white, size: 20),
            label: const Text(
              'এই অর্ডার সম্পর্কে সাহায্য পান',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Timeline Card
            _buildTimelineCard(stepIndex),

            const SizedBox(height: 16),

            // Order Items Card
            _buildItemsCard(),

            const SizedBox(height: 16),

            // Shipping Address Card
            _buildAddressCard(),

            const SizedBox(height: 16),

            // Financial Breakdown Card
            _buildBillSummaryCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(int currentStep) {
    final steps = [
      {'title': 'অর্ডার গৃহীত', 'desc': 'অর্ডার কনফার্ম হয়েছে'},
      {'title': 'প্রক্রিয়াধীন', 'desc': 'পণ্য প্যাকিং চলছে'},
      {'title': 'ডেলিভারিতে', 'desc': 'রাইডারের হাতে হস্তান্তর'},
      {'title': 'সম্পন্ন', 'desc': 'গ্রাহকের নিকট হস্তান্তর'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'অর্ডার ট্র্যাকিং',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.statusDisplayBengali,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline steps
          Column(
            children: List.generate(steps.length, (idx) {
              final isPassed = currentStep >= idx;
              final isCurrent = currentStep == idx;
              final isLast = idx == steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPassed ? AppColors.primary : Colors.white,
                            border: Border.all(
                              color: isPassed ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: isPassed
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: currentStep > idx ? AppColors.primary : AppColors.border,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[idx]['title']!,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                              color: isPassed ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            steps[idx]['desc']!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'অর্ডারকৃত পণ্যসমূহ (${order.items.length}টি)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final itm = order.items[index];
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: AppColors.surfaceContainer,
                      child: itm.productImage != null && itm.productImage!.isNotEmpty
                          ? (itm.productImage!.startsWith('assets/')
                              ? Image.asset(itm.productImage!, fit: BoxFit.cover)
                              : CachedNetworkImage(
                                  imageUrl: ApiClient().resolveImageUrl(itm.productImage),
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(AppAssets.logoIcon, fit: BoxFit.contain),
                                ))
                          : Image.asset(AppAssets.logoIcon, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itm.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${Formatters.formatPrice(itm.unitPrice)} × ${itm.quantity}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.formatPrice(itm.totalPrice),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.mapPin, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'ডেলিভারি ঠিকানা',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.customerFullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          if (order.phone != null && order.phone!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text('মোবাইল: ${order.phone}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
          if (order.address != null && order.address!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${order.address}, ${order.city ?? ''} ${order.postalCode ?? ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('মূল্য বিবরণী', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row('সাবটোটাল', Formatters.formatPrice(order.subtotal)),
          const SizedBox(height: 6),
          _row('ডেলিভারি চার্জ', Formatters.formatPrice(order.shippingFee)),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 6),
            _row('কুপন ছাড়', '-${Formatters.formatPrice(order.discountAmount)}', isGreen: true),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('সর্বমোট প্রদেয়', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                Formatters.formatPrice(order.totalAmount),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isGreen ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

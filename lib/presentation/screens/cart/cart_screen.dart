import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_widget.dart';
import '../checkout/checkout_screen.dart';
import '../main_nav_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('শপিং কার্ট (${cartProvider.cartCount})'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20, color: AppColors.error),
              tooltip: 'কার্ট খালি করুন',
              onPressed: () async {
                final confirm = await UiHelpers.showConfirmDialog(
                  context,
                  title: 'কার্ট খালি করবেন?',
                  message: 'আপনি কি নিশ্চিত যে আপনার কার্ট থেকে সব পণ্য মুছে ফেলতে চান?',
                  confirmText: 'মুছে ফেলুন',
                  isDestructive: true,
                );
                if (confirm == true) {
                  cartProvider.clearCart();
                }
              },
            ),
        ],
      ),
      bottomNavigationBar: items.isNotEmpty ? _buildCheckoutBar(context, cartProvider) : null,
      body: items.isEmpty
          ? EmptyStateWidget(
              icon: LucideIcons.shoppingBag,
              title: 'আপনার কার্ট খালি',
              message: 'আপনার পছন্দের সেরা খাঁটি দেশীয় পণ্যগুলো কার্টে যোগ করে অর্ডার সম্পন্ন করুন।',
              buttonText: 'কেনাকাটা শুরু করুন',
              onButtonPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 0)),
                );
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemCard(context, cartProvider, item);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Coupon Section
                  _buildCouponSection(context, cartProvider),

                  const SizedBox(height: 20),

                  // Bill Breakdown
                  _buildBillSummary(cartProvider),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartProvider cartProvider, dynamic item) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: AppColors.surfaceContainer,
              child: product.image != null && product.image!.isNotEmpty
                  ? (product.image!.startsWith('assets/')
                      ? Image.asset(product.image!, fit: BoxFit.cover)
                      : CachedNetworkImage(
                          imageUrl: ApiClient().resolveImageUrl(product.image),
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Image.asset(AppAssets.logoIcon, fit: BoxFit.contain),
                        ))
                  : Image.asset(AppAssets.logoIcon, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (product.weight != null && product.weight!.isNotEmpty)
                  Text(
                    product.weight!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Stepper + Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                onPressed: () => cartProvider.removeFromCart(product.id),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.surfaceContainer,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => cartProvider.updateQuantity(product.id, item.quantity - 1),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(LucideIcons.minus, size: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    InkWell(
                      onTap: () => cartProvider.updateQuantity(product.id, item.quantity + 1),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(LucideIcons.plus, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context, CartProvider cartProvider) {
    final coupon = cartProvider.appliedCoupon;

    if (coupon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.tag, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'কুপন প্রয়োগ করা হয়েছে: ${coupon.code}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'আপনি ৳${coupon.discountAmount.toStringAsFixed(2)} ছাড় পেয়েছেন!',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.x, color: AppColors.error, size: 18),
              onPressed: () => cartProvider.removeCoupon(),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'ডিসকাউন্ট কুপন কোড লিখুন',
                    prefixIcon: Icon(LucideIcons.ticket, size: 18, color: AppColors.primary),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CustomButton(
                text: 'প্রয়োগ',
                width: 85,
                height: 48,
                isLoading: cartProvider.isValidatingCoupon,
                onPressed: () {
                  if (_couponController.text.isNotEmpty) {
                    cartProvider.applyCoupon(_couponController.text.trim());
                  }
                },
              ),
            ],
          ),
          if (cartProvider.couponError != null) ...[
            const SizedBox(height: 6),
            Text(
              cartProvider.couponError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'অর্ডারের সারসংক্ষেপ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('সাবটোটাল (${cartProvider.cartCount}টি পণ্য)', Formatters.formatPrice(cartProvider.subtotal)),
          const SizedBox(height: 8),
          _summaryRow('ডেলিভারি চার্জ', Formatters.formatPrice(cartProvider.shippingFee)),
          if (cartProvider.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'কুপন ছাড়',
              '-${Formatters.formatPrice(cartProvider.discountAmount)}',
              isGreen: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'সর্বমোট প্রদেয়',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                Formatters.formatPrice(cartProvider.totalAmount),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isGreen ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('সর্বমোট মূল্য:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(
                  Formatters.formatPrice(cartProvider.totalAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                text: 'চেকআউট করুন →',
                height: 48,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

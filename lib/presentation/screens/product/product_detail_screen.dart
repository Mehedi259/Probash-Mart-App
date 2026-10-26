import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/products_provider.dart';
import '../../widgets/product_card.dart';
import '../checkout/checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  bool _isAddedFeedback = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wishlistProvider = context.watch<WishlistProvider>();
    final cartProvider = context.read<CartProvider>();
    final isWishlisted = wishlistProvider.isInWishlist(product.id);
    final relatedProducts = context.watch<ProductsProvider>().featuredProducts
        .where((p) => p.id != product.id)
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? AppColors.error : AppColors.textPrimary,
            ),
            onPressed: () => wishlistProvider.toggleWishlist(product),
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 20),
            onPressed: () {
              UiHelpers.showSnackBar(context, 'পণ্যটির লিংক কপি করা হয়েছে!');
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(cartProvider, product),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery / Image
            _buildGallery(product),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      if (product.isBestSeller) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.amberLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, size: 14, color: AppColors.amber),
                              SizedBox(width: 4),
                              Text(
                                'Best Seller',
                                style: TextStyle(
                                  color: AppColors.amber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (product.discountPercentage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '-${product.discountPercentage}% ছাড়',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title & Weight
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (product.weight != null && product.weight!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'পরিমাণ / ওজন: ${product.weight}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Price & Stock
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        Formatters.formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.comparePrice != null && product.comparePrice! > product.price) ...[
                        const SizedBox(width: 10),
                        Text(
                          Formatters.formatPrice(product.comparePrice),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Stock Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'স্টকে আছে',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Quantity Stepper
                  Row(
                    children: [
                      const Text(
                        'পরিমাণ নির্বাচন করুন:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surfaceContainer,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.minus, size: 16),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: Colors.white,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.plus, size: 16),
                              onPressed: () {
                                setState(() => _quantity++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // WhatsApp Instant Order Button
                  InkWell(
                    onTap: () {
                      final text = 'হ্যালো প্রবাসমার্ট, আমি ${product.name} (পরিমাণ: $_quantity টি) অর্ডার করতে আগ্রহী।';
                      UiHelpers.openWhatsApp(text: text);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.whatsapp,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.messageCircle, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'হোয়াটসঅ্যাপে সরাসরি অর্ডার করুন',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'পণ্যের বিবরণ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description != null && product.description!.isNotEmpty
                        ? product.description!
                        : 'প্রবাসমার্ট থেকে শতভাগ আসল ও খাঁটি খাদ্যপণ্য কিনুন। আমাদের প্রতিটি পণ্য সর্বোচ্চ সতেজতা ও গুণমান বজায় রেখে সংরক্ষিত ও সরবরাহ করা হয়।',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Trust Badges Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: const [
                        _TrustItem(icon: LucideIcons.shieldCheck, text: '১০০% আসল ও খাঁটি পণ্যের নিশ্চয়তা'),
                        SizedBox(height: 10),
                        _TrustItem(icon: LucideIcons.truck, text: 'দেশব্যাপী ও ওমানে ক্যাশ অন হোম ডেলিভারি'),
                        SizedBox(height: 10),
                        _TrustItem(icon: LucideIcons.rotateCcw, text: '৭ দিনের সহজ ও নিশ্চিত রিটার্ন পলিসি'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Related Products
                  if (relatedProducts.isNotEmpty) ...[
                    const Text(
                      'একই ক্যাটাগরির অন্যান্য পণ্য',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: relatedProducts[index],
                            width: 160,
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(ProductModel product) {
    final images = product.images.isNotEmpty
        ? product.images.map((i) => i.image).toList()
        : [product.image ?? ''];

    return Container(
      height: 300,
      width: double.infinity,
      color: AppColors.surfaceContainer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (idx) => setState(() => _selectedImageIndex = idx),
            itemBuilder: (context, index) {
              final raw = images[index];
              if (raw.startsWith('assets/')) {
                return Image.asset(raw, fit: BoxFit.contain);
              }
              return CachedNetworkImage(
                imageUrl: ApiClient().resolveImageUrl(raw),
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => Image.asset(AppAssets.logoIcon, fit: BoxFit.contain),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              child: Row(
                children: List.generate(images.length, (idx) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _selectedImageIndex == idx ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _selectedImageIndex == idx ? AppColors.primary : AppColors.textMuted,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartProvider cartProvider, ProductModel product) {
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
            // Add to Cart Button
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAddedFeedback ? AppColors.success : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    cartProvider.addToCart(product, quantity: _quantity);
                    setState(() => _isAddedFeedback = true);
                    UiHelpers.showSnackBar(
                      context,
                      '$_quantity টি ${product.name} কার্টে যোগ হয়েছে!',
                      isSuccess: true,
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isAddedFeedback = false);
                    });
                  },
                  icon: Icon(
                    _isAddedFeedback ? LucideIcons.check : LucideIcons.shoppingBag,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    _isAddedFeedback ? 'কার্টে যোগ হয়েছে' : 'কার্টে যোগ করুন',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Buy Now Direct Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    cartProvider.addToCart(product, quantity: _quantity);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  child: const Text(
                    'এখনই কিনুন',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

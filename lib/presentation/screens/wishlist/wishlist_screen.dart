import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/wishlist_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../main_nav_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final items = wishlistProvider.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('পছন্দের তালিকা (${wishlistProvider.wishlistCount})'),
      ),
      body: items.isEmpty
          ? EmptyStateWidget(
              icon: LucideIcons.heart,
              title: 'আপনার পছন্দের তালিকা খালি',
              message: 'পছন্দের পণ্যগুলোতে হার্ট আইকনে ট্যাপ করে আপনার পছন্দের তালিকা তৈরি করুন।',
              buttonText: 'পণ্য পছন্দ করুন',
              onButtonPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 0)),
                );
              },
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ProductCard(product: items[index]);
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/products_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state_widget.dart';

class ProductListScreen extends StatefulWidget {
  final String? categorySlug;
  final String? categoryName;
  final String? ordering;

  const ProductListScreen({
    super.key,
    this.categorySlug,
    this.categoryName,
    this.ordering,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? _selectedOrdering;

  @override
  void initState() {
    super.initState();
    _selectedOrdering = widget.ordering;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts(
            categorySlug: widget.categorySlug,
            ordering: _selectedOrdering,
          );
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'সর্ট করুন (ফিল্টার)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _sortOption(ctx, 'ডিফল্ট', null),
              _sortOption(ctx, 'মূল্য: কম থেকে বেশি', 'price'),
              _sortOption(ctx, 'মূল্য: বেশি থেকে কম', '-price'),
              _sortOption(ctx, 'সর্বাধিক বিক্রিত', '-sold_count'),
              _sortOption(ctx, 'নতুন পণ্য', '-created_at'),
            ],
          ),
        );
      },
    );
  }

  Widget _sortOption(BuildContext ctx, String label, String? orderVal) {
    final isSelected = _selectedOrdering == orderVal;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        Navigator.pop(ctx);
        setState(() => _selectedOrdering = orderVal);
        context.read<ProductsProvider>().loadProducts(
              categorySlug: widget.categorySlug,
              ordering: orderVal,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final products = provider.products;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'পণ্য তালিকা'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.slidersHorizontal, size: 20),
            onPressed: _showSortBottomSheet,
            tooltip: 'সর্ট করুন',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await provider.loadProducts(
            categorySlug: widget.categorySlug,
            ordering: _selectedOrdering,
          );
        },
        child: provider.isLoadingProducts
            ? GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => ShimmerLoader.productCardPlaceholder(),
              )
            : products.isEmpty
                ? const EmptyStateWidget(
                    icon: LucideIcons.packageOpen,
                    title: 'কোনো পণ্য পাওয়া যায়নি',
                    message: 'এই ক্যাটাগরিতে বর্তমানে কোনো পণ্য স্টক নেই।',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
      ),
    );
  }
}

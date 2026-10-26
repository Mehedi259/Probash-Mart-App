import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/products_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<String> _popularKeywords = [
    'Hilsa',
    'Rice',
    'Oil',
    'Fish',
    'Masala',
    'Tea',
    'Biscuits',
    'Pickle',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<ProductsProvider>().searchProducts(query);
      }
    });
  }

  void _searchKeyword(String word) {
    _searchController.text = word;
    context.read<ProductsProvider>().searchProducts(word);
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final results = productsProvider.searchResults;
    final isSearching = productsProvider.isSearching;
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'পণ্য অনুসন্ধান করুন...',
              prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textMuted),
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        productsProvider.searchProducts('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Keywords if no query
          if (!hasQuery) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const Text(
                'জনপ্রিয় অনুসন্ধান',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularKeywords.map((word) {
                  return ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    label: Text(
                      word,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    onPressed: () => _searchKeyword(word),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Search Results Header
          if (hasQuery)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'অনুসন্ধানের ফলাফল (${results.length}টি পাওয়া গেছে)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),

          // Results Grid
          Expanded(
            child: isSearching
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, __) => ShimmerLoader.productCardPlaceholder(),
                  )
                : hasQuery && results.isEmpty
                    ? const EmptyStateWidget(
                        icon: LucideIcons.searchX,
                        title: 'কোনো ফলাফল পাওয়া যায়নি',
                        message: 'অন্য কোনো কি-ওয়ার্ড দিয়ে আবার চেষ্টা করুন।',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: results[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

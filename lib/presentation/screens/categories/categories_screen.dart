import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../providers/categories_provider.dart';
import '../product/product_list_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _filter = '';

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'leaf':
        return LucideIcons.leaf;
      case 'fish':
        return LucideIcons.fish;
      case 'drumstick':
        return LucideIcons.drumstick;
      case 'wheat':
        return LucideIcons.wheat;
      case 'flame':
        return LucideIcons.flame;
      case 'cookie':
        return LucideIcons.cookie;
      case 'cupsoda':
        return LucideIcons.cupSoda;
      case 'home':
        return LucideIcons.home;
      case 'smile':
        return LucideIcons.smile;
      case 'cake':
        return LucideIcons.cake;
      default:
        return LucideIcons.grid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final allCategories = provider.categories;

    final categories = _filter.isEmpty
        ? allCategories
        : allCategories
            .where((c) => c.name.toLowerCase().contains(_filter.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('পণ্য ক্যাটাগরি'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (val) => setState(() => _filter = val),
              decoration: InputDecoration(
                hintText: 'ক্যাটাগরি অনুসন্ধান করুন...',
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.loadCategories(forceRefresh: true),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            categorySlug: cat.slug,
                            categoryName: cat.name,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.softShadow,
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: cat.image != null && cat.image!.isNotEmpty
                                  ? (cat.image!.startsWith('assets/')
                                      ? Image.asset(cat.image!, fit: BoxFit.cover)
                                      : CachedNetworkImage(
                                          imageUrl: ApiClient().resolveImageUrl(cat.image),
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => Icon(
                                            _getCategoryIcon(cat.icon),
                                            color: AppColors.primary,
                                            size: 26,
                                          ),
                                        ))
                                  : Icon(
                                      _getCategoryIcon(cat.icon),
                                      color: AppColors.primary,
                                      size: 26,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            cat.productCount > 0 ? '${cat.productCount}টি পণ্য' : 'পণ্য দেখুন',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

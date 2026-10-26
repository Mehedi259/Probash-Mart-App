import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../data/models/category_model.dart';
import '../screens/product/product_list_screen.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

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
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductListScreen(
                  categorySlug: category.slug,
                  categoryName: category.name,
                ),
              ),
            );
          },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: ClipOval(
              child: _buildIconOrImage(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconOrImage() {
    final rawImage = category.image;
    if (rawImage != null && rawImage.isNotEmpty) {
      if (rawImage.startsWith('assets/')) {
        return Image.asset(rawImage, fit: BoxFit.cover);
      }
      return CachedNetworkImage(
        imageUrl: ApiClient().resolveImageUrl(rawImage),
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildFallbackIcon(),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        _getCategoryIcon(category.icon),
        color: isSelected ? Colors.white : AppColors.primary,
        size: 26,
      ),
    );
  }
}

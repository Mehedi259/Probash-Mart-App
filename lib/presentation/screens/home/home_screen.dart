import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/banner_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/products_provider.dart';
import '../../../providers/country_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'সব';

  @override
  Widget build(BuildContext context) {
    final bannerProvider = context.watch<BannerProvider>();
    final categoriesProvider = context.watch<CategoriesProvider>();
    final productsProvider = context.watch<ProductsProvider>();
    final country = context.watch<CountryProvider>().selectedCountry;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, country),
      floatingActionButton: FloatingActionButton(
        onPressed: () => UiHelpers.openWhatsApp(
          text: 'আসসালামু আলাইকুম, আমি ${country.name} থেকে দেশে পরিবারের জন্য উপহার পাঠাতে চাই।',
        ),
        backgroundColor: const Color(0xFF25D366),
        elevation: 3,
        tooltip: 'WhatsApp সাহায্য',
        child: const Icon(LucideIcons.messageCircle, color: Colors.white, size: 26),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            bannerProvider.loadBanners(),
            categoriesProvider.loadCategories(forceRefresh: true),
            productsProvider.loadHomeData(forceRefresh: true),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Search Bar
              _buildSearchBar(context),

              // Premium Hero Card
              _buildHeroCard(country),

              const SizedBox(height: 18),

              // Category Horizontal Filter Chips
              _buildCategoryChips(categoriesProvider),

              const SizedBox(height: 16),

              // Products Section Header & Responsive Grid
              _buildProductsSection(productsProvider),

              const SizedBox(height: 20),

              // Clean Help Banner
              _buildAssistanceCard(country),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CountryOption country) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Image.asset(
            AppAssets.logo,
            height: 36,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Interactive Country / Currency Selector Badge
          InkWell(
            onTap: () => _showCountrySelector(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    country.name,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.messageCircle, color: Color(0xFF25D366), size: 22),
          onPressed: () => UiHelpers.openWhatsApp(),
          tooltip: 'সরাসরি হোয়াটসঅ্যাপ করুন',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showCountrySelector(BuildContext context) {
    final countryProvider = context.read<CountryProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        final current = ctx.watch<CountryProvider>().selectedCountry;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'আপনার অবস্থান ও কারেন্সি নির্বাচন করুন',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'যে দেশ থেকে অর্ডার করছেন সেটি বেছে নিন। মূল্যের হিসাব সে অনুযায়ী পরিবর্তিত হবে।',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              ...CountryProvider.supportedCountries.map((c) {
                final isSelected = c.code == current.code;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.45) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      c.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      c.code == 'BD' ? 'মূল্য: ৳ (টাকা)' : 'কারেন্সি: ${c.currencyCode}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                        : null,
                    onTap: () {
                      countryProvider.setCountry(c);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.search, color: AppColors.textMuted, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'মধু, সরিষার তেল, পাঞ্জাবি, শাড়ি বা শীতের পোশাক...',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(CountryOption country) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F5132), Color(0xFF146C43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F5132).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${country.flag} ${country.name} • দেশে প্রিয়জনের মুখে হাসি ফুটান',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'আপনি দূরে, ভালোবাসা কাছে',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'প্রবাসী ভাইয়েরা দেশের পরিবারে খাঁটি ও প্রিমিয়াম উপহার পাঠান সহজেই। পেমেন্ট ও ডেলিভারি শতভাগ নিশ্চিত সরাসরি হোয়াটসঅ্যাপে।',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            // Trust badges row
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildTrustChip('🛡️ শতভাগ খাঁটি পণ্য'),
                _buildTrustChip('🚚 হোম ডেলিভারি'),
                _buildTrustChip('💬 ১-ট্যাপ WhatsApp অর্ডার'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCategoryChips(CategoriesProvider categoriesProvider) {
    final categories = categoriesProvider.categories;
    final List<String> chips = ['সব'];
    if (categories.isNotEmpty) {
      chips.addAll(categories.map((c) => c.name));
    } else {
      chips.addAll([
        'খাঁটি খাদ্যপণ্য',
        'বাবার পাঞ্জাবি',
        'শীতের পোশাক',
        'মায়ের শাড়ি',
        'প্রিয়জনের উপহার',
        'ফ্যামিলি বাজার কম্বো',
      ]);
    }

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = chips[index];
          final isSelected = _selectedCategory == cat;

          return InkWell(
            onTap: () {
              setState(() => _selectedCategory = cat);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: isSelected ? AppColors.softShadow : null,
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsSection(ProductsProvider provider) {
    final allProducts = provider.featuredProducts;

    final filteredProducts = _selectedCategory == 'সব'
        ? allProducts
        : allProducts.where((p) {
            final cat = p.categoryName?.toLowerCase() ?? '';
            final filter = _selectedCategory.toLowerCase();
            return cat.contains(filter) || filter.contains(cat) || p.name.toLowerCase().contains(filter);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory == 'সব' ? 'জনপ্রিয় উপহার প্যাকেজ' : _selectedCategory,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${filteredProducts.length}টি পণ্য',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (provider.isLoadingHome && filteredProducts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.54,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => ShimmerLoader.productCardPlaceholder(),
            ),
          )
        else if (filteredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'এই ক্যাটাগরিতে বর্তমানে কোনো পণ্য নেই।',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.54,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: filteredProducts[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAssistanceCard(CountryOption country) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.messageCircle, color: Color(0xFF25D366), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'কাস্টম উপহার বা বিশেষ অর্ডার?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${country.flag} ${country.name} থেকে সরাসরি ওনারের সাথে কথা বলুন',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => UiHelpers.openWhatsApp(),
              child: const Text('মেসেজ দিন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

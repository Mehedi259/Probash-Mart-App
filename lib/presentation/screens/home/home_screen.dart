import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/banner_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/products_provider.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/shimmer_loader.dart';
import '../search/search_screen.dart';
import '../categories/categories_screen.dart';
import '../product/product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerCurrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bannerProvider = context.watch<BannerProvider>();
    final categoriesProvider = context.watch<CategoriesProvider>();
    final productsProvider = context.watch<ProductsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => UiHelpers.openWhatsApp(),
        backgroundColor: AppColors.whatsapp,
        elevation: 4,
        child: const Icon(LucideIcons.messageCircle, color: Colors.white, size: 28),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Trigger
              _buildSearchBar(context),

              // Hero Banner Slider
              _buildHeroSlider(bannerProvider),

              const SizedBox(height: 16),

              // Categories Header & Horizontal List
              SectionHeader(
                title: 'পণ্য ক্যাটাগরি',
                subtitle: 'আপনার প্রয়োজনীয় গ্রোসারি বেছে নিন',
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  );
                },
              ),
              _buildCategoriesList(categoriesProvider),

              const SizedBox(height: 20),

              // Flash Deals with Live Countdown Timer
              _buildFlashDealsSection(productsProvider),

              const SizedBox(height: 24),

              // Best Sellers Section
              _buildBestSellersSection(productsProvider),

              const SizedBox(height: 20),

              // Promo Banner Card
              _buildPromoCard(),

              const SizedBox(height: 20),

              // Featured Products Grid
              _buildFeaturedProductsSection(productsProvider),

              const SizedBox(height: 24),

              // Why Choose Probash Mart Section
              _buildWhyProbashMart(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Image.asset(
            AppAssets.logo,
            height: 38,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Location Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.mapPin, color: AppColors.primary, size: 13),
                SizedBox(width: 4),
                Text(
                  'ওমান / বাংলাদেশ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.phoneCall, color: AppColors.primary, size: 22),
          onPressed: () => UiHelpers.makePhoneCall(null),
          tooltip: 'সরাসরি কল করুন',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                  'ইলিশ, চাল, ডাল বা মশলা খুঁজুন...',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(LucideIcons.slidersHorizontal, color: AppColors.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSlider(BannerProvider bannerProvider) {
    final banners = bannerProvider.banners;
    if (banners.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerLoader(width: double.infinity, height: 160, borderRadius: 16),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 170,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            onPageChanged: (index, reason) {
              setState(() => _bannerCurrentIndex = index);
            },
          ),
          items: banners.map((banner) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.mediumShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (banner.image.startsWith('assets/'))
                      Image.asset(banner.image, fit: BoxFit.cover)
                    else
                      Image.network(
                        ApiClient().resolveImageUrl(banner.image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(AppAssets.heroSlide1, fit: BoxFit.cover),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (banner.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              banner.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        AnimatedSmoothIndicator(
          activeIndex: _bannerCurrentIndex,
          count: banners.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: AppColors.border,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(CategoriesProvider provider) {
    if (provider.isLoading && provider.categories.isEmpty) {
      return SizedBox(
        height: 100,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const ShimmerLoader(width: 64, height: 64, borderRadius: 32),
        ),
      );
    }

    final categories = provider.categories;
    return SizedBox(
      height: 105,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return CategoryCard(category: categories[index]);
        },
      ),
    );
  }

  Widget _buildFlashDealsSection(ProductsProvider provider) {
    final flashDeals = provider.flashDeals;
    if (flashDeals.isEmpty && !provider.isLoadingHome) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.zap, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              const Text(
                'ফ্ল্যাশ ডিলস',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              const CountdownTimerWidget(),
            ],
          ),
          const SizedBox(height: 14),

          if (provider.isLoadingHome && flashDeals.isEmpty)
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const SizedBox(
                  width: 165,
                  child: ShimmerLoader(width: 165, height: 250, borderRadius: 16),
                ),
              ),
            )
          else
            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: flashDeals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: flashDeals[index],
                    width: 165,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBestSellersSection(ProductsProvider provider) {
    final bestSellers = provider.bestSellers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'সর্বাধিক বিক্রিত পণ্য',
          subtitle: 'গ্রাহকদের পছন্দের সেরা খাদ্যপণ্য',
          icon: LucideIcons.flame,
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductListScreen(ordering: '-sold_count', categoryName: 'বেস্ট সেলার্স'),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 255,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: bestSellers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ProductCard(
                product: bestSellers[index],
                width: 165,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppAssets.heroBannerBasket, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'হোয়াটসঅ্যাপে সরাসরি অর্ডার',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'পণ্য লিখে বা ছবি তুলে পাঠিয়ে দিন আমাদের নম্বরে',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsapp,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => UiHelpers.openWhatsApp(),
                      icon: const Icon(LucideIcons.messageCircle, size: 14, color: Colors.white),
                      label: const Text('মেসেজ পাঠান', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection(ProductsProvider provider) {
    final products = provider.featuredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'জনপ্রিয় পণ্যসমূহ',
          subtitle: 'টাটকা ও নির্ভেজাল পণ্যের সমাহার',
          icon: LucideIcons.sparkles,
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductListScreen(categoryName: 'সকল পণ্য'),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        if (provider.isLoadingHome && products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => ShimmerLoader.productCardPlaceholder(),
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
      ],
    );
  }

  Widget _buildWhyProbashMart() {
    final features = [
      {'icon': LucideIcons.checkCircle2, 'title': '১০০% খাঁটি পণ্য', 'desc': 'দেশীয় গুণগত মান'},
      {'icon': LucideIcons.truck, 'title': 'দ্রুত ডেলিভারি', 'desc': 'আপনার দরজায়'},
      {'icon': LucideIcons.shieldCheck, 'title': 'ক্যাশ অন ডেলিভারি', 'desc': 'নিরাপদ পেমেন্ট'},
      {'icon': LucideIcons.headphones, 'title': 'সার্বক্ষণিক সাপোর্ট', 'desc': 'হোয়াটসঅ্যাপে সেবা'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'কেন প্রবাসমার্ট সেরা?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final item = features[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

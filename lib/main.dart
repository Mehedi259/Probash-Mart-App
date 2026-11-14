import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/country_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize Local Storage Service
  final storage = StorageService();
  await storage.init();

  // Restore custom base url if set by user in profile settings, otherwise use live production URL
  final savedBaseUrl = storage.customBaseUrl;
  if (savedBaseUrl != null &&
      savedBaseUrl.isNotEmpty &&
      !savedBaseUrl.contains('10.0.2.2') &&
      !savedBaseUrl.contains('127.0.0.1') &&
      !savedBaseUrl.contains('localhost')) {
    ApiClient().updateBaseUrl(savedBaseUrl);
  } else {
    ApiClient().updateBaseUrl(AppConstants.defaultBaseUrl);
  }

  runApp(const ProbashMartApp());
}

class ProbashMartApp extends StatelessWidget {
  const ProbashMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

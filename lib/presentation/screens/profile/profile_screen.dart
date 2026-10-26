import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/services/storage_service.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../orders/orders_screen.dart';
import '../orders/order_tracking_screen.dart';
import '../info/contact_screen.dart';
import '../info/static_page_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showServerSettings(BuildContext context) {
    final client = ApiClient();
    final controller = TextEditingController(text: client.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('সার্ভার সেটিং (API URL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ব্যাকএন্ড সার্ভার নির্বাচন করুন বা নিজস্ব URL লিখুন:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://127.0.0.1:8000',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Local (127.0.0.1)', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'http://127.0.0.1:8000',
                ),
                ActionChip(
                  label: const Text('Android (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'http://10.0.2.2:8000',
                ),
                ActionChip(
                  label: const Text('Live Server', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = AppConstants.productionBaseUrl,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                client.updateBaseUrl(newUrl);
                await StorageService().setCustomBaseUrl(newUrl);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  UiHelpers.showSnackBar(context, 'সার্ভার URL আপডেট করা হয়েছে!', isSuccess: true);
                }
              }
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('আমার অ্যাকাউন্ট'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            tooltip: 'সার্ভার সেটিং',
            onPressed: () => _showServerSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.softShadow,
              ),
              child: isAuthenticated && user != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (user.phone != null && user.phone!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user.phone!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.edit3, color: AppColors.primary, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.surfaceContainer,
                          child: const Icon(LucideIcons.user, color: AppColors.textMuted, size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'স্বাগতম অতিথি!',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'অর্ডার ও প্রোফাইল ট্র্যাকিং করতে লগইন করুন',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text('লগইন', style: TextStyle(fontSize: 13, color: Colors.white)),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 18),

            // Navigation Menu Options
            _buildMenuCard([
              _MenuItem(
                icon: LucideIcons.package,
                title: 'আমার অর্ডারসমূহ',
                subtitle: 'অর্ডারের হিস্ট্রি ও স্ট্যাটাস দেখুন',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
              ),
              _MenuItem(
                icon: LucideIcons.packageSearch,
                title: 'অর্ডার ট্র্যাকিং',
                subtitle: 'অর্ডার নম্বর দিয়ে ট্র্যাকিং করুন',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderTrackingScreen()),
                  );
                },
              ),
              if (isAuthenticated) ...[
                _MenuItem(
                  icon: LucideIcons.lock,
                  title: 'পাসওয়ার্ড পরিবর্তন',
                  subtitle: 'নিরাপত্তা নিশ্চিত করতে পাসওয়ার্ড আপডেট করুন',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),
              ],
            ]),

            const SizedBox(height: 16),

            // Support & Contact
            _buildMenuCard([
              _MenuItem(
                icon: LucideIcons.messageCircle,
                title: 'হোয়াটসঅ্যাপ সাপোর্ট (+৯৬৮ ৯৪৫৭ ৮৫৩৮)',
                subtitle: '২৪/৭ সরাসরি প্রতিনিধির সাথে চ্যাট করুন',
                iconColor: AppColors.whatsapp,
                onTap: () => UiHelpers.openWhatsApp(),
              ),
              _MenuItem(
                icon: LucideIcons.phoneCall,
                title: 'সরাসরি কল করুন',
                subtitle: 'যেকোনো জিজ্ঞাসা বা অর্ডারের সহায়তায়',
                onTap: () => UiHelpers.makePhoneCall(null),
              ),
              _MenuItem(
                icon: LucideIcons.mail,
                title: 'যোগাযোগ ও মেসেজ পাঠান',
                subtitle: 'আমাদের কাছে ইমেইল বা মেসেজ পাঠান',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Legal & About
            _buildMenuCard([
              _MenuItem(
                icon: LucideIcons.info,
                title: 'প্রবাসমার্ট সম্পর্কে',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaticPageScreen(
                        title: 'আমাদের সম্পর্কে',
                        slug: 'about-us',
                      ),
                    ),
                  );
                },
              ),
              _MenuItem(
                icon: LucideIcons.shieldAlert,
                title: 'প্রাইভেসি পলিসি',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaticPageScreen(
                        title: 'প্রাইভেসি পলিসি',
                        slug: 'privacy-policy',
                      ),
                    ),
                  );
                },
              ),
              _MenuItem(
                icon: LucideIcons.fileCheck,
                title: 'শর্তাবলী ও নিয়মাবলী',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaticPageScreen(
                        title: 'ব্যবহারের শর্তাবলী',
                        slug: 'terms-and-conditions',
                      ),
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // Logout Button if Authenticated
            if (isAuthenticated)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final confirm = await UiHelpers.showConfirmDialog(
                      context,
                      title: 'লগআউট নিশ্চিতকরণ',
                      message: 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
                      confirmText: 'লগআউট',
                      isDestructive: true,
                    );
                    if (confirm == true) {
                      await authProvider.logout();
                      if (context.mounted) {
                        UiHelpers.showSnackBar(context, 'লগআউট সফল হয়েছে');
                      }
                    }
                  },
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: const Text('লগআউট করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

            const SizedBox(height: 30),
            const Text(
              'App Version 1.0.0 (Probash Mart Official)',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: List.generate(items.length, (idx) {
          final item = items[idx];
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item.iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18, color: item.iconColor ?? AppColors.primary),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      )
                    : null,
                trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
              ),
              if (idx < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    required this.onTap,
  });
}

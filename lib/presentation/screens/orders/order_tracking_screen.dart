import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import 'order_detail_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? initialOrderNumber;

  const OrderTrackingScreen({super.key, this.initialOrderNumber});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final TextEditingController _orderNumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderNumber != null) {
      _orderNumController.text = widget.initialOrderNumber!;
      _track();
    }
  }

  @override
  void dispose() {
    _orderNumController.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    final num = _orderNumController.text.trim();
    if (num.isEmpty) {
      UiHelpers.showSnackBar(context, 'অনুগ্রহ করে অর্ডার নম্বর লিখুন', isError: true);
      return;
    }

    final order = await context.read<OrderProvider>().trackOrder(num);
    if (order != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: order),
        ),
      );
    } else if (mounted) {
      UiHelpers.showSnackBar(
        context,
        context.read<OrderProvider>().errorMessage ?? 'অর্ডারটি খুঁজে পাওয়া যায়নি।',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('অর্ডার ট্র্যাকিং'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.packageSearch, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'আপনার অর্ডার ট্র্যাক করুন',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'অর্ডার কনফার্মেশনের সময় প্রাপ্ত অর্ডার নম্বরটি (যেমন: PM-261025-0001) নিচে লিখুন।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _orderNumController,
                    decoration: const InputDecoration(
                      hintText: 'যেমন: PM-261025-0001',
                      prefixIcon: Icon(LucideIcons.hash, color: AppColors.primary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'ট্র্যাক করুন',
                    isLoading: orderProvider.isLoading,
                    onPressed: _track,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

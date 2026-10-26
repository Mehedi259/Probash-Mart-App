import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedPaymentMethod = 'cod'; // 'cod', 'bkash', 'whatsapp'

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email;
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _postalCodeController.text = user.postalCode ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) {
      UiHelpers.showSnackBar(context, 'অনুগ্রহ করে সব প্রয়োজনীয় তথ্য পূরণ করুন।', isError: true);
      return;
    }

    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cartProvider.items.isEmpty) {
      UiHelpers.showSnackBar(context, 'আপনার কার্ট খালি!', isError: true);
      return;
    }

    // Split name into first and last
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '.';

    final order = await orderProvider.createOrder(
      firstName: firstName,
      lastName: lastName,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      couponCode: cartProvider.appliedCoupon?.code,
      customerNote: _noteController.text.trim(),
      items: cartProvider.items,
    );

    if (order != null) {
      // Clear cart
      await cartProvider.clearCart();

      // If WhatsApp payment selected, launch WhatsApp message with order details
      if (_selectedPaymentMethod == 'whatsapp') {
        String msg = '*প্রবাসমার্ট নতুন অর্ডার!* 🛍️\n\n';
        msg += '*অর্ডার নম্বর:* ${order.orderNumber}\n';
        msg += '*গ্রাহক:* ${order.customerFullName}\n';
        msg += '*মোবাইল:* ${_phoneController.text}\n';
        msg += '*ঠিকানা:* ${_addressController.text}, ${_cityController.text}\n\n';
        msg += '*পণ্যসমূহ:*\n';
        for (var itm in order.items) {
          msg += '- ${itm.quantity}x ${itm.productName} (৳${itm.totalPrice.toStringAsFixed(2)})\n';
        }
        msg += '\n*সর্বমোট প্রদেয়:* ৳${order.totalAmount.toStringAsFixed(2)}\n';
        msg += '*পেমেন্ট:* হোয়াটসঅ্যাপের মাধ্যমে\n';

        UiHelpers.openWhatsApp(text: msg);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: order),
        ),
      );
    } else {
      if (!mounted) return;
      UiHelpers.showSnackBar(
        context,
        orderProvider.errorMessage ?? 'অর্ডার সম্পন্ন করতে সমস্যা হয়েছে।',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('চেকআউট ও ডেলিভারি'),
      ),
      bottomNavigationBar: _buildBottomConfirmBar(cartProvider, orderProvider),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Info Card
              _buildSectionCard(
                title: 'ডেলিভারির তথ্য',
                icon: LucideIcons.mapPin,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'আপনার নাম *',
                      hintText: 'যেমন: মো: রহিম উদ্দিন',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'নাম আবশ্যক' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'মোবাইল নম্বর *',
                      hintText: 'যেমন: 017XXXXXXXX বা ওমান নম্বর',
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'মোবাইল নম্বর আবশ্যক' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _emailController,
                      label: 'ইমেইল (ঐচ্ছিক)',
                      hintText: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _addressController,
                      label: 'পূর্ণ ঠিকানা *',
                      hintText: 'বাড়ি নং, রোড নং, এলাকা / উইলিয়াত',
                      maxLines: 2,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'ঠিকানা আবশ্যক' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _cityController,
                            label: 'শহর / জেলা *',
                            hintText: 'যেমন: ঢাকা বা মাস্কাট',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'শহর আবশ্যক' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _postalCodeController,
                            label: 'পোস্ট কোড',
                            hintText: 'পোস্ট কোড (যদি থাকে)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _noteController,
                      label: 'ডেলিভারি নোট (ঐচ্ছিক)',
                      hintText: 'বিশেষ কোনো নির্দেশনা থাকলে লিখুন...',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Payment Methods Card
              _buildSectionCard(
                title: 'পেমেন্ট মাধ্যম বেছে নিন',
                icon: LucideIcons.creditCard,
                child: Column(
                  children: [
                    _buildPaymentOption(
                      title: 'ক্যাশ অন ডেলিভারি (COD)',
                      subtitle: 'পণ্য হাতে পেয়ে মূল্য পরিশোধ করুন',
                      value: 'cod',
                      icon: LucideIcons.banknote,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      title: 'বিকাশ / নগদ / রকেট',
                      subtitle: 'বাংলাদেশি মোবাইল ব্যাংকিংয়ের মাধ্যমে',
                      value: 'bkash',
                      icon: LucideIcons.smartphone,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      title: 'হোয়াটসঅ্যাপে সরাসরি অর্ডার ও পেমেন্ট',
                      subtitle: 'সরাসরি প্রতিনিধির সাথে কথা বলে অর্ডার কনফার্ম করুন',
                      value: 'whatsapp',
                      icon: LucideIcons.messageCircle,
                      isWhatsApp: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Order Summary Card
              _buildSectionCard(
                title: 'অর্ডারের বিবরণ (${cartProvider.cartCount}টি পণ্য)',
                icon: LucideIcons.shoppingBag,
                child: Column(
                  children: [
                    ...cartProvider.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                Formatters.formatPrice(item.totalPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    _summaryRow('সাবটোটাল', Formatters.formatPrice(cartProvider.subtotal)),
                    const SizedBox(height: 6),
                    _summaryRow('ডেলিভারি চার্জ', Formatters.formatPrice(cartProvider.shippingFee)),
                    if (cartProvider.discountAmount > 0) ...[
                      const SizedBox(height: 6),
                      _summaryRow(
                        'কুপন ছাড়',
                        '-${Formatters.formatPrice(cartProvider.discountAmount)}',
                        isGreen: true,
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('সর্বমোট প্রদেয়', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          Formatters.formatPrice(cartProvider.totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    bool isWhatsApp = false,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isWhatsApp ? const Color(0xFFE8F9EE) : AppColors.primaryContainer.withValues(alpha: 0.3))
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? (isWhatsApp ? AppColors.whatsapp : AppColors.primary) : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? (isWhatsApp ? AppColors.whatsapp : AppColors.primary) : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              size: 20,
              color: isWhatsApp ? AppColors.whatsapp : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isGreen ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomConfirmBar(CartProvider cartProvider, OrderProvider orderProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: 'অর্ডার নিশ্চিত করুন (${Formatters.formatPrice(cartProvider.totalAmount)})',
          isLoading: orderProvider.isCreatingOrder,
          onPressed: _handleCheckout,
        ),
      ),
    );
  }
}

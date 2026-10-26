import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPassController.text) {
      UiHelpers.showSnackBar(context, 'পাসওয়ার্ড দুটি মিলছে না।', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
    );

    if (success && mounted) {
      UiHelpers.showSnackBar(context, 'রেজিস্ট্রেশন সফল হয়েছে!', isSuccess: true);
      Navigator.pop(context);
    } else if (mounted) {
      UiHelpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'রেজিস্ট্রেশন ব্যর্থ হয়েছে।',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.logo,
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  'নতুন অ্যাকাউন্ট তৈরি করুন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'প্রবাসমার্টে কেনাকাটা সহজ ও দ্রুত করতে তথ্য দিন',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: 'প্রথম নাম *',
                        hintText: 'যেমন: মো:',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'প্রথম নাম আবশ্যক' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: 'শেষ নাম *',
                        hintText: 'যেমন: রহিম',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'শেষ নাম আবশ্যক' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _emailController,
                  label: 'ইমেইল এড্রেস *',
                  hintText: 'user@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                  validator: (v) => (v == null || !v.contains('@')) ? 'সঠিক ইমেইল লিখুন' : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _phoneController,
                  label: 'মোবাইল নম্বর',
                  hintText: '01XXXXXXXXX বা ওমান নম্বর',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _passwordController,
                  label: 'পাসওয়ার্ড *',
                  hintText: 'কমপক্ষে ৬ অক্ষরের পাসওয়ার্ড',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'কমপক্ষে ৬ অক্ষরের হতে হবে' : null,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _confirmPassController,
                  label: 'পাসওয়ার্ড নিশ্চিত করুন *',
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                  validator: (v) => (v == null || v.isEmpty) ? 'পাসওয়ার্ড নিশ্চিত করুন' : null,
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'রেজিস্ট্রেশন সম্পন্ন করুন',
                  isLoading: authProvider.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ইতিমধ্যেই অ্যাকাউন্ট আছে? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'সাইন-ইন করুন',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

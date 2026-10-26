import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPassController.text != _confirmPassController.text) {
      UiHelpers.showSnackBar(context, 'নতুন পাসওয়ার্ড দুটি মিলছে না।', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      _oldPassController.text,
      _newPassController.text,
    );

    if (success && mounted) {
      UiHelpers.showSnackBar(context, 'পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে!', isSuccess: true);
      Navigator.pop(context);
    } else if (mounted) {
      UiHelpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'পাসওয়ার্ড পরিবর্তন ব্যর্থ হয়েছে।',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('পাসওয়ার্ড পরিবর্তন'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'পাসওয়ার্ড আপডেট করুন',
            isLoading: authProvider.isLoading,
            onPressed: _handleSubmit,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              children: [
                CustomTextField(
                  controller: _oldPassController,
                  label: 'বর্তমান পাসওয়ার্ড',
                  hintText: '••••••••',
                  obscureText: _obscureOld,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'বর্তমান পাসওয়ার্ড আবশ্যক' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _newPassController,
                  label: 'নতুন পাসওয়ার্ড',
                  hintText: 'কমপক্ষে ৬ ডিজিটের পাসওয়ার্ড',
                  obscureText: _obscureNew,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'কমপক্ষে ৬ অক্ষরের হতে হবে' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _confirmPassController,
                  label: 'নতুন পাসওয়ার্ড নিশ্চিত করুন',
                  hintText: '••••••••',
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'পাসওয়ার্ড নিশ্চিত করুন' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

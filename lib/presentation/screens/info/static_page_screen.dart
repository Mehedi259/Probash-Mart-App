import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class StaticPageScreen extends StatefulWidget {
  final String title;
  final String slug;

  const StaticPageScreen({
    super.key,
    required this.title,
    required this.slug,
  });

  @override
  State<StaticPageScreen> createState() => _StaticPageScreenState();
}

class _StaticPageScreenState extends State<StaticPageScreen> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    try {
      final response = await ApiClient().get('/api/v1/pages/${widget.slug}/');
      if (response != null && response['content'] != null) {
        setState(() {
          _content = response['content'];
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback static copy
    setState(() {
      _content = _getDefaultContent(widget.slug);
      _isLoading = false;
    });
  }

  String _getDefaultContent(String slug) {
    switch (slug) {
      case 'about-us':
        return 'প্রবাসী মার্ট (Probash Mart) ওমানে বসবাসরত প্রবাসী ভাই-বোনদের জন্য দেশের শতভাগ খাঁটি ও নির্ভেজাল খাদ্যপণ্য দ্রুততম সময়ে পৌঁছে দেওয়ার একটি বিশ্বস্ত প্ল্যাটফর্ম।\n\nআমরা সরাসরি বাংলাদেশ থেকে সংগ্রহ করা দেশীয় পদ্মার ইলিশ, তাজা শাক-সবজি, সুগন্ধি আতপ চাল, খাঁটি তেল, মশলা এবং মিষ্টি আপনার দোরগোড়ায় পৌঁছে দিয়ে থাকি। আমাদের লক্ষ্য সর্বোচ্চ গ্রাহক সন্তুষ্টি এবং খাঁটি স্বাদ নিশ্চিত করা।';
      case 'privacy-policy':
        return 'আপনার তথ্যের গোপনীয়তা ও সুরক্ষা আমাদের কাছে অত্যন্ত গুরুত্বপূর্ণ।\n\n১. তথ্য সংগ্রহ: আমরা আপনার নাম, ফোন নম্বর, ডেলিভারি ঠিকানা এবং ইমেইল কেবল অর্ডার ডেলিভারি ও কাস্টমার সাপোর্টের জন্য ব্যবহার করি।\n\n২. তথ্যের নিরাপত্তা: আপনার কোনো ব্যক্তিগত তথ্য কোনো তৃতীয় পক্ষের কাছে বিক্রি বা হস্তান্তর করা হয় না।\n\n৩. পেমেন্ট সুরক্ষা: সকল লেনদেন সম্পূর্ণ নিরাপদ পদ্ধতিতে সম্পন্ন হয়।';
      case 'terms-and-conditions':
        return 'প্রবাসমার্ট ব্যবহারের সাধারণ নিয়ম ও শর্তাবলী:\n\n১. অর্ডার নিশ্চিতকরণ: পণ্য অর্ডার করার পর আমাদের প্রতিনিধি আপনার সাথে হোয়াটসঅ্যাপ অথবা ফোনে যোগাযোগ করে অর্ডার কনফার্ম করতে পারেন।\n\n২. ডেলিভারি ও পেমেন্ট: ক্যাশ অন ডেলিভারিতে পণ্য বুঝে পেয়ে মূল্য পরিশোধ করুন।\n\n৩. রিটার্ন পলিসি: পণ্য ক্ষতিগ্রস্ত হলে ডেলিভারির সময় তাৎক্ষণিকভাবে রাইডারের কাছে অথবা আমাদের কাস্টমার সার্ভিসে জানান।';
      default:
        return 'প্রবাসমার্টে কেনাকাটা করার জন্য ধন্যবাদ। যেকোনো তথ্যের জন্য আমাদের কাস্টমার সাপোর্টে যোগাযোগ করুন।';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Text(
                  _content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ),
            ),
    );
  }
}

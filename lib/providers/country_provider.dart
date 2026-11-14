import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryOption {
  final String code;
  final String name;
  final String flag;
  final String currencyCode;
  final String currencySymbol;
  final double ratePerBdt;
  final int decimals;

  const CountryOption({
    required this.code,
    required this.name,
    required this.flag,
    required this.currencyCode,
    required this.currencySymbol,
    required this.ratePerBdt,
    this.decimals = 3,
  });

  String formatPrice(double bdtPrice) {
    if (code == 'BD') {
      return '৳${bdtPrice.toStringAsFixed(0)}';
    }
    final converted = bdtPrice * ratePerBdt;
    return '${converted.toStringAsFixed(decimals)} $currencyCode';
  }

  String formatDualPrice(double bdtPrice) {
    if (code == 'BD') {
      return '৳${bdtPrice.toStringAsFixed(0)}';
    }
    final converted = bdtPrice * ratePerBdt;
    return '${converted.toStringAsFixed(decimals)} $currencyCode (৳${bdtPrice.toStringAsFixed(0)})';
  }
}

class CountryProvider with ChangeNotifier {
  static const String _prefKey = 'selected_order_country';

  static const List<CountryOption> supportedCountries = [
    CountryOption(
      code: 'OM',
      name: 'ওমান',
      flag: '🇴🇲',
      currencyCode: 'OMR',
      currencySymbol: 'OMR',
      ratePerBdt: 1.0 / 310.0,
      decimals: 3,
    ),
    CountryOption(
      code: 'BD',
      name: 'বাংলাদেশ',
      flag: '🇧🇩',
      currencyCode: 'BDT',
      currencySymbol: '৳',
      ratePerBdt: 1.0,
      decimals: 0,
    ),
    CountryOption(
      code: 'SA',
      name: 'সৌদি আরব',
      flag: '🇸🇦',
      currencyCode: 'SAR',
      currencySymbol: 'SAR',
      ratePerBdt: 1.0 / 32.0,
      decimals: 2,
    ),
    CountryOption(
      code: 'AE',
      name: 'ইউএই (দুবাই)',
      flag: '🇦🇪',
      currencyCode: 'AED',
      currencySymbol: 'AED',
      ratePerBdt: 1.0 / 32.7,
      decimals: 2,
    ),
    CountryOption(
      code: 'MY',
      name: 'মালয়েশিয়া',
      flag: '🇲🇾',
      currencyCode: 'MYR',
      currencySymbol: 'RM',
      ratePerBdt: 1.0 / 27.0,
      decimals: 2,
    ),
    CountryOption(
      code: 'QA',
      name: 'কাতার',
      flag: '🇶🇦',
      currencyCode: 'QAR',
      currencySymbol: 'QAR',
      ratePerBdt: 1.0 / 33.0,
      decimals: 2,
    ),
  ];

  CountryOption _selected = supportedCountries[0];

  CountryOption get selectedCountry => _selected;

  CountryProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        final match = supportedCountries.firstWhere(
          (c) => c.code == code,
          orElse: () => supportedCountries[0],
        );
        _selected = match;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setCountry(CountryOption country) async {
    _selected = country;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, country.code);
    } catch (_) {}
  }
}


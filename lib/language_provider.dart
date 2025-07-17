import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _languageCode = 'ar'; // Default: Arabic

  String get languageCode => _languageCode;

  void setLanguage(String languageCode) {
    if (!['ar', 'en'].contains(languageCode)) return;
    _languageCode = languageCode;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Singleton ValueNotifier that holds the active locale and persists it.
// Read: LocaleNotifier.instance.value
// Change: await LocaleNotifier.instance.switchTo(const Locale('es'))
class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier._() : super(const Locale('en'));

  static final LocaleNotifier instance = LocaleNotifier._();

  static const _prefKey = 'app_locale';

  // Call once at app startup (before runApp) to restore the saved locale.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) value = Locale(code);
  }

  // Switches the active locale and persists the choice.
  Future<void> switchTo(Locale locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }
}

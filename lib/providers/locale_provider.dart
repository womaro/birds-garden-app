import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(sharedPreferencesProvider)),
);

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs)
      : super(Locale(_prefs.getString('locale') ?? 'pl'));

  void setLocale(Locale locale) {
    _prefs.setString('locale', locale.languageCode);
    state = locale;
  }
}

const supportedLocales = [
  Locale('pl'),
  Locale('en'),
  // Locale('de'), // odkomentuj gdy będzie app_de.arb
];
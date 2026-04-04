import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kDefaultLocale = Locale('ky');
const kSupportedLocales = [Locale('ky'), Locale('ru')];

final localeProvider = StateProvider<Locale>((ref) => kDefaultLocale);

final dictionaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final locale = ref.watch(localeProvider);
  final jsonString = await rootBundle
      .loadString('lib/core/i18n/dictionaries/${locale.languageCode}.json');
  return json.decode(jsonString) as Map<String, dynamic>;
});

/// Helper to get nested dictionary values using dot notation.
/// Example: t(dict, 'nav.home') returns the value at dict['nav']['home']
String t(Map<String, dynamic>? dict, String key, [Map<String, String>? params]) {
  if (dict == null) return key;

  final parts = key.split('.');
  dynamic value = dict;
  for (final part in parts) {
    if (value is Map<String, dynamic> && value.containsKey(part)) {
      value = value[part];
    } else {
      return key;
    }
  }

  var result = value.toString();
  if (params != null) {
    params.forEach((paramKey, paramValue) {
      result = result.replaceAll('{$paramKey}', paramValue);
    });
  }
  return result;
}

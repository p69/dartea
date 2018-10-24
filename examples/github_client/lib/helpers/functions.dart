import 'package:flutter/material.dart';
import 'package:github_client/api.dart';

Color getLanguageColor(String language, Map<String, Language> map) {
  final lang = map[language];
  if (lang == null) {
    return Colors.black;
  }
  return Color(lang.color);
}
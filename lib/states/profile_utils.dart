import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_client_app/models/index.dart' as models;

/// 规范化历史存储的 locale 字符串，保持 UI 读取兼容。
///
/// [locale] 表示存储在 Profile 中的语言标识。
String? normalizeLocaleCode(String? locale) {
  if (locale == null || locale.isEmpty) return null;
  if (locale == 'en_US') return 'en';
  if (locale == 'zh_CN') return 'zh';
  return locale;
}

/// 将 Profile 中的语言字符串转换为 Flutter Locale。
///
/// [locale] 表示存储在 Profile 中的语言标识。
Locale? localeCodeToLocale(String? locale) {
  if (locale == null || locale.isEmpty) return null;

  if (locale == 'en_US') return const Locale('en');
  if (locale == 'zh_CN') return const Locale('zh');

  final String normalized = locale.replaceAll('-', '_');
  final List<String> parts = normalized.split('_');
  if (parts.isEmpty || parts.first.isEmpty) return null;
  if (parts.length == 1) return Locale(parts[0]);
  if (parts.length == 2) return Locale(parts[0], parts[1]);

  return Locale.fromSubtags(
    languageCode: parts[0],
    scriptCode: parts[1],
    countryCode: parts[2],
  );
}

/// 深拷贝 Profile，避免在 Riverpod 状态流转中复用可变对象。
///
/// [source] 表示需要复制的 Profile 对象。
models.Profile cloneProfile(models.Profile source) {
  final Map<String, dynamic> json =
      jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>;

  return models.Profile()
    ..user =
        json['user'] == null
            ? null
            : models.User.fromJson(json['user'] as Map<String, dynamic>)
    ..token = json['token'] as String?
    ..theme = json['theme'] as num
    ..cache =
        json['cache'] == null
            ? null
            : models.CacheConfig.fromJson(json['cache'] as Map<String, dynamic>)
    ..lastLogin = json['lastLogin'] as String?
    ..locale = json['locale'] as String?;
}

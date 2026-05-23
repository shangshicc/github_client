import 'package:flutter/material.dart';

/// 应用主题的单一真相源。
///
/// 该类统一维护可选主题色板、ARGB 到 [MaterialColor] 的解析、
/// 以及 [ThemeData] 的构建入口，避免不同文件重复解释主题来源。
abstract final class AppTheme {
  static const List<MaterialColor> palettes = <MaterialColor>[
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.red,
  ];

  /// 根据持久化的 ARGB 值解析对应主题色。
  ///
  /// [argb] 表示保存在 Profile 中的主题色值。
  ///
  /// 当 [argb] 不在已支持主题列表中时，返回默认蓝色主题。
  static MaterialColor resolveMaterialColor(num? argb) {
    return palettes.firstWhere(
      (MaterialColor color) => color.toARGB32() == argb,
      orElse: () => Colors.blue,
    );
  }

  /// 构建应用主题数据。
  ///
  /// [argb] 表示当前持久化的主题色值。
  static ThemeData buildThemeData(num? argb) {
    return ThemeData(primarySwatch: resolveMaterialColor(argb));
  }
}

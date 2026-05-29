import 'package:flutter/material.dart';

/// 应用皮肤定义。
///
/// 每个皮肤代表一套品牌主色方案，并可同时生成浅色与深色主题。
@immutable
class AppSkin {
  const AppSkin({
    required this.id,
    required this.label,
    required this.swatch,
    required this.seedColor,
  });

  /// 皮肤唯一标识，用于持久化。
  final String id;

  /// 展示名称。
  final String label;

  /// 兼容旧调用时暴露的 MaterialColor 主色板。
  final MaterialColor swatch;

  /// 用于 Material 3 生成 ColorScheme 的种子色。
  final Color seedColor;
}

/// 应用主题的单一真相源。
///
/// 该类统一维护可选皮肤、历史 ARGB 到皮肤的兼容解析、
/// 亮暗模式序列化、以及 [ThemeData] 的构建入口，避免不同文件重复解释主题来源。
///
/// 设计原则：
/// 1. 文案颜色尽量依赖 [ColorScheme] 的语义色，而不是写死黑白色值；
/// 2. 亮色与深色只在主题层分叉，页面层优先直接使用 `Theme.of(context)`；
/// 3. 常见组件主题也尽量复用同一套颜色语义，降低页面侧 `copyWith` 成本。
abstract final class AppTheme {
  static const AppSkin defaultSkin = AppSkin(
    id: 'default',
    label: 'Default',
    swatch: Colors.blue,
    seedColor: Colors.blue,
  );

  static const List<AppSkin> skins = <AppSkin>[
    defaultSkin,
    AppSkin(
      id: 'ocean',
      label: 'Ocean',
      swatch: Colors.cyan,
      seedColor: Colors.cyan,
    ),
    AppSkin(
      id: 'teal',
      label: 'Teal',
      swatch: Colors.teal,
      seedColor: Colors.teal,
    ),
    AppSkin(
      id: 'forest',
      label: 'Forest',
      swatch: Colors.green,
      seedColor: Colors.green,
    ),
    AppSkin(
      id: 'sunset',
      label: 'Sunset',
      swatch: Colors.red,
      seedColor: Colors.red,
    ),
  ];

  /// 为兼容旧调用保留的主题色板列表。
  static const List<MaterialColor> palettes = <MaterialColor>[
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.red,
  ];

  /// 根据皮肤 id 与历史 ARGB 值解析当前皮肤。
  ///
  /// 优先使用 [skinId]，若为空则回退到 [legacyArgb] 对应的历史主题色。
  static AppSkin resolveSkin(String? skinId, {num? legacyArgb}) {
    if (skinId != null && skinId.isNotEmpty) {
      return skins.firstWhere(
        (AppSkin skin) => skin.id == skinId,
        orElse: () => defaultSkin,
      );
    }

    return _resolveSkinFromLegacyArgb(legacyArgb);
  }

  /// 将历史主题色值映射为当前皮肤 id。
  static String resolveSkinId(String? skinId, {num? legacyArgb}) {
    return resolveSkin(skinId, legacyArgb: legacyArgb).id;
  }

  /// 根据持久化的 ARGB 值解析对应主题色。
  ///
  /// [argb] 表示保存在 Profile 中的历史主题色值。
  ///
  /// 当 [argb] 不在已支持主题列表中时，返回默认蓝色主题。
  static MaterialColor resolveMaterialColor(num? argb) {
    return _resolveSkinFromLegacyArgb(argb).swatch;
  }

  /// 根据旧的 [MaterialColor] 反查皮肤。
  static AppSkin resolveSkinFromColor(MaterialColor color) {
    return skins.firstWhere(
      (AppSkin skin) => skin.swatch.toARGB32() == color.toARGB32(),
      orElse: () => defaultSkin,
    );
  }

  /// 根据皮肤构建应用亮色主题数据。
  static ThemeData buildLightThemeDataBySkin(AppSkin skin) {
    return _buildThemeData(skin: skin, brightness: Brightness.light);
  }

  /// 根据皮肤构建应用深色主题数据。
  static ThemeData buildDarkThemeDataBySkin(AppSkin skin) {
    return _buildThemeData(skin: skin, brightness: Brightness.dark);
  }

  /// 构建应用亮色主题数据。
  ///
  /// [argb] 表示当前持久化的历史主题色值。
  static ThemeData buildLightThemeData(num? argb) {
    final AppSkin skin = resolveSkin(null, legacyArgb: argb);
    return buildLightThemeDataBySkin(skin);
  }

  /// 构建应用深色主题数据。
  ///
  /// [argb] 表示当前持久化的历史主题色值。
  static ThemeData buildDarkThemeData(num? argb) {
    final AppSkin skin = resolveSkin(null, legacyArgb: argb);
    return buildDarkThemeDataBySkin(skin);
  }

  /// 根据亮暗模式统一构建应用主题。
  ///
  /// [skin] 表示当前选择的品牌皮肤；
  /// [brightness] 表示当前主题亮暗模式。
  ///
  /// 这里集中配置应用级别的 [ColorScheme]、[TextTheme] 与常见组件主题，
  /// 让页面层尽量只消费语义化样式。
  static ThemeData _buildThemeData({
    required AppSkin skin,
    required Brightness brightness,
  }) {
    final ColorScheme colorScheme = _buildColorScheme(
      skin: skin,
      brightness: brightness,
    );
    final TextTheme textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primarySwatch: skin.swatch,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.38),
      splashColor: colorScheme.primary.withValues(alpha: 0.08),
      highlightColor: colorScheme.primary.withValues(alpha: 0.06),
      textTheme: textTheme,
      primaryTextTheme: textTheme.apply(
        bodyColor: colorScheme.onPrimary,
        displayColor: colorScheme.onPrimary,
      ),
      appBarTheme: _buildAppBarTheme(colorScheme, textTheme),
      cardTheme: _buildCardTheme(colorScheme),
      listTileTheme: _buildListTileTheme(colorScheme, textTheme),
      chipTheme: _buildChipTheme(colorScheme, textTheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme, textTheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme, textTheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme, textTheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme, textTheme),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(colorScheme),
      snackBarTheme: _buildSnackBarTheme(colorScheme, textTheme),
      dialogTheme: _buildDialogTheme(colorScheme, textTheme),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, textTheme),
      tabBarTheme: _buildTabBarTheme(colorScheme, textTheme),
      switchTheme: _buildSwitchTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme),
      radioTheme: _buildRadioTheme(colorScheme),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  /// 基于品牌皮肤与亮暗模式生成统一的语义色板。
  static ColorScheme _buildColorScheme({
    required AppSkin skin,
    required Brightness brightness,
  }) {
    return ColorScheme.fromSeed(
      seedColor: skin.seedColor,
      brightness: brightness,
    );
  }

  /// 构建应用默认文本体系。
  ///
  /// [colorScheme] 表示当前主题使用的语义色板。
  ///
  /// 这里尽量为各层级文本绑定语义颜色：
  /// - 标题、正文优先使用 `onSurface`；
  /// - 说明、标签、辅助信息优先使用 `onSurfaceVariant`；
  /// - 保持页面在深色模式下无需额外写死颜色也能正常阅读。
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final TextTheme baseTextTheme = Typography.material2021().black;

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// 构建顶部导航栏主题。
  static AppBarTheme _buildAppBarTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      titleTextStyle: textTheme.titleLarge,
      toolbarTextStyle: textTheme.bodyMedium,
    );
  }

  /// 构建卡片主题。
  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surfaceContainerLow,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      surfaceTintColor: colorScheme.surfaceTint,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }

  /// 构建列表项主题。
  static ListTileThemeData _buildListTileTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListTileThemeData(
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodySmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// 构建标签主题。
  static ChipThemeData _buildChipTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      disabledColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.secondaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      deleteIconColor: colorScheme.onSurfaceVariant,
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
      secondaryLabelStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  /// 构建输入框主题。
  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final OutlineInputBorder enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
    );
    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.error),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      helperStyle: textTheme.bodySmall,
      errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
      enabledBorder: enabledBorder,
      disabledBorder: enabledBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      border: enabledBorder,
    );
  }

  /// 构建主按钮主题。
  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 构建描边按钮主题。
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.labelLarge,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 构建文字按钮主题。
  static TextButtonThemeData _buildTextButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 构建悬浮操作按钮主题。
  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme(
    ColorScheme colorScheme,
  ) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      splashColor: colorScheme.primary.withValues(alpha: 0.12),
    );
  }

  /// 构建消息提示条主题。
  static SnackBarThemeData _buildSnackBarTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      actionTextColor: colorScheme.inversePrimary,
      disabledActionTextColor: colorScheme.onInverseSurface.withValues(
        alpha: 0.38,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// 构建对话框主题。
  static DialogThemeData _buildDialogTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: colorScheme.surfaceTint,
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  /// 构建底部弹层主题。
  static BottomSheetThemeData _buildBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      modalBackgroundColor: colorScheme.surface,
      modalBarrierColor: colorScheme.scrim.withValues(alpha: 0.32),
      showDragHandle: true,
      dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  /// 构建底部导航栏主题。
  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          );
        }

        return textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.onSecondaryContainer);
        }

        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
    );
  }

  /// 构建标签栏主题。
  static TabBarThemeData _buildTabBarTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      dividerColor: colorScheme.outlineVariant,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
    );
  }

  /// 构建开关主题。
  static SwitchThemeData _buildSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }

        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primaryContainer;
        }

        return colorScheme.surfaceContainerHighest;
      }),
    );
  }

  /// 构建复选框主题。
  static CheckboxThemeData _buildCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }

        return Colors.transparent;
      }),
      checkColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
      side: BorderSide(color: colorScheme.outline),
    );
  }

  /// 构建单选框主题。
  static RadioThemeData _buildRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }

        return colorScheme.onSurfaceVariant;
      }),
    );
  }

  static AppSkin _resolveSkinFromLegacyArgb(num? argb) {
    return skins.firstWhere(
      (AppSkin skin) => skin.swatch.toARGB32() == argb,
      orElse: () => defaultSkin,
    );
  }
}

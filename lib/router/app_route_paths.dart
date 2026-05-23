/// 应用路由路径常量。
///
/// 该类集中维护当前项目对外暴露的页面路径，避免路径字符串散落在
/// `main.dart` 与页面层。首期仅收拢当前 `MaterialApp.routes` 中已注册
/// 的页面与根首页路径，后续子页面路由会在后续步骤继续纳管。
abstract final class AppRoutePaths {
  /// 首页路径。
  static const String home = '/';

  /// 登录页路径。
  static const String login = '/login';

  /// 主题切换页路径。
  static const String themes = '/themes';

  /// 语言切换页路径。
  static const String language = '/language';

  /// Demo 首页路径。
  static const String demo = '/demo';

  /// 商品选择页路径。
  static const String selector = '/selector';

  /// 详情页路径。
  static const String detail = '/detail';

  /// Demo 列表页路径。
  static const String demoList = '/demo/list';

  /// Demo NestedScroll 页路径。
  static const String demoNestedScroll = '/demo/nested-scroll';

  /// 状态管理 Demo 页路径。
  static const String demoStateManagement = '/demo/state-management';
}

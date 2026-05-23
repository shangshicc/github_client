import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/router/app_route_paths.dart';

class DemoRoute extends StatelessWidget {
  const DemoRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.demo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ElevatedButton(onPressed: onPressed, child: Text(l10n.demo)),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const ValueKey<String>('demo-state-management-entry'),
            onPressed: () => _openStateManagementDemo(context),
            child: const Text('State Management Demo'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const ValueKey<String>('demo-list-entry'),
            onPressed: () => _openListDemo(context),
            child: Text(l10n.demoList),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const ValueKey<String>('demo-nested-scroll-entry'),
            onPressed: () => _openNestedScrollDemo(context),
            child: Text(l10n.demoNestedScroll),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const ValueKey<String>('demo-error-debug-entry'),
            onPressed: () => _openErrorDebugPage(context),
            child: const Text('错误调试页'),
          ),
        ],
      ),
    );
  }

  /// 打开状态管理 Demo 页面。
  ///
  /// [context] 表示当前页面上下文，用于执行页面跳转。
  void _openStateManagementDemo(BuildContext context) {
    context.push(AppRoutePaths.demoStateManagement);
  }

  /// 打开多类型列表 Demo 页面。
  ///
  /// [context] 表示当前页面上下文，用于执行页面跳转。
  void _openListDemo(BuildContext context) {
    context.push(AppRoutePaths.demoList);
  }

  /// 打开 NestedScrollView 经典业务 Demo 页面。
  ///
  /// [context] 表示当前页面上下文，用于执行页面跳转。
  void _openNestedScrollDemo(BuildContext context) {
    context.push(AppRoutePaths.demoNestedScroll);
  }

  /// 打开错误调试页。
  void _openErrorDebugPage(BuildContext context) {
    context.push(AppRoutePaths.errorDebug);
  }

  /// 触发当前保留的基础 toast Demo。
  void onPressed() {
    showToast('test');
  }
}

import 'package:flutter/material.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/routes/demo/list/demo_list_route.dart';
import 'package:github_client_app/routes/demo/nested_scroll/demo_nested_scroll_route.dart';

class DemoRoute extends StatelessWidget {
  const DemoRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // 运行时常量
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.demo),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              ElevatedButton(onPressed: onPressed, child: Text(l10n.demo)),
              ElevatedButton(
                onPressed: () => _openListDemo(context),
                child: Text(l10n.demoList),
              ),
              ElevatedButton(
                onPressed: () => _openNestedScrollDemo(context),
                child: Text(l10n.demoNestedScroll),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 打开多类型列表 Demo 页面。
  ///
  /// [context] 表示当前页面上下文，用于执行页面跳转。
  void _openListDemo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DemoListRoute()),
    );
  }

  /// 打开 NestedScrollView 经典业务 Demo 页面。
  ///
  /// [context] 表示当前页面上下文，用于执行页面跳转。
  void _openNestedScrollDemo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DemoNestedScrollRoute()),
    );
  }

  void onPressed() {
    showToast("test");
  }
}

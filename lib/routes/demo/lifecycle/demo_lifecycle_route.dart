import 'package:flutter/material.dart';
import 'package:github_client_app/common/logger.dart';

final _log = createLogger('[DemoLifecycleRoute]');

/// 生命周期 Demo 页面。
///
/// 页面保持最简内容，只用于演示 `StatefulWidget` 常见生命周期回调
/// 与应用前后台生命周期监听。
class DemoLifecycleRoute extends StatefulWidget {
  /// 创建生命周期 Demo 页面。
  ///
  /// [pageTitle] 表示页面标题，同时用于演示 `didUpdateWidget` 时的新旧配置对比。
  const DemoLifecycleRoute({super.key, this.pageTitle = '生命周期 Demo'});

  /// 页面标题。
  final String pageTitle;

  @override
  /// 创建生命周期 Demo 页对应的 State 对象。
  State<DemoLifecycleRoute> createState() => _DemoLifecycleRouteState();
}

class _DemoLifecycleRouteState extends State<DemoLifecycleRoute>
    with WidgetsBindingObserver {
  int _counter = 0;
  AppLifecycleState? _lastAppLifecycleState;

  /// 在 State 首次插入树时注册应用生命周期监听，并记录初始化日志。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _log.i('initState: pageTitle=${widget.pageTitle}');
  }

  /// 当依赖的 InheritedWidget 变化或 State 首次建立依赖关系时记录日志。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _log.i('didChangeDependencies');
  }

  /// 当父组件以同类型新配置重建当前页面时记录新旧标题差异。
  ///
  /// [oldWidget] 表示更新前的旧组件配置。
  @override
  void didUpdateWidget(covariant DemoLifecycleRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log.i(
      'didUpdateWidget: oldTitle=${oldWidget.pageTitle}, '
      'newTitle=${widget.pageTitle}',
    );
  }

  /// 在热重载触发时记录日志，便于本地开发观察回调顺序。
  @override
  void reassemble() {
    super.reassemble();
    _log.i('reassemble');
  }

  /// 当 State 重新插入树中时记录日志。
  @override
  void activate() {
    super.activate();
    _log.i('activate');
  }

  /// 当 State 即将临时从树中移除时记录日志。
  @override
  void deactivate() {
    _log.i('deactivate');
    super.deactivate();
  }

  /// 监听应用前后台生命周期变化并缓存最近一次状态。
  ///
  /// [state] 表示 Flutter 框架感知到的应用生命周期状态。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastAppLifecycleState = state;
    _log.i('didChangeAppLifecycleState: $state');
  }

  /// 释放前注销应用生命周期监听，并记录销毁日志。
  @override
  void dispose() {
    _log.i('dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 累加当前页面上的演示计数并记录变更日志。
  void _incrementCounter() {
    setState(() {
      _counter += 1;
    });
    _log.i('counterChanged: $_counter');
  }

  /// 构建页面主体，展示最小说明、计数值与最近一次应用生命周期状态。
  @override
  Widget build(BuildContext context) {
    _log.d('build: counter=$_counter');
    return Scaffold(
      appBar: AppBar(title: Text(widget.pageTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '这个页面只用于演示 StatefulWidget 生命周期日志。',
              key: ValueKey<String>('demo-lifecycle-description'),
            ),
            const SizedBox(height: 12),
            Text(
              '计数：$_counter',
              key: const ValueKey<String>('demo-lifecycle-counter'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '最近应用生命周期：${_lastAppLifecycleState?.name ?? 'none'}',
              key: const ValueKey<String>('demo-lifecycle-app-state'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const ValueKey<String>('demo-lifecycle-increment-button'),
              onPressed: _incrementCounter,
              child: const Text('计数 +1'),
            ),
          ],
        ),
      ),
    );
  }
}

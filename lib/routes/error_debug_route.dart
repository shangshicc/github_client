import 'package:flutter/material.dart';

/// 错误调试页。
///
/// 仅用于本地验证局部异常提醒与全局 FlutterError。
class ErrorDebugRoute extends StatefulWidget {
  /// 创建错误调试页。
  const ErrorDebugRoute({super.key});

  @override
  State<ErrorDebugRoute> createState() => _ErrorDebugRouteState();
}

class _ErrorDebugRouteState extends State<ErrorDebugRoute> {
  bool _shouldCrashLocalWidget = false;

  void _triggerLocalBuildCrash() {
    setState(() {
      _shouldCrashLocalWidget = true;
    });
  }

  void _triggerGlobalFlutterError() {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: StateError('debug scheduler crash'),
        stack: StackTrace.current,
        library: 'scheduler library',
        context: ErrorDescription('during a scheduler callback'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('错误调试页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text('用于本地验证两类错误展示：局部 build 错误、全局 FlutterError。'),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const ValueKey<String>('error-debug-local-build-button'),
            onPressed: _triggerLocalBuildCrash,
            child: const Text('1. 触发局部 build 错误'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const ValueKey<String>('error-debug-global-flutter-button'),
            onPressed: _triggerGlobalFlutterError,
            child: const Text('2. 触发全局 FlutterError'),
          ),
          const SizedBox(height: 24),
          const Text(
            '局部错误演示区',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _DebugCrashCard(shouldCrash: _shouldCrashLocalWidget),
        ],
      ),
    );
  }
}

class _DebugCrashCard extends StatelessWidget {
  const _DebugCrashCard({required this.shouldCrash});

  final bool shouldCrash;

  @override
  Widget build(BuildContext context) {
    if (shouldCrash) {
      throw StateError('debug local build crash');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              '这是一个正常模块',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('点击上方第一个按钮后，这个模块会被局部错误提醒替换。'),
          ],
        ),
      ),
    );
  }
}

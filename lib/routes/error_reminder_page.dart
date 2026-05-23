import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:github_client_app/common/app_error_presentation_coordinator.dart';

import '../router/app_route_paths.dart';

/// 全局异常提醒页。
class ErrorReminderPage extends StatefulWidget {
  /// 创建全局异常提醒页。
  const ErrorReminderPage({super.key});

  @override
  State<ErrorReminderPage> createState() => _ErrorReminderPageState();
}

class _ErrorReminderPageState extends State<ErrorReminderPage> {
  @override
  void dispose() {
    appErrorPresentationCoordinator?.dismiss();
    super.dispose();
  }

  void _goHome() {
    appErrorPresentationCoordinator?.dismiss();
    context.go(AppRoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _goHome();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('异常提醒'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  '应用刚刚发生了异常',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text('请稍后重试，或者先返回首页继续使用应用。', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  key: const ValueKey<String>('error-reminder-home-button'),
                  onPressed: _goHome,
                  child: const Text('返回首页'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

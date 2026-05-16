import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/states/riverpod/counter_provider.dart';

final _detailPageLogger = createLogger('DetailPage');

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key});

  /// 处理详情页中的计数递增动作。
  ///
  /// [ref] 用于读取和更新 Counter 对应的 Riverpod 状态。
  ///
  /// 副作用：会读取当前计数值、执行加一更新，并输出更新前后的日志。
  void _incrementCounter(WidgetRef ref) {
    final int currentCounter = ref.read(counterProvider);
    _detailPageLogger.i('点击详情页计数按钮，currentCounter=$currentCounter');
    ref.read(counterProvider.notifier).increment();
    final int nextCounter = ref.read(counterProvider);
    _detailPageLogger.i('详情页计数更新完成，nextCounter=$nextCounter');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('detail page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _incrementCounter(ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/widgets/error_widget_fallback.dart';

void main() {
  test('configureErrorWidgetFallback 会安装局部错误提醒模块', () {
    final Widget Function(FlutterErrorDetails) previousBuilder =
        ErrorWidget.builder;
    addTearDown(() {
      ErrorWidget.builder = previousBuilder;
    });

    ErrorWidget.builder = (FlutterErrorDetails _) {
      return const ErrorWidgetFallback();
    };

    final Widget fallbackWidget = ErrorWidget.builder(
      FlutterErrorDetails(
        exception: StateError('boom'),
        stack: StackTrace.fromString('stack'),
      ),
    );

    expect(fallbackWidget, isA<ErrorWidgetFallback>());
  });

  testWidgets('ErrorWidgetFallback 默认展示局部异常提醒', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ErrorWidgetFallback()));

    expect(find.text('当前模块暂时不可用'), findsOneWidget);
    expect(find.text('这部分内容刚刚发生异常，你可以稍后重试或继续使用页面其他功能。'), findsOneWidget);
  });
}

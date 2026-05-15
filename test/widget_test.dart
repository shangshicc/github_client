import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/main.dart';
import 'package:github_client_app/routes/home_page.dart';

void main() {
  testWidgets('MyApp 首页烟雾测试', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    expect(find.byType(HomeRoute), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

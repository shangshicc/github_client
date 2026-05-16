import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/states/riverpod/counter_provider.dart';

void main() {
  test('counterProvider 默认值为 0，调用 increment 后会递增', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);

    final Counter notifier = container.read(counterProvider.notifier);
    notifier.increment();

    expect(container.read(counterProvider), 1);
  });
}

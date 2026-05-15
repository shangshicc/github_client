import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/states/riverpod/selector_notifier.dart';
import 'package:github_client_app/states/riverpod/selector_state.dart';

class SelectorPage extends ConsumerWidget {
  const SelectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int total = ref.watch(selectorProvider.select((SelectorState state) {
      return state.total;
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('selector Page'),
      ),
      body: ListView.builder(
        itemCount: total,
        itemBuilder: (BuildContext context, int index) {
          return _SelectorGoodsTile(index: index);
        },
      ),
    );
  }
}

class _SelectorGoodsTile extends ConsumerWidget {
  const _SelectorGoodsTile({
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SelectorGoodsItem goods = ref.watch(
      selectorProvider.select((SelectorState state) => state.goodsList[index]),
    );

    return ListTile(
      title: Text(goods.goodsName),
      trailing: GestureDetector(
        onTap: () {
          ref.read(selectorProvider.notifier).collect(index);
        },
        child: Icon(
          goods.isCollection ? Icons.star : Icons.star_border,
        ),
      ),
    );
  }
}

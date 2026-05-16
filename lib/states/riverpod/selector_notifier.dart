import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/states/riverpod/selector_state.dart';

part 'selector_notifier.g.dart';

final _selectorNotifierLogger = createLogger('SelectorNotifier');

/// Selector 页面状态控制器。
///
/// 该控制器负责初始化商品列表，并在点击时切换指定商品的收藏状态。
@riverpod
class Selector extends _$Selector {
  /// 构建 Selector 页面初始状态。
  ///
  /// 返回值：包含 10 条初始商品数据的页面状态对象。
  @override
  SelectorState build() {
    return SelectorState(
      goodsList: List<SelectorGoodsItem>.generate(
        10,
        (int index) => SelectorGoodsItem(
          isCollection: false,
          goodsName: 'goods no $index',
        ),
      ),
    );
  }

  /// 切换指定下标商品的收藏状态。
  ///
  /// [index] 表示需要切换收藏状态的商品下标。
  ///
  /// 副作用：会生成新的商品列表状态，并触发对应 UI 刷新。
  void collect(int index) {
    _selectorNotifierLogger.i('切换商品收藏状态，index=$index');
    final List<SelectorGoodsItem> updatedList = List<SelectorGoodsItem>.from(
      state.goodsList,
    );
    final SelectorGoodsItem currentItem = updatedList[index];
    updatedList[index] = currentItem.copyWith(
      isCollection: !currentItem.isCollection,
    );
    state = state.copyWith(goodsList: updatedList);
    _selectorNotifierLogger.i(
      '商品收藏状态切换完成，index=$index, isCollection=${updatedList[index].isCollection}',
    );
  }
}

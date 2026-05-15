/// Selector 页面单个商品项状态。
///
/// 该对象用于承载商品列表中的单项展示数据，避免 UI 直接依赖可变对象。
class SelectorGoodsItem {
  /// 创建一个商品项状态对象。
  ///
  /// [isCollection] 表示当前商品是否已收藏。
  /// [goodsName] 表示当前商品名称。
  const SelectorGoodsItem({
    required this.isCollection,
    required this.goodsName,
  });

  /// 当前商品是否已收藏。
  final bool isCollection;

  /// 当前商品名称。
  final String goodsName;

  /// 基于当前对象复制一个新对象。
  ///
  /// [isCollection] 用于覆盖收藏状态。
  /// [goodsName] 用于覆盖商品名称。
  ///
  /// 返回值：复制后的新商品项对象。
  SelectorGoodsItem copyWith({
    bool? isCollection,
    String? goodsName,
  }) {
    return SelectorGoodsItem(
      isCollection: isCollection ?? this.isCollection,
      goodsName: goodsName ?? this.goodsName,
    );
  }
}

/// Selector 页面整体状态。
///
/// 该对象用于统一承载商品列表，供页面和局部 item 订阅。
class SelectorState {
  /// 创建 Selector 页面状态对象。
  ///
  /// [goodsList] 表示页面当前商品列表。
  const SelectorState({
    required this.goodsList,
  });

  /// 当前商品列表。
  final List<SelectorGoodsItem> goodsList;

  /// 当前商品总数。
  int get total => goodsList.length;

  /// 基于当前对象复制一个新状态对象。
  ///
  /// [goodsList] 用于覆盖新的商品列表。
  ///
  /// 返回值：复制后的新状态对象。
  SelectorState copyWith({
    List<SelectorGoodsItem>? goodsList,
  }) {
    return SelectorState(
      goodsList: goodsList ?? this.goodsList,
    );
  }
}

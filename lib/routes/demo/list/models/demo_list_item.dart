import 'package:github_client_app/models/index.dart';

/// Demo 列表条目抽象模型。
///
/// 该模型用于把一个仓库数据拆分为不同类型的展示条目，提升列表渲染的复用性和可读性。
sealed class DemoListItem {
  /// 创建 Demo 列表条目抽象模型。
  const DemoListItem();
}

/// 仓库标题条目数据。
///
/// 用于承载仓库标题 item 所需的非空仓库数据。
final class DemoListTitleItemData extends DemoListItem {
  /// 创建仓库标题条目数据。
  ///
  /// [repo] 表示当前标题条目展示的仓库对象。
  const DemoListTitleItemData(this.repo);

  /// 当前条目绑定的仓库数据。
  final Repo repo;
}

/// 仓库核心信息条目数据。
///
/// 用于承载仓库核心信息 item 所需的非空仓库数据。
final class DemoListMetaItemData extends DemoListItem {
  /// 创建仓库核心信息条目数据。
  ///
  /// [repo] 表示当前核心信息条目展示的仓库对象。
  const DemoListMetaItemData(this.repo);

  /// 当前条目绑定的仓库数据。
  final Repo repo;
}

/// 列表状态条目数据。
///
/// 用于承载 loading、empty、error 等状态 item 所需的数据。
final class DemoListStateItemData extends DemoListItem {
  /// 创建列表状态条目数据。
  ///
  /// [stateType] 表示当前状态类型。
  /// [message] 表示当前状态下用于展示的提示文案。
  const DemoListStateItemData({
    required this.stateType,
    this.message,
  });

  /// 当前状态条目类型。
  final DemoListStateType stateType;

  /// 当前状态条目对应的提示文案。
  final String? message;
}

/// 列表状态类型枚举。
///
/// 该枚举用于统一控制 loading、empty、error 三种页面状态的展示逻辑。
enum DemoListStateType {
  /// 首次进入或刷新中的加载状态。
  loading,

  /// 数据为空状态。
  empty,

  /// 数据加载失败状态。
  error,
}

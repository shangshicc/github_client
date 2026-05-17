# Riverpod 3.x 日志模板

适用于：

- `@riverpod` / `@Riverpod`
- `Notifier` / `AsyncNotifier`
- 页面状态管理
- 列表分页
- 刷新 / 加载更多 / 重试
- 带 loading / data / empty / error 的状态流转

## Notifier 页面状态模板

```dart
import 'package:github_client_app/common/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_controller.g.dart';

final _log = createLogger('[ModuleController]');

@riverpod
class ModuleController extends _$ModuleController {
  /// 构建模块初始状态。
  ///
  /// 返回值：页面首次展示需要的初始状态对象。
  @override
  ModuleState build() {
    _log.i('ModuleController initialized');
    return ModuleState.initial();
  }

  /// 首次加载页面数据。
  ///
  /// [keyword] 表示用户输入或页面传入的查询关键词。
  ///
  /// 副作用：会更新 [state] 并触发监听该 Provider 的界面刷新。
  Future<void> loadInitialData(String keyword) async {
    if (state.isLoading) {
      _log.w('Initial load skipped because another loading task is running');
      return;
    }

    _log.i('Initial load requested, keyword=$keyword');
    state = state.copyWith(
      pageState: ModulePageState.loading,
      errorMessage: '',
    );

    try {
      final List<ModuleItem> items = await _fetchItems(keyword: keyword);
      state = state.copyWith(
        items: List<ModuleItem>.unmodifiable(items),
        pageState: items.isEmpty ? ModulePageState.empty : ModulePageState.data,
      );

      if (items.isEmpty) {
        _log.w('Initial load completed with empty result, keyword=$keyword');
      } else {
        _log.i('Initial load completed, count=${items.length}, keyword=$keyword');
      }
    } catch (error, stackTrace) {
      state = state.copyWith(
        pageState: ModulePageState.error,
        errorMessage: error.toString(),
      );
      _log.e(
        'Initial load failed, keyword=$keyword',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 拉取远程列表数据。
  ///
  /// [keyword] 表示查询关键词。
  ///
  /// 返回值：远程返回的列表数据。
  Future<List<ModuleItem>> _fetchItems({required String keyword}) async {
    return const <ModuleItem>[];
  }
}
```

## AsyncNotifier 简单异步数据模板

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_detail_controller.g.dart';

final _log = createLogger('[ModuleDetailController]');

@riverpod
class ModuleDetailController extends _$ModuleDetailController {
  /// 构建详情页初始异步数据。
  ///
  /// 返回值：详情页首次展示需要的数据对象。
  @override
  Future<ModuleDetail> build() async {
    _log.i('Detail initial load requested');
    return _fetchDetail();
  }

  /// 重新加载详情数据。
  ///
  /// 副作用：会更新 [state]，触发详情页刷新 loading、data 或 error 状态。
  Future<void> reload() async {
    _log.i('Detail reload requested');
    state = const AsyncLoading<ModuleDetail>();
    state = await AsyncValue.guard(() async {
      final ModuleDetail detail = await _fetchDetail();
      _log.i('Detail reload completed');
      return detail;
    });

    if (state.hasError) {
      _log.e(
        'Detail reload failed',
        error: state.error,
        stackTrace: state.stackTrace,
      );
    }
  }

  /// 拉取详情数据。
  ///
  /// 返回值：远程返回的详情数据。
  Future<ModuleDetail> _fetchDetail() async {
    throw UnimplementedError();
  }
}
```

## 使用说明

- 若当前模块已有状态对象，优先沿用现有结构。
- 若已有 logger，优先复用。
- 不为了加日志重构整段状态逻辑。
- 日志重点放在入口、分页参数、空态、跳过分支、异常和状态切换结果。
- 不打印 token、Authorization、Cookie、密码等敏感信息。
- 不在 widget `build()`、列表 item 构建或动画帧回调中打印重复日志。

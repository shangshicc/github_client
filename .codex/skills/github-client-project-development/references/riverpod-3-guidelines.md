# Riverpod 3.x 项目实践指南

本指南用于 `github_client` 项目新增或修改状态管理代码。主原则：优先使用 Riverpod 3.x 注解生成 Provider，减少手写样板，并保持状态流、日志和生成文件可验证。

## 章节导航

- [依赖现状](#依赖现状)
- [优先级](#优先级)
- [文件结构](#文件结构)
- [现有样板参考](#现有样板参考)
- [选择规则](#选择规则)
- [UI 接入规则](#ui-接入规则)
- [生命周期和缓存](#生命周期和缓存)
- [异步状态和空态](#异步状态和空态)
- [代码生成和验证](#代码生成和验证)

## 依赖现状

项目当前已配置（以 `pubspec.yaml` 为准）：

- `flutter_riverpod: 3.3.1`
- `riverpod_annotation: 4.0.2`
- `riverpod_generator: ^4.0.3`
- `build_runner: ^2.3.3`

不要为状态管理新增其他框架。需要新增或升级依赖时，先按主 Skill 的依赖规则说明原因并等待确认。

## 优先级

1. 复用当前模块已有 Riverpod 模式。
2. 新增状态优先使用 `@riverpod` / `@Riverpod` 注解。
3. 简单派生状态使用函数式 Provider。
4. 可变状态、分页、刷新、重试、缓存或异步请求使用注解生成的 `Notifier` / `AsyncNotifier`。
5. 仅在维护遗留模块或用户明确要求时，沿用 `ChangeNotifier` 或手写 Provider。

## 文件结构

- 全局状态优先放在 `lib/states/`。
- 页面或功能局部状态优先放在该功能目录的 `states/`。
- 示例和迁移样板可参考 `lib/states/riverpod/`。
- Riverpod 注解源文件必须包含 `part '<file_name>.g.dart';`。
- 不手动修改 `*.g.dart`，通过 `build_runner` 生成。

## 现有样板参考

- `lib/states/profile_state.dart`：全局 keepAlive 状态与持久化同步。
- `lib/states/profile_selectors.dart`：函数式派生 Provider。
- `lib/states/riverpod/selector_notifier.dart`：注解 `Notifier` 管理不可变页面状态。
- `lib/routes/demo/list/states/demo_list_controller.dart`：页面级分页、刷新、加载更多和错误恢复控制器。

## 选择规则

### 函数式 `@riverpod`

适用于：

- 从已有 Provider 派生同步值。
- 暴露只读计算结果。
- 组合多个 Provider 的轻量逻辑。

要求：

- 参数使用 `Ref ref`。
- 用 `ref.watch` 订阅依赖。
- 不在函数体内发起重复网络请求或写状态。

### `Notifier`

适用于：

- 同步可变状态。
- 页面显式状态机。
- 分页字段、筛选条件、选中状态、收藏状态等。

要求：

- `build()` 返回初始状态。
- 用不可变对象或不可变集合更新 `state`。
- 方法中记录入口、跳过、成功、异常日志。

### `AsyncNotifier`

适用于：

- 首屏即需要异步加载。
- 状态天然可以表达为 `AsyncValue<T>`。
- 简单远程详情、配置、账户信息等异步数据。

要求：

- `build()` 负责初始异步数据。
- 刷新、重试方法使用 `state = const AsyncLoading<T>()` 或保留旧值的加载策略时说明原因。
- 远程请求用 `AsyncValue.guard` 或显式 `try/catch`，并补充日志。

## UI 接入规则

- 优先使用 `ConsumerWidget`、`ConsumerStatefulWidget`、`WidgetRef` 或局部 `Consumer`。
- 用 `ref.watch(provider)` 订阅 UI 展示数据。
- 用 `ref.read(provider.notifier)` 调用一次性动作。
- 不在 `build()` 中直接调用会重复执行的加载方法。
- 首次加载可通过 Provider 的 `build()`、页面生命周期、用户动作或已有项目模式触发，避免重复请求。

## 生命周期和缓存

- 资源释放优先使用 `ref.onDispose`。
- 需要监听其他 Provider 时优先使用 `ref.listen`，并注意取消或生命周期。
- 使用 `@Riverpod(keepAlive: true)` 前必须说明缓存目的、失效策略和内存影响。
- 不为了避免重新请求而盲目 keepAlive。

## 异步状态和空态

- 简单异步数据优先使用 `AsyncValue<T>`。
- 页面复合状态可以使用独立状态对象，显式表达 loading、data、empty、error、refreshing、loadingMore 等状态。
- 空列表不是异常，应单独记录 warning 或状态字段。
- 错误信息面向用户时保持友好，日志中保留 `error` 和 `stackTrace`，但不输出敏感信息。

## 代码生成和验证

新增、删除、重命名注解 Provider 或修改注解参数后，运行：

```sh
dart run build_runner build --delete-conflicting-outputs
```

然后运行：

```sh
dart format <changed_dart_files>
flutter analyze
```

生成失败时说明失败原因和影响，不手写生成结果。

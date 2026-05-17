# GitHub Client 测试策略

本策略用于 `github_client` 项目在 Codex 执行开发任务时决定**默认补什么测试、补到哪一层、如何隔离依赖**。目标不是追求测试数量，而是用最小测试成本锁定改动行为，降低回归风险。

## 章节导航

- [现状与结论](#现状与结论)
- [默认策略](#默认策略)
- [分层选择规则](#分层选择规则)
- [Riverpod 测试规则](#riverpod-测试规则)
- [Widget 测试规则](#widget-测试规则)
- [Integration Test 触发条件](#integration-test-触发条件)
- [依赖隔离与 Mock](#依赖隔离与-mock)
- [测试文件放置建议](#测试文件放置建议)
- [可以不写测试的少数情况](#可以不写测试的少数情况)
- [验证命令](#验证命令)

## 现状与结论

当前项目已具备以下测试基础：

- `flutter_test`：已在 `pubspec.yaml` 中配置。
- `integration_test`：已在 `pubspec.yaml` 中配置。
- `mockito`：已存在于 `pubspec.lock`。
- 仓库已有 `ProviderContainer` 状态测试、`testWidgets` 页面测试与基础 smoke 测试。

结合 Flutter 与 Riverpod 官方建议，本项目推荐的默认策略是：

1. **业务逻辑 / 状态改动**：优先写单元测试或 Provider 测试。
2. **页面交互 / 渲染状态改动**：优先写 Widget 测试。
3. **跨页面主链路 / 插件 / 真机联动**：只在必要时写 Integration Test。
4. **外部依赖**：优先 mock 或 override，不连真实网络。

## 默认策略

- 默认主动为本次改动补充或更新高价值测试。
- 测试只覆盖与当前改动直接相关的行为，不为了“看起来完整”而写大而泛的测试。
- 优先复用已有测试文件和已有测试辅助函数；没有合适位置时再新增测试文件。
- 先选**最小可证明**的一层；能用 Provider 测试证明的，不升级成 Widget 测试；能用 Widget 测试证明的，不轻易升级成 Integration Test。

## 分层选择规则

### 1. 单元测试 / Provider 测试

适用于：

- Riverpod `Notifier` / `AsyncNotifier` / 函数式 Provider 的状态流转。
- Repository / Service 的纯逻辑分支、数据转换、错误映射。
- 分页、刷新、重试、缓存命中/未命中、回滚、幂等、边界条件。

优先理由：

- 运行快。
- 易覆盖错误分支。
- 对 UI 结构变化不敏感。

### 2. Widget 测试

适用于：

- 页面按钮点击、筛选切换、错误态/空态/加载态切换。
- Widget 是否根据 Provider 状态显示正确 UI。
- 路由页面局部交互。

优先理由：

- 能验证 UI 与状态的联动。
- 成本比 Integration Test 低得多。

### 3. Integration Test

适用于：

- 跨页面关键主链路。
- 依赖插件、系统能力、真实路由栈或桌面/移动端行为。
- 需要验证“多个 Widget + 状态 + 服务”整体协作。

不适用于：

- 单纯的 Provider 状态流转。
- 单页面局部按钮逻辑。
- 纯数据转换逻辑。

## Riverpod 测试规则

官方 Riverpod 文档建议：在测试里不要直接手动管理普通 `ProviderContainer` 生命周期，优先使用 `ProviderContainer.test`；在 Widget 测试中使用 `ProviderScope` 承载状态。

项目内推荐：

- 纯 Provider / Notifier 测试：优先 `ProviderContainer.test()`。
- 需要替换依赖时：优先使用 provider override。
- 断言重点放在状态、分支、副作用，而不是实现细节。
- 一条测试聚焦一个业务语义，例如“refresh 挂起期间保持错误态”而不是“调用了某方法”。

## Widget 测试规则

Flutter 官方建议 Widget 测试用于验证单个 widget 或页面局部交互。项目内推荐：

- 使用 `testWidgets`。
- 用 `ProviderScope` 包裹待测 Widget。
- 优先断言用户可观察结果：文案、按钮、错误态、空态、列表、选中状态、跳转结果。
- 避免断言过度依赖布局细节，除非当前任务就是视觉/布局修复。
- 首选已有页面测试写法，如 `test/routes/...` 下模式。

## Integration Test 触发条件

只有满足以下任一情况时，才优先考虑 `integration_test/`：

- 需要验证完整业务主链路，而 Widget 测试无法稳定覆盖。
- 需要真实路由、插件、系统能力或多页面协作。
- 用户明确要求集成测试。

若只是单页面交互或状态联动，优先退回 Widget 测试。

## 依赖隔离与 Mock

Flutter 官方文档建议对外部依赖使用 mock，避免真实网络和易波动外部系统。当前项目已有 `mockito` 依赖记录，可优先沿用既有模式。

推荐顺序：

1. 优先使用 provider override 注入假实现或测试替身。
2. 对 Repository / Service 依赖可用 Mockito 或手写 fake。
3. 不连真实 GitHub API，不打印敏感鉴权信息。
4. Mock 只保留当前测试所需行为，避免构造臃肿测试夹具。

## 测试文件放置建议

- `test/states/...`：全局状态、Riverpod、Provider、Notifier 测试。
- `test/routes/...`：页面或路由 Widget 测试。
- `test/widgets/...`：可复用组件 Widget 测试。
- `integration_test/...`：跨页面或真机/桌面集成测试。

命名优先贴近被测对象，例如：

- `profile_state_test.dart`
- `demo_list_controller_test.dart`
- `demo_list_route_test.dart`

## 可以不写测试的少数情况

只有以下情况可不主动写测试，但必须在总结中说明原因与风险：

- 纯静态文案改动，且不影响逻辑分支。
- 纯资源替换或注释调整。
- 当前模块严重耦合，短时间内无法稳定构造测试，且已有其他验证手段足以证明改动正确。
- 用户明确要求不要补测试。

## 验证命令

按改动范围选择最小命令集：

```sh
flutter test <target_test_files>
dart format <changed_dart_files>
flutter analyze
```

涉及代码生成时：

```sh
dart run build_runner build --delete-conflicting-outputs
flutter test <target_test_files>
dart format <changed_dart_files>
flutter analyze
```

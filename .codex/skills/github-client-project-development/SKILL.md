---
name: github-client-project-development
description: github_client Flutter 项目开发通用 Skill。Codex 在 /Users/chenwei/code/github_client 项目中进行开发、修改代码、新增页面、调整路由、使用 Riverpod 3.x（flutter_riverpod、riverpod_annotation、riverpod_generator）及注解维护状态、集成 Dio 网络请求、修改模型、处理资源、本地化、格式化、静态分析或排查问题时使用。要求中文回答，修改代码前先提供修改方案和目标代码，确认后再修改；新增页面遵循 clean 架构，已有代码遵循历史架构；不主动编写单元测试；不手动修改生成文件；每个新增方法必须添加中文注释并说明方法功能和参数含义。
---

# GitHub Client 项目开发

## 使用目标

使用本 Skill 在 `github_client` Flutter 项目中进行日常开发、问题修复、页面新增、接口集成、状态管理、资源处理和代码维护。

## 基本原则

- 回答必须使用中文。
- 优先遵循用户当前请求。
- 优先遵循项目根目录的 `analysis_options.yaml` 和现有代码约定。
- 修改代码前必须先提供修改方案和目标代码，等待用户确认后再修改；如果用户当前消息已经明确授权执行，则按已确认方案继续。
- 请按生产级别商业项目进行操作，代码实现时要简洁，要考虑复用性、可读性和性能，必要时可以使用缓存。
- 修改已有模块时遵循历史代码架构，不强行重构为 clean 架构。
- 不主动新增单元测试；用户明确要求、已有测试需要维护，或修改风险较高且缺少其他验证手段时，再补充或更新测试。
- 不做无关重构。
- 不随意新增依赖。
- 不手动修改生成文件。
- 不提交、不打印、不暴露 GitHub Token、Authorization Header、密码或其他敏感信息。
- 保持改动范围最小，优先完成用户明确要求。

## 日志要求

新增或修改涉及业务逻辑、状态流转、异步请求、异常处理的代码时，必须补充日志，统一使用 `lib/common/logger.dart` 中的 `createLogger()`，不使用 `print()` 作为常规业务日志方案。

最低要求：

- 核心链路入口必须记录日志
- 请求成功或关键状态完成后必须记录日志
- 空态、跳过执行、降级分支必须记录日志
- catch 异常分支必须记录错误日志，并附带 `error` 与 `stackTrace`
- 新增日志优先使用英文；维护已有中文日志模块时，使用英文优化

日志必须满足以下要求：

- 能说明当前模块、当前动作、关键参数和执行结果
- 不打印 token、Authorization、密码、Cookie 等敏感信息
- 不在高频 `build()`、列表 item 构建、动画回调中打印重复日志
- 如果当前模块已有 logger，优先复用，不重复创建

当任务涉及 Riverpod Notifier、Provider、Repository、Service、分页、刷新、重试、缓存、网络请求等场景时，先参考：

- `references/logging-guidelines.md`
- `references/riverpod-3-guidelines.md`
- `templates/riverpod-logging-template.md`
- `templates/repository-logging-template.md`

## 项目结构

| 路径 | 说明 |
|---|---|
| `lib/common/` | 全局配置、网络请求、Dio、缓存等公共能力 |
| `lib/models/` | JSON 模型，生成文件通常以 `*.g.dart` 结尾 |
| `lib/routes/` | 页面、路由目标、功能模块和主要界面代码 |
| `lib/routes/<feature>/.../states/` | 页面或功能局部 Riverpod 3.x 状态 |
| `lib/states/` | 全局 Riverpod 3.x 状态、派生选择器和注解 Provider |
| `lib/states/riverpod/` | Riverpod 示例、迁移样板或局部状态模块 |
| `lib/widgets/` | 可复用 UI 组件 |
| `lib/l10n/` | 生成的本地化代码，不要手动修改 |
| `l10n-arb/` | ARB 本地化源文件 |
| `imgs/` | 图片资源 |
| `fonts/` | 字体资源 |
| `test/` | 测试目录；除非用户明确要求，否则不新增测试 |

## 修改前流程

在开始修改前，先执行以下工作：

1. 理解用户需求，确认要解决的问题或要实现的功能。
2. 阅读项目说明和相关代码。
3. 查找类似功能，优先复用当前项目已有模式。
4. 判断本次修改涉及的页面、状态、模型、网络、资源或本地化范围。
5. 输出修改方案和目标代码。
6. 等待用户确认；如果用户当前消息已经明确授权执行，则直接进入修改。
7. 用户确认后再进行文件修改。

## 推荐检查命令

根据任务需要使用以下命令了解项目现状：

```sh
pwd
rg --files lib
rg "MaterialApp|Navigator|routes:" lib
rg "Riverpod|riverpod|@riverpod|@Riverpod|Notifier|AsyncNotifier|Provider|ChangeNotifier" lib
rg "part '.*\.g\.dart'|riverpod_annotation" lib
rg "Dio|dio|Http|Authorization" lib
rg "AppLocalizations|Intl|S.of|l10n" lib l10n-arb
```

## 修改方案格式

修改代码前，使用以下格式说明方案：

| 项目 | 说明 |
|---|---|
| 目标 | 本次要实现或修复什么 |
| 涉及文件 | 预计新增或修改哪些文件 |
| 实现方案 | 准备如何实现 |
| 目标代码 | 关键代码结构或主要代码片段 |
| 验证方式 | 修改后准备执行哪些检查 |
| 风险说明 | 可能影响的功能或需要确认的点 |

如果方案中包含不确定点，应先说明假设，不要直接修改。

## 新增页面规则

新增页面时遵循 clean 架构，但应结合当前项目目录习惯进行落地。

推荐流程：

1. 查看 `lib/routes/` 下已有页面写法。
2. 查看 `lib/states/`、`lib/states/riverpod/` 或同功能目录 `states/` 下已有 Riverpod 3.x、`@riverpod`、`@Riverpod`、`Notifier` 或 `AsyncNotifier` 写法。
3. 查看现有路由注册方式。
4. 明确页面是否需要网络请求、状态管理、模型、缓存或本地化。
5. 提供 clean 架构文件规划和目标代码。
6. 用户确认后再创建文件。
7. 接入现有路由体系。
8. 按项目规范格式化代码。

推荐目录结构：

```text
lib/routes/<feature_name>/
  data/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    pages/
    widgets/
    states/
```

如果页面很简单，可以减少不必要层级，但需要说明原因。

## 修改已有代码规则

修改已有代码时：

- 遵循当前文件附近的代码风格。
- 遵循当前模块已有架构。
- 不为了引入 clean 架构而扩大改动范围。
- 不随意移动文件。
- 不重写大段无关代码。
- 优先修复或实现用户明确提出的问题。
- 如果发现历史问题但与当前任务无关，只在总结中说明，不直接修改。

## 状态管理规则

本项目状态管理统一优先使用 Riverpod 3.x，并优先通过 `riverpod_annotation` 注解生成 Provider，减少手写样板代码。

当前项目已使用：

- `flutter_riverpod: 3.3.1`
- `riverpod_annotation: 4.0.2`
- `riverpod_generator: ^4.0.3`
- `build_runner: ^2.3.3`

新增或修改状态时：

- 状态类或 Provider 源文件放在现有约定目录中，优先参考 `lib/states/`、`lib/states/riverpod/` 和同功能目录的 `states/`。
- 新增状态优先使用 `@riverpod` 或 `@Riverpod` 注解；只有维护遗留代码或用户明确要求时，才沿用 `ChangeNotifier` 或手写 Provider。
- 简单同步派生状态优先使用函数式 `@riverpod`。
- 需要可变状态、分页、刷新、重试、缓存或异步请求时，优先使用注解生成的 `Notifier` 或 `AsyncNotifier`。
- 不要为新增功能手写大量 `Provider`、`StateNotifierProvider`、`ChangeNotifierProvider` 样板。
- Riverpod 注解文件必须包含 `part '<file_name>.g.dart';`。
- `*.g.dart` 只能通过 `build_runner` 生成，禁止手动修改。
- 使用 `ref.watch` 订阅会影响 UI 的状态，使用 `ref.read` 触发一次性动作或调用 notifier 方法。
- 不在 widget 的 `build()` 中直接触发会重复执行的网络请求或状态变更。
- UI 中优先使用 `ConsumerWidget`、`ConsumerStatefulWidget`、`WidgetRef` 或 `Consumer` 接入状态。
- 异步远程数据优先表达为 `AsyncValue<T>`，并明确处理 loading、data、empty、error 分支；需要分页等复合页面态时，可以使用不可变状态对象承载页面状态。
- 可释放资源优先通过 `ref.onDispose` 注册清理。
- 使用 `keepAlive` 前必须说明缓存目的、失效策略和内存影响。
- 状态变更通过更新 `state` 或暴露派生 Provider 驱动 UI，避免手动通知 UI。
- 不引入新的状态管理框架，除非用户明确要求。

涉及状态管理、分页、刷新、重试、缓存或异步请求时，先参考：

- `references/riverpod-3-guidelines.md`
- `templates/riverpod-logging-template.md`

## 网络请求规则

本项目网络请求优先复用 `lib/common/` 中已有 Dio 配置和封装。

新增或修改接口时：

- 先查找已有 Dio 实例、拦截器、基础 URL、缓存和错误处理方式。
- 不重复创建不必要的网络客户端。
- 不硬编码 GitHub Token。
- 不打印 `Authorization` Header。
- 不在 UI 层直接堆叠复杂网络逻辑。
- 按已有模型和仓储风格解析响应。
- 错误信息面向用户时保持友好，调试信息不得包含敏感数据。

## 模型和生成文件规则

模型相关修改遵循以下规则：

- 可以修改模型源文件。
- 不手动修改 `*.g.dart` 文件。
- 如果模型字段发生变化，需要使用项目已有生成命令重新生成。
- 生成失败时说明原因，不直接编造生成结果。
- 不修改 `lib/l10n/` 下生成文件。

Riverpod 注解相关修改遵循以下规则：

- 可以修改带 `@riverpod` 或 `@Riverpod` 的源文件。
- 不手动修改对应的 `*.g.dart` 生成文件。
- 新增、删除、重命名注解 Provider 或修改注解参数后，必须运行生成命令。
- 生成失败时说明失败原因和影响，不直接编造生成结果。

常用生成命令：

```sh
dart run build_runner build --delete-conflicting-outputs
```

## 本地化规则

处理用户可见文案时：

- 优先查看项目现有本地化方式。
- ARB 源文件位于 `l10n-arb/`。
- 不手动修改 `lib/l10n/` 下生成文件。
- 如果需要新增文案，优先修改 ARB 源文件。
- 如果本地化生成流程不可用，需要在总结中说明。

旧流程命令：

```sh
./intl.sh
```

注意：该脚本是历史流程，可能需要迁移或依赖修复。

## 资源规则

处理图片、字体等资源时：

- 图片优先放在 `imgs/`。
- 字体优先放在 `fonts/`。
- 修改 `pubspec.yaml` 时保持原有缩进和分组。
- 不添加过大的二进制资源，除非用户明确提供或要求。
- 使用资源前确认路径已在 `pubspec.yaml` 中声明。

## 注释规则

每个新增方法都必须添加中文注释。着重解释为什么。

注释必须说明：

| 内容 | 说明 |
|---|---|
| 方法功能 | 这个方法做什么 |
| 参数含义 | 每个参数代表什么 |
| 返回值 | 返回什么内容；如果无返回值可省略 |
| 副作用 | 是否会修改状态、发起请求、写缓存、跳转页面等 |

示例：

```dart
/// 根据关键词搜索仓库，并更新当前页面展示的仓库列表。
///
/// [keyword] 表示用户输入的搜索关键词。
/// [page] 表示分页查询的页码。
///
/// 方法会发起网络请求，并在请求完成后通知界面刷新。
Future<void> searchRepositories(String keyword, int page) async {
  // 实现代码
}
```

私有辅助方法也建议添加注释，尤其是存在业务逻辑、状态变化或参数不直观时。

## 依赖规则

新增依赖前必须先说明原因并等待用户确认。

确认内容包括：

| 检查项 | 说明 |
|---|---|
| 是否已有替代方案 | 项目中是否已有可复用依赖或工具 |
| 是否必要 | 不新增依赖是否也能合理完成 |
| 是否兼容 | 是否兼容当前 Flutter / Dart SDK 和项目依赖 |
| 影响范围 | 是否会影响构建、平台配置或现有功能 |

不要为了少写少量代码而新增依赖。

## 验证规则

修改完成后，根据改动范围执行验证。

优先命令：

```sh
dart format <changed_dart_files>
flutter analyze
```

涉及模型或 Riverpod 注解生成时：

```sh
dart run build_runner build --delete-conflicting-outputs
dart format <changed_dart_files>
flutter analyze
```

不主动新增单元测试。除非用户明确要求，不需要新增测试文件。

如果验证命令无法执行，需要说明：

| 项目 | 说明 |
|---|---|
| 未执行命令 | 哪个命令没有执行 |
| 原因 | 为什么无法执行 |
| 影响 | 是否影响本次结果判断 |

## 最终回复格式

完成修改后，使用中文总结。

| 项目 | 说明 |
|---|---|
| 已完成 | 本次完成的功能或修复 |
| 已修改 | 新增或修改的文件 |
| 已验证 | 执行的命令和结果 |
| 备注 | 假设、限制、未执行项或需要用户注意的内容 |

如果只是提供方案，使用以下格式：

| 项目 | 说明 |
|---|---|
| 目标 | 本次计划实现什么 |
| 方案 | 准备如何实现 |
| 目标代码 | 关键代码结构或代码片段 |
| 待确认 | 需要用户确认后才能继续的内容 |

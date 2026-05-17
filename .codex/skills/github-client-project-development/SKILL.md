---
name: github-client-project-development
description: Use when Codex works in the /Users/chenwei/code/github_client Flutter project for feature development, bug fixes, page or route additions, Riverpod 3.x state management with flutter_riverpod/riverpod_annotation/riverpod_generator, Dio/GitHub API integration, models and generated code, assets, localization, formatting, static analysis, testing, or project-specific troubleshooting. Respond in Chinese, keep diffs small, preserve existing architecture, use clean architecture only for new pages when it fits, use createLogger() for business/state/network logs, proactively add or update high-value tests for changed behavior, never hand-edit generated files, never expose secrets, and avoid new runtime dependencies unless explicitly required by the task or risk.
---

# GitHub Client 项目开发

## 目标

在 `github_client` Flutter 项目内完成用户要求的开发、修复、排查或维护工作，并让另一个 Codex 实例能用最少上下文安全落地：先复用现有模式，再补充必要代码，最后用格式化、静态分析或更小的针对性检查验证结果。

## 不变量

- 始终用中文回复。
- 优先满足用户当前请求；保持改动小、可回滚、可审查。
- 先查现有实现和附近风格，再决定实现方式；已有模块遵循历史架构，不强行改成 clean 架构。
- 新增页面默认按 clean architecture 思路拆分，但简单页面可减少层级并说明原因。
- 不做无关重构，不随意移动文件，不主动新增依赖。
- 默认主动补充或更新**高价值测试**来锁定本次改动行为；只在纯文案/资源微调、无法稳定构造、或测试成本明显高于收益时，才可以不写测试，但必须在总结中说明原因。
- 不手动修改 `*.g.dart`、`lib/l10n/` 等生成文件；需要生成时运行项目生成命令。
- 不提交、不打印、不暴露 GitHub Token、Authorization Header、Cookie、密码或其他敏感信息。
- 新增方法必须写中文 Dartdoc，说明方法功能、参数含义，并在必要时说明返回值和副作用。

## 渐进式披露导航

不要一次性读取所有参考资料。按任务信号只加载相关文件：

| 任务信号 | 需要读取 |
|---|---|
| 任意代码修改、路径判断、验证策略 | `references/project-conventions.md` 的相关章节 |
| 需要决定写什么测试、补哪一层测试、如何 mock/override | `references/testing-strategy.md` |
| Riverpod、Provider、Notifier、AsyncNotifier、分页、刷新、重试、缓存状态 | `references/riverpod-3-guidelines.md`；需要样板时再读 `templates/riverpod-logging-template.md` |
| Repository、Service、Dio、网络请求、本地缓存 | `references/project-conventions.md` 的“网络请求规则”；需要日志样板时再读 `templates/repository-logging-template.md` |
| 业务逻辑、状态流转、异步请求、异常处理日志 | `references/logging-guidelines.md` |
| 新增页面或新增功能目录 | `references/project-conventions.md` 的“新增页面规则”和“项目结构速查” |
| 模型字段、Riverpod 注解、代码生成 | `references/project-conventions.md` 的“模型和生成文件规则” |
| 本地化、图片、字体、`pubspec.yaml` 资源声明 | `references/project-conventions.md` 的“本地化规则”和“资源规则” |
| 只做简单只读排查 | 可先直接检索代码；需要项目约定时再加载参考文件 |

## 执行流程

1. 明确目标、成功标准、影响范围和停止条件。
2. 检索相关代码和相似实现；简单文件/符号/关系查找优先用项目约定的 `omx explore --prompt ...`，不足时再用 `rg`、IDE/MCP 或普通 shell。
3. 判断任务类型：已有代码修复、新增页面、状态管理、网络请求、模型生成、本地化、资源、测试补强或纯排查。
4. 按“渐进式披露导航”读取最少必要参考资料。
5. 代码修改前形成简短方案和目标代码结构，并同时明确**测试策略**：改动影响哪层、最小可证明测试是什么、是否需要 mock/override。
6. 如果用户只是要方案，则停止在方案；如果用户已明确要求执行、修复、优化或当前运行指令要求自主完成，则把方案作为内部约束直接实施。只有新增依赖、破坏性操作、生产权限、外部凭据或范围实质分叉时再询问。
7. 修改时优先复用现有工具、模型、状态对象、Repository、Widget、测试样板和日志模式。
8. 涉及生成代码时，先改源文件，再运行生成命令，绝不手写生成结果。
9. 默认补充或更新与改动直接相关的高价值测试，再执行 `dart format <changed_dart_files>`、`flutter analyze`、生成命令和目标测试。
10. 总结改动、验证证据、未验证项和剩余风险。

## 核心工程规则

### 日志

新增或修改业务逻辑、状态流转、异步请求、异常处理时，使用 `lib/common/logger.dart` 的 `createLogger()`。不要用 `print()` 做常规业务日志。最低要求：入口、成功/关键完成、空态/跳过/降级、catch 异常都要有可搜索日志；异常日志必须带 `error` 和 `stackTrace`；不得输出敏感信息或高频重复日志。

### Riverpod

状态管理优先使用 Riverpod 3.x 注解生成 Provider。新增状态优先 `@riverpod` / `@Riverpod`；简单派生用函数式 Provider；可变状态、分页、刷新、重试、缓存或异步请求用注解生成的 `Notifier` / `AsyncNotifier`。UI 中用 `ref.watch` 订阅展示状态，用 `ref.read` 触发一次性动作；不要在 `build()` 中触发重复请求。

### 网络和模型

网络请求优先复用 `lib/common/` 既有 Dio、拦截器、缓存和错误处理。不要硬编码或打印鉴权信息。模型和 Riverpod 注解源文件可以修改；生成文件只能由 `build_runner` 或项目既有脚本生成。

### 测试

默认主动补足与改动直接相关的高价值测试，优先选择**最小但足以证明正确性**的一层：纯状态/纯逻辑优先单元或 Provider 测试，页面交互优先 Widget 测试，跨页面/插件/真实设备联动再考虑 Integration Test。已有测试优先就近扩展；外部依赖优先用项目现有 mock 能力隔离，避免真实网络与易波动环境。具体分层、mock 和落点规则见 `references/testing-strategy.md`。

### 注释

每个新增方法写中文 Dartdoc：

```dart
/// 根据关键词搜索仓库，并更新当前页面展示的仓库列表。
///
/// [keyword] 表示用户输入的搜索关键词。
/// [page] 表示分页查询的页码。
///
/// 返回值：远程返回的仓库列表。
/// 副作用：会发起网络请求，并在请求完成后更新页面状态。
Future<List<Repository>> searchRepositories(String keyword, int page) async {
  // 实现代码
}
```

## 常用命令

按需使用，避免无意义全量执行：

```sh
# 代码检索
rg --files lib
rg "@riverpod|@Riverpod|Notifier|AsyncNotifier|Provider|ChangeNotifier" lib
rg "Dio|dio|Authorization|createLogger|AppLocalizations|l10n" lib l10n-arb

# 代码生成
dart run build_runner build --delete-conflicting-outputs

# 验证
dart format <changed_dart_files>
flutter analyze
flutter test <target_test_files>
```

## 输出格式

只提供方案时：

| 项目 | 说明 |
|---|---|
| 目标 | 本次计划实现或修复什么 |
| 涉及文件 | 预计新增或修改哪些文件 |
| 方案 | 准备如何实现 |
| 目标代码 | 关键结构或主要代码片段 |
| 验证方式 | 计划执行哪些检查与哪些测试文件 |
| 待确认 | 仅列真正阻塞的确认项；没有则写“无” |

完成修改后：

| 项目 | 说明 |
|---|---|
| 已完成 | 本次完成的功能、修复或优化 |
| 已修改 | 新增或修改的文件 |
| 已验证 | 执行的命令、测试文件和结果 |
| 备注 | 假设、限制、未执行项或需要注意的风险 |

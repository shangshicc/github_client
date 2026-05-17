# GitHub Client 项目约定

按任务需要读取对应章节。本文件承载较稳定的项目约定，避免 `SKILL.md` 过长。

## 章节导航

- [目录速查](#目录速查)
- [修改边界](#修改边界)
- [修改前检索建议](#修改前检索建议)
- [新增页面规则](#新增页面规则)
- [网络请求规则](#网络请求规则)
- [模型和生成文件规则](#模型和生成文件规则)
- [本地化规则](#本地化规则)
- [资源规则](#资源规则)
- [注释规则](#注释规则)
- [依赖规则](#依赖规则)
- [验证规则](#验证规则)

## 目录速查

| 路径 | 说明 |
|---|---|
| `lib/common/` | 全局配置、网络请求、Dio、缓存、日志等公共能力 |
| `lib/models/` | JSON 模型；生成文件通常以 `*.g.dart` 结尾 |
| `lib/routes/` | 页面、路由目标、功能模块和主要界面代码 |
| `lib/routes/<feature>/.../states/` | 页面或功能局部 Riverpod 状态 |
| `lib/states/` | 全局 Riverpod 状态、派生选择器和注解 Provider |
| `lib/states/riverpod/` | Riverpod 示例、迁移样板或局部状态模块 |
| `lib/widgets/` | 可复用 UI 组件 |
| `lib/l10n/` | 生成的本地化代码；不要手动修改 |
| `l10n-arb/` | ARB 本地化源文件 |
| `imgs/` | 图片资源 |
| `fonts/` | 字体资源 |
| `test/` | 单元测试、Provider 测试、Widget 测试；默认应补与改动直接相关的高价值测试 |
| `integration_test/` | 集成测试；用于跨页面、插件或真实设备联动主链路 |

## 修改边界

- 修改已有模块时，遵循当前文件附近的代码风格和当前模块架构。
- 不为了引入 clean architecture 而扩大已有模块改动范围。
- 不重写大段无关代码，不随意移动文件。
- 优先修复或实现用户明确提出的问题。
- 发现与当前任务无关的历史问题时，只在总结中说明，不直接修改。
- 新增依赖、破坏性操作、生产外部系统变更、凭据访问等需要用户确认。
- 测试相关优先复用项目现有 `flutter_test`、`integration_test`、`mockito` 与 Riverpod 测试模式，不为图省事引入新的测试框架。

## 修改前检索建议

根据任务选择最少命令：

```sh
pwd
rg --files lib
rg "MaterialApp|Navigator|routes:" lib
rg "@riverpod|@Riverpod|Notifier|AsyncNotifier|Provider|ChangeNotifier" lib
rg "part '.*\.g\.dart'|riverpod_annotation" lib
rg "Dio|dio|Http|Authorization|createLogger" lib
rg "AppLocalizations|Intl|S\.of|l10n" lib l10n-arb
```

## 新增页面规则

新增页面时遵循 clean architecture 思路，并结合当前目录习惯落地。

推荐流程：

1. 查看 `lib/routes/` 下已有页面写法。
2. 查看 `lib/states/`、`lib/states/riverpod/` 或同功能目录 `states/` 下已有 Riverpod 写法。
3. 查看现有路由注册方式。
4. 明确页面是否需要网络请求、状态管理、模型、缓存或本地化。
5. 规划文件结构和目标代码。
6. 创建文件并接入现有路由体系。
7. 按项目规范格式化并验证。

推荐结构：

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

页面很简单时可减少层级，但要说明减少原因，避免制造空目录和无意义抽象。

## 网络请求规则

- 优先复用 `lib/common/` 中已有 Dio 配置、拦截器、基础 URL、缓存和错误处理方式。
- 不重复创建不必要的网络客户端。
- 不硬编码 GitHub Token，不打印 `Authorization` Header。
- 不在 UI 层堆叠复杂网络逻辑；按已有模型、Repository、Service 风格解析响应。
- 面向用户的错误信息保持友好；日志可记录调试上下文，但不得包含敏感数据。
- 涉及请求、缓存、重试或分页时，同时遵循 `references/logging-guidelines.md`。

## 模型和生成文件规则

- 可以修改模型源文件和带 `@riverpod` / `@Riverpod` 的源文件。
- 不手动修改 `*.g.dart` 文件。
- Riverpod 注解源文件必须包含 `part '<file_name>.g.dart';`。
- 新增、删除、重命名注解 Provider，修改注解参数，或模型字段变化后，运行：

```sh
dart run build_runner build --delete-conflicting-outputs
```

- 生成失败时说明失败原因和影响，不编造生成结果。
- 生成后按需运行 `dart format <changed_dart_files>` 与 `flutter analyze`。

## 本地化规则

- 处理用户可见文案时，先查看项目现有本地化方式。
- ARB 源文件位于 `l10n-arb/`。
- 不手动修改 `lib/l10n/` 下生成文件。
- 需要新增文案时优先修改 ARB 源文件。
- 旧流程命令为 `./intl.sh`；该脚本是历史流程，可能需要迁移或依赖修复。不可用时在总结中说明。

## 资源规则

- 图片优先放在 `imgs/`，字体优先放在 `fonts/`。
- 修改 `pubspec.yaml` 时保持原有缩进和分组。
- 不添加过大的二进制资源，除非用户明确提供或要求。
- 使用资源前确认路径已在 `pubspec.yaml` 中声明。

## 注释规则

新增方法必须写中文 Dartdoc，重点解释“为什么”和调用边界。至少覆盖：

| 内容 | 说明 |
|---|---|
| 方法功能 | 方法做什么 |
| 参数含义 | 每个参数代表什么 |
| 返回值 | 有返回值时说明返回内容 |
| 副作用 | 是否改状态、发请求、写缓存、跳转页面等 |

私有辅助方法也建议添加注释，尤其是存在业务逻辑、状态变化或参数不直观时。

## 依赖规则

新增依赖前必须确认：

| 检查项 | 说明 |
|---|---|
| 是否已有替代方案 | 项目中是否已有可复用依赖或工具 |
| 是否必要 | 不新增依赖是否也能合理完成 |
| 是否兼容 | 是否兼容当前 Flutter / Dart SDK 和项目依赖 |
| 影响范围 | 是否影响构建、平台配置或现有功能 |

不要为了少写少量代码而新增依赖。

## 验证规则

根据改动范围选择最小可证明检查：

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

默认新增或更新与改动直接相关的高价值测试；仅在纯文案/资源微调、测试成本显著高于收益、或当前代码高度耦合且无法稳定构造时，才允许不写测试，但必须说明原因、风险与替代验证。

优先验证顺序：

```sh
flutter test <target_test_files>
dart format <changed_dart_files>
flutter analyze
```

若涉及代码生成，先生成再运行上述验证。若验证命令无法执行，总结中说明未执行命令、原因和影响。

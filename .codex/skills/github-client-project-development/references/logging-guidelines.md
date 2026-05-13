# 日志规范说明

本项目日志统一使用 `lib/common/logger.dart` 中的 `createLogger()`。新增或修改业务逻辑代码时，应补充足够的问题定位日志，但避免制造控制台噪音。

## 基本原则

- 日志用于定位核心链路和异常问题，不是为了凑数量。
- 优先记录“开始做什么、成功结果、异常原因、关键上下文”。
- 日志内容应简洁、稳定、可搜索。
- 不输出敏感信息，如 token、Authorization、密码、Cookie、完整隐私数据。
- 长对象不要整包打印，优先输出关键字段摘要。
- 临时调试日志在任务完成前应清理。

## 日志工具

统一写法：

```dart
import 'package:github_client_app/common/logger.dart';

final _log = createLogger('[ModuleName]');
```

建议：

- 每个 Page / Provider / Repository / Service 文件最多保留一个模块级 logger
- 模块名建议使用 `[模块名]` 格式
- 如果当前文件已有 `_log`，优先复用

## 日志级别约定

### debug

用于记录调试细节、关键入参、分页信息、状态切换前后、分支命中等。

示例：

```dart
_log.d('请求分页，username: $username, page: $_page, reset: $resetBeforeLoad');
```

### info

用于记录核心链路上的重要节点。

示例：

```dart
_log.i('开始初始化加载，username: $username');
_log.i('列表加载成功，count: ${repos.length}, hasMore: $_hasMore');
```

### warning

用于记录可恢复异常、空数据、跳过执行、降级逻辑。

示例：

```dart
_log.w('列表为空，username: $username');
_log.w('当前正在加载中，忽略重复请求');
```

### error

用于记录明确异常。

示例：

```dart
_log.e(
  '加载失败，username: $username, page: $_page, error: $e',
  error: e,
  stackTrace: stackTrace,
);
```

## 必须加日志的场景

以下场景必须补日志：

### 1. 核心链路入口

例如：

- 页面初始化
- 首次加载
- 下拉刷新
- 上拉加载更多
- 用户点击重试
- 用户提交、删除、确认等关键动作

### 2. 核心链路关键节点

例如：

- 发起网络请求前
- 请求成功后
- 数据转换完成后
- 状态更新完成后
- 关键分支命中时

### 3. 异常和边界场景

例如：

- 网络失败
- JSON 解析失败
- 列表为空
- 参数为空或不合法
- 权限不足
- 缓存未命中或读取失败
- 降级逻辑生效
- catch 分支

## 各层推荐日志职责

### Page / Route 层

适合记录：

- 页面初始化
- 页面首次发起加载
- 用户点击重试、提交、切换 tab、切换筛选条件
- 页面级错误提示触发前后的状态

示例：

```dart
_log.i('页面初始化，username: $username');
_log.i('用户点击重试，username: $username');
_log.d('用户切换筛选条件，tab: $tab');
```

### Provider / ChangeNotifier 层

适合记录：

- load / refresh / loadMore / retry 入口
- 状态切换
- 列表为空
- 是否还有更多
- 异常后状态更新

示例：

```dart
_log.i('开始初始化加载，username: $username');
_log.d('请求分页，page: $_page, reset: $resetBeforeLoad');
_log.i('分页加载成功，count: ${repos.length}, hasMore: $_hasMore');
_log.w('列表为空，username: $username');
```

### Repository / Service 层

适合记录：

- 发起请求前的关键参数
- 请求成功后的结果摘要
- 空结果
- 请求异常

示例：

```dart
_log.d('开始请求仓库列表，username: $username, page: $page');
_log.i('仓库列表请求成功，count: ${response.length}');
_log.w('仓库列表结果为空，username: $username');
```

### Cache / Storage 层

适合记录：

- 读取缓存
- 缓存命中 / 未命中
- 写入缓存
- 缓存异常

示例：

```dart
_log.d('读取缓存，key: $cacheKey');
_log.i('缓存命中，key: $cacheKey');
_log.w('缓存未命中，key: $cacheKey');
```

## 不建议打印的场景

以下场景不要默认打印重复日志：

- `build()` 方法每次重建
- 列表 item 的 `itemBuilder`
- 动画帧回调
- 高频滚动监听
- 每次 `notifyListeners()` 前后都打印同类日志
- 大对象整包输出
- 敏感请求头和鉴权字段

## 文案建议

推荐使用这种句式：

- 开始 + 动作 + 上下文
- 成功 + 动作 + 结果摘要
- 失败 + 动作 + 关键上下文 + error
- 跳过 + 原因
- 空态 + 查询条件

推荐示例：

- `开始初始化加载，username: $username`
- `开始加载更多，page: $_page`
- `仓库列表请求成功，count: ${repos.length}`
- `列表为空，username: $username`
- `当前正在加载中，忽略重复请求`
- `加载失败，username: $username, page: $_page, error: $e`

## 最低日志要求

凡是新增或修改以下方法，至少满足：

- 方法入口：1 条 `info` 或 `debug`
- 成功完成：1 条 `info`
- 空态 / 跳过 / 降级：1 条 `warning`
- catch 异常：1 条 `error`

适用范围：

- 网络请求方法
- Provider / ChangeNotifier 中会改状态的方法
- 分页 / 刷新 / 重试方法
- 含 `try-catch` 的方法
- 有错误态、空态、降级逻辑的方法

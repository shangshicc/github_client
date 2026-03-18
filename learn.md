# 字符串资源管理
- 使用 ARB 文件管理文案，位于 `l10n-arb/`
  - `intl_messages.arb`：英文模板（默认文案）
  - `intl_zh.arb`：中文翻译

# 字符串国际化（Flutter gen-l10n / flutter_localizations）
- json文件：声明要用的字符串资源
- 配置文件：`l10n.yaml`，指定代码生成的输入路径和输出路径/输出代码名  
- 生成命令：`flutter gen-l10n`（或运行 `./intl.sh`）
- 生成输出：`lib/l10n/app_localizations*.dart`（自动生成，不要手改）通过生成的类获取字符串资源
- 修改点
- 切换到 Flutter 官方 gen-l10n + flutter_localizations，并启用 flutter.generate：pubspec.yaml:30
- 新增 l10n.yaml，ARB 源文件在 l10n-arb/，输出生成到 lib/l10n/：l10n.yaml:1，lib/l10n/app_localizations.dart:1
- 删除旧的 intl_generator/GmLocalizations 产物与用法，页面统一用 AppLocalizations.of(context)：lib/main.dart:1
- 语言选择改为 en/zh，并兼容历史 en_US/zh_CN 存档（避免 gen-l10n 对 locale/文件名的约束报错）：lib/routes/language.dart:1，lib/states/profile_change_notifier.dart:50
- 补齐列表底部“没有更多数据了”的本地化键 noMoreData：lib/routes/home_page.dart:60
- ./intl.sh 更新为 flutter gen-l10n（走 l10n.yaml 配置）：intl.sh:1

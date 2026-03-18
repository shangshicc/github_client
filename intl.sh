#!/usr/bin/env bash
set -euo pipefail

# Flutter 3.41+ 建议使用官方 `gen-l10n`（依赖 `flutter_localizations` + `intl`）
# 来生成 `AppLocalizations`，配置见项目根目录 `l10n.yaml`。
flutter gen-l10n


# Skill 架构规范

使用本参考文件创建、新增、审查、重构、拆分、合并或维护 Skill 结构。这里沉淀通用架构规则；具体 Skill 的业务规则仍应放在该 Skill 自己的 `SKILL.md` 或 `references/` 中。

## 核心原则

- Skill 是给 Codex 使用的执行说明，不是给人阅读的教程。
- `SKILL.md` 应保持简洁，只放触发后必须立即知道的规则、流程和 reference 加载规则。
- 复杂内容应拆分到 `references/`。
- 可重复、确定性强的操作应放到 `scripts/`。
- 模板、示例文件、静态资源应放到 `assets/`。
- 不创建无关文档，例如 `README.md`、`CHANGELOG.md`、`INSTALLATION.md`，除非用户明确要求。
- 不把同一条规则重复写在多个文件中。
- 不写含糊规则，优先使用具体、可执行、可验证的描述。
- Skill 内容应可维护、可扩展，并避免和上层系统指令、项目指令或自身其他规则冲突。

## 标准结构

最小结构：

```text
skill-name/
  SKILL.md
```

复杂结构：

```text
skill-name/
  SKILL.md
  references/
    topic-a.md
    topic-b.md
  scripts/
    command.sh
  assets/
    template/
```

## `SKILL.md` 职责

`SKILL.md` 必须包含 YAML frontmatter：

```yaml
---
name: skill-name
description: 清楚说明这个 Skill 做什么，以及 Codex 应该在什么场景下使用它。
---
```

`SKILL.md` 适合放：

- 触发后必须立即知道的全局约束。
- 主要工作流。
- 用户确认或停止条件。
- 需要按需读取的 reference 列表和加载规则。
- 最常用、最短的输出格式要求。

`SKILL.md` 不适合放：

- 大段项目背景。
- 多个独立主题的详细清单。
- 长示例、长模板、长命令说明。
- 可以由脚本稳定完成的重复操作步骤。

如果 `SKILL.md` 接近 500 行，或模型每次触发都不需要阅读其中大部分内容，应优先拆分到 `references/`。

## name 规则

- 使用小写字母、数字和短横线。
- 与 Skill 文件夹名保持一致。
- 不使用空格、中文、下划线或大写字母。
- 名称应简短、准确、可复用。

示例：

```text
github-client-project-development
github-client-code-review
skill-development
flutter-page-development
```

## description 规则

`description` 是 Skill 的主要触发依据，必须写清楚：

- 这个 Skill 做什么。
- Codex 什么时候应该使用它。
- 典型任务触发词。
- 关键约束。
- 适用项目或技术栈。

description 应比正文更关注“什么时候触发”。不要把大量执行细节塞进 description；执行细节应放在正文或 reference。

好的 description 通常包含：

- 明确动词，例如 create、review、refactor、optimize、debug、generate。
- 用户可能使用的自然语言表达。
- 关键文件、目录、框架、工具或业务域。
- 必须使用该 Skill 的边界。

## 分层规则

| 内容类型 | 放置位置 |
|---|---|
| 触发条件 | `SKILL.md` frontmatter |
| 全局硬约束 | `SKILL.md` |
| 总流程 | `SKILL.md` |
| Reference 加载规则 | `SKILL.md` |
| 架构细节 | `references/architecture.md` |
| 审查清单 | `references/review-checklist.md` |
| 输出格式细节 | `references/output-format.md` |
| 可执行脚本 | `scripts/` |
| 模板资源 | `assets/` |

当 Skill 支持多个领域、框架或供应商时，按变体拆分 reference。例如：

```text
cloud-deploy/
  SKILL.md
  references/
    aws.md
    gcp.md
    azure.md
```

`SKILL.md` 应说明什么时候读取哪个 reference，避免每次触发都加载所有细节。

## 约束编写规则

约束必须具体、可执行。

推荐写法：

- 必须使用中文回答。
- 新增依赖前必须说明必要性、替代方案、兼容性和影响范围。
- 不得手动修改 `*.g.dart` 文件。
- 如果用户请求涉及破坏性操作，则必须先说明风险并等待确认。

不推荐写法：

- 注意代码质量。
- 尽量安全。
- 合理拆分。
- 适当验证。

避免把“示例约束”写成所有 Skill 都必须遵守的通用硬规则。例如“修改文件前必须等待用户确认”只适合某些高风险工作流，不应无条件套用到所有开发类 Skill。

## 创建 Skill 流程

1. 明确 Skill 的使用场景和边界。
2. 确定 Skill 名称和放置目录。
3. 编写 frontmatter，尤其是可触发的 description。
4. 编写核心规则和工作流。
5. 判断是否需要 `references/`、`scripts/`、`assets/`。
6. 如果内容过长或主题独立，拆分到 reference。
7. 检查是否存在重复规则、模糊规则和冲突规则。
8. 根据 Skill 类型决定是否需要 eval。

## 重构 Skill 流程

1. 阅读现有 `SKILL.md` 和目录结构。
2. 识别全局规则、专项规则、流程、示例和输出格式。
3. 保留入口层规则在 `SKILL.md`。
4. 将专项内容拆分到 `references/`。
5. 在 `SKILL.md` 添加清楚的 reference 加载规则。
6. 删除重复内容。
7. 检查 frontmatter 是否仍准确。
8. 汇总重构后的文件结构和职责。

## 审查 Skill 清单

| 检查项 | 判断标准 |
|---|---|
| 名称 | 是否小写、短横线、语义清晰，并与目录名一致 |
| 触发描述 | 是否清楚说明使用场景、触发词、边界和技术栈 |
| 入口文件 | 是否过长，是否混入大量细节 |
| 分层结构 | 是否把复杂内容拆到 `references/` |
| 约束规则 | 是否具体、可执行、无歧义 |
| 重复规则 | 是否同一规则写在多个位置 |
| 冲突规则 | 是否和系统、项目或自身其他规则矛盾 |
| 输出格式 | 是否明确 Codex 最终如何汇报 |
| 安全边界 | 是否说明不能做什么，尤其是凭据、破坏性操作和数据暴露 |
| 停止条件 | 是否说明什么时候必须询问用户或等待确认 |
| 验证方式 | 是否说明如何验证 Skill 产出或行为 |

## 集成已有 Skill 的判断

当用户要求“把 A Skill 集成到 B Skill”时，先判断两者关系：

- 如果 A 是 B 的通用基础能力，优先抽取为 B 的 reference。
- 如果 A 是某个项目或领域的专项规则，优先放入 B 的 project/domain reference，而不是写进 B 的主入口。
- 如果 A 和 B 是并列能力，不要强行合并；可以在 description 或正文中说明分别何时使用。
- 如果合并会让 `SKILL.md` 明显变长或重复，应使用 reference 分层。

集成时优先保留语义，不逐字搬运。删除与目标 Skill 已有内容重复的段落，并调整会造成冲突的硬规则。

## 安全和停止条件

Skill 不得包含恶意代码、隐蔽数据外传、绕过权限、误导用户或泄露敏感信息的指令。

以下情况应要求 Codex 停下来询问用户或等待确认：

- 用户目标不明确，继续执行会造成明显偏差。
- 涉及破坏性文件操作、删除、重置、覆盖或不可逆迁移。
- 需要新增高影响依赖、外部服务、凭据或网络访问。
- Skill 规则和用户请求、系统指令或项目约定冲突。

## 最终汇报建议

维护 Skill 后，最终汇报应包含：

- 已修改的 Skill 文件。
- 新增、删除或移动的 reference、script、asset。
- 核心规则变化。
- 是否运行了验证或只做了文档检查。
- 仍然存在的风险或后续可优化点。

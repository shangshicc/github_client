---
name: detail-plan-executor
description: "[OMX] Execute an approved ralplan detail plan with stepwise implementation, tests, build, and lint."
metadata:
  short-description: "按 detail plan 分步实现并完成验证"
---

# Detail Plan Executor

## 何时使用

- 已有批准的 `ralplan-detail-plan`，且要把它落地为代码、测试、构建和 lint 结果
- 任务需要按 detail plan 的步骤执行，而不是重新做总体方案
- 在 `github_client` 项目内执行时，遵守项目级约定即可

## 何时不用

- 还没有 detail plan：先用 `ralplan-detail-plan`
- 只需要快速单点修复：用 `executor`
- 只需要持续推进直到完成：用 `finish-loop`
- 仍在做总体取舍或架构讨论：用 `plan` / `ralplan`
- 计划还不清楚、步骤之间边界冲突明显：先回到 `ralplan-detail-plan`

## 核心原则

- detail plan 是执行来源，不是建议文档
- 每轮只做一个最小可交付切片
- 执行顺序固定为：开发 → 构建/打包 → 单元测试 → UI 测试 → 集成测试 → lint/静态分析
- 任一步失败，先修复再重跑同一步
- 同一问题连续修复 3 次仍失败时，记录到 `.omx/question/{slug}-{YYYYMMDD-HHMM}.md` 并输出问题
- `question` 记录只写清：问题现象、复现条件、已尝试修复、仍然卡住的原因、影响面、下一步需要谁确认
- 测试随变更类型选择：逻辑用单元，界面用 widget/UI，跨屏或平台链路用集成测试
- 发现计划与现实冲突时，先记录差异，不要静默改计划
- 若仓库已有更具体的项目技能，优先遵守项目级约定
- 当当前切片目标不再成立、步骤边界被打破、或依赖前置产物缺失时，立即停止扩展并回到 `ralplan-detail-plan`
- 若本轮只是重跑验证、未改实现内容，不重复全量读取项目级 skill，只回看本轮相关章节

## 执行流程

1. 读取项目级 skill（条件触发）：在 `github_client` 项目内、且首次进入该项目或本轮约定有变化时，先读 `.codex/skills/github-client-project-development`
2. 读取 detail plan：看方案总览、当前步骤、测试用例、风险与回归点
3. 选择当前切片：只做一个最小可交付步骤
4. 实现：先主路径，再边界与回退
5. 验证：按固定顺序执行构建/打包、单元测试、UI 测试、集成测试、lint / 静态分析
6. 修复并重跑：任一步失败都先修复，再重跑该步；同一问题连续 3 次仍失败时停止扩展，并记录 `.omx/question/`
7. 收口：报告变更、验证结果、剩余风险、下一步建议；若写入过 `.omx/question/`，同步输出问题摘要和文件路径

## 失败与升级

- 单步失败只在当前步骤内修复，不要跳步
- 若修复 3 次仍失败，停止扩展本轮实现
- 若失败说明当前 step 的目标不成立，或需要新增/重拆步骤，直接回到 `ralplan-detail-plan`
- 记录 `.omx/question/` 后，回复里必须输出：
  - 问题是什么
  - 为什么卡住
  - 哪一步失败
  - 需要哪类确认
- `.omx/question/` 文件应使用与当前 detail plan 一致的 slug 命名，避免后续检索困难
- 若问题说明计划本身不成立或需要重拆步骤，回到 `ralplan-detail-plan`

## 参考资料

- `references/plan-consumption.md`：如何消费 detail plan、如何把步骤映射成代码切片
- `references/verification-matrix.md`：不同变更类型对应的测试、构建、lint 顺序
- `templates/question-template.md`：`.omx/question/{slug}-{YYYYMMDD-HHMM}.md` 的记录模板
- `github-client-project-development`：当在 `github_client` 项目内执行时优先读取；若本轮约定已确认且未变化，可跳过重复全量读取

## 输出要求

完成后简明说明：

- 采用了哪个 detail plan
- 当前实现了哪个步骤
- 改了哪些文件
- 新增或更新了哪些测试
- 跑了哪些验证
- 构建和 lint 是否通过
- 仍然存在的风险或待确认项

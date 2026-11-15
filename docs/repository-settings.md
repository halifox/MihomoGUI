# 仓库管理设置

这些是 GitHub 仓库设置，文件本身不会自动启用远端保护。修改前核对当前配置和工作流，应用后从 API 回读确认。

## 主分支保护

2026-11-15 已应用并独立回读核对。目标为 `halifox/mihomoGUI` 的 `main`；期望配置见 [branch-protection.json](../.github/branch-protection.json)。

- 通过 PR 合入，必须通过 GitHub Actions（App ID `15368`）的 `build` 检查，并保持分支基线最新。
- 要求评审讨论已解决，禁止强推和删除，管理员同样遵守。
- 不限制合并历史形式，保留逐项提交。审批人数为0，不强制代码所有者或最后推送者之外的批准，避免单维护者无法合并自己的 PR；这不代表其他人的 PR 可以跳过维护者审阅。需要多人审批时应先配置有实际评审权限的维护者。

`build` 名称已与现有 PR 的检查运行及构建工作流核对。更改 job 名称时，应同步更新保护规则，避免必需检查永久等待。

应用和回读（需要仓库管理权限）：

```bash
gh api --method PUT repos/halifox/mihomoGUI/branches/main/protection --input .github/branch-protection.json
gh api repos/halifox/mihomoGUI/branches/main/protection
```

GitHub API 参数依据：[保护分支 API](https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection)。

## Actions 创建 PR

2026-11-15 已将 `can_approve_pull_request_reviews` 设为 `true`，并独立回读确认默认 `default_workflow_permissions=read` 保持不变。期望配置见 [actions-permissions.json](../.github/actions-permissions.json)。这个仓库开关允许 Actions 创建和批准 PR，不会替代具体 job 的权限声明。资源更新和 Release Please job 已显式声明 `contents: write`、`pull-requests: write`，构建 job 保持只读。

内置令牌创建的 PR 由现有自动化主动触发分支构建，以满足 `main` 的必需检查；不自动合并。不通过创建测试 PR 或触发发布来验证权限，本次验证为设置回读及现有工作流声明核对。

```bash
gh api --method PUT repos/halifox/mihomoGUI/actions/permissions/workflow --input .github/actions-permissions.json
gh api repos/halifox/mihomoGUI/actions/permissions/workflow
```

API 参数依据：[Actions 仓库默认工作流权限](https://docs.github.com/en/rest/actions/permissions#set-default-workflow-permissions-for-a-repository)。

## 私密漏洞报告

2026-11-15 已启用 GitHub Private Vulnerability Reporting，并独立回读确认 `enabled=true`。公开安全政策和 Issue 联系入口直接指向 [私密表单](https://github.com/halifox/MihomoGUI/security/advisories/new)，不再要求先创建公开联系 Issue。不公布未经验证的邮箱或处理时限。

```bash
gh api --method PUT repos/halifox/mihomoGUI/private-vulnerability-reporting
gh api repos/halifox/mihomoGUI/private-vulnerability-reporting
```

本次验证为实际开关回读和入口配置一致性检查，未提交测试漏洞报告。

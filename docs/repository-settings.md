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

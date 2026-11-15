# 安全报告

请勿在公开 Issue、PR、截图或日志中披露尚未修复的漏洞细节、利用代码、订阅 URL、控制接口密钥、节点凭据或个人连接记录。普通功能故障请按 [贡献指南](CONTRIBUTING.md) 报告；权限绕过、任意命令/文件操作、凭据泄露和不受信输入导致的安全问题应使用以下流程。

## 报告渠道

优先检查仓库的 [Security 页面](https://github.com/halifox/MihomoGUI/security)。当维护者启用 GitHub Private Vulnerability Reporting 后，可使用 [Report a vulnerability](https://github.com/halifox/MihomoGUI/security/advisories/new) 私下提交。

2026-11-15 通过 GitHub API 核对时，该仓库尚未启用私密漏洞报告；本项目也尚未公布经过验证的安全联系邮箱。因此，目前不要将上述表单当作已可用的私密渠道。如果入口不可用，请仅创建标题为 `Request a private security contact` 的 [Issue](https://github.com/halifox/MihomoGUI/issues/new)，请求维护者提供私密联系方式，正文不要包含漏洞描述、影响组件、复现步骤或附件。获得私密渠道后再提供完整报告。此回退方式遵循 [GitHub 官方报告指引](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)。

维护者启用私密报告或公布可验证的安全联系方式后，应同步更新本文件和 Issue 联系入口。不要在没有验证的情况下添加邮箱、PGP 密钥或响应时间承诺。

## 私密报告内容

- 应用版本或提交号、mihomo 版本、macOS 版本及机器架构。
- 漏洞影响、所需权限和前置条件，以及最小复现步骤。
- 使用测试地址和虚构凭据的最小配置或验证代码；涉及文件操作时使用临时目录。
- 实际结果、预期边界和必要的脱敏证据；如已发现凭据泄露，请先撤销或轮换凭据。

请勿在未经许可的设备、网络或第三方订阅上验证漏洞。涉及上游 mihomo 或 GEO 资源的问题，请区分 GUI 与上游影响；必要时按上游安全政策协调报告。

## 版本与处理范围

本项目尚未建立历史版本的安全回补或长期支持分支。维护工作以主分支和当前发布版本为基础，不承诺旧版本修复期限；报告旧版本问题时仍请提供准确版本，以便判断影响范围。

收到私密报告后，维护者应确认复现条件和受影响版本，私下协作修复、验证后协调披露；修复版本、缓解措施与署名须在发布说明或安全公告中明确。当前没有漏洞奖励计划或固定响应时限的承诺。

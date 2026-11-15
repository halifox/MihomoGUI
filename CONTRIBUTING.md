# 贡献指南

欢迎报告问题、改进文档和提交代码。参与前请阅读 [README](README.md) 了解产品边界，修改代码时遵循 [AGENTS.md](AGENTS.md) 中的工程规范。

## 报告问题

疑似安全漏洞请先阅读 [安全报告政策](SECURITY.md)，不要在公开 Issue 中提交漏洞细节。

请在 [Issues](https://github.com/halifox/mihomoGUI/issues) 中提供：

- 应用版本或提交号、macOS 版本、Apple Silicon / Intel 架构。
- 复现步骤、预期行为和实际行为。
- 涉及服务启动、TUN、DNS 或网络切换时，补充相关设置及其他 VPN 的使用情况。
- 已脱敏的错误信息、截图或必要配置片段。

不要上传完整用户数据目录或未脱敏的订阅地址、控制接口密钥、节点凭据及个人连接记录。

## 本地开发与验证

环境与资源准备见 [源码构建说明](README.md#从源码运行与构建) 和 [资源说明](resources/README.md)。没有第三方 Swift 包依赖；完整应用须通过打包脚本构建，包含特权辅助程序、内核和 GEO 数据。

```bash
bash scripts/build.sh
bash scripts/check-interactions.sh
```

交互检查使用隔离配置和真实内核，覆盖数据契约、规则、状态与重连等行为，不会替代真实环境中的管理员授权、TUN、休眠恢复和网络切换验证。按改动范围验证关键行为，并在 PR 中说明执行结果与未覆盖的场景。

纯文档修改检查内容与实现是否一致、本地链接与图片路径是否有效，并运行 `git diff --check`；无需为文档修改完整构建应用。

## 提交变更

保持改动聚焦，避免无关重构、依赖升级或格式调整。不要提交 `.build/`、`dist/`、下载的内核与 GEO 数据、临时文件或真实凭据。

Commit Message 和 PR 标题、描述使用英文。提交遵循 Conventional Commits，例如：

```text
fix: preserve applied configuration when reconnecting
feat: add connection details
docs: clarify installation requirements
```

Issue 表单与 PR 模板提供必要信息提示。`.github/CODEOWNERS` 将评审请求分配给仓库所有者；该文件本身不强制审批，是否要求批准由仓库规则控制。`main` 的保护要求与管理方式见[仓库设置](docs/repository-settings.md)；合入必须走 PR 并通过必需检查。

PR 说明应包含问题、变更后的行为、验证方式及必要限制。界面变更可提供截图；修改配置生成或请求语义时，应说明对未设置值、空值和默认值的影响。

版本与资源更新流程见 [发布维护文档](docs/releasing.md)。

## 贡献许可

提交贡献即表示你有权提交相应内容，并同意贡献代码按本项目的 [GPL-3.0-only](LICENSE) 许可证分发。引入第三方内容时保留其许可证与归属说明；打包资源的现有说明见 [resources/licenses/](resources/licenses/)。

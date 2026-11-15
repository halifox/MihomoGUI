# 构建与发布维护

本文面向维护者。用户安装与本地构建见 [README](../README.md)，资源来源及下载方式见 [资源说明](../resources/README.md)。以下行为以仓库当前工作流配置为准。

## 版本与自动发布

版本由根目录 [VERSION](../VERSION) 管理，Release Please 的配置与状态分别保存在 [release-please-config.json](../release-please-config.json) 和 [.release-please-manifest.json](../.release-please-manifest.json)。初始版本配置为 `1.0.0`。

提交遵循 Conventional Commits：`fix:` 用于修复，`feat:` 用于新增功能，破坏性变更使用 `!` 或 `BREAKING CHANGE:`。Release Please 根据提交计算版本并维护版本及 CHANGELOG 发布 PR。

[发布工作流](../.github/workflows/release-please.yml) 在推送 `main` 或手动触发时运行。合并发布 PR 后创建标签与 GitHub Release，再调用 arm64 构建工作流。工作流也会为新建或更新的发布 PR 主动触发分支构建。

仓库 Settings → Actions → General 需要允许 GitHub Actions 创建和批准 Pull Request。工作流使用内置 `GITHUB_TOKEN`；当前应用使用本地临时签名，不需要 Apple 签名证书，也未进行 Apple 公证。

## 构建与重新上传

[Build macOS arm64](../.github/workflows/build.yml) 在面向 `main` 的 PR、推送 `v*` 标签或手动触发时构建。当前配置使用 `macos-26` runner、Xcode 26.5 和 macOS 26.5 SDK，并检查机器架构为 arm64。

手动运行时：

- `release_tag` 留空：构建所选分支，不上传 Release 附件。
- `release_tag` 填写已有标签（例如 `v1.0.0`）：检出该标签，检查其与 `VERSION` 一致，构建并上传 ZIP。

标签推送同样构建标签对应源码并上传。文件名为 `MihomoGUI-v版本号-macos-arm64.zip`，Actions 构建产物保留 7 天。上传时会替换同名附件；Release 不存在时会基于已有标签创建 Release。

构建依次执行资源下载与摘要校验、应用打包、交互回归、签名验证、SDK 与应用版本检查，然后生成 ZIP。当前不生成 `SHA256SUMS` 附件。

Release 可能在构建完成前已创建。构建失败时先查明原因；若是临时下载或 runner 故障，可重新运行原任务。源码修复需要新的提交与版本，不应移动已发布标签来替换源码。

## 资源与工作流更新

[Update bundled resources](../.github/workflows/update-resources.yml) 每周一 UTC 03:00（新加坡时间 11:00）或手动运行，更新 [resources/manifest.json](../resources/manifest.json)，创建资源更新 PR 并触发分支构建，不自动合并。

清单固定上游资产 ID、来源与 SHA-256。审核资源更新时核对内核兼容性、资源来源及许可归属；旧资产被上游移除会导致下载失败，需要更新清单，不会自动切换到未确认的资源。

[Dependabot](../.github/dependabot.yml) 每周检查 GitHub Actions 更新。内置令牌创建的 PR 不能依赖普通 `pull_request` 触发完成验证，因此资源更新与发布工作流会主动调用分支构建。

## 发布前检查

确认版本、变更说明和附件对应同一标签，检查 CI 结果，并在实际 macOS 环境验证本次改动涉及的功能。管理员授权、TUN、其他 VPN 并存、休眠恢复与网络切换不由 CI 完整覆盖。

分发时保留应用内的第三方许可文本与资源清单，项目源代码许可见 [LICENSE](../LICENSE)。

# 构建与发布维护

本文面向维护者。用户安装与本地构建见 [README](../README.md)，资源来源及下载方式见 [资源说明](../resources/README.md)。以下行为以仓库当前工作流配置为准。

## 版本与自动发布

版本由根目录 [VERSION](../VERSION) 管理，Release Please 的配置与状态分别保存在 [release-please-config.json](../release-please-config.json) 和 [.release-please-manifest.json](../.release-please-manifest.json)。初始版本配置为 `1.0.0`。

提交遵循 Conventional Commits：`fix:` 用于修复，`feat:` 用于新增功能，破坏性变更使用 `!` 或 `BREAKING CHANGE:`。Release Please 根据提交计算版本并维护版本及 CHANGELOG 发布 PR。

[发布工作流](../.github/workflows/release-please.yml) 在推送 `main` 或手动触发时运行。合并发布 PR 后创建标签与草稿 GitHub Release，再调用 arm64 构建工作流。`draft` 与 `force-tag-creation` 同时启用，确保草稿阶段已有可构建的标签。工作流也会为新建或更新的发布 PR 主动触发分支构建。

仓库 Settings → Actions → General 需要允许 GitHub Actions 创建和批准 Pull Request。工作流使用内置 `GITHUB_TOKEN`；默认构建使用本地临时签名；可选 Developer ID 签名和公证流程见下文。未启用正式签名时，附件仍是临时签名构建。

## 构建与附件上传

[Build macOS arm64](../.github/workflows/build.yml) 在面向 `main` 的 PR、推送 `v*` 标签或手动触发时构建。当前配置使用 `macos-26` runner、Xcode 26.5 和 macOS 26.5 SDK，并检查机器架构为 arm64。

手动运行时：

- `release_tag` 留空：构建所选分支，不上传 Release 附件。
- `release_tag` 填写已有标签（例如 `v1.0.0`）：检出该标签，检查其与 `VERSION` 一致，构建并上传 ZIP。

标签推送同样构建标签对应源码并上传。文件名为 `MihomoGUI-v版本号-macos-arm64.zip`，Actions 构建产物保留 7 天。同一发布标签的构建串行执行。上传前检查已有附件；同名冲突时失败，不覆盖或删除原文件。成功分页列出发布记录并确认目标标签不存在后，才基于已有标签创建草稿；查询或授权错误直接失败。已经公开的 Release 不再添加或替换附件。

构建依次执行资源下载与摘要校验、应用打包、交互回归、签名验证、SDK 与应用版本检查，然后生成 ZIP。归档脚本生成 ZIP、`SHA256SUMS` 及 `BUILD-METADATA.json`。发布时额外生成 `provenance.sigstore.json`，由 GitHub OIDC 身份签署 ZIP 和构建元数据的来源证明。

Release 在构建期间保持草稿。上传前核验完整附件集合、校验和、来源证明及标签对应的源码提交，上传后逐个核对远端资产状态与 SHA-256，全部通过后才公开。前置检查失败不会执行公开操作；最终公开请求失败时需人工核对实际状态，不自动重试。构建失败时先查明原因；若是临时下载或 runner 故障且尚未上传附件，可重新运行原任务。已有同名附件时不得通过删除或覆盖它们来重试，应排查上传状态并使用新版本发布变更。源码修复需要新的提交与版本，不应移动已发布标签来替换源码。

## 资源与工作流更新

[Update bundled resources](../.github/workflows/update-resources.yml) 每周一 UTC 03:00（新加坡时间 11:00）或手动运行，更新 [resources/manifest.json](../resources/manifest.json)，创建资源更新 PR 并触发分支构建，不自动合并。

清单固定上游资产 ID、来源与 SHA-256。审核资源更新时核对内核兼容性、资源来源及许可归属；旧资产被上游移除会导致下载失败，需要更新清单，不会自动切换到未确认的资源。

[Dependabot](../.github/dependabot.yml) 每周检查 GitHub Actions 更新。内置令牌创建的 PR 不能依赖普通 `pull_request` 触发完成验证，因此资源更新与发布工作流会主动调用分支构建。

## 发布前检查

确认版本、变更说明和附件对应同一标签，检查 CI 结果，并在实际 macOS 环境验证本次改动涉及的功能。管理员授权、TUN、其他 VPN 并存、休眠恢复与网络切换不由 CI 完整覆盖。

分发时保留应用内的第三方许可文本与资源清单，项目源代码许可见 [LICENSE](../LICENSE)。

## Developer ID 签名与公证

本地开发继续使用 `bash scripts/build.sh`。正式构建需在钥匙串安装可用的 Developer ID Application 证书及私钥，然后执行：

```bash
SIGNING_IDENTITY="Developer ID Application: YOUR_NAME (TEAM_ID)" bash scripts/build.sh
bash scripts/check-interactions.sh
NOTARY_PROFILE="your-stored-profile" bash scripts/notarize.sh
```

公证凭据通过 `xcrun notarytool store-credentials` 存入钥匙串，勿将证书、私钥或密码写入仓库。使用自定义钥匙串时再设置 `NOTARY_KEYCHAIN`。构建对 GUI、辅助服务及内核启用 hardened runtime；正式签名附加安全时间戳。公证脚本检查 Developer ID 签名，提交后要求状态为 `Accepted`，再执行 stapler 和 Gatekeeper 验证；报告保存在忽略目录 `.build/notarization-result.json`。公证成功后应重新生成分发 ZIP，以包含 stapled ticket。具体要求见 [Apple 公证工作流文档](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow)。

CI 可通过手动输入 `signed_release: true` 启用。自动发布需设置仓库变量 `ENABLE_SIGNED_RELEASES=true`，并在 GitHub Actions Secrets 中配置：

- `MACOS_SIGNING_CERTIFICATE`：包含私钥的 P12 文件的 Base64 内容。
- `MACOS_SIGNING_CERTIFICATE_PASSWORD`：P12 导出密码。
- `MACOS_SIGNING_IDENTITY`：Developer ID Application 身份的 40 位十六进制 SHA-1 标识。
- `APPLE_NOTARY_KEY_P8`：App Store Connect Team API 私钥内容。
- `APPLE_NOTARY_KEY_ID`、`APPLE_NOTARY_ISSUER_ID`：该 Team API 密钥的 ID 与 issuer。

CI 在临时钥匙串导入身份，仅在非 PR 构建中使用签名凭据，完成交互检查后才提交公证，归档前完成 stapling，并在结束时删除临时钥匙串及私钥文件。缺少凭据或公证失败时，正式构建失败，不会静默退回临时签名。

启用自动正式分发前，应使用实际发布身份验证 Developer ID 签名、公证提交、stapling 和 Gatekeeper 接受结果。

## 校验安装包与来源

本地通过 `bash scripts/archive.sh` 生成 `dist/release/` 下的归档、SHA-256 校验文件和构建元数据。该目录是本次构建产物，脚本会重新创建。元数据区分实际检出源码提交与触发工作流的提交，并记录工具链、架构、资源清单摘要和工作区是否存在未提交修改。

下载同一 Release 的 ZIP、`SHA256SUMS` 和 `BUILD-METADATA.json` 到同一目录后执行：

```bash
shasum -a 256 -c SHA256SUMS
gh attestation verify MihomoGUI-v版本号-macos-arm64.zip --repo halifox/mihomoGUI
gh attestation verify BUILD-METADATA.json --repo halifox/mihomoGUI
```

SHA-256 检查文件完整性，来源证明检查发布工作流身份；二者不能替代对代码行为的审核。手动构建历史标签时，工作流提交可能不同于检出源码提交，应同时检查元数据中的 `source_commit`、`workflow_commit`、`workflow_ref`。本地归档不伪造 GitHub 证明，证明签发需要在 GitHub Actions 实际运行，使用方式见 [官方 attest 文档](https://github.com/actions/attest)。

发布门禁的离线回归使用 `python3 scripts/check-release.py`。它从实际工作流读取发布步骤，以临时 `gh` 模拟新草稿、已有草稿、分页、公开版本、附件冲突、部分上传、摘要错误、来源证明失败、标签变化、权限和网络错误；不访问或修改远端 Release。

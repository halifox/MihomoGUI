<div align="center">

<img src="resources/AppIcon.png" width="160" height="160">

# MihomoGUI

一款使用 SwiftUI 构建的 macOS 原生 mihomo 客户端。

**订阅提供节点，网络策略由你掌控。**

[![Built with SwiftUI](https://img.shields.io/badge/built%20with-SwiftUI-F05138)](#从源码运行与构建)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-000000)](#安装)
[![Apple Silicon / Intel](https://img.shields.io/badge/architecture-arm64%20%2F%20x86__64-555555)](#环境要求)

[项目初衷](#项目初衷) · [功能](#功能概览) · [预览](#界面预览) · [安装](#安装) · [构建](#从源码运行与构建) · [数据与隐私](#数据与隐私)

</div>

---

## 项目初衷

**Mac 的内存比金子贵，日常代理只需要内核运行。** 配置完成后，没有必要让管理界面一直占着内存。MihomoGUI 的定位就是一个纯粹的配置与管理 GUI：需要修改配置或查看连接时打开，用完便可退出 GUI，让 mihomo 内核独立运行，尽量减少界面带来的常驻内存开销。重新打开 GUI 会连接现有内核，无需重启代理服务。

另一个原因是，很多订阅附带的配置质量参差不齐，DNS、TUN 和路由规则未必适合自己的网络环境。我需要的是订阅里的节点，以及自己维护的一套网络策略。但在其他客户端中，修改这些参数往往要处理配置覆写、混合配置或手动编辑文件，维护起来很麻烦。

因此，这个项目将订阅与个人配置分开：**订阅只导入节点，不接管 DNS、代理分组和路由规则。** TUN、DNS、分流规则及相关参数由自己通过界面配置，更换或更新订阅时继续使用自己的策略。界面提供字段说明与配置预览，最终交由 mihomo 内核校验。

这个项目主要面向**了解 Clash / mihomo 配置、需要低常驻内存占用、希望自定义网络策略，并且只想从订阅导入节点的用户**。

## 功能概览

- **全局配置**：编辑端口、DNS、嗅探和 TUN 等参数，自动保存，字段旁提供说明与上游文档链接。
- **代理订阅**：添加、编辑、更新和删除 mihomo YAML 订阅，查看流量与到期信息；仅导入节点。
- **出站代理**：管理手动节点与订阅节点，执行延迟测试，自定义测速地址与超时。
- **代理分组**：管理 `select`、`url-test`、`fallback`、`load-balance` 分组及有序成员。
- **规则集合**：管理 HTTP、本地文件和内嵌规则来源。
- **路由规则**：编辑匹配条件、出口与顺序，末尾保留 MATCH；支持从活动连接添加规则。
- **运行监控**：查看内核版本、内存、实时速率、累计流量、活动连接和配置预览，按需断开连接。
- **实时日志**：在日志页面查看内核日志，仅在页面打开时接收。
- **独立服务**：通过特权辅助服务管理内核，退出 GUI 后继续运行。

## 界面预览

<table>
  <tr>
    <th>全局配置</th>
    <th>新建出站代理 · Hysteria2</th>
    <th>新建出站代理 · VLESS</th>
  </tr>
  <tr>
    <td width="33%"><a href="screenshots/general-configuration.jpg"><img src="screenshots/general-configuration.jpg" alt="全局配置" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/new-outbound-proxy.jpg"><img src="screenshots/new-outbound-proxy.jpg" alt="新建出站代理 · Hysteria2" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/new-outbound-vless.jpg"><img src="screenshots/new-outbound-vless.jpg" alt="新建出站代理 · VLESS" width="100%" /></a></td>
  </tr>
  <tr>
    <th>新建代理分组</th>
    <th>新建规则集合</th>
    <th>新建路由规则</th>
  </tr>
  <tr>
    <td width="33%"><a href="screenshots/new-proxy-group.jpg"><img src="screenshots/new-proxy-group.jpg" alt="新建代理分组" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/new-rule-provider.jpg"><img src="screenshots/new-rule-provider.jpg" alt="新建规则集合" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/new-route-rule.jpg"><img src="screenshots/new-route-rule.jpg" alt="新建路由规则" width="100%" /></a></td>
  </tr>
</table>

<details>
<summary>展开更多截图（全部主页面）</summary>

<table>
  <tr>
    <th>仪表盘</th>
    <th>代理订阅</th>
    <th>出站代理</th>
  </tr>
  <tr>
    <td width="33%"><a href="screenshots/dashboard.jpg"><img src="screenshots/dashboard.jpg" alt="仪表盘" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/subscriptions.jpg"><img src="screenshots/subscriptions.jpg" alt="代理订阅" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/outbound-proxies.jpg"><img src="screenshots/outbound-proxies.jpg" alt="出站代理" width="100%" /></a></td>
  </tr>
  <tr>
    <th>代理分组</th>
    <th>规则集合</th>
    <th>路由规则</th>
  </tr>
  <tr>
    <td width="33%"><a href="screenshots/proxy-groups.jpg"><img src="screenshots/proxy-groups.jpg" alt="代理分组" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/rule-providers.jpg"><img src="screenshots/rule-providers.jpg" alt="规则集合" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/rules.jpg"><img src="screenshots/rules.jpg" alt="路由规则" width="100%" /></a></td>
  </tr>
  <tr>
    <th>活动连接</th>
    <th>内核日志</th>
  </tr>
  <tr>
    <td width="33%"><a href="screenshots/connections.jpg"><img src="screenshots/connections.jpg" alt="活动连接" width="100%" /></a></td>
    <td width="33%"><a href="screenshots/core-logs.jpg"><img src="screenshots/core-logs.jpg" alt="内核日志" width="100%" /></a></td>
  </tr>
</table>

</details>

## 安装

### macOS

从 [GitHub Releases](https://github.com/halifox/mihomoGUI/releases) 下载 `MihomoGUI-v版本号-macos-arm64.zip`，解压后将 `MihomoGUI.app` 放入“应用程序”目录。自动发布包仅提供 Apple Silicon 版本。

- **Apple Silicon（M 系列芯片）**：选择 `arm64` 安装包。
- **Intel 芯片**：需要自行准备对应内核并从源码构建。

需要 macOS 13 或更高版本。应用已包含 mihomo 内核与 GEO 数据，无需另行下载。

首次启动内核时，按系统提示授予管理员权限。当前应用使用本地临时签名，尚未正式签名或公证；更新后首次启动内核可能需要重新授权。

## 使用说明与限制

### 首次使用

1. 在“全局配置”中按需设置端口、DNS、嗅探和 TUN。默认启用 DNS，使用 `fake-ip` 模式，默认关闭接受 IPv6 流量；已保存的用户设置优先。
2. 添加代理订阅或手动出站代理。订阅只导入节点，不导入其 DNS、代理组与路由规则。
3. 配置代理分组、规则集合和路由规则，确认末尾 MATCH 的出口。
4. 在“仪表盘”点击“启动 mihomo 内核”。应用校验配置，并在需要时请求管理员授权。
5. 通过仪表盘、活动连接与日志页面检查运行情况；需要停止服务时，在仪表盘明确点击“停止 mihomo 内核”。

### 配置与运行边界

- 运行期间，全局配置与规则集合只读。节点、代理组与路由规则修改后自动应用。
- 全局配置中显示的已定义默认值和布尔开关会明确写入 YAML，界面、配置预览与运行配置使用同一份默认值；已编辑值优先。
- 未填写且没有默认值的可选字段继续省略，文档示例不会自动写入，其他平台专用字段不会自动补值。
- TUN 和代理监听端口需要用户自行开启和配置。应用提供控制接口与随机密钥以供 GUI 连接，已有配置保留。
- 订阅仅支持 mihomo YAML，不支持 Base64 / URI 转换；订阅由 GUI 更新，内核使用内联节点。
- 字段是否可用取决于打包的 mihomo 版本，复杂配置最终以内核校验结果为准。
- 真实 TUN 的 IPv6、其他 VPN 并存、休眠恢复与网络切换仍需实际环境验证。
- 辅助服务权限绑定一个安装用户，其他用户使用时需重新授权。

## 从源码运行与构建

### 环境要求

- macOS 13 或更高版本。
- Xcode 或 Command Line Tools 提供的 Swift 编译器；`Package.swift` 声明 Swift tools 5.9。
- 当前机器架构对应的 macOS mihomo 内核，以及四份 GEO 数据。
- 系统 Ruby / Psych，用于订阅 YAML 解析；无需安装第三方 Swift 包。

### 获取源码与准备资源

```bash
git clone https://github.com/halifox/mihomoGUI.git MihomoGUI
cd MihomoGUI
```

按照 [内置资源说明](resources/README.md) 准备以下文件：

```text
resources/
  core/
    arm64/mihomo       # Apple Silicon 构建使用
    x86_64/mihomo      # Intel 构建使用
  geodata/
    Country.mmdb
    geoip.dat
    geosite.dat
    ASN.mmdb
```

只需准备当前构建机器对应架构的内核。内核必须是已解压的 macOS 可执行文件；构建脚本不会自动下载资源，缺少或为空时会报错。为两个架构分发时，分别在对应架构环境构建。

### 构建与运行

在仓库根目录执行：

```bash
bash scripts/build.sh
open dist/MihomoGUI.app
```

脚本直接调用 `swiftc`，编译 GUI 与特权辅助程序，打包内核和 GEO 数据，然后进行本地临时签名。中间文件位于 `.build/manual/`，最终交付整个 `dist/MihomoGUI.app`，无需另外交付 `resources/`。

重新构建后，请先用 Cmd-Q 退出旧应用，再打开新构建。也可通过 [Package.swift](Package.swift) 在支持 Swift Package 的开发环境中打开项目；完整编译、打包与签名仍使用上述脚本。

### 验证

完成构建后，可运行仓库现有的交互回归检查：

```bash
bash scripts/check-interactions.sh
```

脚本使用隔离配置和真实内核检查配置、规则、运行状态及重连等行为。TUN、系统授权和真实网络环境下的行为仍需相应的人工验证。

### 技术栈与代码组织

| 部分 | 实现 |
| --- | --- |
| 原生界面 | SwiftUI，最低 macOS 13 |
| 代理内核 | 随应用打包的 mihomo |
| 配置与接口 | Swift / Foundation、mihomo API |
| YAML 解析 | 系统 Ruby / Psych |
| 本地持久化 | JSON 设置、节点与订阅缓存 |
| 服务管理 | launchd、特权 XPC 辅助服务 |
| 构建 | Shell / swiftc，无第三方 Swift 包依赖 |

```text
Sources/
  MihomoGUI/           页面、共享状态、配置协调与服务管理
  MihomoGUICore/           配置类型、API、订阅解析及字段文档
  MihomoGUIHelper/         特权 XPC 服务入口
scripts/
  build.sh             编译、打包与本地签名
  check-interactions.sh
resources/             构建所需的内核与 GEO 数据
```

## 数据与隐私

### 本地数据

用户数据保存在 `~/Library/Application Support/MihomoGUI/`：

| 内容 | 文件或目录 |
| --- | --- |
| 草稿配置 | `settings.json` |
| 已确认运行配置 | `runtime.json` |
| 节点与订阅缓存 | `nodes.json`、`providers/` |
| GEO 缓存 | `geodata/` |

用户数据目录权限为 `700`，设置与密钥文件权限为 `600`。配置与缓存可能包含订阅地址、节点凭据和控制接口密钥，请勿直接公开整个数据目录。

草稿与已确认配置分开保存，重新打开 GUI 时使用已确认运行配置连接现有内核，避免尚未应用的编辑影响重连。

当前不安装流量统计后台，也不写入统计数据库。内核日志通过 API 实时查看，应用不再额外采集落盘。

### 系统服务

| 内容 | 位置 |
| --- | --- |
| 内核 LaunchDaemon | `/Library/LaunchDaemons/local.MihomoGUI.core.plist` |
| 辅助服务 LaunchDaemon | `/Library/LaunchDaemons/local.MihomoGUI.helper.plist` |
| 特权辅助程序 | `/Library/PrivilegedHelperTools/local.MihomoGUI.helper` |
| 安装的内核 | `/Library/PrivilegedHelperTools/MihomoGUI/mihomo` |
| 系统运行配置 | `/Library/Application Support/MihomoGUI/` |

辅助服务只接受安装用户及当前应用签名的请求。

### 网络请求与诊断

更新订阅时，应用会访问用户配置的订阅地址；测速会通过内核访问设置的测速地址。内核还会按配置访问远程规则来源、DNS 服务及代理服务器，并处理用户的网络流量。

首次启动会准备配置需要的 GEO 数据，优先使用所选内核的配套数据、应用内置数据，否则下载；自定义 GEO 下载地址优先。应用通过 mihomo 控制接口获取运行状态、连接和日志。

日志、配置预览与连接信息可能包含域名、IP 地址或其他敏感信息。提交 Issue、分享截图或日志前，请先删除订阅链接、密钥、节点凭据与个人网络信息。

## 许可证与第三方资源

当前仓库未附带源代码许可证文件。

mihomo 内核、GEO 数据及其他第三方资源遵循各自的许可证与使用条件，不因随应用打包而改变。分发应用时，应保留所使用内核及数据要求的许可和归属说明，资源准备要求见 [resources/README.md](resources/README.md)。

## 参与贡献

### 自动构建与发布

版本由根目录 `VERSION` 管理，首次自动发布为 `v1.0.0`。提交使用 Conventional Commits：`fix:` 触发补丁发布，`feat:` 触发功能发布，破坏性变更使用 `!` 或 `BREAKING CHANGE:`。推送 `main` 后 Release Please 维护版本与 CHANGELOG 发布 PR；合并后创建 Release 并直接调用 arm64 构建工作流。

仓库 Settings → Actions → General 需要允许 GitHub Actions 创建和批准 Pull Request。工作流使用内置 `GITHUB_TOKEN`，无需配置签名证书；应用继续使用临时签名，未进行 Apple 公证。首次启用自动化的提交建议使用 `feat: add automated macOS releases`，使其进入首次发布。

`Build macOS arm64` 支持手动运行：`release_tag` 留空只构建，填写已有 `v版本号` 标签则为该版本构建并上传 ZIP；标签必须与 `VERSION` 一致。手动推送 `v*` 标签也会构建并上传。两个触发方式均构建标签对应源码，产物在 Actions 保留 7 天。

Dependabot 每周创建 Actions 更新 PR；`Update bundled resources` 每周一 UTC 03:00 检查内核和 GEO 更新，创建资源清单更新 PR，并主动触发其分支构建。资源更新不自动合并。Release Please 创建或更新发布 PR 后也会主动触发分支构建，补足内置令牌创建 PR 不触发 `pull_request` 工作流的限制。

发布构建检查资源摘要、arm64 架构、交互回归、应用版本和签名后上传 ZIP，不生成 SHA256SUMS 附件。CI 无法替代真实环境下的管理员授权、TUN 和网络切换验证。构建失败时 Release 可能已经创建，可修复后为相应标签重新构建。

欢迎提交问题、改进建议和 Pull Request。修改代码前，请阅读 [AGENTS.md](AGENTS.md) 中的工程规范。

反馈问题时，请提供构建版本或提交号、macOS 版本、机器架构、复现步骤和实际现象；涉及网络、TUN 或服务启停问题时，请补充相关配置与环境，并在分享前脱敏。

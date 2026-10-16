# ClashDesk

macOS 原生 mihomo 客户端，使用 SwiftUI 管理代理、订阅、分流与连接，通过独立的 Swift 采集进程将流量统计写入 SQLite。关闭窗口或退出应用后，已启动的服务继续运行。

## 编译构建

需要 macOS 13 或更高版本，以及 Xcode 或 Command Line Tools 提供的 Swift 编译器。没有第三方 Swift 包依赖；订阅解析使用系统 Ruby / Psych，数据库使用系统 SQLite。

```sh
# 先按 resources/README.md 放入内核与四份 GEO 数据
bash scripts/build.sh
open dist/ClashDesk.app
```

脚本直接调用 `swiftc`，编译当前机器架构的 GUI 和统计程序，打包并进行本地临时签名。构建产物为 `dist/ClashDesk.app`，中间文件在 `.build/manual/`。重新构建后，请用 Cmd-Q 退出旧进程，再打开应用。

也可通过 `Package.swift` 在支持 Swift Package 的开发环境中打开项目。`scripts/` 只保留编译构建脚本。

## 使用

1. 应用使用打包的 mihomo 内核，无需选择内核文件。
2. 在“全局配置”调整端口、DNS、嗅探和 TUN。
3. 添加代理订阅或手动出站代理。订阅只导入节点，不导入其 DNS、代理组与路由规则。
4. 按需配置代理分组、规则集合和路由规则，并确认末尾 MATCH 的出口。
5. 点击“启动全部”，应用校验配置并请求管理员授权安装和启动服务。

运行期间，全局配置与规则集合只读；节点、代理组与路由规则修改后自动应用。顶栏可查看内核日志或停止服务。退出应用不会停止服务。

## 页面

| 页面 | 功能 |
|---|---|
| 全局配置 | 编辑全局参数、DNS、嗅探、TUN，自动保存 |
| 代理订阅 | 添加、编辑、更新、删除订阅，查看流量与到期信息 |
| 出站代理 | 管理手动节点，查看订阅节点，执行延迟测试 |
| 代理分组 | 管理 select、url-test、fallback、load-balance 与有序成员 |
| 规则集合 | 管理 HTTP、本地文件、内嵌规则来源 |
| 路由规则 | 编辑规则、出口和匹配顺序，MATCH 固定在末尾 |
| 活动连接 | 查看实时连接和速率、断开连接、添加路由规则 |
| 流量统计 | 按域名、进程、目标 IP 或端口汇总最近 24 小时、7 天或 30 天流量 |
| 应用设置 | 调整测速参数，查看版本、内存和服务状态 |

配置字段旁的问号提供说明与上游文档链接。可选字段未配置时使用应用或内核默认值；修改后会显式保存，点击字段旁的恢复按钮可重新省略该字段。字段是否可用取决于所选 mihomo 版本，启动前以内核配置校验结果为准。

## 代码组织

按实际使用关系组织代码：一个页面一个文件；页面专用的表单、类型与辅助逻辑留在页面文件中；复用组件各自独立；较大的共享状态、服务逻辑和字段数据单独维护。避免为单次使用的逻辑增加中间层。

```text
Sources/
  ClashDesk/
    App.swift                       应用入口、窗口与页面导航
    GeneralConfigurationView.swift  全局配置
    SubscriptionsView.swift         订阅及专用编辑表单
    OutboundProxiesView.swift       出站代理及专用编辑表单
    ProxyGroupsView.swift           代理分组
    RuleProvidersView.swift         规则集合
    RulesView.swift                 路由规则及专用编辑表单
    ConnectionsView.swift           活动连接
    StatisticsView.swift            流量统计
    ApplicationSettingsView.swift   应用设置
    ResourceEditorView.swift        分组与规则集合共用的编辑表单及行数据
    Model.swift                     跨页面共享状态、持久化与运行配置协调
    Services.swift                  launchd 服务安装、启停与日志
    …                               复用字段控件、表格和格式化函数
  ClashCore/                        配置、API、订阅、字段数据、SQLite 统计
  ClashStats/main.swift             后台采集程序入口
  CSQLite/                          系统 SQLite 模块声明
scripts/build.sh                    编译、打包与本地签名
Package.swift                       Swift Package 目标定义
```

`ClashCore` 供 GUI 与采集程序共用。`DocSchemas.swift` 保存字段定义，`HelpDocs.swift` 保存字段说明，更新时应核对上游文档正文、示例和协议限制；这些数据随程序编译，无需本地文档目录。仓库不包含测试目录、测试脚本或 `docs/` 目录。

## 数据与服务

| 内容 | 位置 |
|---|---|
| 用户数据目录 | `~/Library/Application Support/ClashDesk/` |
| 草稿 / 已确认运行配置 | 数据目录内 `settings.json` / `runtime.json` |
| 节点与订阅缓存 | 数据目录内 `nodes.json` / `providers/` |
| 流量统计与 GEO 缓存 | 数据目录内 `traffic.sqlite` / `geodata/` |
| 内核日志 | 数据目录内 `logs/core.log` |
| 用户采集服务 | `~/Library/LaunchAgents/local.clashdesk.stats.plist` |
| 系统内核服务 | `/Library/LaunchDaemons/local.clashdesk.mihomo.plist` |
| 安装的内核 | `/Library/PrivilegedHelperTools/ClashDesk/mihomo` |
| 系统运行配置 | `/Library/Application Support/ClashDesk/` |

用户数据目录权限为 700，设置与密钥文件权限为 600。系统内核由 LaunchDaemon 管理，采集程序由用户 LaunchAgent 管理；退出用户登录后采集停止。草稿与已确认配置分开保存，避免编辑控制接口时影响正在运行的采集。

统计程序每 2 秒采样，内核不可用时每 5 秒重试；按小时聚合，保留 90 天。日志按大小轮转。首次启动会准备配置需要的 GEO 数据，优先使用所选内核的配套数据、应用内置数据，否则下载；自定义 GEO 下载地址优先。内置资源目录与文件要求见 [resources/README.md](resources/README.md)。

## 当前限制

- 服务安装通过 AppleScript 请求管理员授权，尚未采用正式签名、公证或 SMAppService / XPC helper。
- 订阅仅支持 Clash YAML，不支持 Base64 / URI 转换；订阅由 GUI 更新，内核使用内联节点。
- 流量来自连接快照，会遗漏短连接、断线与重启期间的流量；时间范围按小时分桶，结果最多显示 500 项。
- 未设置的内核选项使用 mihomo 默认值；TUN、DNS、监听端口等由用户自行开启和配置。仅控制接口与随机密钥由应用提供，以供 GUI 和统计后台连接；已有配置保留。
- 真实 TUN 的 IPv6、其他 VPN 并存、休眠恢复与网络切换仍需实际环境验证。
- 复杂规则最终以所选 mihomo 内核校验结果为准。

# ClashDesk 0.5

仅支持 macOS 的原生 mihomo 客户端。SwiftUI GUI、独立 mihomo 内核、Swift 流量采集服务和 SQLite。退出 GUI 后，launchd 管理的服务继续运行。

## 构建

macOS 13+，需要 Swift 编译器。没有第三方 Swift 依赖；构建当前机器架构。

```sh
bash scripts/build.sh
open dist/ClashDesk.app
```

提供 `Package.swift`，可在完整 Xcode 中打开。构建脚本直接调用 swiftc，适用于只有 Command Line Tools 的环境。重新构建后必须 Cmd-Q 退出旧进程，再打开应用。

## 七个页面

1. **通用配置**：全局配置、DNS、域名嗅探和 TUN，按配置文档生成可视化控件。包含开关、枚举、数字、文本、列表和键值表；合并为卡片表单，支持搜索与保存，DNS / 嗅探 / TUN 开关联动禁用下属字段。DNS 的 hosts / nameserver-policy 支持单值和列表。macOS 不支持的 Linux / Android TUN 项没有列入表单。
2. **订阅管理**：表格显示名称、订阅链接与节点数，右上角添加按钮打开名称 / 地址表单，成功解析非空节点后才保存；选中订阅后通过右上角按钮更新、编辑、删除，另可更新全部订阅。
3. **出站代理**：统一代理表格，支持手动代理和 HTTPS Clash YAML 订阅。选择协议后生成必填字段、公共字段和适用的 TLS / 传输字段。覆盖 26 种文档中的代理类型，包括 Hysteria2、TUIC、Shadowsocks、VMess、VLESS、Trojan、AnyTLS、HTTP、SOCKS5 等。手动代理支持编辑和删除；订阅节点由订阅更新。表格显示 UDP 能力，点击延迟值进行测速；选中手动代理后可通过右上角编辑 / 删除按钮管理。
4. **路由规则**：表格按从上到下顺序执行，支持添加、编辑、删除、上移、下移及直接修改出口。IP-CIDR 表单提供地址、掩码与 no-resolve / src；其他类型包括域名、ASN、端口、网络、进程、通配符、正则和逻辑条件。内置 DIRECT、REJECT、REJECT-DROP。支持 inline / http / file 规则集合与子规则配置。MATCH 始终保留在末尾。
5. **当前连接**：域名 / IP、进程、协议、出口、上传和下载，可断开单个连接，右键添加域名 / IP / 程序规则。
6. **流量统计**：按域名汇总上传、下载、总流量、程序数、出口数和当前连接数；选择最近 24 小时、7 天或 30 天。
7. **设置**：选择 mihomo 二进制，显示内核版本、内存占用、Clash PID、采集服务 PID、最后采集时间、控制接口及数据目录。内存来自内核 WebSocket API，PID 来自对应 launchd 服务；离线显示“—”。

表单中的“设置此项”表示显式配置可选字段；未设置时由默认配置或内核默认值决定。新文档里的协议或选项是否可用，还取决于所选 mihomo 版本；内核启动前会做配置校验。

## 首次使用

1. 在“设置”选择可信的 [mihomo 二进制](https://github.com/MetaCubeX/mihomo/releases)。如果使用压缩包，请先解压并赋予可执行权限。
2. 在“通用配置”设置所需参数。
3. 在“出站代理”填写手动代理，或在“订阅管理”添加订阅并立即拉取。订阅只提供节点，不采用订阅内的 DNS、策略组或路由规则。生成的 mihomo YAML 不包含订阅链接、token 或名称；节点以内部唯一名称内联写入 proxies。
4. 初次添加代理后 MATCH 指向第一个代理；在“路由规则”调整出口和分流条件。
5. 点击“安装 / 启动全部”，查看完整只读 YAML 预览，再点击“确认并启动”。确认后才校验并安装服务，随后出现 macOS 管理员授权。
6. 运行中修改配置，点击“应用运行配置”，同样先预览并确认。改变控制地址或密钥时会改为确认后重启服务，确保 GUI 和采集后台连接到新的接口。
7. 开发版热更新不会改写 root 启动配置；需要重启后持久化时使用“安装 / 启动全部”。

取消预览不会安装、启动或更新系统代理。预览和实际运行使用同一份配置快照。关闭窗口 / Cmd-Q 不停止服务；通过“停止”菜单停止代理、统计或全部服务。

## 配置与兼容

预览、启动文件与热更新配置内容使用标准 YAML；REST API 请求外层仍为 mihomo 规定的 JSON。动态字段会生成正确的嵌套 YAML，单引号、Emoji、正则、URL 和进程路径保留原值。

默认参数沿用已有设置：规则模式、本机 7890、info 日志、统一延迟、TCP 并发、mips / utun1024 / MTU 1500、指定 DNS 和 fallback 等。都可在通用配置页调整。默认控制接口为 `127.0.0.1:19090`，使用已有随机密钥；GUI 和采集后台需要有效的 host:port。未确认的草稿保存在 `settings.json`，已确认运行的接口配置保存在 `runtime.json`，防止编辑地址或密钥时中断采集。

旧版本设置、订阅、缓存和统计数据库保留。旧版“程序优先”的规则排列会在首次迁移时转成相同的显式表格顺序，后续严格按表格顺序匹配。指定订阅节点消失时保留原引用并使用 REJECT，不自动直连；被规则引用的手动代理不允许直接删除。

首次确认启动后准备 DNS / 路由所需 GEO 数据：优先使用所选内核应用的配套数据；否则从官方数据地址下载。支持自定义 GEO URL 和 geodata-mode，ASN 规则会准备 ASN 数据。

## 数据和服务

| 内容 | 位置 |
|---|---|
| 草稿设置 / 已确认配置 | `~/Library/Application Support/ClashDesk/settings.json` / `runtime.json` |
| 订阅节点和延迟缓存 | 同目录 `nodes.json` / `providers/` |
| SQLite 统计和 GEO 缓存 | 同目录 `traffic.sqlite` / `geodata/` |
| 用户采集服务 | `~/Library/LaunchAgents/local.clashdesk.stats.plist` |
| 系统代理服务 | `/Library/LaunchDaemons/local.clashdesk.mihomo.plist` |
| 系统 mihomo | `/Library/PrivilegedHelperTools/ClashDesk/mihomo` |
| 系统 YAML、节点和 GEO 文件 | `/Library/Application Support/ClashDesk/` |

数据目录权限 700，设置 / 密钥文件权限 600，系统文件为 root 所有。统计后台是用户 LaunchAgent，退出 GUI 后继续采集、退出用户登录后停止。mihomo 是 LaunchDaemon，可在登录前运行。停止操作会 disable 对应任务；再次启动会 enable。

统计后台每 2 秒采样一次，内核不可用时每 5 秒重试。内存只保留活跃连接计数，数据库按小时聚合，保留 90 天；SQLite 缓存目标 1 MiB、关闭 mmap，没有 HTTP 服务或内存历史列表。文件锁阻止重复采集，重启后建立新基线以避免重复累计。

## 文档字段与测试

字段定义来源于用户提供的 Meta-Docs 配置文档，当前生成 104 个通用字段和 26 个代理类型。生成结果在 `Sources/ClashCore/DocSchemas.swift`，正常构建和运行不需要文档目录或 Ruby。更新字段定义时：

```sh
ruby scripts/build-schema.rb /path/to/Meta-Docs-main/docs/config
```

生成器解析文档的 YAML 示例，并过滤协议专属或平台不适用的字段；少数文档的示例片段语法不完整，会报告并跳过该片段。可使用代理表单“额外字段”添加新版本字段。

```sh
bash scripts/test.sh
bash scripts/integration-test.sh /path/to/mihomo
python3 scripts/stats-integration-test.py
```

核心测试覆盖 YAML、规则顺序、旧设置迁移、嵌套配置、协议字段归属、手动 Hysteria2、CIDR / 逻辑验证、域名汇总和已确认配置隔离。集成测试使用临时目录、本地 HTTP CONNECT 假代理和无 TUN 内核，校验真实内核解析、API 鉴权、内存 WebSocket、热更新、规则集合和延迟。不启动系统代理。

统计测试验证 1000 个活跃模拟连接、进程互斥、重启基线及草稿修改不影响采集；此前观测 RSS 约 17.9 MiB，仅为单次测试结果，不是长期或真实负载保证。

## 当前边界

- 使用 AppleScript 管理员授权安装 launchd 服务，尚未完成正式签名、notarization、SMAppService / XPC helper 和完整安装回滚。
- 支持 Clash YAML 订阅；Base64 / URI 转换尚未实现。节点表格从本地订阅 YAML 补全服务器和端口；使用 macOS 自带 Ruby / Psych 安全解析，仅提取显示字段，不缓存密码。订阅节点凭据暂不单独编辑。
- GUI 订阅缓存需点击“更新全部订阅”同步；mihomo 不再拉取订阅，只接收内联节点；订阅更新由 GUI 管理，更新后预览并应用配置。
- 流量为连接快照近似统计，会遗漏短连接、断线 / 重启期间和结束前最后一段流量；时间范围按小时分桶，最多显示 500 个域名，未提供历史分页或速率图表。
- IPv6 配置已开放，但默认关闭；尚未完成真实 TUN 的 IPv6、其他 VPN 并存、休眠恢复和网络切换验证。
- Linux UID / DSCP 等依赖其他平台入站的规则未列入 macOS 表单。复杂逻辑规则可以直接输入表达式；最终语法以 mihomo 校验为准。
- 不记录无限增长的服务 stdout / stderr 日志。配置校验和操作错误显示在 GUI；启动后的完整日志诊断仍待完善。

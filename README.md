# ClashDesk

macOS 原生代理管理客户端的可运行开发版。SwiftUI GUI、原版 mihomo 内核、独立 Swift 统计后台。退出 GUI 后，launchd 管理的服务继续运行。

## 构建和打开

需要 macOS 13+ 与 Swift 编译器。无需第三方 Swift 依赖；构建当前机器架构。

```sh
bash scripts/build.sh
open dist/ClashDesk.app
```

也提供 `Package.swift`，可以在完整 Xcode 中打开。构建脚本直接调用 swiftc，适用于只有 Command Line Tools 的环境。

重新构建后，如果 GUI 已经运行，必须先 Cmd-Q 完全退出，再重新打开 `dist/ClashDesk.app`。关闭窗口或再次打开同一路径不会替换旧进程。

## 使用

1. 从 [mihomo 官方 Releases](https://github.com/MetaCubeX/mihomo/releases) 获取匹配 macOS 架构的二进制，解压并赋予可执行权限。内核不随本项目分发。
2. 在“配置与节点”依次选择可信的 mihomo 文件、设置 TUN、填写 HTTPS Clash YAML 订阅，点击“添加并拉取”。程序立即下载订阅、解析节点并存到本地；不需要先启动代理。
3. 节点表显示名称、协议、订阅；最后两列显示延迟和“测试延迟”按钮。点击测试会临时运行无 TUN 的内核，通过该节点访问测试站点。完成后临时进程退出，结果保存在本地。
4. “规则”表初始只有一条 MATCH，首次导入时固定指向订阅顺序的第一个节点。直接用表格中的下拉框修改出口，可以选择其他节点或直连。通过 + / − 增删域名和程序规则；MATCH 永远位于最后，不能删除。规则类型可直接修改，匹配内容修改后按回车保存。
5. 点击“安装 / 启动全部”，先查看完整的只读 `config.yaml` 预览，点击“确认并启动”后才安装并启动服务，随后在 macOS 系统授权窗口中批准管理员操作。取消预览不会启动代理。API 地址是 `127.0.0.1:19090`，本机代理端口是 `7890`。
6. 修改规则后点击“应用运行配置”，同样先显示完整配置，点击“确认并应用”后才更新内核。预览和实际应用使用同一份配置快照，不会确认后重新生成另一份配置。
7. 开发版要将当前配置持久化到系统服务，请再次点击“安装 / 启动全部”并确认配置。这会请求管理员授权并重启内核，现有连接会断开。
8. 关闭窗口或 Cmd-Q 退出 GUI，不会停止服务。通过 GUI 的“停止”菜单停止代理、统计或全部服务。

只有需要启动或停止系统级代理服务时才请求管理员授权。普通界面、统计和 API 配置更新不需要 root。

## YAML 配置和默认参数

预览、`config.yaml` 启动文件及热更新 payload 都使用标准 YAML。API 请求外层仍遵循 mihomo 的 JSON 协议，里面的配置内容是 YAML。节点名称、URL、正则和单引号通过 YAML 标量转义，不把 JSON 内容保存为 YAML 文件。

默认参数采用用户提供的模板：`log-level: info`、`unified-delay: true`、`tcp-concurrent: true`、指定 CORS 来源、`bind-address: '*'`、`store-selected: true`；TUN 使用 `utun1024`、`mips`、MTU 1500 和指定的路由参数，`enable` 跟随界面开关；DNS 使用 223.5.5.5 / 119.29.29.29 / 114.114.114.114，以及指定的 fake-IP、respect-rules、fallback 和过滤设置。

运行时保留必要的两项设置：`external-controller: '127.0.0.1:19090'` 和用户已有的随机 `secret`，以便 GUI 和统计后台能连接内核；不使用空控制地址或 `set-your-secret` 占位文本。进程规则所需的 `find-process-mode: always` 也保留。

DNS fallback 的 GeoIP / GeoSite 数据在用户确认启动后准备：优先复用所选 mihomo 所在应用的配套数据文件，否则从 MetaCubeX 官方数据仓库下载，缓存在用户数据目录的 `geodata/`，校验后安装到系统内核目录。首次升级到这个默认配置建议使用“安装 / 启动全部”，让数据文件一并安装。

## 已实现

- GUI 直接下载订阅并保存原始 YAML，通过临时非特权 mihomo 的 file-provider 解析节点，只提取节点列表；不使用订阅中的分流规则、策略组或 DNS。启动系统内核时复制这些节点缓存，运行中 HTTP proxy-provider 每小时更新一次。
- 节点缓存和延迟结果在退出 GUI 后保留。重新拉取订阅保留默认出口；指定节点消失时标记失效，不自动切换。
- 规则模式：程序规则 → 域名规则 → `MATCH` 默认出口。
- 指定节点通过所属订阅和节点名称精确过滤；节点消失后使用 REJECT，不自动直连。
- 精确域名、域名及子域名、进程名、进程路径分流；规则表支持直接编辑类型、内容和出口。
- 当前连接列表；右键域名或程序添加规则；单独断开旧连接。
- 独立统计进程每 2 秒采集一次，内核不可用时每 5 秒重试。
- SQLite 按小时、域名、进程、出口累计上传/下载，保留 90 天。
- 域名流量表按域名汇总，展示上传、下载、总流量、程序数、出口数和当前连接数；连接表包含协议、出口和上传/下载。
- 活跃连接计数保存在内存，SQLite 缓存目标 1 MiB、关闭 mmap；没有内存历史列表或 HTTP 服务。
- 文件锁阻止多个统计进程重复累计；重启统计后台时先建立基线。
- launchd 独立管理服务，可在登录 / 系统启动时自动运行。停止操作同时 disable，防止下次启动自动恢复；再次启动会 enable。

## 服务与数据位置

| 内容 | 位置 |
|---|---|
| 用户设置、API secret、统计数据库 | `~/Library/Application Support/ClashDesk/` |
| 本地节点列表与延迟结果 | `~/Library/Application Support/ClashDesk/nodes.json` |
| GUI 下载的原始订阅缓存 | `~/Library/Application Support/ClashDesk/providers/` |
| 用户统计服务 | `~/Library/LaunchAgents/local.clashdesk.stats.plist` |
| 系统代理服务 | `/Library/LaunchDaemons/local.clashdesk.mihomo.plist` |
| root 内核 | `/Library/PrivilegedHelperTools/ClashDesk/mihomo` |
| root 配置与节点缓存 | `/Library/Application Support/ClashDesk/` |

用户设置文件权限 600，数据目录 700；系统二进制和配置安装为 root 所有。统计后台是当前用户的 LaunchAgent，退出 GUI 后继续运行，退出用户登录后停止。代理内核是 LaunchDaemon，在用户登录前也可能运行。开发版以单用户使用为范围。

## 测试

```sh
bash scripts/test.sh
bash scripts/integration-test.sh /path/to/mihomo
python3 scripts/stats-integration-test.py
```

核心测试涵盖规则顺序、配置转义、规则注入拒绝、失效订阅引用、流量计数重置、数据库累计和保留策略。没有 XCTest 的 Command Line Tools 环境使用简易断言运行器。

mihomo 集成测试启动隔离内核与本地 HTTP CONNECT 假代理，不启用 TUN、DNS 或系统代理；验证非特权节点解析、订阅顺序、本地缓存、延迟测试，以及生成配置、API 鉴权、精确节点过滤、热更新和节点失效行为。测试需要 Python 3，不访问外部测试站点。

统计集成测试使用本地假控制器和临时数据库，测试 1000 个活跃连接下的采集、进程互斥、重启基线，并输出一次 RSS 观测值。该值不是长期运行或真实工作负载的内存保证。

本机历史内存观测：1000 个活跃模拟连接时，统计进程 RSS 为 17.6 MiB。当前版本的核心测试增加了旧设置迁移、MATCH 直连和跨程序域名合计校验。实际订阅下载、解析和临时缓存验证得到 54 个节点，没有修改用户配置或启用 TUN。

## 当前边界

- 可运行开发版，使用 AppleScript 系统管理员授权安装 launchd 服务。还没有正式签名、notarization、SMAppService/XPC 特权 helper 或完整安装回滚；不作为正式发行的权限实现。
- 支持 mihomo 可读取的 Clash YAML 订阅；Base64 / URI 列表转换尚未实现。
- 目前 IPv6 未接管；不能保证 IPv6 流量都走代理。尚未验证其他 VPN 并存、休眠恢复、网络切换或真实 TUN 权限安装。
- 流量来自连接快照，是近似值。短连接、断线、统计重启期间会遗漏，连接关闭前的最后一段流量可能未采到。重启建立基线避免重复计量，但不补采历史。
- 历史数据按小时分桶，因此时间范围包含边界所在小时；列表显示最大的 500 个域名，尚无分页、速率图表或精确总量页面。
- GUI 本地缓存由“添加并拉取 / 重新拉取”更新；运行中的系统内核自动更新订阅不会同时改写 GUI 的本地缓存，需要重新拉取同步。节点表的协议由内核解析提供，尚未显示节点服务器地址。
- 选择 `.app` 只添加主可执行文件规则；辅助进程需要从连接列表添加。无法识别的域名按 IP 展示；IP 分流规则尚未提供。
- 运行配置热更新不会改写 root 启动配置；需要通过“安装 / 启动全部”持久化。节点名称改变会使对应规则失效。
- 开发版关闭服务 stdout/stderr 文件输出，避免日志无限增长或泄漏订阅凭证；配置检验、服务操作错误会显示在 GUI。内核启动后错误诊断能力仍需完善。

后续优先完善签名与特权 helper、配置持久化和安装回滚，再验证真实 TUN 行为与长时间内存使用。

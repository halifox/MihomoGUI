# 配置字段与文档核对记录

核对日期：2026-10-14。依据本地 `Meta-Docs-main/docs/config` 的中文正文、YAML 示例及注释、相关通用字段章节。此次由 AI 阅读文档后直接修订固定数据，没有运行原 Ruby 生成器，也没有保留替代文档解析器。

核对范围：126 个全局配置字段、26 种代理协议的现有字段（包括 WireGuard peers、ZeroTier orbit 子字段），共 1,061 个字段条目；另核对代理组、规则集合、路由规则及原帮助数据中的高级 TLS / 传输选项。共享字段在不同协议中重复计数；合并配置页中的同一字段不重复计数。帮助数据现有 702 条。

## 一一对应方式

- `DocSchemas.swift` 的每个叶字段保存完整 `path`、核对后的 `description` 和来源 `document`；嵌套对象子字段的来源键包含父路径，例如 `peers.server`。
- `HelpDocs.swift` 按 `文档路径|完整字段路径` 存储解释；正文已经解释清楚的高级选项保留原有正确说明。
- 帮助按钮优先显示字段的已核对说明，并链接到来源文档。按完整路径查找，禁止通过最后一段名称匹配不相关字段。
- 代理的公共字段分别对应 `proxies/index.md`、`proxies/tls.md`、`proxies/transport.md`；协议专有说明优先于公共说明。
- 客户端表单操作说明继续说明客户端行为。规则匹配说明与 `rules/index.md` 分开对应，避免将 GUI 输入方式当成内核语义。

## 各章节核对结果

| 来源文档（相对 docs/config） | 核对与处理 |
| --- | --- |
| `general.md` | 补齐局域网限制、认证、模式、API、CORS、UI、缓存、TLS、GEO、UA、ETag；纠正自动更新与更新间隔错配；区分内核默认 IPv6 与客户端初始值。 |
| `inbound/port.md` | 分清 HTTP、SOCKS、混合、redirect、TPROXY 的协议和平台；监听端口示例不作为默认值。 |
| `dns/index.md`、`dns/hosts.md` | 区分三种 Fake-IP 过滤模式，补齐解析器用途、优先级和前置条件；标注 fallback-filter.geosite 弃用；移除 DNS 示例中的顶层 proxies 被误收录为 DNS 字段的问题。hosts 来源改为独立文档。 |
| `sniff/index.md` | 分清全局 override-destination 与 HTTP 的局部覆盖，逐项解释协议端口、域名及来源/目标地址过滤。 |
| `inbound/tun.md` | 补齐协议栈差异、路由与网卡条件、Linux/Android 限制、IPv6 条件、单位及明确默认值；标注四个 inet*-route-* 旧字段即将废弃。 |
| `proxies/index.md` | 核对名称、服务器、端口、IP 版本、UDP、接口、路由标记、TFO、MPTCP、拨号代理、smux 与 Brutal；补齐冲突关系和上下行带宽说明。 |
| `proxies/tls.md` | 补齐 SNI/servername、完整证书指纹与公钥指纹区别、ALPN、mTLS、ECH、Reality、ShadowTLS、Restls、JLS；保留正确的 TLSMirror 高级说明，主密钥对应 VMess 和 TLS 的条件。 |
| `proxies/transport.md` | HTTP/H2/gRPC/WS 参数按传输类型对应，避免共用 path、headers 等末级名称；保留已正确对应的 mKCP、Mekya、XHTTP 高级说明。 |
| `proxies/anytls.md` | 补认证密码、元数据行为和会话参数，补正文明确的 30/30/0 默认提示。 |
| `proxies/direct.md`、`proxies/dns.md` | 对应现有公共字段；没有服务器和端口必填项。未将示例之外的未知协议行为写成确定结论。 |
| `proxies/http.md`、`proxies/socks.md` | 认证字段按可选示例解释，TLS 说明对应通用 TLS 章节。HTTP 请求头单独解释。 |
| `proxies/ss.md` | 核对 cipher、认证、UDP-over-TCP、插件及插件选项；去掉 plugin-opts.mode 错套全局运行模式的枚举；示例中的插件参数使用完整 plugin-opts 路径。 |
| `proxies/ssr.md` | 逐项说明认证、加密、混淆、协议及可选参数；仅有示例的算法不推断完整枚举。 |
| `proxies/snell.md` | 补协议版本、UDP 支持、reuse、默认指纹及混淆字段；说明 password 正文与多个示例的差异。 |
| `proxies/trojan.md` | 将正文错拼的 ss-opfs 对应到实际 YAML 的 ss-opts；分清节点密码与 AEAD 密码；network 只提供 tcp/ws/grpc。 |
| `proxies/vmess.md` | 补用户 ID、旧协议、加密与填充语义，按正文将 alterId/cipher 标为必填；传输选项补 mkcp/mekya。 |
| `proxies/vless.md` | 补 flow、UDP 编码、Encryption 和传输说明；传输选项补 xhttp，明确相关 ALPN 设置。 |
| `proxies/hysteria.md` | 将 YAML 注释中的带宽单位、port 不可省略及 fast-open 默认值明确对应；接收窗口等只给示例的参数不补猜测。 |
| `proxies/hysteria2.md` | 核对跳端口、随机间隔、带宽、gecko 限定参数、Realm 和握手超时；四项 quic-go 参数注明文档只给示例。 |
| `proxies/tuic.md` | 分清 V4 token 与 V5 uuid/password；超时和心跳用毫秒；拥塞算法纠正为 cubic/new_reno/bbr。 |
| `proxies/shadowquic.md` | 分清流/连接接收窗口、JLS、私有 Brutal 扩展、0-RTT 已知限制；拥塞算法纠正为 cubic/new_reno/bbr。 |
| `proxies/mieru.md` | 分清 port 与 port-range 互斥、多路复用、握手模式；port-range 有值时客户端不再要求 port。 |
| `proxies/ssh.md` | 解释密钥内容/路径、密钥密码、主机密钥；将 private_key_passphrase 标题对应到 YAML 的 private-key-passphrase。 |
| `proxies/sudoku.md` | 补认证、AEAD、填充率、字节布局、复用和 HTTPMask 生效条件；修正 HTTPMask 模式错套全局模式的枚举。 |
| `proxies/easytier.md` | 核对网络、身份、DHCP、入口/监听、出口、加密、MagicDNS；network-name 按正文标必填，network-secret 按敏感字段处理；不将底层 IPv6 偏好当成 overlay IPv6 支持。 |
| `proxies/tailscale.md` | 核对登录、状态、路由、出口和控制面代理；保留无覆盖路由时报错且不回退直连的条件；auth-key 按敏感字段处理。 |
| `proxies/zerotier.md` | network 改为网络 ID 文本，移除传输协议枚举；补 Moon 子字段、MTU、端口、中继和诊断说明；identity-secret 按敏感字段处理。 |
| `proxies/openvpn.md` | CA、server、port 按正文标必填；解释两种认证、三个互斥 TLS 密钥、加密协商、peer-info；密钥按敏感字段处理。 |
| `proxies/masque.md` | 客户端私钥/服务端公钥按必填处理；network 纠正为 quic/h2/h3-l4proxy；外层拥塞选项只保留文档列出的 bbr，分清内层 TCP 算法。 |
| 四种协议的 `ip-stack` 章节 | WireGuard、MASQUE、OpenVPN、ZeroTier 的 ip-stack.mode 纠正为 auto/gvisor/mips，默认 auto；不再错套 rule/global/direct。 |
| `proxies/wg.md` | 区分简化与 peers 写法、被忽略的顶层字段、保留字段的两种格式；AmneziaWG 每个参数按原注释的版本条件说明，删除“只有一个 peer”的错配文本。 |
| `proxies/trusttunnel.md` | 补认证、QUIC、复用参数冲突；未给出完整拥塞枚举，改用文本字段；health-check 注明只有示例。 |
| `proxies/rematch.md` | 对应 metadata 覆盖与子规则跳转，加入规则顺序、循环和不存在时回退条件；删除示例代理组等被误收录的帮助键。 |
| `proxies/built-in.md`、`proxy-groups/built-in.md` | 核对 DIRECT、REJECT、REJECT-DROP、PASS、PASS-RULE、COMPATIBLE、GLOBAL；区别主/子规则下的 PASS 行为。 |
| `proxy-groups/index.md`、`select.md`、`url-test.md`、`fallback.md`、`load-balance.md` | 核对现有组字段、健康检查范围和单位、过滤作用范围、默认选择和负载均衡。empty-fallback 同时解释内核默认 COMPATIBLE 与客户端写入 REJECT 的差异。 |
| `proxy-groups/relay.md` | 文档明确弃用，客户端继续不提供新增入口。 |
| `rule-providers/index.md` | 核对来源、格式、行为、更新、文件大小、请求头和内联内容；说明内核路径规则与客户端复制本地文件行为。 |
| `rules/index.md`、`sub-rule.md` | 完整域名、通配、IP、端口、进程、逻辑和子规则分别对应；IP-CIDR6 是 IP-CIDR 别名；no-resolve 不妨碍匹配已解析 IP。 |

## 保留的文档疑点与现有表单边界

以下内容无法仅凭该文档确定，说明中明确保留疑点，不以示例代替事实：

- 全局 keep-alive-idle 未明确单位；移除字段标题中未经文档确认的“秒”。
- OpenVPN 文档同时用 proto 说明传输协议、用 udp 说明 TCP/UDP，未明确二者关系。
- Snell 混淆 password 正文只写 ShadowTLS，但 Restls/JLS 示例也使用；ALPN 正文写 http1.1。
- ZeroTier orbit.seed 正文写“10 位数字”，没有明确是否接受十六进制字母。
- Hysteria 的接收窗口、Hysteria2 的 quic-go/Realm 部分选项、WireGuard AmneziaWG 多个参数、TrustTunnel health-check、WS Early Data 头名缺少完整正文说明。
- WireGuard reserved 文档支持整数列表或字符串，目前列表控件只提供列表形式；AmneziaWG h1–h4 的现有整数控件不能编辑范围。此次保留兼容的控件类型，没有新增联合类型编辑器。
- OpenVPN peer-info 在文档中是开放键值表；现有表单保留原有两个示例字段，其他键可通过额外字段填写。
- 此次核对现有字段及帮助，不承诺文档的所有新选项都有专用控件。mKCP、Mekya、XHTTP 的完整参数仍通过额外字段填写；是否可运行取决于所选内核版本及实际配置。

## 维护和验证

删除 `scripts/build-schema.rb`、`scripts/build-help.rb`。后续读取变更的文档章节和关联章节，直接维护两份 Swift 数据，避免 Markdown 结构或 YAML 示例决定字段语义。

核心测试检查全部叶字段的说明/来源对应、枚举默认值、组/规则帮助覆盖、完整路径隔离、已确认的协议选项和必填条件。测试验证静态对应与客户端行为，不能替代所选 mihomo 内核对配置的校验。

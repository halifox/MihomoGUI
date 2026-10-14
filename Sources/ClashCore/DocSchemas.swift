// Configuration fields reviewed against local Meta-Docs; maintain directly after semantic review.
import Foundation

let docSchemaJSON = #"""
{
  "sections": [
    {
      "name": "全局配置",
      "key": "general",
      "fields": [
        {
          "path": "allow-lan",
          "title": "allow-lan",
          "kind": "boolean",
          "hint": "true",
          "description": "允许其他设备通过 HTTP(S)、SOCKS 或混合代理端口访问互联网。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "bind-address",
          "title": "bind-address",
          "kind": "string",
          "hint": "*",
          "description": "代理端口的绑定地址。* 表示所有 IP；也可指定单个 IPv4 或方括号包裹的 IPv6 地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "lan-allowed-ips",
          "title": "lan-allowed-ips",
          "kind": "list",
          "hint": "[\"0.0.0.0/0\",\"::/0\"]",
          "description": "允许连接的 IP 地址段，仅在 allow-lan 开启时生效。文档默认值为 0.0.0.0/0 和 ::/0。",
          "required": false,
          "elementKind": "string",
          "document": "general.md"
        },
        {
          "path": "lan-disallowed-ips",
          "title": "lan-disallowed-ips",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "禁止连接的 IP 地址段，默认为空；黑名单优先于允许列表。",
          "required": false,
          "elementKind": "string",
          "document": "general.md"
        },
        {
          "path": "authentication",
          "title": "authentication",
          "kind": "list",
          "hint": "[\"user1:pass1\",\"user2:pass2\"]",
          "description": "HTTP(S)、SOCKS 和混合代理端口的用户名与密码列表，每项使用 user:pass 格式。",
          "required": false,
          "elementKind": "string",
          "document": "general.md"
        },
        {
          "path": "skip-auth-prefixes",
          "title": "skip-auth-prefixes",
          "kind": "list",
          "hint": "[\"127.0.0.1/8\",\"::1/128\"]",
          "description": "允许跳过代理端口用户验证的 IP 地址段。",
          "required": false,
          "elementKind": "string",
          "document": "general.md"
        },
        {
          "path": "mode",
          "title": "mode",
          "kind": "choice",
          "hint": "rule",
          "description": "运行模式：rule 按规则匹配（内核默认）；global 使用 GLOBAL 策略组选择的出口；direct 全局直连。",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ],
          "document": "general.md",
          "defaultHint": "rule"
        },
        {
          "path": "log-level",
          "title": "log-level",
          "kind": "choice",
          "hint": "info",
          "description": "内核日志级别：silent 不输出；error 错误；warning 警告及错误；info 一般运行信息及警告、错误；debug 尽可能输出所有运行信息。",
          "required": false,
          "choices": [
            "silent",
            "error",
            "warning",
            "info",
            "debug"
          ],
          "document": "general.md"
        },
        {
          "path": "ipv6",
          "title": "ipv6",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许内核接受 IPv6 流量。文档中的内核默认值为 true；客户端初始配置关闭此项。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "keep-alive-interval",
          "title": "keep-alive-interval",
          "kind": "integer",
          "hint": "15",
          "description": "TCP Keep Alive 包的发送间隔，单位为秒。文档中的 15 是示例值。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "keep-alive-idle",
          "title": "keep-alive-idle",
          "kind": "integer",
          "hint": "15",
          "description": "TCP Keep Alive 的最大空闲时间。文档未明确标注此字段的单位或默认值。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "disable-keep-alive",
          "title": "disable-keep-alive",
          "kind": "boolean",
          "hint": "false",
          "description": "禁用 TCP Keep Alive。文档注明 Android 上强制为 true。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "find-process-mode",
          "title": "find-process-mode",
          "kind": "choice",
          "hint": "strict",
          "description": "进程匹配模式：always 强制匹配所有进程；strict 由内核判断是否开启（默认）；off 不匹配进程。",
          "required": false,
          "choices": [
            "always",
            "strict",
            "off"
          ],
          "document": "general.md",
          "defaultHint": "strict"
        },
        {
          "path": "external-controller",
          "title": "external-controller",
          "kind": "string",
          "hint": "127.0.0.1:9090",
          "description": "RESTful API 监听地址，格式为 host:port。127.0.0.1 只监听本机；0.0.0.0 监听所有 IPv4 地址。客户端和统计服务使用此接口。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "external-controller-cors.allow-origins",
          "title": "external-controller-cors.allow-origins",
          "kind": "list",
          "hint": "[\"*\"]",
          "description": "API 跨域访问允许的来源列表。文档示例使用 *；示例不代表默认值。",
          "required": false,
          "elementKind": "string",
          "document": "general.md"
        },
        {
          "path": "external-controller-cors.allow-private-network",
          "title": "external-controller-cors.allow-private-network",
          "kind": "boolean",
          "hint": "true",
          "description": "API CORS 私有网络访问设置。文档仅给出示例，未声明默认值。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "external-controller-unix",
          "title": "external-controller-unix",
          "kind": "string",
          "hint": "mihomo.sock",
          "description": "Unix Socket API 的监听路径。该接口不验证 secret，需要控制文件访问权限。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "external-controller-pipe",
          "title": "external-controller-pipe",
          "kind": "string",
          "hint": "\\\\.\\pipe\\mihomo",
          "description": "Windows 命名管道 API 的监听地址，仅适用于 Windows。该接口不验证 secret。",
          "required": false,
          "unavailableReason": "仅支持 Windows",
          "document": "general.md"
        },
        {
          "path": "external-controller-tls",
          "title": "external-controller-tls",
          "kind": "string",
          "hint": "127.0.0.1:9443",
          "description": "HTTPS API 监听地址。需要配置 tls.certificate 和 tls.private-key，并同时填写 external-controller。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "external-controller-routing-mark",
          "title": "external-controller-routing-mark",
          "kind": "integer",
          "hint": "0",
          "description": "为 HTTP / HTTPS API 的监听 socket 设置路由标记，仅支持 Linux。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "general.md"
        },
        {
          "path": "external-doh-server",
          "title": "external-doh-server",
          "kind": "string",
          "hint": "/dns-query",
          "description": "在 RESTful API 端口上提供 DoH 服务的 URL 路径，例如 /dns-query。该 URL 不验证 secret。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "secret",
          "title": "secret",
          "kind": "secret",
          "hint": "",
          "description": "RESTful API 的访问密钥。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "external-ui",
          "title": "external-ui",
          "kind": "string",
          "hint": "/path/to/ui/folder",
          "description": "外部控制面板静态资源目录，通过 API 地址的 /ui 路径访问。支持绝对路径或内核工作目录的相对路径；目录外路径需加入 SAFE_PATHS。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "external-ui-name",
          "title": "external-ui-name",
          "kind": "string",
          "hint": "xd",
          "description": "外部控制面板更新时使用的子目录名。不填则直接更新到 external-ui 目录。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "external-ui-url",
          "title": "external-ui-url",
          "kind": "string",
          "hint": "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip",
          "description": "外部控制面板的下载地址。文档示例使用 GitHub Pages 分支的 ZIP 压缩包。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "profile.store-selected",
          "title": "profile.store-selected",
          "kind": "boolean",
          "hint": "true",
          "description": "保存 API 对策略组的选择，供内核下次启动使用。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "profile.store-fake-ip",
          "title": "profile.store-fake-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "保存 Fake-IP 映射表，使域名再次连接时沿用原有映射地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "unified-delay",
          "title": "unified-delay",
          "kind": "boolean",
          "hint": "true",
          "description": "测速时计算 RTT，减少连接握手等因素造成的不同类型节点延迟差异。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "tcp-concurrent",
          "title": "tcp-concurrent",
          "kind": "boolean",
          "hint": "true",
          "description": "对 DNS 解析得到的所有 IP 地址并发发起 TCP 连接，使用第一个成功的连接。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "en0",
          "description": "指定内核流量的出站网络接口，例如 en0。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "Linux 出站连接使用的默认流量标记，仅适用于 Linux。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "general.md"
        },
        {
          "path": "tls.certificate",
          "title": "tls.certificate",
          "kind": "string",
          "hint": "string",
          "description": "HTTPS API 的证书，填写 PEM 内容或证书文件路径。自 v1.19.18 起，本地文件支持自动重载。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "tls.private-key",
          "title": "tls.private-key",
          "kind": "secret",
          "hint": "string",
          "description": "HTTPS API 证书对应的私钥，填写 PEM 内容或私钥文件路径。自 v1.19.18 起，本地文件支持自动重载。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "tls.ech-key",
          "title": "tls.ech-key",
          "kind": "string",
          "hint": "-----BEGIN ECH KEYS-----\nACATwY30o/RKgD6hgeQxwrSiApLaCgU+HKh7B6SUrAHaDwBD/g0APwAAIAAgHjzK\nmadSJjYQIf9o1N5GXjkW4DEEeb17qMxHdwMdNnwADAABAAEAAQACAAEAAwAIdGVz\ndC5jb20AAA==\n-----END ECH KEYS-----",
          "description": "HTTPS API 的 ECH 密钥；填写后启用 ECH。自 v1.19.18 起，本地文件支持自动重载。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geodata-mode",
          "title": "geodata-mode",
          "kind": "boolean",
          "hint": "true",
          "description": "GEOIP 数据格式：true 使用 geoip.dat；false 使用 MMDB。文档默认值为 false。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geodata-loader",
          "title": "geodata-loader",
          "kind": "choice",
          "hint": "memconservative",
          "description": "GEO 数据加载器：standard 标准加载器；memconservative 适合内存受限设备（默认）。",
          "required": false,
          "choices": [
            "memconservative",
            "standard"
          ],
          "document": "general.md",
          "defaultHint": "memconservative"
        },
        {
          "path": "geo-auto-update",
          "title": "geo-auto-update",
          "kind": "boolean",
          "hint": "false",
          "description": "是否自动更新 GEO 数据。更新间隔由 geo-update-interval 设置；文档没有声明此开关的默认值。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geo-update-interval",
          "title": "geo-update-interval",
          "kind": "integer",
          "hint": "24",
          "description": "GEO 数据自动更新的间隔，单位为小时。文档中的 24 是示例值。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.geoip",
          "title": "geox-url.geoip",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat",
          "description": "自定义 geoip.dat 数据文件的下载地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.geosite",
          "title": "geox-url.geosite",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
          "description": "自定义 geosite.dat 域名分类数据文件的下载地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.mmdb",
          "title": "geox-url.mmdb",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb",
          "description": "自定义 MMDB 格式的 IP 地理位置数据库下载地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.asn",
          "title": "geox-url.asn",
          "kind": "string",
          "hint": "https://github.com/xishang0128/geoip/releases/download/latest/GeoLite2-ASN.mmdb",
          "description": "自定义 ASN 数据库的下载地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "global-ua",
          "title": "global-ua",
          "kind": "string",
          "hint": "clash.meta",
          "description": "下载外部资源时使用的 User-Agent，内核默认值为 clash.meta。",
          "required": false,
          "document": "general.md",
          "defaultHint": "clash.meta"
        },
        {
          "path": "etag-support",
          "title": "etag-support",
          "kind": "boolean",
          "hint": "true",
          "description": "是否支持外部资源下载的 ETag，文档默认值为 true。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "7890",
          "description": "HTTP(S) 代理监听端口。",
          "required": false,
          "document": "inbound/port.md"
        },
        {
          "path": "socks-port",
          "title": "socks-port",
          "kind": "integer",
          "hint": "7891",
          "description": "SOCKS 代理监听端口，支持 SOCKS4、SOCKS4a 和 SOCKS5。",
          "required": false,
          "document": "inbound/port.md"
        },
        {
          "path": "mixed-port",
          "title": "mixed-port",
          "kind": "integer",
          "hint": "7892",
          "description": "同时支持 HTTP(S) 和 SOCKS5 的混合代理监听端口。",
          "required": false,
          "document": "inbound/port.md"
        },
        {
          "path": "redir-port",
          "title": "redir-port",
          "kind": "integer",
          "hint": "7893",
          "description": "redirect 透明代理监听端口，只代理 TCP 流量；支持 Linux、Android 和 macOS。",
          "required": false,
          "document": "inbound/port.md"
        },
        {
          "path": "tproxy-port",
          "title": "tproxy-port",
          "kind": "integer",
          "hint": "7894",
          "description": "TPROXY 透明代理监听端口，支持 TCP 和 UDP；仅适用于 Linux / Android。",
          "required": false,
          "unavailableReason": "仅支持 Linux / Android",
          "document": "inbound/port.md"
        }
      ],
      "document": "general.md"
    },
    {
      "name": "DNS",
      "key": "dns",
      "fields": [
        {
          "path": "dns.enable",
          "title": "dns.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用内核 DNS。关闭时使用系统 DNS 解析。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.cache-algorithm",
          "title": "dns.cache-algorithm",
          "kind": "choice",
          "hint": "arc",
          "description": "DNS 缓存算法：lru 最近最少使用（默认）；arc 自适应替换缓存。",
          "required": false,
          "choices": [
            "lru",
            "arc"
          ],
          "document": "dns/index.md",
          "defaultHint": "lru"
        },
        {
          "path": "dns.prefer-h3",
          "title": "dns.prefer-h3",
          "kind": "boolean",
          "hint": "false",
          "description": "DoH 连接优先使用 HTTP/3。文档强烈不建议与 respect-rules 一起使用。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.use-hosts",
          "title": "dns.use-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否使用配置中的静态 hosts 映射，默认 true。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.use-system-hosts",
          "title": "dns.use-system-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否查询系统 hosts，默认 true。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.respect-rules",
          "title": "dns.respect-rules",
          "kind": "boolean",
          "hint": "false",
          "description": "DNS 连接遵守路由规则，需要配置 proxy-server-nameserver，避免代理节点域名解析循环。强烈不建议与 prefer-h3 一起使用。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.listen",
          "title": "dns.listen",
          "kind": "string",
          "hint": "0.0.0.0:1053",
          "description": "DNS 服务监听地址，支持 UDP 和 TCP。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.ipv6",
          "title": "dns.ipv6",
          "kind": "boolean",
          "hint": "false",
          "description": "是否解析 IPv6 地址。关闭时对 AAAA 查询返回空结果；与顶层 ipv6 接受流量的开关含义不同。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.default-nameserver",
          "title": "dns.default-nameserver",
          "kind": "list",
          "hint": "[\"223.5.5.5\"]",
          "description": "用于解析 DNS 服务器自身域名的 DNS 地址列表。服务器地址必须使用 IP，可以使用加密 DNS。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.enhanced-mode",
          "title": "dns.enhanced-mode",
          "kind": "choice",
          "hint": "fake-ip",
          "description": "DNS 处理模式，可选 fake-ip 或 redir-host；内核默认 redir-host。",
          "required": false,
          "choices": [
            "fake-ip",
            "redir-host"
          ],
          "document": "dns/index.md",
          "defaultHint": "redir-host"
        },
        {
          "path": "dns.fake-ip-range",
          "title": "dns.fake-ip-range",
          "kind": "string",
          "hint": "198.18.0.1/16",
          "description": "Fake-IP 的 IPv4 地址段，也作为 TUN 默认 IPv4 地址的参考。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-range6",
          "title": "dns.fake-ip-range6",
          "kind": "string",
          "hint": "fdfe:dcba:9876::1/64",
          "description": "Fake-IP 的 IPv6 地址段。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-filter-mode",
          "title": "dns.fake-ip-filter-mode",
          "kind": "choice",
          "hint": "rule",
          "description": "Fake-IP 过滤模式：blacklist 匹配域名返回真实 IP（默认）；whitelist 只有匹配域名才返回 Fake-IP；rule 按从上到下的规则决定 fake-ip 或 real-ip。",
          "required": false,
          "choices": [
            "blacklist",
            "whitelist",
            "rule"
          ],
          "document": "dns/index.md",
          "defaultHint": "blacklist"
        },
        {
          "path": "dns.fake-ip-filter",
          "title": "dns.fake-ip-filter",
          "kind": "list",
          "hint": "[\"RULE-SET,reject-domain,fake-ip\",\"RULE-SET,proxy-domain,fake-ip\",\"GEOSITE,gfw,fake-ip\",\"DOMAIN,www.baidu.com,real-ip\",\"DOMAIN-SUFFIX,qq.com,real-ip\",\"DOMAIN-SUFFIX,jd.com,fake-ip\",\"MATCH,fake-ip\"]",
          "description": "Fake-IP 过滤列表。blacklist / whitelist 模式支持域名通配和域名集合；rule 模式使用路由规则语法，以 fake-ip 或 real-ip 为结果，最后可用 MATCH 兜底。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-ttl",
          "title": "dns.fake-ip-ttl",
          "kind": "integer",
          "hint": "1",
          "description": "Fake-IP 查询响应的 TTL。文档未声明默认值，非必要时不建议修改。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.nameserver-policy",
          "title": "dns.nameserver-policy",
          "kind": "map",
          "hint": "{\"+.arpa\":\"10.0.0.1\",\"rule-set:cn\":[\"https://doh.pub/dns-query\",\"https://dns.alidns.com/dns-query\"]}",
          "description": "指定域名使用的 DNS 服务器，优先于 nameserver / fallback。键支持域名通配、geosite 或规则集；值支持单个服务器或列表。",
          "required": false,
          "elementKind": "list",
          "document": "dns/index.md"
        },
        {
          "path": "dns.nameserver",
          "title": "dns.nameserver",
          "kind": "list",
          "hint": "[\"https://8.8.8.8/dns-query#proxy&ecs=1.1.1.1/24&ecs-override=true\"]",
          "description": "默认的域名解析服务器列表。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback",
          "title": "dns.fallback",
          "kind": "list",
          "hint": "[\"tls://8.8.4.4\",\"tls://1.1.1.1\"]",
          "description": "后备域名解析服务器列表。配置后默认启用 fallback-filter，geoip-code 默认为 CN。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.proxy-server-nameserver",
          "title": "dns.proxy-server-nameserver",
          "kind": "list",
          "hint": "[\"https://doh.pub/dns-query\"]",
          "description": "仅用于解析代理节点域名。留空时按 nameserver-policy、nameserver 和 fallback 的配置解析。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.proxy-server-nameserver-policy",
          "title": "dns.proxy-server-nameserver-policy",
          "kind": "map",
          "hint": "{\"www.yournode.com\":\"114.114.114.114\"}",
          "description": "代理节点域名的解析策略，格式同 nameserver-policy；仅在 proxy-server-nameserver 非空时生效。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.direct-nameserver",
          "title": "dns.direct-nameserver",
          "kind": "list",
          "hint": "[\"system\"]",
          "description": "用于 direct 出口的域名解析。留空时按 nameserver-policy、nameserver 和 fallback 的配置解析。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.direct-nameserver-follow-policy",
          "title": "dns.direct-nameserver-follow-policy",
          "kind": "boolean",
          "hint": "false",
          "description": "direct-nameserver 是否遵循 nameserver-policy，默认 false；仅在 direct-nameserver 非空时生效。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback-filter.geoip",
          "title": "dns.fallback-filter.geoip",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 GEOIP 判断，用 geoip-code 指定的国家筛选 nameserver 结果。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback-filter.geoip-code",
          "title": "dns.fallback-filter.geoip-code",
          "kind": "string",
          "hint": "CN",
          "description": "国家缩写，默认 CN。该国家的解析结果直接采用；其他国家的结果视为污染，改用 fallback 结果。",
          "required": false,
          "document": "dns/index.md",
          "defaultHint": "CN"
        },
        {
          "path": "dns.fallback-filter.geosite",
          "title": "dns.fallback-filter.geosite",
          "kind": "list",
          "hint": "[\"gfw\"]",
          "description": "已弃用，建议使用 nameserver-policy。匹配这些 GEOSITE 集合的域名只使用 fallback 解析。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback-filter.ipcidr",
          "title": "dns.fallback-filter.ipcidr",
          "kind": "list",
          "hint": "[\"240.0.0.0/4\",\"0.0.0.0/32\",\"127.0.0.1/32\",\"100.64.0.0/10\"]",
          "description": "视为污染的 IP 网段列表，格式为 IP/掩码。nameserver 返回这些地址时改用 fallback 结果。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback-filter.domain",
          "title": "dns.fallback-filter.domain",
          "kind": "list",
          "hint": "[\"+.google.com\",\"+.facebook.com\",\"+.youtube.com\"]",
          "description": "只使用 fallback 解析的域名列表，不查询 nameserver。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback-lazy-query",
          "title": "dns.fallback-lazy-query",
          "kind": "boolean",
          "hint": "false",
          "description": "默认 false；开启后先检查 nameserver 结果是否满足 fallback-filter，再按需发起 fallback 查询。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "hosts",
          "title": "hosts",
          "kind": "map",
          "hint": "{\"*.clash.dev\":\"127.0.0.1\",\"alpha.clash.dev\":\"::1\",\"test.com\":[\"1.1.1.1\",\"2.2.2.2\"],\"baidu.com\":\"google.com\"}",
          "description": "静态域名映射。键支持域名通配；值支持单个 IP、IP 列表或重定向域名，重定向不支持列表。完整域名优先于通配域名。",
          "required": false,
          "elementKind": "list",
          "document": "dns/hosts.md"
        }
      ],
      "document": "dns/index.md"
    },
    {
      "name": "域名嗅探",
      "key": "sniffer",
      "fields": [
        {
          "path": "sniffer.enable",
          "title": "sniffer.enable",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用域名嗅探。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.force-dns-mapping",
          "title": "sniffer.force-dns-mapping",
          "kind": "boolean",
          "hint": "true",
          "description": "对 redir-host 类型识别的流量强制嗅探。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.parse-pure-ip",
          "title": "sniffer.parse-pure-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "对尚未获取域名的流量强制嗅探。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.override-destination",
          "title": "sniffer.override-destination",
          "kind": "boolean",
          "hint": "false",
          "description": "是否以嗅探结果作为实际访问目标，文档默认 true。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.sniff.HTTP.ports",
          "title": "sniffer.sniff.HTTP.ports",
          "kind": "list",
          "hint": "[80,\"8080-8880\"]",
          "description": "对这些端口的 HTTP 流量进行嗅探，支持单个端口或端口范围，例如 80、8080-8880。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.sniff.HTTP.override-destination",
          "title": "sniffer.sniff.HTTP.override-destination",
          "kind": "boolean",
          "hint": "true",
          "description": "HTTP 嗅探是否覆盖实际访问目标；此项覆盖 sniffer.override-destination 的全局设置。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.sniff.TLS.ports",
          "title": "sniffer.sniff.TLS.ports",
          "kind": "list",
          "hint": "[443,8443]",
          "description": "对这些端口的 TLS 流量进行嗅探，支持单个端口或端口范围。",
          "required": false,
          "elementKind": "integer",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.sniff.QUIC.ports",
          "title": "sniffer.sniff.QUIC.ports",
          "kind": "list",
          "hint": "[443,8443]",
          "description": "对这些端口的 QUIC 流量进行嗅探，支持单个端口或端口范围。",
          "required": false,
          "elementKind": "integer",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.force-domain",
          "title": "sniffer.force-domain",
          "kind": "list",
          "hint": "[\"+.v2ex.com\"]",
          "description": "强制嗅探的域名列表，支持 Clash 域名通配。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-domain",
          "title": "sniffer.skip-domain",
          "kind": "list",
          "hint": "[\"Mijia Cloud\"]",
          "description": "跳过嗅探的域名列表，支持 Clash 域名通配。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-src-address",
          "title": "sniffer.skip-src-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的来源 IP 网段列表。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-dst-address",
          "title": "sniffer.skip-dst-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的目标 IP 网段列表。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        }
      ],
      "document": "sniff/index.md"
    },
    {
      "name": "TUN",
      "key": "tun",
      "fields": [
        {
          "path": "tun.enable",
          "title": "tun.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TUN。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.stack",
          "title": "tun.stack",
          "kind": "choice",
          "hint": "mips",
          "description": "TUN 协议栈：system 使用系统栈；gvisor 使用用户空间栈；mixed 的 TCP 使用 system、UDP 使用 gvisor；mips 使用 mihomo 自研 IP 栈（默认）。",
          "required": false,
          "choices": [
            "system",
            "gvisor",
            "mixed",
            "mips"
          ],
          "document": "inbound/tun.md",
          "defaultHint": "mips"
        },
        {
          "path": "tun.auto-route",
          "title": "tun.auto-route",
          "kind": "boolean",
          "hint": "true",
          "description": "自动配置全局路由，将流量路由到 TUN 网卡。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-redirect",
          "title": "tun.auto-redirect",
          "kind": "boolean",
          "hint": "true",
          "description": "自动配置 iptables / nftables 重定向 TCP，需要启用 auto-route。文档标注仅支持 Linux，并另述 Android 仅转发本地 IPv4 的行为；macOS 不适用。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-detect-interface",
          "title": "tun.auto-detect-interface",
          "kind": "boolean",
          "hint": "true",
          "description": "自动选择流量出口接口。多网卡同时连接时，文档建议手动指定出口接口。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.dns-hijack",
          "title": "tun.dns-hijack",
          "kind": "list",
          "hint": "[\"any:53\",\"tcp://any:53\"]",
          "description": "将匹配的 DNS 连接导入内核 DNS 模块；省略协议时使用 UDP。macOS / Windows 无法自动劫持发往局域网的 DNS 请求。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.device",
          "title": "tun.device",
          "kind": "string",
          "hint": "utun0",
          "description": "TUN 网卡名称；macOS 只能使用 utun 开头的名称。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.mtu",
          "title": "tun.mtu",
          "kind": "integer",
          "hint": "9000",
          "description": "TUN 最大传输单元，会影响极限状态下的速率。文档没有声明默认值。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.strict-route",
          "title": "tun.strict-route",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 auto-route 时执行严格路由。文档具体说明 Linux 的路由限制和 Windows 的防 DNS 泄漏行为，没有单独说明 macOS 效果。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.gso",
          "title": "tun.gso",
          "kind": "boolean",
          "hint": "true",
          "description": "启用通用分段卸载，仅支持 Linux。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.gso-max-size",
          "title": "tun.gso-max-size",
          "kind": "integer",
          "hint": "65536",
          "description": "GSO 数据块的最大长度，配合 Linux 的 gso 使用。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-address",
          "title": "tun.inet6-address",
          "kind": "list",
          "hint": "[\"fdfe:dcba:9876::1/126\"]",
          "description": "TUN IPv6 地址列表，需要顶层 ipv6 为 true。启动时检测不到其他网卡 IPv6 时会禁用；文档提供 SKIP_SYSTEM_IPV6_CHECK=1 环境变量强制开启。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.udp-timeout",
          "title": "tun.udp-timeout",
          "kind": "integer",
          "hint": "300",
          "description": "UDP NAT 映射过期时间，单位为秒，默认 300（5 分钟）。",
          "required": false,
          "document": "inbound/tun.md",
          "defaultHint": "300"
        },
        {
          "path": "tun.iproute2-table-index",
          "title": "tun.iproute2-table-index",
          "kind": "integer",
          "hint": "2022",
          "description": "auto-route 创建的 Linux iproute2 路由表索引，默认 2022。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md",
          "defaultHint": "2022"
        },
        {
          "path": "tun.iproute2-rule-index",
          "title": "tun.iproute2-rule-index",
          "kind": "integer",
          "hint": "9000",
          "description": "auto-route 创建的 Linux iproute2 规则起始索引，默认 9000。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md",
          "defaultHint": "9000"
        },
        {
          "path": "tun.endpoint-independent-nat",
          "title": "tun.endpoint-independent-nat",
          "kind": "boolean",
          "hint": "false",
          "description": "启用独立于端点的 NAT，可能略微降低性能，不需要时不建议开启。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-address-set",
          "title": "tun.route-address-set",
          "kind": "list",
          "hint": "[\"ruleset-1\"]",
          "description": "将规则集中的目标 IP CIDR 加入防火墙，不匹配的流量绕过路由。仅支持 Linux，需要 nftables、auto-route 和 auto-redirect；与任何 routing-mark 配置冲突。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-exclude-address-set",
          "title": "tun.route-exclude-address-set",
          "kind": "list",
          "hint": "[\"ruleset-2\"]",
          "description": "将规则集中的目标 IP CIDR 加入防火墙，匹配的流量绕过路由。仅支持 Linux，需要 nftables、auto-route 和 auto-redirect；与任何 routing-mark 配置冲突。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-address",
          "title": "tun.route-address",
          "kind": "list",
          "hint": "[\"0.0.0.0/1\",\"128.0.0.0/1\",\"::/1\",\"8000::/1\"]",
          "description": "启用 auto-route 时仅路由指定网段，代替默认路由；一般无需配置。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-exclude-address",
          "title": "tun.route-exclude-address",
          "kind": "list",
          "hint": "[\"192.168.0.0/16\",\"fc00::/7\"]",
          "description": "启用 auto-route 时排除指定网段。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-interface",
          "title": "tun.include-interface",
          "kind": "list",
          "hint": "[\"eth0\"]",
          "description": "只路由指定接口的流量，默认不限制；与 exclude-interface 互斥。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-interface",
          "title": "tun.exclude-interface",
          "kind": "list",
          "hint": "[\"eth1\"]",
          "description": "排除指定接口的流量；与 include-interface 互斥。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-uid",
          "title": "tun.include-uid",
          "kind": "list",
          "hint": "[0]",
          "description": "仅路由指定用户 ID 的流量，默认不限制。UID 规则仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-uid-range",
          "title": "tun.include-uid-range",
          "kind": "list",
          "hint": "[\"1000:9999\"]",
          "description": "仅路由指定用户 ID 范围的流量。仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-uid",
          "title": "tun.exclude-uid",
          "kind": "list",
          "hint": "[1000]",
          "description": "排除指定用户 ID 的流量。仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-uid-range",
          "title": "tun.exclude-uid-range",
          "kind": "list",
          "hint": "[\"1000:9999\"]",
          "description": "排除指定用户 ID 范围的流量。仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-mac-address",
          "title": "tun.include-mac-address",
          "kind": "list",
          "hint": "[\"00:11:22:33:44:55\"]",
          "description": "按来源 MAC 地址只路由指定局域网设备的流量。仅支持 Linux，需要 auto-route 和 auto-redirect。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-mac-address",
          "title": "tun.exclude-mac-address",
          "kind": "list",
          "hint": "[\"00:11:22:33:44:66\"]",
          "description": "按来源 MAC 地址排除指定局域网设备的流量。仅支持 Linux，需要 auto-route 和 auto-redirect。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-android-user",
          "title": "tun.include-android-user",
          "kind": "list",
          "hint": "[0,10]",
          "description": "仅路由指定 Android 用户的流量，需要 auto-route。常见用户 ID：机主 0、分身 10、应用多开 999。",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Android",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-package",
          "title": "tun.include-package",
          "kind": "list",
          "hint": "[\"com.android.chrome\"]",
          "description": "仅路由指定 Android 应用包名的流量，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Android",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-package",
          "title": "tun.exclude-package",
          "kind": "list",
          "hint": "[\"com.android.captiveportallogin\"]",
          "description": "排除指定 Android 应用包名的流量，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Android",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet4-route-address",
          "title": "tun.inet4-route-address",
          "kind": "list",
          "hint": "[\"0.0.0.0/1\",\"128.0.0.0/1\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时路由指定 IPv4 网段；建议改用 route-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-route-address",
          "title": "tun.inet6-route-address",
          "kind": "list",
          "hint": "[\"::/1\",\"8000::/1\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时路由指定 IPv6 网段；建议改用 route-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet4-route-exclude-address",
          "title": "tun.inet4-route-exclude-address",
          "kind": "list",
          "hint": "[\"192.168.0.0/16\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时排除指定 IPv4 网段；建议改用 route-exclude-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-route-exclude-address",
          "title": "tun.inet6-route-exclude-address",
          "kind": "list",
          "hint": "[\"fc00::/7\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时排除指定 IPv6 网段；建议改用 route-exclude-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.congestion-controller",
          "title": "tun.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法：cubic、reno、bbr 或 bbr3，默认 cubic；仅在 mips 协议栈下生效。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ],
          "document": "inbound/tun.md",
          "defaultHint": "cubic"
        }
      ],
      "document": "inbound/tun.md"
    }
  ],
  "proxies": [
    {
      "name": "anytls",
      "key": "anytls",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "anytls",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "1.2.3.4",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "<your password>",
          "description": "AnyTLS 服务器的认证密码，必填。",
          "required": true,
          "document": "proxies/anytls.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 uTLS 指纹。通用 TLS 文档列出 VMess、VLESS、Trojan、AnyTLS；其他协议是否适用须看各自文档。random 按 Cloudflare Radar 分布生成现代浏览器指纹。",
          "required": false,
          "choices": [
            "chrome",
            "firefox",
            "safari",
            "ios",
            "android",
            "edge",
            "360",
            "qq",
            "random"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "client-metadata",
          "title": "client-metadata",
          "kind": "string",
          "hint": "",
          "description": "发送给服务端的客户端元数据，可选。自 v1.19.30 起默认不发送，需要时自行填写。",
          "required": false,
          "document": "proxies/anytls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "Base64 编码的 ECH 配置。为空时通过 DNS 获取，非空时使用所填配置。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 ECH（Encrypted Client Hello）。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "通过 DNS 获取 ECH 配置时使用的域名，可选。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "idle-session-check-interval",
          "title": "idle-session-check-interval",
          "kind": "integer",
          "hint": "30",
          "description": "检查空闲会话的间隔，单位秒，默认 30。",
          "required": false,
          "document": "proxies/anytls.md",
          "defaultHint": "30"
        },
        {
          "path": "idle-session-timeout",
          "title": "idle-session-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "检查时关闭闲置时间超过此值的会话，单位秒，默认 30。",
          "required": false,
          "document": "proxies/anytls.md",
          "defaultHint": "30"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "min-idle-session",
          "title": "min-idle-session",
          "kind": "integer",
          "hint": "0",
          "description": "检查时至少保留的空闲会话数量，默认 0。",
          "required": false,
          "document": "proxies/anytls.md",
          "defaultHint": "0"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "Restls 的 TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "ShadowTLS 版本，支持 1、2、3，默认 2。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md",
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/anytls.md"
    },
    {
      "name": "direct",
      "key": "direct",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "direct",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "1234",
          "description": "节点连接附加的路由标记；全局配置及相关组网文档将此功能限定为 Linux。",
          "required": false,
          "document": "proxies/index.md",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/direct.md"
    },
    {
      "name": "dns",
      "key": "dns",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "dns-out",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/dns.md"
    },
    {
      "name": "easytier",
      "key": "easytier",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "easytier",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "accept-dns",
          "title": "accept-dns",
          "kind": "boolean",
          "hint": "false",
          "description": "是否接受网络下发的 DNS 配置。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "dhcp",
          "title": "dhcp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否通过 DHCP 获取 overlay IPv4；ipv4 留空时默认开启，否则默认关闭。未获取到时实例没有 overlay IPv4。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "承载 EasyTier 网络通信的其他出站代理名称。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "disable-kcp-input",
          "title": "disable-kcp-input",
          "kind": "boolean",
          "hint": "false",
          "description": "是否禁用 KCP 输入，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "disable-p2p",
          "title": "disable-p2p",
          "kind": "boolean",
          "hint": "false",
          "description": "是否禁用 P2P、只通过中继通信，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "disable-quic-input",
          "title": "disable-quic-input",
          "kind": "boolean",
          "hint": "false",
          "description": "是否禁用 QUIC 输入，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "enable-encryption",
          "title": "enable-encryption",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用节点间加密，默认 true。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "enable-exit-node",
          "title": "enable-exit-node",
          "kind": "boolean",
          "hint": "false",
          "description": "是否作为其他节点的出口节点，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "enable-kcp-proxy",
          "title": "enable-kcp-proxy",
          "kind": "boolean",
          "hint": "false",
          "description": "是否通过 KCP 转发 TCP 流量，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "enable-quic-proxy",
          "title": "enable-quic-proxy",
          "kind": "boolean",
          "hint": "false",
          "description": "是否通过 QUIC 转发 TCP 流量，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "encryption-algorithm",
          "title": "encryption-algorithm",
          "kind": "string",
          "hint": "aes-gcm",
          "description": "加密算法，默认 aes-gcm。",
          "required": false,
          "document": "proxies/easytier.md",
          "defaultHint": "aes-gcm"
        },
        {
          "path": "exit-nodes",
          "title": "exit-nodes",
          "kind": "list",
          "hint": "[\"10.144.0.1\"]",
          "description": "出口节点的 overlay IPv4 地址列表，用于转发流量出网。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/easytier.md"
        },
        {
          "path": "hostname",
          "title": "hostname",
          "kind": "string",
          "hint": "mihomo",
          "description": "本机 overlay 主机名，用于 MagicDNS；留空时由 EasyTier 处理。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "instance-name",
          "title": "instance-name",
          "kind": "string",
          "hint": "mihomo-easytier",
          "description": "实例名称，默认使用代理名称。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "WLAN",
          "description": "EasyTier 使用的网络接口名称。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4-prefer",
          "description": "底层 peer 连接的 IP 版本偏好；不启用 overlay IPv6。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/easytier.md"
        },
        {
          "path": "ipv4",
          "title": "ipv4",
          "kind": "string",
          "hint": "10.144.0.1/24",
          "description": "本机 overlay IPv4 地址，使用 CIDR 格式，例如 10.144.0.1/24。overlay 网络只支持 IPv4。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "latency-first",
          "title": "latency-first",
          "kind": "boolean",
          "hint": "false",
          "description": "优先选择最低延迟而非最少跳数的路径，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "listeners",
          "title": "listeners",
          "kind": "list",
          "hint": "[\"tcp://0.0.0.0:11010\"]",
          "description": "接受其他节点连接的监听 URI 列表，例如 tcp://0.0.0.0:11010。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/easytier.md"
        },
        {
          "path": "local-private-key",
          "title": "local-private-key",
          "kind": "secret",
          "hint": "base64-x25519-private-key",
          "description": "本机 Base64 编码的 X25519 私钥，用于固定身份。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "local-public-key",
          "title": "local-public-key",
          "kind": "string",
          "hint": "base64-x25519-public-key",
          "description": "本机 Base64 编码的 X25519 公钥，必须与 local-private-key 一起配置。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "mapped-listeners",
          "title": "mapped-listeners",
          "kind": "list",
          "hint": "[\"tcp://203.0.113.10:11010\"]",
          "description": "对外公告的映射监听 URI 列表，适用于端口映射。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/easytier.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1380",
          "description": "MTU 覆盖值，默认 1380。",
          "required": false,
          "document": "proxies/easytier.md",
          "defaultHint": "1380"
        },
        {
          "path": "network-name",
          "title": "network-name",
          "kind": "string",
          "hint": "example",
          "description": "EasyTier 网络名称，必填。",
          "required": true,
          "document": "proxies/easytier.md"
        },
        {
          "path": "network-secret",
          "title": "network-secret",
          "kind": "secret",
          "hint": "secret",
          "description": "EasyTier 网络密钥，可选；名称和密钥相同的节点属于同一虚拟网络。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "no-listener",
          "title": "no-listener",
          "kind": "boolean",
          "hint": "true",
          "description": "是否禁用监听，默认 true；不能与 listeners 同时启用。显式 false 且 listeners 为空时监听 tcp://0.0.0.0:11010。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "peers",
          "title": "peers",
          "kind": "list",
          "hint": "[\"tcp://192.0.2.10:11010\",\"udp://192.0.2.11:11010\"]",
          "description": "初始入口节点 URI 列表，支持 tcp://、udp:// 等。不会默认连接 public.easytier.top；listeners 为空时至少配置一个 peer。URI 可附加 peer-public-key 锁定对端公钥。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/easytier.md"
        },
        {
          "path": "private-mode",
          "title": "private-mode",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用隐私模式，默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "proxy-networks",
          "title": "proxy-networks",
          "kind": "list",
          "hint": "[\"10.0.0.0/24\"]",
          "description": "通过 EasyTier 网络访问的远端子网 CIDR 列表。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/easytier.md"
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "Linux 路由标记，仅适用于 Linux。",
          "required": false,
          "document": "proxies/easytier.md",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "secure-mode",
          "title": "secure-mode",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 Noise 端到端加密。设置 local-private-key、local-public-key 或 peer URI 的 peer-public-key 时自动启用。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "state-dir",
          "title": "state-dir",
          "kind": "string",
          "hint": "./easytier",
          "description": "保存 instance_id 的状态目录，默认 easytier/<代理名称>。",
          "required": false,
          "document": "proxies/easytier.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tld-dns-zone",
          "title": "tld-dns-zone",
          "kind": "string",
          "hint": "et.net.",
          "description": "MagicDNS 的 TLD DNS 区域，默认 et.net.。DNS 配置可用 et://<代理名称> 解析 overlay A / PTR 记录。",
          "required": false,
          "document": "proxies/easytier.md",
          "defaultHint": "et.net."
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 UDP，协议文档默认 false。",
          "required": false,
          "document": "proxies/easytier.md"
        }
      ],
      "document": "proxies/easytier.md"
    },
    {
      "name": "http",
      "key": "http",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "http",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "Base64 编码的 ECH 配置。为空时通过 DNS 获取，非空时使用所填配置。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 ECH（Encrypted Client Hello）。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "通过 DNS 获取 ECH 配置时使用的域名，可选。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "headers",
          "title": "headers",
          "kind": "map",
          "hint": "{}",
          "description": "HTTP 代理的自定义请求头。文档只列出 headers 字段，没有给出默认值。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/http.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "dual",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "HTTP 代理的认证密码；文档示例中为可选字段。",
          "required": false,
          "document": "proxies/http.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "Restls 的 TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "ShadowTLS 版本，支持 1、2、3，默认 2。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md",
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "custom.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TLS；仅用于支持 TLS 的协议。Trojan 强制启用 TLS。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "HTTP 代理的认证用户名；文档示例中为可选字段。",
          "required": false,
          "document": "proxies/http.md"
        }
      ],
      "document": "proxies/http.md"
    },
    {
      "name": "hysteria",
      "key": "hysteria",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "hysteria",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server.com",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "auth-str",
          "title": "auth-str",
          "kind": "secret",
          "hint": "yourpassword",
          "description": "Hysteria 认证密码。文档通过 YAML 示例说明此字段。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "disable_mtu_discovery",
          "title": "disable_mtu_discovery",
          "kind": "boolean",
          "hint": "false",
          "description": "Hysteria 的 MTU 探测开关。文档仅列出示例，未声明默认值。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "down",
          "title": "down",
          "kind": "string",
          "hint": "200 Mbps",
          "description": "Hysteria 下载带宽，省略单位时按 Mbps 处理。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "fast-open",
          "title": "fast-open",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 Fast Open，以降低建立连接的延迟；示例注释明确默认 false。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "obfs",
          "title": "obfs",
          "kind": "string",
          "hint": "obfs_str",
          "description": "Hysteria 流量混淆字符串。文档仅给出示例，没有解释其他约束。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "ports",
          "title": "ports",
          "kind": "string",
          "hint": "1000,2000-3000,4000",
          "description": "Hysteria 端口跳跃列表，示例格式为 1000,2000-3000,4000；配置此项时 port 仍不可省略。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "protocol",
          "title": "protocol",
          "kind": "string",
          "hint": "udp",
          "description": "Hysteria 传输协议，示例注释列出 udp、wechat-video 和 faketcp。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "recv-window",
          "title": "recv-window",
          "kind": "integer",
          "hint": "52428800",
          "description": "Hysteria 接收窗口参数。文档仅列出示例，未明确范围、单位或默认值。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "recv-window-conn",
          "title": "recv-window-conn",
          "kind": "integer",
          "hint": "12582912",
          "description": "Hysteria 接收窗口参数。文档仅列出示例，未明确范围、单位或默认值。",
          "required": false,
          "document": "proxies/hysteria.md"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "false",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "server.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "up",
          "title": "up",
          "kind": "string",
          "hint": "30 Mbps",
          "description": "Hysteria 上传带宽，省略单位时按 Mbps 处理。",
          "required": false,
          "document": "proxies/hysteria.md"
        }
      ],
      "document": "proxies/hysteria.md"
    },
    {
      "name": "hysteria2",
      "key": "hysteria2",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "hysteria2",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server.com",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "yourpassword",
          "description": "Hysteria2 认证密码，必填。",
          "required": true,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "BBR 配置，可选 standard、conservative 或 aggressive。示例注释声明默认 standard。",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ],
          "document": "proxies/hysteria2.md",
          "defaultHint": "standard"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "down",
          "title": "down",
          "kind": "string",
          "hint": "200 Mbps",
          "description": "Brutal 下载速率，省略单位时按 Mbps 处理。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "handshake-timeout",
          "title": "handshake-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "握手超时，单位秒；设置后不受外层连接超时影响。默认 0，表示只使用外层连接超时。",
          "required": false,
          "document": "proxies/hysteria2.md",
          "defaultHint": "0"
        },
        {
          "path": "hop-interval",
          "title": "hop-interval",
          "kind": "string",
          "hint": "30",
          "description": "端口跳跃间隔，单位秒，默认 30。也可填写单个范围，例如 15-30，每次随机选择；不允许用逗号列出多个范围。",
          "required": false,
          "document": "proxies/hysteria2.md",
          "defaultHint": "30"
        },
        {
          "path": "initial-connection-receive-window",
          "title": "initial-connection-receive-window",
          "kind": "integer",
          "hint": "20971520",
          "description": "quic-go 的初始连接接收窗口参数。文档只列出示例，并提示不要随意修改，未声明默认值。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "initial-stream-receive-window",
          "title": "initial-stream-receive-window",
          "kind": "integer",
          "hint": "8388608",
          "description": "quic-go 的初始流接收窗口参数。文档只列出示例，并提示不要随意修改，未声明默认值。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "max-connection-receive-window",
          "title": "max-connection-receive-window",
          "kind": "integer",
          "hint": "20971520",
          "description": "quic-go 的最大连接接收窗口参数。文档只列出示例，并提示不要随意修改，未声明默认值。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "max-stream-receive-window",
          "title": "max-stream-receive-window",
          "kind": "integer",
          "hint": "8388608",
          "description": "quic-go 的最大流接收窗口参数。文档只列出示例，并提示不要随意修改，未声明默认值。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "obfs",
          "title": "obfs",
          "kind": "choice",
          "hint": "salamander",
          "description": "QUIC 流量混淆器，可选 salamander 或 gecko；为空时禁用。",
          "required": false,
          "choices": [
            "salamander",
            "gecko"
          ],
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "obfs-max-packet-size",
          "title": "obfs-max-packet-size",
          "kind": "integer",
          "hint": "1200",
          "description": "最大线上数据包大小，单位字节，仅 gecko 混淆器适用。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "obfs-min-packet-size",
          "title": "obfs-min-packet-size",
          "kind": "integer",
          "hint": "512",
          "description": "最小线上数据包大小，单位字节，仅 gecko 混淆器适用。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "obfs-password",
          "title": "obfs-password",
          "kind": "secret",
          "hint": "yourpassword",
          "description": "QUIC 混淆器的密码，启用混淆时填写。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "ports",
          "title": "ports",
          "kind": "string",
          "hint": "443-8443",
          "description": "配置后启用端口跳跃并忽略 port，支持端口和端口范围。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "realm-opts.enable",
          "title": "realm-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 Realm。文档示例注明必须手动开启。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "realm-opts.realm-id",
          "title": "realm-opts.realm-id",
          "kind": "string",
          "hint": "my-cabin-1f3a8c2e9b",
          "description": "Realm 标识。文档仅给出示例，没有说明其他约束。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "realm-opts.server-url",
          "title": "realm-opts.server-url",
          "kind": "string",
          "hint": "https://realm.hy2.io",
          "description": "Realm 服务地址。文档仅给出示例，没有声明默认地址。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "realm-opts.stun-servers",
          "title": "realm-opts.stun-servers",
          "kind": "list",
          "hint": "[\"stun.nextcloud.com:3478\",\"stun.sip.us:3478\",\"global.stun.twilio.com:3478\"]",
          "description": "Realm 使用的 STUN 服务器地址列表。文档中的地址仅为示例。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "realm-opts.token",
          "title": "realm-opts.token",
          "kind": "secret",
          "hint": "public",
          "description": "Realm 令牌。文档中的 public 是示例值，不是默认值。",
          "required": false,
          "document": "proxies/hysteria2.md"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "false",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "server.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "up",
          "title": "up",
          "kind": "string",
          "hint": "30 Mbps",
          "description": "Brutal 上传速率，省略单位时按 Mbps 处理。",
          "required": false,
          "document": "proxies/hysteria2.md"
        }
      ],
      "document": "proxies/hysteria2.md"
    },
    {
      "name": "masque",
      "key": "masque",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "masque-h2",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server.com",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "BBR 配置，可选 standard、conservative 或 aggressive。示例注释声明默认 standard。",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ],
          "document": "proxies/masque.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "bbr",
          "description": "修改外层连接的拥塞控制算法，默认不启用；文档列出 bbr。",
          "required": false,
          "choices": [
            "bbr"
          ],
          "document": "proxies/masque.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"1.1.1.1\",\"8.8.8.8\"]",
          "description": "远程 DNS 地址列表，仅 remote-dns-resolve 开启时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/masque.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "handshake-timeout",
          "title": "handshake-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "握手超时，单位秒，默认 0，表示只使用外层连接超时。",
          "required": false,
          "document": "proxies/masque.md",
          "defaultHint": "0"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip",
          "title": "ip",
          "kind": "string",
          "hint": "172.16.0.2/32",
          "description": "本地 IPv4 地址，使用 CIDR 格式，例如 172.16.0.2/32。",
          "required": false,
          "document": "proxies/masque.md"
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "内层 TCP 拥塞控制算法，可选 cubic、reno、bbr 或 bbr3，默认 cubic；gvisor 协议栈下不生效。与外层 QUIC 的 congestion-controller 含义不同。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ],
          "document": "proxies/masque.md",
          "defaultHint": "cubic"
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "IP 协议栈，可选 auto、gvisor 或 mips，默认 auto。auto 始终使用 mihomo 的 MIPS；gvisor 需要内核以 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "auto",
            "gvisor",
            "mips"
          ],
          "document": "proxies/masque.md",
          "defaultHint": "auto"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "ipv6",
          "title": "ipv6",
          "kind": "string",
          "hint": "fd00::2/128",
          "description": "本地 IPv6 地址，使用 CIDR 格式，例如 fd00::2/128。",
          "required": false,
          "document": "proxies/masque.md"
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1280",
          "description": "TUN 最大传输单元，默认 1280。",
          "required": false,
          "document": "proxies/masque.md",
          "defaultHint": "1280"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "h2",
          "description": "MASQUE 传输模式：quic（默认）、h2 或 h3-l4proxy。h3-l4proxy 目前不支持 UDP。",
          "required": false,
          "choices": [
            "quic",
            "h2",
            "h3-l4proxy"
          ],
          "document": "proxies/masque.md",
          "defaultHint": "quic"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "BASE64_ENCODED_PRIVATE_KEY",
          "description": "Base64 编码的 ECDSA 客户端私钥，必填。",
          "required": true,
          "document": "proxies/masque.md"
        },
        {
          "path": "public-key",
          "title": "public-key",
          "kind": "string",
          "hint": "BASE64_ENCODED_PUBLIC_KEY",
          "description": "Base64 编码的 ECDSA 服务端公钥，必填；去掉 PEM 头尾标识和换行。",
          "required": true,
          "document": "proxies/masque.md"
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "是否通过 MASQUE 隧道进行远程 DNS 解析。",
          "required": false,
          "document": "proxies/masque.md"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TLS；仅用于支持 TLS 的协议。Trojan 强制启用 TLS。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否支持 UDP，协议文档默认 false。h3-l4proxy 模式目前不支持 UDP。",
          "required": false,
          "document": "proxies/masque.md"
        }
      ],
      "document": "proxies/masque.md"
    },
    {
      "name": "mieru",
      "key": "mieru",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "mieru",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "2999",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "Mieru 认证密码，文档通过 YAML 示例给出。",
          "required": true,
          "document": "proxies/mieru.md"
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "user",
          "description": "Mieru 认证用户名，文档通过 YAML 示例给出。",
          "required": true,
          "document": "proxies/mieru.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "handshake-mode",
          "title": "handshake-mode",
          "kind": "string",
          "hint": "HANDSHAKE_STANDARD",
          "description": "握手模式：HANDSHAKE_STANDARD 等待握手完成（默认）；HANDSHAKE_NO_WAIT 使用 0-RTT。",
          "required": false,
          "document": "proxies/mieru.md",
          "defaultHint": "HANDSHAKE_STANDARD"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "multiplexing",
          "title": "multiplexing",
          "kind": "string",
          "hint": "MULTIPLEXING_LOW",
          "description": "多路复用级别，可选 MULTIPLEXING_OFF、MULTIPLEXING_LOW、MULTIPLEXING_MIDDLE、MULTIPLEXING_HIGH；默认 MULTIPLEXING_LOW，OFF 关闭复用。",
          "required": false,
          "document": "proxies/mieru.md",
          "defaultHint": "MULTIPLEXING_LOW"
        },
        {
          "path": "port-range",
          "title": "port-range",
          "kind": "string",
          "hint": "2090-2099",
          "description": "服务器端口范围，与 port 互斥。",
          "required": false,
          "document": "proxies/mieru.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "traffic-pattern",
          "title": "traffic-pattern",
          "kind": "string",
          "hint": "",
          "description": "调整网络行为的 Base64 字符串，格式参见 Mieru 的 traffic-pattern 文档。",
          "required": false,
          "document": "proxies/mieru.md"
        },
        {
          "path": "transport",
          "title": "transport",
          "kind": "choice",
          "hint": "TCP",
          "description": "Mieru 传输协议，可选 TCP 或 UDP。",
          "required": false,
          "choices": [
            "TCP",
            "UDP"
          ],
          "document": "proxies/mieru.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/mieru.md"
    },
    {
      "name": "openvpn",
      "key": "openvpn",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "openvpn",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "vpn.example.com",
          "description": "OpenVPN 服务器地址，必填。",
          "required": true,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "1194",
          "description": "OpenVPN 服务器端口，文档默认 1194。",
          "required": true,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "auth",
          "title": "auth",
          "kind": "string",
          "hint": "SHA256",
          "description": "数据验证算法，支持 MD5、SHA1、SHA256、SHA384、SHA512，默认 SHA256；AEAD 加密算法忽略此项。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "SHA256"
        },
        {
          "path": "ca",
          "title": "ca",
          "kind": "string",
          "hint": "-----BEGIN CERTIFICATE-----\nMIIB...example\n-----END CERTIFICATE-----\n",
          "description": "CA 证书内容，必填；从 .ovpn 的 <ca> 标签中复制。",
          "required": true,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "cert",
          "title": "cert",
          "kind": "string",
          "hint": "",
          "description": "客户端证书内容，从 .ovpn 的 <cert> 标签中复制；使用用户名 / 密码认证时可省略。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "string",
          "hint": "AES-128-GCM",
          "description": "加密方式，支持 AES-128-GCM、AES-256-GCM、AES-128-CBC、AES-256-CBC、CHACHA20-POLY1305，默认 AES-128-GCM；AES-CBC 按 AES-128-CBC 处理。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "AES-128-GCM"
        },
        {
          "path": "comp-lzo",
          "title": "comp-lzo",
          "kind": "string",
          "hint": "no",
          "description": "数据压缩方式，可选 yes、no 或 adaptive。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "data-ciphers",
          "title": "data-ciphers",
          "kind": "list",
          "hint": "[\"AES-256-GCM\",\"AES-128-GCM\"]",
          "description": "数据通道加密算法协商列表，发送到服务端的 IV_CIPHERS；与服务端列表取交集，使用第一个匹配项。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/openvpn.md"
        },
        {
          "path": "data-ciphers-fallback",
          "title": "data-ciphers-fallback",
          "kind": "string",
          "hint": "AES-128-CBC",
          "description": "加密算法协商失败时的回退算法，对应 --data-ciphers-fallback。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "dev",
          "title": "dev",
          "kind": "string",
          "hint": "tun",
          "description": "虚拟网卡类型，目前仅支持 tun，默认 tun。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "tun"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "承载 OpenVPN 连接的其他出站代理名称。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"1.1.1.1\",\"8.8.8.8\"]",
          "description": "远程 DNS 地址列表，仅 remote-dns-resolve 为 true 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/openvpn.md"
        },
        {
          "path": "handshake-timeout",
          "title": "handshake-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "握手超时，单位秒，默认 0，仅使用外层连接超时。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "0"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "内层 TCP 拥塞控制算法，可选 cubic、reno、bbr 或 bbr3，默认 cubic；gvisor 协议栈下不生效。与外层 QUIC 的 congestion-controller 含义不同。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ],
          "document": "proxies/openvpn.md",
          "defaultHint": "cubic"
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "IP 协议栈，可选 auto、gvisor 或 mips，默认 auto。auto 始终使用 mihomo 的 MIPS；gvisor 需要内核以 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "auto",
            "gvisor",
            "mips"
          ],
          "document": "proxies/openvpn.md",
          "defaultHint": "auto"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "key",
          "title": "key",
          "kind": "secret",
          "hint": "",
          "description": "客户端私钥内容，从 .ovpn 的 <key> 标签中复制；使用用户名 / 密码认证时可省略。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "key-direction",
          "title": "key-direction",
          "kind": "string",
          "hint": "1",
          "description": "tls-auth 密钥方向，可选字符串 0 或 1；不填或空字符串使用双向模式。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1500",
          "description": "最大传输单元，默认 1500。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "1500"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "pass",
          "description": "auth-user-pass 认证密码；与 username 一起配置，或改用 cert / key 证书认证，两种方式不能同时为空。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "peer-info.IV_HWADDR",
          "title": "peer-info.IV_HWADDR",
          "kind": "string",
          "hint": "52:54:00:ff:72:87",
          "description": "自定义 peer-info 的 IV_HWADDR 条目。文档只有示例，未声明默认值或固定条目集合。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "peer-info.UV_DEVICE_ID",
          "title": "peer-info.UV_DEVICE_ID",
          "kind": "string",
          "hint": "laptop-001",
          "description": "自定义 peer-info 的 UV_DEVICE_ID 条目。文档只有示例，未声明默认值或固定条目集合。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "ping",
          "title": "ping",
          "kind": "integer",
          "hint": "10",
          "description": "OpenVPN ping 选项，文档默认 0；未明确解释单位和行为。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "0"
        },
        {
          "path": "ping-restart",
          "title": "ping-restart",
          "kind": "integer",
          "hint": "60",
          "description": "OpenVPN ping-restart 选项，文档默认 0；未明确解释单位和行为。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "0"
        },
        {
          "path": "proto",
          "title": "proto",
          "kind": "string",
          "hint": "udp",
          "description": "OpenVPN 传输协议，可选 udp 或 tcp，默认 udp。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "udp"
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "是否强制远程 DNS 解析，默认 false。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tls-auth",
          "title": "tls-auth",
          "kind": "secret",
          "hint": "",
          "description": "从 .ovpn 的 <tls-auth> 标签复制静态密钥；与 tls-crypt、tls-crypt-v2 互斥。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "tls-crypt",
          "title": "tls-crypt",
          "kind": "secret",
          "hint": "",
          "description": "从 .ovpn 的 <tls-crypt> 标签复制 TLS 加密密钥内容，不保留标签；与 tls-auth、tls-crypt-v2 互斥。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "tls-crypt-v2",
          "title": "tls-crypt-v2",
          "kind": "secret",
          "hint": "",
          "description": "从 .ovpn 的 <tls-crypt-v2> 标签复制客户端密钥内容，不保留标签；与 tls-auth、tls-crypt 互斥。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "tran-window",
          "title": "tran-window",
          "kind": "integer",
          "hint": "3600",
          "description": "rekey 后旧 data key 保留时间，单位秒，默认 3600；0 立即过期，应与服务端 --tran-window 一致。",
          "required": false,
          "document": "proxies/openvpn.md",
          "defaultHint": "3600"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "协议文档将 true 解释为使用 UDP、false 解释为使用 TCP；同时另列 proto 传输协议，二者关系未明确，需通过内核配置校验确认。",
          "required": false,
          "document": "proxies/openvpn.md"
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "user",
          "description": "auth-user-pass 认证用户名；与 password 一起配置，或改用 cert / key 证书认证，两种方式不能同时为空。",
          "required": false,
          "document": "proxies/openvpn.md"
        }
      ],
      "document": "proxies/openvpn.md"
    },
    {
      "name": "rematch",
      "key": "rematch",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "use-ai-rules",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "target-rematch-name",
          "title": "target-rematch-name",
          "kind": "string",
          "hint": "streaming",
          "description": "覆盖 metadata 的 rematch-name，可用 REMATCH-NAME 规则匹配；该规则应放在触发 rematch 的规则之前，避免循环。",
          "required": false,
          "document": "proxies/rematch.md"
        },
        {
          "path": "target-sub-rule",
          "title": "target-sub-rule",
          "kind": "string",
          "hint": "ai-rules",
          "description": "后续直接使用指定子规则集匹配；名称不存在或为空时回退到主 rules。建议为子规则配置 MATCH 兜底。",
          "required": false,
          "document": "proxies/rematch.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/rematch.md"
    },
    {
      "name": "shadowquic",
      "key": "shadowquic",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "shadowquic",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "www.example.com",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "10443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "ShadowQUIC 认证密码，必填。ShadowQUIC 强制启用 JLS，无需单独配置 jls-opts。",
          "required": true,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "ShadowQUIC 认证用户名，必填。",
          "required": true,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "应用层协议协商列表，默认使用 h3。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "standard",
          "description": "BBR 算法的激进程度，可选 standard、conservative 或 aggressive；仅在 congestion-controller 为 bbr 时生效。",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ],
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "拥塞控制算法，可选 cubic、new_reno 或 bbr，默认 cubic。",
          "required": false,
          "choices": [
            "cubic",
            "new_reno",
            "bbr"
          ],
          "document": "proxies/shadowquic.md",
          "defaultHint": "cubic"
        },
        {
          "path": "cwnd",
          "title": "cwnd",
          "kind": "integer",
          "hint": "32",
          "description": "初始拥塞窗口大小，默认 32。",
          "required": false,
          "document": "proxies/shadowquic.md",
          "defaultHint": "32"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "disable-mtu-discovery",
          "title": "disable-mtu-discovery",
          "kind": "boolean",
          "hint": "false",
          "description": "是否禁用路径 MTU 发现，开启后使用固定 MTU。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "down",
          "title": "down",
          "kind": "string",
          "hint": "100 Mbps",
          "description": "请求的下载速率，受服务端 Listener 的 up 限制；通过 mihomo 私有扩展协商 Brutal，对端不支持时回退到 congestion-controller。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "keep-alive-interval",
          "title": "keep-alive-interval",
          "kind": "integer",
          "hint": "10000",
          "description": "保持连接活动的心跳间隔，单位毫秒。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "max-datagram-frame-size",
          "title": "max-datagram-frame-size",
          "kind": "integer",
          "hint": "1400",
          "description": "最大数据报帧大小，单位字节，默认 1400。",
          "required": false,
          "document": "proxies/shadowquic.md",
          "defaultHint": "1400"
        },
        {
          "path": "max-open-streams",
          "title": "max-open-streams",
          "kind": "integer",
          "hint": "1024",
          "description": "最大同时打开的并发流数，默认 1024。",
          "required": false,
          "document": "proxies/shadowquic.md",
          "defaultHint": "1024"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "quic-versions",
          "title": "quic-versions",
          "kind": "list",
          "hint": "[\"v1\"]",
          "description": "支持的 QUIC 版本列表，可选 v1、v2，默认 v1。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "recv-window",
          "title": "recv-window",
          "kind": "integer",
          "hint": "0",
          "description": "连接级接收窗口大小；0 使用内部默认值。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "recv-window-conn",
          "title": "recv-window-conn",
          "kind": "integer",
          "hint": "0",
          "description": "单个流的接收窗口大小；0 使用内部默认值。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "ShadowQUIC TLS 握手使用的 SNI，可选。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp-over-stream",
          "title": "udp-over-stream",
          "kind": "boolean",
          "hint": "false",
          "description": "是否通过数据流传输 UDP，默认 false。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "up",
          "title": "up",
          "kind": "string",
          "hint": "100 Mbps",
          "description": "上传速率；配置后通过 mihomo 私有扩展协商 Brutal，对端不支持时回退到 congestion-controller。",
          "required": false,
          "document": "proxies/shadowquic.md"
        },
        {
          "path": "zero-rtt",
          "title": "zero-rtt",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 0-RTT。文档指出官方 server 的该路径存在认证前读取用户状态的问题（已确认影响 v0.3.11）；遇到不通或断联时在服务端关闭 zero-rtt。",
          "required": false,
          "document": "proxies/shadowquic.md"
        }
      ],
      "document": "proxies/shadowquic.md"
    },
    {
      "name": "snell",
      "key": "snell",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "snell-jls",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "44046",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "psk",
          "title": "psk",
          "kind": "secret",
          "hint": "yourpsk",
          "description": "Snell 预共享密钥，必填。",
          "required": true,
          "document": "proxies/snell.md"
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "Snell 客户端指纹，可选，默认 chrome。",
          "required": false,
          "choices": [
            "chrome",
            "firefox",
            "safari",
            "ios",
            "android",
            "edge",
            "360",
            "qq",
            "random"
          ],
          "document": "proxies/snell.md",
          "defaultHint": "chrome"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "obfs-opts.alpn",
          "title": "obfs-opts.alpn",
          "kind": "list",
          "hint": "[\"h2\"]",
          "description": "ShadowTLS 的 ALPN 列表。正文写 h2 和 http1.1，仅 shadow-tls 模式使用；具体值需与服务端核对。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/snell.md"
        },
        {
          "path": "obfs-opts.host",
          "title": "obfs-opts.host",
          "kind": "string",
          "hint": "bing.com",
          "description": "Snell 混淆使用的域名。",
          "required": false,
          "document": "proxies/snell.md"
        },
        {
          "path": "obfs-opts.mode",
          "title": "obfs-opts.mode",
          "kind": "choice",
          "hint": "jls",
          "description": "Snell 混淆模式，支持 http、tls、shadow-tls、restls 或 jls。",
          "required": false,
          "choices": [
            "http",
            "tls",
            "shadow-tls",
            "restls",
            "jls"
          ],
          "document": "proxies/snell.md"
        },
        {
          "path": "obfs-opts.password",
          "title": "obfs-opts.password",
          "kind": "secret",
          "hint": "jls_password",
          "description": "混淆认证密码。标题正文只说明 ShadowTLS，但 YAML 示例同时用于 Restls 和 JLS；按所选模式与服务端保持一致。",
          "required": false,
          "document": "proxies/snell.md"
        },
        {
          "path": "obfs-opts.username",
          "title": "obfs-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名，仅 jls 模式使用。",
          "required": false,
          "document": "proxies/snell.md"
        },
        {
          "path": "obfs-opts.version",
          "title": "obfs-opts.version",
          "kind": "integer",
          "hint": "2",
          "description": "ShadowTLS 版本，可选 1、2、3，仅 shadow-tls 模式使用。",
          "required": false,
          "document": "proxies/snell.md"
        },
        {
          "path": "obfs-opts.version-hint",
          "title": "obfs-opts.version-hint",
          "kind": "string",
          "hint": "tls13",
          "description": "Restls TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "document": "proxies/snell.md"
        },
        {
          "path": "reuse",
          "title": "reuse",
          "kind": "boolean",
          "hint": "false",
          "description": "Snell 复用选项，仅版本 4、5 支持，默认 false。",
          "required": false,
          "document": "proxies/snell.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "version",
          "title": "version",
          "kind": "integer",
          "hint": "4",
          "description": "Snell 协议版本，支持 1、2、3、4、5；仅 3、4、5 支持 UDP。文档未声明默认版本。",
          "required": false,
          "document": "proxies/snell.md"
        }
      ],
      "document": "proxies/snell.md"
    },
    {
      "name": "socks5",
      "key": "socks5",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "socks",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "Base64 编码的 ECH 配置。为空时通过 DNS 获取，非空时使用所填配置。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 ECH（Encrypted Client Hello）。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "通过 DNS 获取 ECH 配置时使用的域名，可选。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv6",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "SOCKS5 代理的认证密码；文档示例中为可选字段。",
          "required": false,
          "document": "proxies/socks.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "Restls 的 TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "ShadowTLS 版本，支持 1、2、3，默认 2。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md",
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TLS；仅用于支持 TLS 的协议。Trojan 强制启用 TLS。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "SOCKS5 代理的认证用户名；文档示例中为可选字段。",
          "required": false,
          "document": "proxies/socks.md"
        }
      ],
      "document": "proxies/socks.md"
    },
    {
      "name": "ss",
      "key": "ss",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "ss1",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "string",
          "hint": "aes-128-gcm",
          "description": "Shadowsocks 加密方法，需与服务端一致。文档列出 AES、CHACHA、2022 Blake3、LEA 等算法；没有声明默认方法。",
          "required": true,
          "document": "proxies/ss.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "Shadowsocks 密码，必填。",
          "required": true,
          "document": "proxies/ss.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "plugin",
          "title": "plugin",
          "kind": "string",
          "hint": "obfs",
          "description": "Shadowsocks 插件，可选 obfs、v2ray-plugin、gost-plugin、shadow-tls、restls、kcptun 或 jls。",
          "required": false,
          "document": "proxies/ss.md"
        },
        {
          "path": "plugin-opts.mode",
          "title": "plugin-opts.mode",
          "kind": "string",
          "hint": "tls",
          "description": "插件模式随 plugin 改变：obfs 示例为 tls；v2ray-plugin / gost-plugin 示例为 websocket；kcptun 使用 fast3、fast2、fast、normal 或 manual 等预设。文档未声明统一默认值。",
          "required": false,
          "document": "proxies/ss.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp-over-tcp",
          "title": "udp-over-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 UDP over TCP，默认 false。",
          "required": false,
          "document": "proxies/ss.md"
        },
        {
          "path": "udp-over-tcp-version",
          "title": "udp-over-tcp-version",
          "kind": "integer",
          "hint": "2",
          "description": "UDP over TCP 协议版本，可选 1 或 2，默认 1。",
          "required": false,
          "document": "proxies/ss.md",
          "defaultHint": "1"
        }
      ],
      "document": "proxies/ss.md"
    },
    {
      "name": "ssh",
      "key": "ssh",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "ssh-out",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "127.0.0.1",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "22",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "root",
          "description": "SSH 登录用户名。",
          "required": true,
          "document": "proxies/ssh.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "host-key",
          "title": "host-key",
          "kind": "list",
          "hint": "[\"ssh-rsa AAAAB3NzaC1yc2EAA...\"]",
          "description": "允许的 SSH 主机密钥列表；留空时接受所有主机密钥。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/ssh.md"
        },
        {
          "path": "host-key-algorithms",
          "title": "host-key-algorithms",
          "kind": "list",
          "hint": "[\"rsa\"]",
          "description": "SSH 主机密钥算法列表。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/ssh.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "SSH 登录密码。",
          "required": false,
          "document": "proxies/ssh.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "key",
          "description": "SSH 私钥内容或文件路径。",
          "required": false,
          "document": "proxies/ssh.md"
        },
        {
          "path": "private-key-passphrase",
          "title": "private-key-passphrase",
          "kind": "secret",
          "hint": "key_password",
          "description": "SSH 私钥密码。",
          "required": false,
          "document": "proxies/ssh.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/ssh.md"
    },
    {
      "name": "ssr",
      "key": "ssr",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "ssr",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "string",
          "hint": "chacha20-ietf",
          "description": "ShadowsocksR 加密方法，需与服务端一致；文档只给出示例，没有列出完整选项或默认值。",
          "required": true,
          "document": "proxies/ssr.md"
        },
        {
          "path": "obfs",
          "title": "obfs",
          "kind": "string",
          "hint": "tls1.2_ticket_auth",
          "description": "ShadowsocksR 混淆方式，需与服务端一致；文档示例为 tls1.2_ticket_auth。",
          "required": true,
          "document": "proxies/ssr.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "ShadowsocksR 认证密码。",
          "required": true,
          "document": "proxies/ssr.md"
        },
        {
          "path": "protocol",
          "title": "protocol",
          "kind": "string",
          "hint": "auth_sha1_v4",
          "description": "ShadowsocksR 协议，需与服务端一致；文档示例为 auth_sha1_v4。",
          "required": true,
          "document": "proxies/ssr.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "obfs-param",
          "title": "obfs-param",
          "kind": "string",
          "hint": "domain.tld",
          "description": "ShadowsocksR 混淆参数，文档通过可选 YAML 字段给出。",
          "required": false,
          "document": "proxies/ssr.md"
        },
        {
          "path": "protocol-param",
          "title": "protocol-param",
          "kind": "string",
          "hint": "#",
          "description": "ShadowsocksR 协议参数，文档通过可选 YAML 字段给出。",
          "required": false,
          "document": "proxies/ssr.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/ssr.md"
    },
    {
      "name": "sudoku",
      "key": "sudoku",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "sudoku",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "1.2.3.4",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "aead-method",
          "title": "aead-method",
          "kind": "string",
          "hint": "chacha20-poly1305",
          "description": "AEAD 方法，可选 chacha20-poly1305、aes-128-gcm 或 none；none 不提供 AEAD 保护，文档不建议使用。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "custom-table",
          "title": "custom-table",
          "kind": "string",
          "hint": "xpxvvpvv",
          "description": "自定义字节布局，必须包含 2 个 x、2 个 p、4 个 v，仅作用于 entropy 方向。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "custom-tables",
          "title": "custom-tables",
          "kind": "list",
          "hint": "[\"xpxvvpvv\",\"vxpvxvvp\"]",
          "description": "自定义字节布局列表，非空时覆盖 custom-table。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/sudoku.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "enable-pure-downlink",
          "title": "enable-pure-downlink",
          "kind": "boolean",
          "hint": "false",
          "description": "下行模式：false 为带宽优化下行，true 为纯 Sudoku 下行；必须与服务端一致。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "httpmask.disable",
          "title": "httpmask.disable",
          "kind": "boolean",
          "hint": "false",
          "description": "是否禁用全部 HTTP 伪装和隧道。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "httpmask.host",
          "title": "httpmask.host",
          "kind": "string",
          "hint": "",
          "description": "覆盖 Host / SNI，可填写域名或域名:端口；仅 stream / poll / auto / ws 模式生效。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "httpmask.mode",
          "title": "httpmask.mode",
          "kind": "choice",
          "hint": "legacy",
          "description": "HTTPMask 模式：legacy（默认）、stream、poll、auto、ws；stream / poll / auto / ws 支持 CDN 和反向代理。",
          "required": false,
          "choices": [
            "legacy",
            "stream",
            "poll",
            "auto",
            "ws"
          ],
          "document": "proxies/sudoku.md",
          "defaultHint": "legacy"
        },
        {
          "path": "httpmask.multiplex",
          "title": "httpmask.multiplex",
          "kind": "string",
          "hint": "off",
          "description": "兼容旧配置的复用选项；设置后优先于顶层 multiplex。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "httpmask.path-root",
          "title": "httpmask.path-root",
          "kind": "string",
          "hint": "",
          "description": "HTTP 隧道端点的一级路径前缀，需与服务端一致。例如 aabbcc 对应 /aabbcc/session 等路径。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "httpmask.tls",
          "title": "httpmask.tls",
          "kind": "boolean",
          "hint": "true",
          "description": "仅 stream / poll / auto / ws 模式生效。true 强制 HTTPS，false 强制 HTTP，不按端口自动推断。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "key",
          "title": "key",
          "kind": "secret",
          "hint": "<client_key>",
          "description": "Sudoku 认证密钥。使用 Sudoku 生成的 ED25519 密钥对时填写私钥，否则填写与服务端一致的 UUID。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "multiplex",
          "title": "multiplex",
          "kind": "string",
          "hint": "off",
          "description": "多路复用模式：off 关闭（默认）；auto 仅复用 HTTPMask 底层连接；on 在原始 TCP 或 HTTPMask 上启用 Sudoku 单会话多目标复用。",
          "required": false,
          "document": "proxies/sudoku.md",
          "defaultHint": "off"
        },
        {
          "path": "padding-max",
          "title": "padding-max",
          "kind": "integer",
          "hint": "7",
          "description": "最大填充率，范围 0–100，且不得小于 padding-min。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "padding-min",
          "title": "padding-min",
          "kind": "integer",
          "hint": "2",
          "description": "最小填充率，范围 0–100。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "table-type",
          "title": "table-type",
          "kind": "string",
          "hint": "prefer_ascii",
          "description": "字节表类型，可选 prefer_ascii、prefer_entropy、up_ascii_down_entropy 或 up_entropy_down_ascii。",
          "required": false,
          "document": "proxies/sudoku.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/sudoku.md"
    },
    {
      "name": "tailscale",
      "key": "tailscale",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "tailscale",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "accept-routes",
          "title": "accept-routes",
          "kind": "boolean",
          "hint": "true",
          "description": "是否接受 Tailnet 发布的子网路由。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "auth-key",
          "title": "auth-key",
          "kind": "secret",
          "hint": "tskey-auth-xxxx",
          "description": "Tailscale / Headscale 登录密钥。留空时首次启动在内核日志中输出交互登录 URL。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "control-url",
          "title": "control-url",
          "kind": "string",
          "hint": "https://controlplane.tailscale.com",
          "description": "自定义 Tailscale 控制服务器或 Headscale 地址。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "承载 Tailscale 控制面和 DERP / STUN 等连接的其他出站代理名称。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "ephemeral",
          "title": "ephemeral",
          "kind": "boolean",
          "hint": "false",
          "description": "是否以临时节点登录，默认 false。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "exit-node",
          "title": "exit-node",
          "kind": "string",
          "hint": "100.64.0.1",
          "description": "出口节点 IP 或 auto:any。目标不在 Tailscale 路由内时连接报错，不回退直连；访问公网需要可用出口节点或覆盖目标的子网路由。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "exit-node-allow-lan-access",
          "title": "exit-node-allow-lan-access",
          "kind": "boolean",
          "hint": "true",
          "description": "使用出口节点时是否允许访问本地局域网。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "hostname",
          "title": "hostname",
          "kind": "string",
          "hint": "mihomo",
          "description": "Tailscale 设备名，留空时由 tsnet 处理。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "WLAN",
          "description": "指定出站网卡。",
          "required": false,
          "document": "proxies/tailscale.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4-prefer",
          "description": "底层出站连接的 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/tailscale.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "Linux 的 fwmark，仅适用于 Linux。",
          "required": false,
          "document": "proxies/tailscale.md",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "state-dir",
          "title": "state-dir",
          "kind": "string",
          "hint": "./tailscale",
          "description": "tsnet 状态目录，默认 tailscale。",
          "required": false,
          "document": "proxies/tailscale.md",
          "defaultHint": "tailscale"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 UDP，协议文档默认 false。",
          "required": false,
          "document": "proxies/tailscale.md"
        }
      ],
      "document": "proxies/tailscale.md"
    },
    {
      "name": "trojan",
      "key": "trojan",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "trojan",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "yourpsk",
          "description": "Trojan 服务器密码，必填。",
          "required": true,
          "document": "proxies/trojan.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "random",
          "description": "客户端 uTLS 指纹。通用 TLS 文档列出 VMess、VLESS、Trojan、AnyTLS；其他协议是否适用须看各自文档。random 按 Cloudflare Radar 分布生成现代浏览器指纹。",
          "required": false,
          "choices": [
            "chrome",
            "firefox",
            "safari",
            "ios",
            "android",
            "edge",
            "360",
            "qq",
            "random"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "Base64 编码的 ECH 配置。为空时通过 DNS 获取，非空时使用所填配置。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 ECH（Encrypted Client Hello）。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "通过 DNS 获取 ECH 配置时使用的域名，可选。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "grpc-opts.grpc-service-name",
          "title": "grpc-opts.grpc-service-name",
          "kind": "string",
          "hint": "example",
          "description": "gRPC 服务名称，仅在 network 为 grpc 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.grpc-user-agent",
          "title": "grpc-opts.grpc-user-agent",
          "kind": "string",
          "hint": "",
          "description": "gRPC 请求的 User-Agent，仅在 network 为 grpc 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.max-connections",
          "title": "grpc-opts.max-connections",
          "kind": "integer",
          "hint": "1",
          "description": "gRPC 最大底层连接数，默认 1；与 grpc-opts.max-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md",
          "defaultHint": "1"
        },
        {
          "path": "grpc-opts.max-streams",
          "title": "grpc-opts.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 建立新连接前的最大复用流数；与 grpc-opts.max-connections、grpc-opts.min-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.min-streams",
          "title": "grpc-opts.min-streams",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 建立新连接前的最小复用流数；与 grpc-opts.max-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.ping-interval",
          "title": "grpc-opts.ping-interval",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 心跳间隔，单位秒，默认关闭。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "h2-opts.host",
          "title": "h2-opts.host",
          "kind": "list",
          "hint": "[\"example.com\"]",
          "description": "H2 传输层主机域名列表；设置后客户端随机选择，服务器验证。仅在 network 为 h2 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "h2-opts.path",
          "title": "h2-opts.path",
          "kind": "string",
          "hint": "/",
          "description": "H2 传输层请求路径，仅在 network 为 h2 时生效。mihomo 的 H2 传输未实现多路复用，需要时可选 gRPC 或 sing-mux。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.headers",
          "title": "http-opts.headers",
          "kind": "map",
          "hint": "{\"Connection\":[\"keep-alive\"]}",
          "description": "HTTP 传输层的请求头，可为每个头填写值列表，仅在 network 为 http 时生效。",
          "required": false,
          "elementKind": "list",
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.method",
          "title": "http-opts.method",
          "kind": "string",
          "hint": "GET",
          "description": "HTTP 传输层的请求方法，仅在 network 为 http 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.path",
          "title": "http-opts.path",
          "kind": "list",
          "hint": "[\"/\",\"/video\"]",
          "description": "HTTP 传输层的请求路径列表，仅在 network 为 http 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "tcp",
          "description": "Trojan 传输层，支持 tcp、ws、grpc；未设置时使用 tcp。",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "grpc"
          ],
          "document": "proxies/trojan.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.public-key",
          "title": "reality-opts.public-key",
          "kind": "string",
          "hint": "xxxx",
          "description": "Reality 服务端私钥对应的公钥；配置 Reality 时填写。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.short-id",
          "title": "reality-opts.short-id",
          "kind": "string",
          "hint": "xxxx",
          "description": "服务端允许的 Short ID 之一。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.support-x25519mlkem768",
          "title": "reality-opts.support-x25519mlkem768",
          "kind": "boolean",
          "hint": "true",
          "description": "是否支持 X25519-MLKEM768 密钥交换。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "Restls 的 TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "ShadowTLS 版本，支持 1、2、3，默认 2。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md",
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ss-opts.enabled",
          "title": "ss-opts.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 trojan-go 的 Shadowsocks AEAD 加密。",
          "required": false,
          "document": "proxies/trojan.md"
        },
        {
          "path": "ss-opts.method",
          "title": "ss-opts.method",
          "kind": "string",
          "hint": "aes-128-gcm",
          "description": "trojan-go 的 Shadowsocks AEAD 算法，可选 aes-128-gcm、aes-256-gcm 或 chacha20-ietf-poly1305。",
          "required": false,
          "document": "proxies/trojan.md"
        },
        {
          "path": "ss-opts.password",
          "title": "ss-opts.password",
          "kind": "secret",
          "hint": "example",
          "description": "trojan-go 的 Shadowsocks AEAD 加密密码，与节点 password 含义不同。",
          "required": false,
          "document": "proxies/trojan.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ws-opts.early-data-header-name",
          "title": "ws-opts.early-data-header-name",
          "kind": "string",
          "hint": "",
          "description": "WebSocket Early Data 的头名称。文档仅列出字段，未解释具体行为或默认值。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.headers",
          "title": "ws-opts.headers",
          "kind": "map",
          "hint": "{\"Host\":\"example.com\"}",
          "description": "WebSocket 请求头，仅在 network 为 ws 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.max-early-data",
          "title": "ws-opts.max-early-data",
          "kind": "string",
          "hint": "",
          "description": "WebSocket Early Data 首包长度阈值。文档未声明默认值或单位。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.path",
          "title": "ws-opts.path",
          "kind": "string",
          "hint": "/path",
          "description": "WebSocket 请求路径，仅在 network 为 ws 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.v2ray-http-upgrade",
          "title": "ws-opts.v2ray-http-upgrade",
          "kind": "boolean",
          "hint": "false",
          "description": "是否使用 HTTP Upgrade，仅在 WebSocket 传输设置中生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.v2ray-http-upgrade-fast-open",
          "title": "ws-opts.v2ray-http-upgrade-fast-open",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 HTTP Upgrade 的 Fast Open。",
          "required": false,
          "document": "proxies/transport.md"
        }
      ],
      "document": "proxies/trojan.md"
    },
    {
      "name": "trusttunnel",
      "key": "trusttunnel",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "trusttunnel",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "1.2.3.4",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "TrustTunnel 认证密码，文档通过 YAML 示例给出。",
          "required": true,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "TrustTunnel 认证用户名，文档通过 YAML 示例给出。",
          "required": true,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "BBR 配置，可选 standard、conservative 或 aggressive。示例注释声明默认 standard。",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ],
          "document": "proxies/trusttunnel.md",
          "defaultHint": "standard"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 uTLS 指纹。通用 TLS 文档列出 VMess、VLESS、Trojan、AnyTLS；其他协议是否适用须看各自文档。random 按 Cloudflare Radar 分布生成现代浏览器指纹。",
          "required": false,
          "choices": [
            "chrome",
            "firefox",
            "safari",
            "ios",
            "android",
            "edge",
            "360",
            "qq",
            "random"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "string",
          "hint": "bbr",
          "description": "QUIC 拥塞控制算法。文档正文未列出完整选项；示例使用 bbr，不应套用 TUN 的算法列表。",
          "required": false,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "Base64 编码的 ECH 配置。为空时通过 DNS 获取，非空时使用所填配置。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 ECH（Encrypted Client Hello）。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "通过 DNS 获取 ECH 配置时使用的域名，可选。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "health-check",
          "title": "health-check",
          "kind": "boolean",
          "hint": "true",
          "description": "健康检查选项。文档仅给出 true 示例，没有解释具体行为或默认值。",
          "required": false,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "max-connections",
          "title": "max-connections",
          "kind": "integer",
          "hint": "8",
          "description": "最大连接数，与 max-streams 互斥。",
          "required": false,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "max-streams",
          "title": "max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 max-connections、min-streams 互斥。",
          "required": false,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "min-streams",
          "title": "min-streams",
          "kind": "integer",
          "hint": "5",
          "description": "建立新连接前，每条连接的最小复用流数量；与 max-streams 互斥。",
          "required": false,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "quic",
          "title": "quic",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 QUIC，默认 false。",
          "required": false,
          "document": "proxies/trusttunnel.md"
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "Restls 的 TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "ShadowTLS 版本，支持 1、2、3，默认 2。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md",
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/trusttunnel.md"
    },
    {
      "name": "tuic",
      "key": "tuic",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "tuic",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "www.example.com",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "10443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "BBR 配置，可选 standard、conservative 或 aggressive。示例注释声明默认 standard。",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ],
          "document": "proxies/tuic.md",
          "defaultHint": "standard"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "bbr",
          "description": "TUIC 拥塞控制算法，可选 cubic、new_reno 或 bbr。文档未声明默认值。",
          "required": false,
          "choices": [
            "cubic",
            "new_reno",
            "bbr"
          ],
          "document": "proxies/tuic.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "disable-sni",
          "title": "disable-sni",
          "kind": "boolean",
          "hint": "true",
          "description": "是否在 TLS 握手中禁用 SNI。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "fast-open",
          "title": "fast-open",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 Fast Open，减少连接建立时间。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "heartbeat-interval",
          "title": "heartbeat-interval",
          "kind": "integer",
          "hint": "10000",
          "description": "保持连接活动的心跳间隔，单位毫秒。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip",
          "title": "ip",
          "kind": "string",
          "hint": "127.0.0.1",
          "description": "覆盖 server 域名的 DNS 解析结果，使用指定 IP 连接。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "max-open-streams",
          "title": "max-open-streams",
          "kind": "integer",
          "hint": "20",
          "description": "最大打开流数量；过多的流可能影响性能。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "max-udp-relay-packet-size",
          "title": "max-udp-relay-packet-size",
          "kind": "integer",
          "hint": "1500",
          "description": "最大 UDP 中继数据包大小，单位字节。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "PASSWORD_1",
          "description": "TUIC V5 的认证密码，V5 必填。TUIC V4 不可填写此项。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reduce-rtt",
          "title": "reduce-rtt",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 QUIC 0-RTT 握手，可降低连接建立延迟，也可能增加重放风险。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "request-timeout",
          "title": "request-timeout",
          "kind": "integer",
          "hint": "8000",
          "description": "建立 TUIC 代理连接的超时，单位毫秒。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "TLS 服务器名称指示（SNI）；留空时使用 server。VMess / VLESS 使用 servername 字段。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "token",
          "title": "token",
          "kind": "secret",
          "hint": "TOKEN",
          "description": "TUIC V4 的认证标识，V4 必填。TUIC V5 不可填写此项。",
          "required": false,
          "document": "proxies/tuic.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "udp-relay-mode",
          "title": "udp-relay-mode",
          "kind": "choice",
          "hint": "native",
          "description": "UDP 中继模式，可选 native 或 quic。",
          "required": false,
          "choices": [
            "native",
            "quic"
          ],
          "document": "proxies/tuic.md"
        },
        {
          "path": "uuid",
          "title": "uuid",
          "kind": "string",
          "hint": "00000000-0000-0000-0000-000000000001",
          "description": "TUIC V5 的用户 UUID，V5 必填。TUIC V4 不可填写此项。",
          "required": false,
          "document": "proxies/tuic.md"
        }
      ],
      "document": "proxies/tuic.md"
    },
    {
      "name": "vless",
      "key": "vless",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "vless",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "uuid",
          "title": "uuid",
          "kind": "string",
          "hint": "uuid",
          "description": "VLESS 用户 UUID，必填。",
          "required": true,
          "document": "proxies/vless.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 uTLS 指纹。通用 TLS 文档列出 VMess、VLESS、Trojan、AnyTLS；其他协议是否适用须看各自文档。random 按 Cloudflare Radar 分布生成现代浏览器指纹。",
          "required": false,
          "choices": [
            "chrome",
            "firefox",
            "safari",
            "ios",
            "android",
            "edge",
            "360",
            "qq",
            "random"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "Base64 编码的 ECH 配置。为空时通过 DNS 获取，非空时使用所填配置。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 ECH（Encrypted Client Hello）。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "通过 DNS 获取 ECH 配置时使用的域名，可选。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "encryption",
          "title": "encryption",
          "kind": "string",
          "hint": "",
          "description": "VLESS Encryption 客户端配置字符串，需按服务端参数填写；其中算法、模式、填充和 Base64 密钥按文档组合，不可直接照抄括号占位内容。",
          "required": false,
          "document": "proxies/vless.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "flow",
          "title": "flow",
          "kind": "string",
          "hint": "xtls-rprx-vision",
          "description": "VLESS 子协议，可选 xtls-rprx-vision。mihomo 的 xtls 流控不自动拦截 UDP 443，需要时另加路由规则。",
          "required": false,
          "document": "proxies/vless.md"
        },
        {
          "path": "grpc-opts.grpc-service-name",
          "title": "grpc-opts.grpc-service-name",
          "kind": "string",
          "hint": "example",
          "description": "gRPC 服务名称，仅在 network 为 grpc 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.grpc-user-agent",
          "title": "grpc-opts.grpc-user-agent",
          "kind": "string",
          "hint": "",
          "description": "gRPC 请求的 User-Agent，仅在 network 为 grpc 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.max-connections",
          "title": "grpc-opts.max-connections",
          "kind": "integer",
          "hint": "1",
          "description": "gRPC 最大底层连接数，默认 1；与 grpc-opts.max-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md",
          "defaultHint": "1"
        },
        {
          "path": "grpc-opts.max-streams",
          "title": "grpc-opts.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 建立新连接前的最大复用流数；与 grpc-opts.max-connections、grpc-opts.min-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.min-streams",
          "title": "grpc-opts.min-streams",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 建立新连接前的最小复用流数；与 grpc-opts.max-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.ping-interval",
          "title": "grpc-opts.ping-interval",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 心跳间隔，单位秒，默认关闭。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "h2-opts.host",
          "title": "h2-opts.host",
          "kind": "list",
          "hint": "[\"example.com\"]",
          "description": "H2 传输层主机域名列表；设置后客户端随机选择，服务器验证。仅在 network 为 h2 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "h2-opts.path",
          "title": "h2-opts.path",
          "kind": "string",
          "hint": "/",
          "description": "H2 传输层请求路径，仅在 network 为 h2 时生效。mihomo 的 H2 传输未实现多路复用，需要时可选 gRPC 或 sing-mux。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.headers",
          "title": "http-opts.headers",
          "kind": "map",
          "hint": "{\"Connection\":[\"keep-alive\"]}",
          "description": "HTTP 传输层的请求头，可为每个头填写值列表，仅在 network 为 http 时生效。",
          "required": false,
          "elementKind": "list",
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.method",
          "title": "http-opts.method",
          "kind": "string",
          "hint": "GET",
          "description": "HTTP 传输层的请求方法，仅在 network 为 http 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.path",
          "title": "http-opts.path",
          "kind": "list",
          "hint": "[\"/\",\"/video\"]",
          "description": "HTTP 传输层的请求路径列表，仅在 network 为 http 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "tcp",
          "description": "VLESS 传输层，支持 tcp、ws、http、h2、grpc、xhttp；未设置时使用 tcp。xhttp 默认使用 H2，H3 / HTTP/1.1 需配套设置 alpn；新传输参数可通过额外字段填写。",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "http",
            "h2",
            "grpc",
            "xhttp"
          ],
          "document": "proxies/vless.md"
        },
        {
          "path": "packet-encoding",
          "title": "packet-encoding",
          "kind": "choice",
          "hint": "xudp",
          "description": "UDP 包编码，可选 packetaddr（v2ray 5+）或 xudp（xray）；留空使用原始编码。",
          "required": false,
          "choices": [
            "xudp",
            "packetaddr"
          ],
          "document": "proxies/vless.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.public-key",
          "title": "reality-opts.public-key",
          "kind": "string",
          "hint": "xxxx",
          "description": "Reality 服务端私钥对应的公钥；配置 Reality 时填写。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.short-id",
          "title": "reality-opts.short-id",
          "kind": "string",
          "hint": "xxxx",
          "description": "服务端允许的 Short ID 之一。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.support-x25519mlkem768",
          "title": "reality-opts.support-x25519mlkem768",
          "kind": "boolean",
          "hint": "true",
          "description": "是否支持 X25519-MLKEM768 密钥交换。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "Restls 的 TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "servername",
          "title": "servername",
          "kind": "string",
          "hint": "example.com",
          "description": "VMess / VLESS 的 TLS 服务器名称指示（SNI）；留空时使用 server。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "ShadowTLS 版本，支持 1、2、3，默认 2。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md",
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TLS；仅用于支持 TLS 的协议。Trojan 强制启用 TLS。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ws-opts.early-data-header-name",
          "title": "ws-opts.early-data-header-name",
          "kind": "string",
          "hint": "",
          "description": "WebSocket Early Data 的头名称。文档仅列出字段，未解释具体行为或默认值。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.headers",
          "title": "ws-opts.headers",
          "kind": "map",
          "hint": "{\"Host\":\"example.com\"}",
          "description": "WebSocket 请求头，仅在 network 为 ws 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.max-early-data",
          "title": "ws-opts.max-early-data",
          "kind": "string",
          "hint": "",
          "description": "WebSocket Early Data 首包长度阈值。文档未声明默认值或单位。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.path",
          "title": "ws-opts.path",
          "kind": "string",
          "hint": "/path",
          "description": "WebSocket 请求路径，仅在 network 为 ws 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.v2ray-http-upgrade",
          "title": "ws-opts.v2ray-http-upgrade",
          "kind": "boolean",
          "hint": "false",
          "description": "是否使用 HTTP Upgrade，仅在 WebSocket 传输设置中生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.v2ray-http-upgrade-fast-open",
          "title": "ws-opts.v2ray-http-upgrade-fast-open",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 HTTP Upgrade 的 Fast Open。",
          "required": false,
          "document": "proxies/transport.md"
        }
      ],
      "document": "proxies/vless.md"
    },
    {
      "name": "vmess",
      "key": "vmess",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "vmess",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "代理服务器的域名或 IP 地址。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "代理服务器端口。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "uuid",
          "title": "uuid",
          "kind": "string",
          "hint": "uuid",
          "description": "VMess 用户 UUID，必填。",
          "required": true,
          "document": "proxies/vmess.md"
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "应用层协议协商列表，按优先顺序排列；双方没有共同支持的协议时连接失败。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/tls.md"
        },
        {
          "path": "alterId",
          "title": "alterId",
          "kind": "integer",
          "hint": "0",
          "description": "VMess 用户的 alterId，文档标为必填；非 0 时启用旧协议。示例 0 不代表文档声明的默认值。",
          "required": true,
          "document": "proxies/vmess.md"
        },
        {
          "path": "authenticated-length",
          "title": "authenticated-length",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用协议长度块加密。",
          "required": false,
          "document": "proxies/vmess.md"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "mTLS 客户端证书，填写 PEM 内容或文件路径；必须同时填写 private-key。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "choice",
          "hint": "auto",
          "description": "VMess 加密方法，文档标为必填；支持 auto、none、zero、aes-128-gcm 或 chacha20-poly1305。",
          "required": true,
          "choices": [
            "auto",
            "aes-128-gcm",
            "chacha20-poly1305",
            "none",
            "zero"
          ],
          "document": "proxies/vmess.md"
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 uTLS 指纹。通用 TLS 文档列出 VMess、VLESS、Trojan、AnyTLS；其他协议是否适用须看各自文档。random 按 Cloudflare Radar 分布生成现代浏览器指纹。",
          "required": false,
          "choices": [
            "chrome",
            "firefox",
            "safari",
            "ios",
            "android",
            "edge",
            "360",
            "qq",
            "random"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "Base64 编码的 ECH 配置。为空时通过 DNS 获取，非空时使用所填配置。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 ECH（Encrypted Client Hello）。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "通过 DNS 获取 ECH 配置时使用的域名，可选。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "完整证书的 SHA-256 指纹，不是公钥指纹。叶子证书指纹只核对该证书；中间或根证书指纹核对签发链，自 v1.19.20 起还需符合 SNI / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "global-padding",
          "title": "global-padding",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用协议随机填充，会消耗额外流量；文档注明 v2ray 默认启用且无法禁用。",
          "required": false,
          "document": "proxies/vmess.md"
        },
        {
          "path": "grpc-opts.grpc-service-name",
          "title": "grpc-opts.grpc-service-name",
          "kind": "string",
          "hint": "example",
          "description": "gRPC 服务名称，仅在 network 为 grpc 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.grpc-user-agent",
          "title": "grpc-opts.grpc-user-agent",
          "kind": "string",
          "hint": "",
          "description": "gRPC 请求的 User-Agent，仅在 network 为 grpc 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.max-connections",
          "title": "grpc-opts.max-connections",
          "kind": "integer",
          "hint": "1",
          "description": "gRPC 最大底层连接数，默认 1；与 grpc-opts.max-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md",
          "defaultHint": "1"
        },
        {
          "path": "grpc-opts.max-streams",
          "title": "grpc-opts.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 建立新连接前的最大复用流数；与 grpc-opts.max-connections、grpc-opts.min-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.min-streams",
          "title": "grpc-opts.min-streams",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 建立新连接前的最小复用流数；与 grpc-opts.max-streams 互斥。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "grpc-opts.ping-interval",
          "title": "grpc-opts.ping-interval",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 心跳间隔，单位秒，默认关闭。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "h2-opts.host",
          "title": "h2-opts.host",
          "kind": "list",
          "hint": "[\"example.com\"]",
          "description": "H2 传输层主机域名列表；设置后客户端随机选择，服务器验证。仅在 network 为 h2 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "h2-opts.path",
          "title": "h2-opts.path",
          "kind": "string",
          "hint": "/",
          "description": "H2 传输层请求路径，仅在 network 为 h2 时生效。mihomo 的 H2 传输未实现多路复用，需要时可选 gRPC 或 sing-mux。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.headers",
          "title": "http-opts.headers",
          "kind": "map",
          "hint": "{\"Connection\":[\"keep-alive\"]}",
          "description": "HTTP 传输层的请求头，可为每个头填写值列表，仅在 network 为 http 时生效。",
          "required": false,
          "elementKind": "list",
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.method",
          "title": "http-opts.method",
          "kind": "string",
          "hint": "GET",
          "description": "HTTP 传输层的请求方法，仅在 network 为 http 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "http-opts.path",
          "title": "http-opts.path",
          "kind": "list",
          "hint": "[\"/\",\"/video\"]",
          "description": "HTTP 传输层的请求路径列表，仅在 network 为 http 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "只修改证书 DNSName 的校验目标，不改变 SNI。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "tcp",
          "description": "VMess 传输层，支持 tcp、ws、http、h2、grpc、mkcp、mekya；未设置时使用 tcp。新传输参数可通过额外字段填写。",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "http",
            "h2",
            "grpc",
            "mkcp",
            "mekya"
          ],
          "document": "proxies/vmess.md"
        },
        {
          "path": "packet-encoding",
          "title": "packet-encoding",
          "kind": "choice",
          "hint": "packetaddr",
          "description": "UDP 包编码，可选 packetaddr（v2ray 5+）或 xudp（xray）；留空使用原始编码。",
          "required": false,
          "choices": [
            "xudp",
            "packetaddr"
          ],
          "document": "proxies/vmess.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "mTLS 客户端私钥，填写 PEM 内容或文件路径；必须同时填写 certificate。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.public-key",
          "title": "reality-opts.public-key",
          "kind": "string",
          "hint": "xxxx",
          "description": "Reality 服务端私钥对应的公钥；配置 Reality 时填写。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.short-id",
          "title": "reality-opts.short-id",
          "kind": "string",
          "hint": "xxxx",
          "description": "服务端允许的 Short ID 之一。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "reality-opts.support-x25519mlkem768",
          "title": "reality-opts.support-x25519mlkem768",
          "kind": "boolean",
          "hint": "true",
          "description": "是否支持 X25519-MLKEM768 密钥交换。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "Restls 的 TLS 版本提示，可选 tls12 或 tls13。",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ],
          "document": "proxies/tls.md"
        },
        {
          "path": "servername",
          "title": "servername",
          "kind": "string",
          "hint": "example.com",
          "description": "VMess / VLESS 的 TLS 服务器名称指示（SNI）；留空时使用 server。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "ShadowTLS 版本，支持 1、2、3，默认 2。需要启用 TLS，SNI 沿用 sni / servername。",
          "required": false,
          "document": "proxies/tls.md",
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过 TLS 证书验证。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "TCP Brutal 下载带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TCP Brutal 拥塞控制。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "TCP Brutal 上传带宽，默认单位为 Mbps。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 sing-mux 多路复用，仅用于支持 TCP 传输的协议。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大底层连接数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "建立新连接前，每条连接的最大复用流数量；与 smux.max-connections、smux.min-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "建立新连接前，每条连接的最小复用流数量；与 smux.max-streams 互斥。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "只对 TCP 启用 smux；开启后 UDP 沿用节点默认 UDP 传输方式。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用填充。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，可选 h2mux、smux 或 yamux，默认 h2mux。",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ],
          "document": "proxies/index.md",
          "defaultHint": "h2mux"
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "是否在控制面板显示底层连接，方便断开底层连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open，仅对 TCP 传输生效。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TLS；仅用于支持 TLS 的协议。Trojan 强制启用 TLS。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "tlsmirror-opts.primary-key",
          "title": "tlsmirror-opts.primary-key",
          "kind": "secret",
          "hint": "xxxx",
          "description": "TLSMirror 的 32 字节主密钥，使用 Base64 编码。仅 VMess 支持，需要启用 TLS。",
          "required": false,
          "document": "proxies/tls.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ws-opts.early-data-header-name",
          "title": "ws-opts.early-data-header-name",
          "kind": "string",
          "hint": "",
          "description": "WebSocket Early Data 的头名称。文档仅列出字段，未解释具体行为或默认值。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.headers",
          "title": "ws-opts.headers",
          "kind": "map",
          "hint": "{\"Host\":\"example.com\"}",
          "description": "WebSocket 请求头，仅在 network 为 ws 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.max-early-data",
          "title": "ws-opts.max-early-data",
          "kind": "string",
          "hint": "",
          "description": "WebSocket Early Data 首包长度阈值。文档未声明默认值或单位。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.path",
          "title": "ws-opts.path",
          "kind": "string",
          "hint": "/path",
          "description": "WebSocket 请求路径，仅在 network 为 ws 时生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.v2ray-http-upgrade",
          "title": "ws-opts.v2ray-http-upgrade",
          "kind": "boolean",
          "hint": "false",
          "description": "是否使用 HTTP Upgrade，仅在 WebSocket 传输设置中生效。",
          "required": false,
          "document": "proxies/transport.md"
        },
        {
          "path": "ws-opts.v2ray-http-upgrade-fast-open",
          "title": "ws-opts.v2ray-http-upgrade-fast-open",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用 HTTP Upgrade 的 Fast Open。",
          "required": false,
          "document": "proxies/transport.md"
        }
      ],
      "document": "proxies/vmess.md"
    },
    {
      "name": "wireguard",
      "key": "wireguard",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "wg",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "162.159.192.1",
          "description": "单 peer 的服务端地址；配置 peers 时顶层此字段被忽略。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "2480",
          "description": "单 peer 的服务端端口；配置 peers 时顶层此字段被忽略。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "allowed-ips",
          "title": "allowed-ips",
          "kind": "list",
          "hint": "[\"0.0.0.0/0\"]",
          "description": "由 peer 转发的 IP 网段列表。多 peer 的 allowed-ips 需区分，文档示例使用 0.0.0.0/0。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.content-padding-addition",
          "title": "amnezia-wg-option.content-padding-addition",
          "kind": "string",
          "hint": "0-32",
          "description": "AmneziaWG v3+ 参数，文档只给出 0-32 范围示例，未声明默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.disable-cookies",
          "title": "amnezia-wg-option.disable-cookies",
          "kind": "boolean",
          "hint": "true",
          "description": "AmneziaWG v3.1+ 开关，文档只给出 true 示例，未声明默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.h1",
          "title": "amnezia-wg-option.h1",
          "kind": "integer",
          "hint": "123456",
          "description": "AmneziaWG h1 参数：v1.0 / v1.5 只支持单个数值，v2+ 也支持范围。文档未解释其他约束。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.h2",
          "title": "amnezia-wg-option.h2",
          "kind": "integer",
          "hint": "67543",
          "description": "AmneziaWG h2 参数：v1.0 / v1.5 只支持单个数值，v2+ 也支持范围。文档未解释其他约束。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.h3",
          "title": "amnezia-wg-option.h3",
          "kind": "integer",
          "hint": "123123",
          "description": "AmneziaWG h3 参数：v1.0 / v1.5 只支持单个数值，v2+ 也支持范围。文档未解释其他约束。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.h4",
          "title": "amnezia-wg-option.h4",
          "kind": "integer",
          "hint": "32345",
          "description": "AmneziaWG h4 参数：v1.0 / v1.5 只支持单个数值，v2+ 也支持范围。文档未解释其他约束。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.header-protection-key",
          "title": "amnezia-wg-option.header-protection-key",
          "kind": "secret",
          "hint": "",
          "description": "AmneziaWG v3+ 参数，文档只给出 Base64 字符串示例，未说明其他约束。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.i1",
          "title": "amnezia-wg-option.i1",
          "kind": "string",
          "hint": "<b 0xf6ab3267fa><b 0xf6ab><t><r 10>",
          "description": "AmneziaWG v1.5+ 的 i1 字符串参数，文档只给出标签表达式示例，没有解释完整语法。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.i2",
          "title": "amnezia-wg-option.i2",
          "kind": "string",
          "hint": "<b 0xf6ab3267fa><r 100>",
          "description": "AmneziaWG v1.5+ 的 i2 字符串参数，文档只给出标签表达式示例，没有解释完整语法。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.i3",
          "title": "amnezia-wg-option.i3",
          "kind": "string",
          "hint": "",
          "description": "AmneziaWG v1.5+ 的 i3 字符串参数，文档只给出空字符串示例。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.i4",
          "title": "amnezia-wg-option.i4",
          "kind": "string",
          "hint": "",
          "description": "AmneziaWG v1.5+ 的 i4 字符串参数，文档只给出空字符串示例。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.i5",
          "title": "amnezia-wg-option.i5",
          "kind": "string",
          "hint": "",
          "description": "AmneziaWG v1.5+ 的 i5 字符串参数，文档只给出空字符串示例。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.itime",
          "title": "amnezia-wg-option.itime",
          "kind": "integer",
          "hint": "60",
          "description": "仅 AmneziaWG v1.5 支持的 itime 参数，v2+ 已移除。文档未解释单位或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.j1",
          "title": "amnezia-wg-option.j1",
          "kind": "string",
          "hint": "<b 0xffffffff><c><b 0xf6ab><t><r 10>",
          "description": "仅 AmneziaWG v1.5 支持的 j1 参数，v2+ 已移除。文档只给出标签表达式示例。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.j2",
          "title": "amnezia-wg-option.j2",
          "kind": "string",
          "hint": "<c><b 0xf6ab><t><wt 1000>",
          "description": "仅 AmneziaWG v1.5 支持的 j2 参数，v2+ 已移除。文档只给出标签表达式示例。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.j3",
          "title": "amnezia-wg-option.j3",
          "kind": "string",
          "hint": "<t><b 0xf6ab><c><r 10>",
          "description": "仅 AmneziaWG v1.5 支持的 j3 参数，v2+ 已移除。文档只给出标签表达式示例。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.jc",
          "title": "amnezia-wg-option.jc",
          "kind": "integer",
          "hint": "5",
          "description": "AmneziaWG v1.0+ 参数 jc。文档只给出示例，没有解释含义、范围或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.jmax",
          "title": "amnezia-wg-option.jmax",
          "kind": "integer",
          "hint": "501",
          "description": "AmneziaWG v1.0+ 参数 jmax。文档只给出示例，没有解释含义、范围或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.jmin",
          "title": "amnezia-wg-option.jmin",
          "kind": "integer",
          "hint": "500",
          "description": "AmneziaWG v1.0+ 参数 jmin。文档只给出示例，没有解释含义、范围或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.keepalive-timeout",
          "title": "amnezia-wg-option.keepalive-timeout",
          "kind": "integer",
          "hint": "10",
          "description": "AmneziaWG v3+ 参数，文档只给出 10 示例，未说明单位或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.max-handshake-attempts",
          "title": "amnezia-wg-option.max-handshake-attempts",
          "kind": "integer",
          "hint": "18",
          "description": "AmneziaWG v3+ 参数，文档只给出 18 示例，未声明默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.random-trailers",
          "title": "amnezia-wg-option.random-trailers",
          "kind": "boolean",
          "hint": "true",
          "description": "AmneziaWG v3.1+ 开关，文档只给出 true 示例，未声明默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.reject-after-time",
          "title": "amnezia-wg-option.reject-after-time",
          "kind": "integer",
          "hint": "180",
          "description": "AmneziaWG v3+ 参数，文档只给出 180 示例，未说明单位或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.rekey-after-time",
          "title": "amnezia-wg-option.rekey-after-time",
          "kind": "integer",
          "hint": "120",
          "description": "AmneziaWG v3+ 参数，文档只给出 120 示例，未说明单位或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.rekey-timeout",
          "title": "amnezia-wg-option.rekey-timeout",
          "kind": "integer",
          "hint": "5",
          "description": "AmneziaWG v3+ 参数，文档只给出 5 示例，未说明单位或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.s1",
          "title": "amnezia-wg-option.s1",
          "kind": "integer",
          "hint": "30",
          "description": "AmneziaWG v1.0+ 参数 s1。文档只给出示例，没有解释含义、范围或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.s2",
          "title": "amnezia-wg-option.s2",
          "kind": "integer",
          "hint": "40",
          "description": "AmneziaWG v1.0+ 参数 s2。文档只给出示例，没有解释含义、范围或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.s3",
          "title": "amnezia-wg-option.s3",
          "kind": "integer",
          "hint": "50",
          "description": "AmneziaWG v1.5+ 参数 s3。文档只给出示例，没有解释含义、范围或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.s4",
          "title": "amnezia-wg-option.s4",
          "kind": "integer",
          "hint": "8",
          "description": "AmneziaWG v1.5+ 参数 s4。文档只给出示例，没有解释含义、范围或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "amnezia-wg-option.version",
          "title": "amnezia-wg-option.version",
          "kind": "integer",
          "hint": "2",
          "description": "AmneziaWG 版本选择。示例注释说明只有值 3 使用 v3 实现，其他值使用旧实现；示例 2 不代表默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "通过指定代理或策略组建立当前节点的网络连接，填写其名称。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"1.1.1.1\",\"8.8.8.8\"]",
          "description": "远程 DNS 服务器地址列表，仅 remote-dns-resolve 为 true 时生效。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/wg.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "节点绑定的网络接口，从此接口发起连接。",
          "required": false,
          "document": "proxies/index.md"
        },
        {
          "path": "ip",
          "title": "ip",
          "kind": "string",
          "hint": "172.16.0.2",
          "description": "本机在 WireGuard 网络中使用的 IPv4 地址。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "内层 TCP 拥塞控制算法，可选 cubic、reno、bbr 或 bbr3，默认 cubic；gvisor 协议栈下不生效。与外层 QUIC 的 congestion-controller 含义不同。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ],
          "document": "proxies/wg.md",
          "defaultHint": "cubic"
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "IP 协议栈，可选 auto、gvisor 或 mips，默认 auto。auto 始终使用 mihomo 的 MIPS；gvisor 需要内核以 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "auto",
            "gvisor",
            "mips"
          ],
          "document": "proxies/wg.md",
          "defaultHint": "auto"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "出站 IP 版本，可选 dual、ipv4、ipv6、ipv4-prefer 或 ipv6-prefer，默认 dual。非 direct 节点主要影响服务器域名的地址选择。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/index.md",
          "defaultHint": "dual"
        },
        {
          "path": "ipv6",
          "title": "ipv6",
          "kind": "string",
          "hint": "fd01:5ca1:ab1e:80fa:ab85:6eea:213f:f4a5",
          "description": "本机在 WireGuard 网络中使用的 IPv6 地址，可选。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1408",
          "description": "WireGuard 的 MTU 覆盖值，文档未声明默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "peers",
          "title": "peers",
          "kind": "list",
          "hint": "[{\"server\":\"162.159.192.1\",\"port\":2480,\"public-key\":\"Cr8hWlKvtDt7nrvf+f0brNQQzabAqrjfBvas9pmowjo=\",\"allowed-ips\":[\"0.0.0.0/0\"],\"pre-shared-key\":\"31aIhAPwktDGpH4JDhA8GNvjFXEf/a6+UaQRyOAiyfM=\",\"reserved\":[209,98,59]}]",
          "description": "多 peer 配置列表。每个 peer 的 allowed-ips 需区分；顶层 server、port、public-key、pre-shared-key、reserved 等字段被忽略，private-key 仍在顶层设置。",
          "required": false,
          "elementKind": "object",
          "children": [
            {
              "path": "server",
              "title": "server",
              "kind": "string",
              "hint": "162.159.192.1",
              "description": "此 peer 的服务器域名或 IP。",
              "required": false,
              "document": "proxies/wg.md"
            },
            {
              "path": "port",
              "title": "port",
              "kind": "integer",
              "hint": "2480",
              "description": "此 peer 的服务器端口。",
              "required": false,
              "document": "proxies/wg.md"
            },
            {
              "path": "public-key",
              "title": "public-key",
              "kind": "string",
              "hint": "Cr8hWlKvtDt7nrvf+f0brNQQzabAqrjfBvas9pmowjo=",
              "description": "此 peer 的 Base64 编码服务端公钥。",
              "required": false,
              "document": "proxies/wg.md"
            },
            {
              "path": "allowed-ips",
              "title": "allowed-ips",
              "kind": "list",
              "hint": "[\"0.0.0.0/0\"]",
              "description": "此 peer 转发的 IP 网段列表；不同 peer 的网段需区分。",
              "required": false,
              "elementKind": "string",
              "document": "proxies/wg.md"
            },
            {
              "path": "pre-shared-key",
              "title": "pre-shared-key",
              "kind": "secret",
              "hint": "31aIhAPwktDGpH4JDhA8GNvjFXEf/a6+UaQRyOAiyfM=",
              "description": "此 peer 的可选预共享密钥。",
              "required": false,
              "document": "proxies/wg.md"
            },
            {
              "path": "reserved",
              "title": "reserved",
              "kind": "list",
              "hint": "[209,98,59]",
              "description": "此 peer 的保留字段，文档支持整数列表或字符串，部分 WARP 节点需要。",
              "required": false,
              "elementKind": "integer",
              "document": "proxies/wg.md"
            }
          ],
          "document": "proxies/wg.md"
        },
        {
          "path": "persistent-keepalive",
          "title": "persistent-keepalive",
          "kind": "integer",
          "hint": "0",
          "description": "定期发送数据包以维持连接。文档没有明确说明单位或默认值。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "pre-shared-key",
          "title": "pre-shared-key",
          "kind": "secret",
          "hint": "31aIhAPwktDGpH4JDhA8GNvjFXEf/a6+UaQRyOAiyfM=",
          "description": "WireGuard 预共享密钥，可选；配置 peers 时顶层此字段被忽略。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "eCtXsJZ27+4PbhDkHnB923tkUn2Gj59wZw5wFA75MnU=",
          "description": "Base64 编码的 WireGuard 客户端私钥；单 peer 和多 peer 都在顶层设置。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "public-key",
          "title": "public-key",
          "kind": "string",
          "hint": "Cr8hWlKvtDt7nrvf+f0brNQQzabAqrjfBvas9pmowjo=",
          "description": "Base64 编码的 WireGuard 服务端公钥；配置 peers 时顶层此字段被忽略。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "是否强制远程 DNS 解析，默认 false。",
          "required": false,
          "document": "proxies/wg.md"
        },
        {
          "path": "reserved",
          "title": "reserved",
          "kind": "list",
          "hint": "[209,98,59]",
          "description": "WireGuard 保留字段，部分 WARP 节点需要。文档同时支持整数列表和字符串；配置 peers 时顶层此字段被忽略。",
          "required": false,
          "elementKind": "integer",
          "document": "proxies/wg.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，通用文档默认 false；TUIC 等基于 UDP 的协议以及 direct、dns 默认开启。具体协议有单独说明时以协议文档为准。",
          "required": false,
          "document": "proxies/index.md"
        }
      ],
      "document": "proxies/wg.md"
    },
    {
      "name": "zerotier",
      "key": "zerotier",
      "fields": [
        {
          "path": "name",
          "title": "name",
          "kind": "string",
          "hint": "zerotier",
          "description": "代理名称，必填且不可重复。",
          "required": true,
          "document": "proxies/index.md"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "承载 ZeroTier 网络通信的其他出站代理名称。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"10.147.17.1\"]",
          "description": "覆盖控制器下发的 DNS 服务器，可填写一个或多个。",
          "required": false,
          "elementKind": "string",
          "document": "proxies/zerotier.md"
        },
        {
          "path": "encrypted-hello",
          "title": "encrypted-hello",
          "kind": "boolean",
          "hint": "false",
          "description": "encrypted-hello 选项，文档默认 false；未解释具体行为。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "identity-secret",
          "title": "identity-secret",
          "kind": "secret",
          "hint": "0123456789:0:public-key:private-key",
          "description": "完整 identity.secret 内容，覆盖状态目录中的身份，但不写入状态目录。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "WLAN",
          "description": "ZeroTier 使用的网络接口名称。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "内层 TCP 拥塞控制算法，可选 cubic、reno、bbr 或 bbr3，默认 cubic；gvisor 协议栈下不生效。与外层 QUIC 的 congestion-controller 含义不同。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ],
          "document": "proxies/zerotier.md",
          "defaultHint": "cubic"
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "IP 协议栈，可选 auto、gvisor 或 mips，默认 auto。auto 始终使用 mihomo 的 MIPS；gvisor 需要内核以 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "auto",
            "gvisor",
            "mips"
          ],
          "document": "proxies/zerotier.md",
          "defaultHint": "auto"
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4-prefer",
          "description": "底层连接的 IP 版本偏好。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ],
          "document": "proxies/zerotier.md"
        },
        {
          "path": "low-bandwidth",
          "title": "low-bandwidth",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用低带宽模式，默认 false。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1400",
          "description": "本地 MTU 覆盖值，不可超过 ZeroTier 控制器提供的 MTU。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "network",
          "title": "network",
          "kind": "string",
          "hint": "0123456789abcdef",
          "description": "ZeroTier 网络 ID，文档示例为 16 位十六进制字符串；与其他协议的 network 传输类型含义不同。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "orbit",
          "title": "orbit",
          "kind": "list",
          "hint": "[{\"world\":\"0123456789abcdef\",\"seed\":\"0123456789\"}]",
          "description": "私有 Moon 根服务器列表，每项包含 world 和 seed。",
          "required": false,
          "elementKind": "object",
          "children": [
            {
              "path": "world",
              "title": "world",
              "kind": "string",
              "hint": "0123456789abcdef",
              "description": "Moon World ID，文档要求 16 位十六进制字符串。",
              "required": false,
              "document": "proxies/zerotier.md"
            },
            {
              "path": "seed",
              "title": "seed",
              "kind": "string",
              "hint": "0123456789",
              "description": "Moon 根节点 Node ID。正文写“10 位数字”，示例为带引号的 10 位 ID；文档未明确是否接受十六进制字母，需与控制器 / 内核核对。",
              "required": false,
              "document": "proxies/zerotier.md"
            }
          ],
          "document": "proxies/zerotier.md"
        },
        {
          "path": "physical-mtu",
          "title": "physical-mtu",
          "kind": "integer",
          "hint": "1432",
          "description": "ZeroTier UDP 负载 MTU，范围 510–10324，默认 1432。",
          "required": false,
          "document": "proxies/zerotier.md",
          "defaultHint": "1432"
        },
        {
          "path": "planet",
          "title": "planet",
          "kind": "string",
          "hint": "./planet",
          "description": "自定义 Planet 文件路径，用于替换内置 Earth Planet。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "primary-port",
          "title": "primary-port",
          "kind": "integer",
          "hint": "0",
          "description": "主 UDP 端口，0 表示自动选择可用端口。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "是否经 ZeroTier、使用控制器提供的 DNS 服务器解析目标域名。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "remote-trace-level",
          "title": "remote-trace-level",
          "kind": "integer",
          "hint": "0",
          "description": "远程诊断级别：0 普通、10 详细、15 规则、20 调试、30 极详。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "remote-trace-target",
          "title": "remote-trace-target",
          "kind": "string",
          "hint": "0123456789",
          "description": "接收全局诊断信息的 ZeroTier 节点 ID。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "Linux 路由标记，仅适用于 Linux。",
          "required": false,
          "document": "proxies/zerotier.md",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "secondary-port",
          "title": "secondary-port",
          "kind": "integer",
          "hint": "0",
          "description": "第二 UDP 端口，0 表示自动选择，-1 禁用。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "state-dir",
          "title": "state-dir",
          "kind": "string",
          "hint": "./zerotier-node",
          "description": "保存节点状态及默认身份的目录，默认按网络 ID 和出站名称创建独立目录。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "tcp-fallback-mode",
          "title": "tcp-fallback-mode",
          "kind": "string",
          "hint": "auto",
          "description": "TCP 中继回退模式：auto 在 UDP 失败后使用中继（默认）；force 只用中继；disable 禁用回退。",
          "required": false,
          "document": "proxies/zerotier.md",
          "defaultHint": "auto"
        },
        {
          "path": "tcp-fallback-relay",
          "title": "tcp-fallback-relay",
          "kind": "string",
          "hint": "204.80.128.1:443",
          "description": "TCP 回退中继服务器地址。",
          "required": false,
          "document": "proxies/zerotier.md"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 UDP，协议文档默认 true。",
          "required": false,
          "document": "proxies/zerotier.md"
        }
      ],
      "document": "proxies/zerotier.md"
    }
  ],
  "configuration": [
    {
      "path": "port",
      "title": "port",
      "kind": "integer",
      "hint": "7890",
      "description": "HTTP(S) 代理监听端口。",
      "required": false,
      "document": "inbound/port.md"
    },
    {
      "path": "socks-port",
      "title": "socks-port",
      "kind": "integer",
      "hint": "7891",
      "description": "SOCKS 代理监听端口，支持 SOCKS4、SOCKS4a 和 SOCKS5。",
      "required": false,
      "document": "inbound/port.md"
    },
    {
      "path": "redir-port",
      "title": "redir-port",
      "kind": "integer",
      "hint": "7893",
      "description": "redirect 透明代理监听端口，只代理 TCP 流量；支持 Linux、Android 和 macOS。",
      "required": false,
      "document": "inbound/port.md"
    },
    {
      "path": "tproxy-port",
      "title": "tproxy-port",
      "kind": "integer",
      "hint": "7894",
      "description": "TPROXY 透明代理监听端口，支持 TCP 和 UDP；仅适用于 Linux / Android。",
      "required": false,
      "unavailableReason": "仅支持 Linux / Android",
      "document": "inbound/port.md"
    },
    {
      "path": "mixed-port",
      "title": "mixed-port",
      "kind": "integer",
      "hint": "7892",
      "description": "同时支持 HTTP(S) 和 SOCKS5 的混合代理监听端口。",
      "required": false,
      "document": "inbound/port.md"
    },
    {
      "path": "allow-lan",
      "title": "allow-lan",
      "kind": "boolean",
      "hint": "true",
      "description": "允许其他设备通过 HTTP(S)、SOCKS 或混合代理端口访问互联网。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "bind-address",
      "title": "bind-address",
      "kind": "string",
      "hint": "*",
      "description": "代理端口的绑定地址。* 表示所有 IP；也可指定单个 IPv4 或方括号包裹的 IPv6 地址。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "authentication",
      "title": "authentication",
      "kind": "list",
      "hint": "[\"user1:pass1\",\"user2:pass2\"]",
      "description": "HTTP(S)、SOCKS 和混合代理端口的用户名与密码列表，每项使用 user:pass 格式。",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "skip-auth-prefixes",
      "title": "skip-auth-prefixes",
      "kind": "list",
      "hint": "[\"127.0.0.1/8\",\"::1/128\"]",
      "description": "允许跳过代理端口用户验证的 IP 地址段。",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "lan-allowed-ips",
      "title": "lan-allowed-ips",
      "kind": "list",
      "hint": "[\"0.0.0.0/0\",\"::/0\"]",
      "description": "允许连接的 IP 地址段，仅在 allow-lan 开启时生效。文档默认值为 0.0.0.0/0 和 ::/0。",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "lan-disallowed-ips",
      "title": "lan-disallowed-ips",
      "kind": "list",
      "hint": "[\"192.168.0.3/32\"]",
      "description": "禁止连接的 IP 地址段，默认为空；黑名单优先于允许列表。",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "find-process-mode",
      "title": "find-process-mode",
      "kind": "choice",
      "hint": "strict",
      "description": "进程匹配模式：always 强制匹配所有进程；strict 由内核判断是否开启（默认）；off 不匹配进程。",
      "required": false,
      "choices": [
        "always",
        "strict",
        "off"
      ],
      "defaultHint": "strict",
      "document": "general.md"
    },
    {
      "path": "mode",
      "title": "mode",
      "kind": "choice",
      "hint": "rule",
      "description": "运行模式：rule 按规则匹配（内核默认）；global 使用 GLOBAL 策略组选择的出口；direct 全局直连。",
      "required": false,
      "choices": [
        "rule",
        "global",
        "direct"
      ],
      "defaultHint": "rule",
      "document": "general.md"
    },
    {
      "path": "geox-url",
      "title": "geox-url",
      "kind": "group",
      "hint": "",
      "description": "",
      "required": false,
      "children": [
        {
          "path": "geox-url.geoip",
          "title": "geoip",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat",
          "description": "自定义 geoip.dat 数据文件的下载地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.geosite",
          "title": "geosite",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
          "description": "自定义 geosite.dat 域名分类数据文件的下载地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.mmdb",
          "title": "mmdb",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb",
          "description": "自定义 MMDB 格式的 IP 地理位置数据库下载地址。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.asn",
          "title": "asn",
          "kind": "string",
          "hint": "https://github.com/xishang0128/geoip/releases/download/latest/GeoLite2-ASN.mmdb",
          "description": "自定义 ASN 数据库的下载地址。",
          "required": false,
          "document": "general.md"
        }
      ]
    },
    {
      "path": "geo-auto-update",
      "title": "geo-auto-update",
      "kind": "boolean",
      "hint": "false",
      "description": "是否自动更新 GEO 数据。更新间隔由 geo-update-interval 设置；文档没有声明此开关的默认值。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "geo-update-interval",
      "title": "geo-update-interval",
      "kind": "integer",
      "hint": "24",
      "description": "GEO 数据自动更新的间隔，单位为小时。文档中的 24 是示例值。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "log-level",
      "title": "log-level",
      "kind": "choice",
      "hint": "info",
      "description": "内核日志级别：silent 不输出；error 错误；warning 警告及错误；info 一般运行信息及警告、错误；debug 尽可能输出所有运行信息。",
      "required": false,
      "choices": [
        "silent",
        "error",
        "warning",
        "info",
        "debug"
      ],
      "document": "general.md"
    },
    {
      "path": "ipv6",
      "title": "ipv6",
      "kind": "boolean",
      "hint": "true",
      "description": "是否允许内核接受 IPv6 流量。文档中的内核默认值为 true；客户端初始配置关闭此项。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "tls",
      "title": "tls",
      "kind": "group",
      "hint": "",
      "description": "",
      "required": false,
      "children": [
        {
          "path": "tls.certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "string",
          "description": "HTTPS API 的证书，填写 PEM 内容或证书文件路径。自 v1.19.18 起，本地文件支持自动重载。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "tls.private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "string",
          "description": "HTTPS API 证书对应的私钥，填写 PEM 内容或私钥文件路径。自 v1.19.18 起，本地文件支持自动重载。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "tls.ech-key",
          "title": "ech-key",
          "kind": "string",
          "hint": "-----BEGIN ECH KEYS-----\nACATwY30o/RKgD6hgeQxwrSiApLaCgU+HKh7B6SUrAHaDwBD/g0APwAAIAAgHjzK\nmadSJjYQIf9o1N5GXjkW4DEEeb17qMxHdwMdNnwADAABAAEAAQACAAEAAwAIdGVz\ndC5jb20AAA==\n-----END ECH KEYS-----",
          "description": "HTTPS API 的 ECH 密钥；填写后启用 ECH。自 v1.19.18 起，本地文件支持自动重载。",
          "required": false,
          "document": "general.md"
        }
      ]
    },
    {
      "path": "external-controller",
      "title": "external-controller",
      "kind": "string",
      "hint": "127.0.0.1:9090",
      "description": "RESTful API 监听地址，格式为 host:port。127.0.0.1 只监听本机；0.0.0.0 监听所有 IPv4 地址。客户端和统计服务使用此接口。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-controller-tls",
      "title": "external-controller-tls",
      "kind": "string",
      "hint": "127.0.0.1:9443",
      "description": "HTTPS API 监听地址。需要配置 tls.certificate 和 tls.private-key，并同时填写 external-controller。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "secret",
      "title": "secret",
      "kind": "secret",
      "hint": "",
      "description": "RESTful API 的访问密钥。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-controller-cors",
      "title": "external-controller-cors",
      "kind": "group",
      "hint": "",
      "description": "",
      "required": false,
      "children": [
        {
          "path": "external-controller-cors.allow-origins",
          "title": "allow-origins",
          "kind": "list",
          "hint": "[\"*\"]",
          "description": "API 跨域访问允许的来源列表。文档示例使用 *；示例不代表默认值。",
          "required": false,
          "elementKind": "string",
          "document": "general.md"
        },
        {
          "path": "external-controller-cors.allow-private-network",
          "title": "allow-private-network",
          "kind": "boolean",
          "hint": "true",
          "description": "API CORS 私有网络访问设置。文档仅给出示例，未声明默认值。",
          "required": false,
          "document": "general.md"
        }
      ]
    },
    {
      "path": "external-controller-unix",
      "title": "external-controller-unix",
      "kind": "string",
      "hint": "mihomo.sock",
      "description": "Unix Socket API 的监听路径。该接口不验证 secret，需要控制文件访问权限。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "tcp-concurrent",
      "title": "tcp-concurrent",
      "kind": "boolean",
      "hint": "true",
      "description": "对 DNS 解析得到的所有 IP 地址并发发起 TCP 连接，使用第一个成功的连接。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-ui",
      "title": "external-ui",
      "kind": "string",
      "hint": "/path/to/ui/folder",
      "description": "外部控制面板静态资源目录，通过 API 地址的 /ui 路径访问。支持绝对路径或内核工作目录的相对路径；目录外路径需加入 SAFE_PATHS。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-ui-name",
      "title": "external-ui-name",
      "kind": "string",
      "hint": "xd",
      "description": "外部控制面板更新时使用的子目录名。不填则直接更新到 external-ui 目录。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-ui-url",
      "title": "external-ui-url",
      "kind": "string",
      "hint": "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip",
      "description": "外部控制面板的下载地址。文档示例使用 GitHub Pages 分支的 ZIP 压缩包。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-doh-server",
      "title": "external-doh-server",
      "kind": "string",
      "hint": "/dns-query",
      "description": "在 RESTful API 端口上提供 DoH 服务的 URL 路径，例如 /dns-query。该 URL 不验证 secret。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "interface-name",
      "title": "interface-name",
      "kind": "string",
      "hint": "en0",
      "description": "指定内核流量的出站网络接口，例如 en0。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "disable-keep-alive",
      "title": "disable-keep-alive",
      "kind": "boolean",
      "hint": "false",
      "description": "禁用 TCP Keep Alive。文档注明 Android 上强制为 true。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "keep-alive-idle",
      "title": "keep-alive-idle",
      "kind": "integer",
      "hint": "15",
      "description": "TCP Keep Alive 的最大空闲时间。文档未明确标注此字段的单位或默认值。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "keep-alive-interval",
      "title": "keep-alive-interval",
      "kind": "integer",
      "hint": "15",
      "description": "TCP Keep Alive 包的发送间隔，单位为秒。文档中的 15 是示例值。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "hosts",
      "title": "hosts",
      "kind": "map",
      "hint": "{\"*.clash.dev\":\"127.0.0.1\",\"alpha.clash.dev\":\"::1\",\"test.com\":[\"1.1.1.1\",\"2.2.2.2\"],\"baidu.com\":\"google.com\"}",
      "description": "静态域名映射。键支持域名通配；值支持单个 IP、IP 列表或重定向域名，重定向不支持列表。完整域名优先于通配域名。",
      "required": false,
      "elementKind": "list",
      "document": "dns/hosts.md"
    },
    {
      "path": "profile",
      "title": "profile",
      "kind": "group",
      "hint": "",
      "description": "",
      "required": false,
      "children": [
        {
          "path": "profile.store-selected",
          "title": "store-selected",
          "kind": "boolean",
          "hint": "true",
          "description": "保存 API 对策略组的选择，供内核下次启动使用。",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "profile.store-fake-ip",
          "title": "store-fake-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "保存 Fake-IP 映射表，使域名再次连接时沿用原有映射地址。",
          "required": false,
          "document": "general.md"
        }
      ]
    },
    {
      "path": "tun",
      "title": "tun",
      "kind": "group",
      "hint": "",
      "description": "",
      "required": false,
      "children": [
        {
          "path": "tun.enable",
          "title": "enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 TUN。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.stack",
          "title": "stack",
          "kind": "choice",
          "hint": "mips",
          "description": "TUN 协议栈：system 使用系统栈；gvisor 使用用户空间栈；mixed 的 TCP 使用 system、UDP 使用 gvisor；mips 使用 mihomo 自研 IP 栈（默认）。",
          "required": false,
          "defaultHint": "mips",
          "choices": [
            "system",
            "gvisor",
            "mixed",
            "mips"
          ],
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.dns-hijack",
          "title": "dns-hijack",
          "kind": "list",
          "hint": "[\"any:53\",\"tcp://any:53\"]",
          "description": "将匹配的 DNS 连接导入内核 DNS 模块；省略协议时使用 UDP。macOS / Windows 无法自动劫持发往局域网的 DNS 请求。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-detect-interface",
          "title": "auto-detect-interface",
          "kind": "boolean",
          "hint": "true",
          "description": "自动选择流量出口接口。多网卡同时连接时，文档建议手动指定出口接口。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-route",
          "title": "auto-route",
          "kind": "boolean",
          "hint": "true",
          "description": "自动配置全局路由，将流量路由到 TUN 网卡。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "9000",
          "description": "TUN 最大传输单元，会影响极限状态下的速率。文档没有声明默认值。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.gso",
          "title": "gso",
          "kind": "boolean",
          "hint": "true",
          "description": "启用通用分段卸载，仅支持 Linux。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.gso-max-size",
          "title": "gso-max-size",
          "kind": "integer",
          "hint": "65536",
          "description": "GSO 数据块的最大长度，配合 Linux 的 gso 使用。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.strict-route",
          "title": "strict-route",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 auto-route 时执行严格路由。文档具体说明 Linux 的路由限制和 Windows 的防 DNS 泄漏行为，没有单独说明 macOS 效果。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法：cubic、reno、bbr 或 bbr3，默认 cubic；仅在 mips 协议栈下生效。",
          "required": false,
          "defaultHint": "cubic",
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ],
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-address",
          "title": "route-address",
          "kind": "list",
          "hint": "[\"0.0.0.0/1\",\"128.0.0.0/1\",\"::/1\",\"8000::/1\"]",
          "description": "启用 auto-route 时仅路由指定网段，代替默认路由；一般无需配置。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.endpoint-independent-nat",
          "title": "endpoint-independent-nat",
          "kind": "boolean",
          "hint": "false",
          "description": "启用独立于端点的 NAT，可能略微降低性能，不需要时不建议开启。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-interface",
          "title": "include-interface",
          "kind": "list",
          "hint": "[\"eth0\"]",
          "description": "只路由指定接口的流量，默认不限制；与 exclude-interface 互斥。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-interface",
          "title": "exclude-interface",
          "kind": "list",
          "hint": "[\"eth1\"]",
          "description": "排除指定接口的流量；与 include-interface 互斥。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-redirect",
          "title": "auto-redirect",
          "kind": "boolean",
          "hint": "true",
          "description": "自动配置 iptables / nftables 重定向 TCP，需要启用 auto-route。文档标注仅支持 Linux，并另述 Android 仅转发本地 IPv4 的行为；macOS 不适用。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.device",
          "title": "device",
          "kind": "string",
          "hint": "utun0",
          "description": "TUN 网卡名称；macOS 只能使用 utun 开头的名称。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-address",
          "title": "inet6-address",
          "kind": "list",
          "hint": "[\"fdfe:dcba:9876::1/126\"]",
          "description": "TUN IPv6 地址列表，需要顶层 ipv6 为 true。启动时检测不到其他网卡 IPv6 时会禁用；文档提供 SKIP_SYSTEM_IPV6_CHECK=1 环境变量强制开启。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.udp-timeout",
          "title": "udp-timeout",
          "kind": "integer",
          "hint": "300",
          "description": "UDP NAT 映射过期时间，单位为秒，默认 300（5 分钟）。",
          "required": false,
          "defaultHint": "300",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.iproute2-table-index",
          "title": "iproute2-table-index",
          "kind": "integer",
          "hint": "2022",
          "description": "auto-route 创建的 Linux iproute2 路由表索引，默认 2022。",
          "required": false,
          "defaultHint": "2022",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.iproute2-rule-index",
          "title": "iproute2-rule-index",
          "kind": "integer",
          "hint": "9000",
          "description": "auto-route 创建的 Linux iproute2 规则起始索引，默认 9000。",
          "required": false,
          "defaultHint": "9000",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-address-set",
          "title": "route-address-set",
          "kind": "list",
          "hint": "[\"ruleset-1\"]",
          "description": "将规则集中的目标 IP CIDR 加入防火墙，不匹配的流量绕过路由。仅支持 Linux，需要 nftables、auto-route 和 auto-redirect；与任何 routing-mark 配置冲突。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-exclude-address-set",
          "title": "route-exclude-address-set",
          "kind": "list",
          "hint": "[\"ruleset-2\"]",
          "description": "将规则集中的目标 IP CIDR 加入防火墙，匹配的流量绕过路由。仅支持 Linux，需要 nftables、auto-route 和 auto-redirect；与任何 routing-mark 配置冲突。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.route-exclude-address",
          "title": "route-exclude-address",
          "kind": "list",
          "hint": "[\"192.168.0.0/16\",\"fc00::/7\"]",
          "description": "启用 auto-route 时排除指定网段。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-uid",
          "title": "include-uid",
          "kind": "list",
          "hint": "[0]",
          "description": "仅路由指定用户 ID 的流量，默认不限制。UID 规则仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-uid-range",
          "title": "include-uid-range",
          "kind": "list",
          "hint": "[\"1000:9999\"]",
          "description": "仅路由指定用户 ID 范围的流量。仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-uid",
          "title": "exclude-uid",
          "kind": "list",
          "hint": "[1000]",
          "description": "排除指定用户 ID 的流量。仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-uid-range",
          "title": "exclude-uid-range",
          "kind": "list",
          "hint": "[\"1000:9999\"]",
          "description": "排除指定用户 ID 范围的流量。仅支持 Linux，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-mac-address",
          "title": "include-mac-address",
          "kind": "list",
          "hint": "[\"00:11:22:33:44:55\"]",
          "description": "按来源 MAC 地址只路由指定局域网设备的流量。仅支持 Linux，需要 auto-route 和 auto-redirect。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-mac-address",
          "title": "exclude-mac-address",
          "kind": "list",
          "hint": "[\"00:11:22:33:44:66\"]",
          "description": "按来源 MAC 地址排除指定局域网设备的流量。仅支持 Linux，需要 auto-route 和 auto-redirect。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-android-user",
          "title": "include-android-user",
          "kind": "list",
          "hint": "[0,10]",
          "description": "仅路由指定 Android 用户的流量，需要 auto-route。常见用户 ID：机主 0、分身 10、应用多开 999。",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Android",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-package",
          "title": "include-package",
          "kind": "list",
          "hint": "[\"com.android.chrome\"]",
          "description": "仅路由指定 Android 应用包名的流量，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Android",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-package",
          "title": "exclude-package",
          "kind": "list",
          "hint": "[\"com.android.captiveportallogin\"]",
          "description": "排除指定 Android 应用包名的流量，需要 auto-route。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Android",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet4-route-address",
          "title": "inet4-route-address",
          "kind": "list",
          "hint": "[\"0.0.0.0/1\",\"128.0.0.0/1\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时路由指定 IPv4 网段；建议改用 route-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-route-address",
          "title": "inet6-route-address",
          "kind": "list",
          "hint": "[\"::/1\",\"8000::/1\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时路由指定 IPv6 网段；建议改用 route-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet4-route-exclude-address",
          "title": "inet4-route-exclude-address",
          "kind": "list",
          "hint": "[\"192.168.0.0/16\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时排除指定 IPv4 网段；建议改用 route-exclude-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-route-exclude-address",
          "title": "inet6-route-exclude-address",
          "kind": "list",
          "hint": "[\"fc00::/7\"]",
          "description": "即将废弃的旧写法。启用 auto-route 时排除指定 IPv6 网段；建议改用 route-exclude-address。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        }
      ]
    },
    {
      "path": "sniffer",
      "title": "sniffer",
      "kind": "group",
      "hint": "",
      "description": "",
      "required": false,
      "children": [
        {
          "path": "sniffer.enable",
          "title": "enable",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用域名嗅探。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.force-dns-mapping",
          "title": "force-dns-mapping",
          "kind": "boolean",
          "hint": "true",
          "description": "对 redir-host 类型识别的流量强制嗅探。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.parse-pure-ip",
          "title": "parse-pure-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "对尚未获取域名的流量强制嗅探。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.override-destination",
          "title": "override-destination",
          "kind": "boolean",
          "hint": "false",
          "description": "是否以嗅探结果作为实际访问目标，文档默认 true。",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.sniff",
          "title": "sniff",
          "kind": "group",
          "hint": "",
          "description": "",
          "required": false,
          "children": [
            {
              "path": "sniffer.sniff.QUIC",
              "title": "QUIC",
              "kind": "group",
              "hint": "",
              "description": "",
              "required": false,
              "children": [
                {
                  "path": "sniffer.sniff.QUIC.ports",
                  "title": "ports",
                  "kind": "list",
                  "hint": "[443,8443]",
                  "description": "对这些端口的 QUIC 流量进行嗅探，支持单个端口或端口范围。",
                  "required": false,
                  "elementKind": "integer",
                  "document": "sniff/index.md"
                }
              ]
            },
            {
              "path": "sniffer.sniff.TLS",
              "title": "TLS",
              "kind": "group",
              "hint": "",
              "description": "",
              "required": false,
              "children": [
                {
                  "path": "sniffer.sniff.TLS.ports",
                  "title": "ports",
                  "kind": "list",
                  "hint": "[443,8443]",
                  "description": "对这些端口的 TLS 流量进行嗅探，支持单个端口或端口范围。",
                  "required": false,
                  "elementKind": "integer",
                  "document": "sniff/index.md"
                }
              ]
            },
            {
              "path": "sniffer.sniff.HTTP",
              "title": "HTTP",
              "kind": "group",
              "hint": "",
              "description": "",
              "required": false,
              "children": [
                {
                  "path": "sniffer.sniff.HTTP.ports",
                  "title": "ports",
                  "kind": "list",
                  "hint": "[80,\"8080-8880\"]",
                  "description": "对这些端口的 HTTP 流量进行嗅探，支持单个端口或端口范围，例如 80、8080-8880。",
                  "required": false,
                  "elementKind": "string",
                  "document": "sniff/index.md"
                },
                {
                  "path": "sniffer.sniff.HTTP.override-destination",
                  "title": "override-destination",
                  "kind": "boolean",
                  "hint": "true",
                  "description": "HTTP 嗅探是否覆盖实际访问目标；此项覆盖 sniffer.override-destination 的全局设置。",
                  "required": false,
                  "document": "sniff/index.md"
                }
              ]
            }
          ]
        },
        {
          "path": "sniffer.force-domain",
          "title": "force-domain",
          "kind": "list",
          "hint": "[\"+.v2ex.com\"]",
          "description": "强制嗅探的域名列表，支持 Clash 域名通配。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-src-address",
          "title": "skip-src-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的来源 IP 网段列表。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-dst-address",
          "title": "skip-dst-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的目标 IP 网段列表。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-domain",
          "title": "skip-domain",
          "kind": "list",
          "hint": "[\"Mijia Cloud\"]",
          "description": "跳过嗅探的域名列表，支持 Clash 域名通配。",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        }
      ]
    },
    {
      "path": "dns",
      "title": "dns",
      "kind": "group",
      "hint": "",
      "description": "",
      "required": false,
      "children": [
        {
          "path": "dns.cache-algorithm",
          "title": "cache-algorithm",
          "kind": "choice",
          "hint": "arc",
          "description": "DNS 缓存算法：lru 最近最少使用（默认）；arc 自适应替换缓存。",
          "required": false,
          "defaultHint": "lru",
          "choices": [
            "lru",
            "arc"
          ],
          "document": "dns/index.md"
        },
        {
          "path": "dns.enable",
          "title": "enable",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用内核 DNS。关闭时使用系统 DNS 解析。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.prefer-h3",
          "title": "prefer-h3",
          "kind": "boolean",
          "hint": "false",
          "description": "DoH 连接优先使用 HTTP/3。文档强烈不建议与 respect-rules 一起使用。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.listen",
          "title": "listen",
          "kind": "string",
          "hint": "0.0.0.0:1053",
          "description": "DNS 服务监听地址，支持 UDP 和 TCP。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.ipv6",
          "title": "ipv6",
          "kind": "boolean",
          "hint": "false",
          "description": "是否解析 IPv6 地址。关闭时对 AAAA 查询返回空结果；与顶层 ipv6 接受流量的开关含义不同。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.default-nameserver",
          "title": "default-nameserver",
          "kind": "list",
          "hint": "[\"223.5.5.5\"]",
          "description": "用于解析 DNS 服务器自身域名的 DNS 地址列表。服务器地址必须使用 IP，可以使用加密 DNS。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.enhanced-mode",
          "title": "enhanced-mode",
          "kind": "choice",
          "hint": "fake-ip",
          "description": "DNS 处理模式，可选 fake-ip 或 redir-host；内核默认 redir-host。",
          "required": false,
          "defaultHint": "redir-host",
          "choices": [
            "fake-ip",
            "redir-host"
          ],
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-range",
          "title": "fake-ip-range",
          "kind": "string",
          "hint": "198.18.0.1/16",
          "description": "Fake-IP 的 IPv4 地址段，也作为 TUN 默认 IPv4 地址的参考。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-range6",
          "title": "fake-ip-range6",
          "kind": "string",
          "hint": "fdfe:dcba:9876::1/64",
          "description": "Fake-IP 的 IPv6 地址段。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-filter",
          "title": "fake-ip-filter",
          "kind": "list",
          "hint": "[\"RULE-SET,reject-domain,fake-ip\",\"RULE-SET,proxy-domain,fake-ip\",\"GEOSITE,gfw,fake-ip\",\"DOMAIN,www.baidu.com,real-ip\",\"DOMAIN-SUFFIX,qq.com,real-ip\",\"DOMAIN-SUFFIX,jd.com,fake-ip\",\"MATCH,fake-ip\"]",
          "description": "Fake-IP 过滤列表。blacklist / whitelist 模式支持域名通配和域名集合；rule 模式使用路由规则语法，以 fake-ip 或 real-ip 为结果，最后可用 MATCH 兜底。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-filter-mode",
          "title": "fake-ip-filter-mode",
          "kind": "choice",
          "hint": "rule",
          "description": "Fake-IP 过滤模式：blacklist 匹配域名返回真实 IP（默认）；whitelist 只有匹配域名才返回 Fake-IP；rule 按从上到下的规则决定 fake-ip 或 real-ip。",
          "required": false,
          "defaultHint": "blacklist",
          "choices": [
            "blacklist",
            "whitelist",
            "rule"
          ],
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-ttl",
          "title": "fake-ip-ttl",
          "kind": "integer",
          "hint": "1",
          "description": "Fake-IP 查询响应的 TTL。文档未声明默认值，非必要时不建议修改。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.use-hosts",
          "title": "use-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否使用配置中的静态 hosts 映射，默认 true。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.respect-rules",
          "title": "respect-rules",
          "kind": "boolean",
          "hint": "false",
          "description": "DNS 连接遵守路由规则，需要配置 proxy-server-nameserver，避免代理节点域名解析循环。强烈不建议与 prefer-h3 一起使用。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.nameserver",
          "title": "nameserver",
          "kind": "list",
          "hint": "[\"https://8.8.8.8/dns-query#proxy&ecs=1.1.1.1/24&ecs-override=true\"]",
          "description": "默认的域名解析服务器列表。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback",
          "title": "fallback",
          "kind": "list",
          "hint": "[\"tls://8.8.4.4\",\"tls://1.1.1.1\"]",
          "description": "后备域名解析服务器列表。配置后默认启用 fallback-filter，geoip-code 默认为 CN。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.proxy-server-nameserver",
          "title": "proxy-server-nameserver",
          "kind": "list",
          "hint": "[\"https://doh.pub/dns-query\"]",
          "description": "仅用于解析代理节点域名。留空时按 nameserver-policy、nameserver 和 fallback 的配置解析。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.proxy-server-nameserver-policy",
          "title": "proxy-server-nameserver-policy",
          "kind": "map",
          "hint": "{\"www.yournode.com\":\"114.114.114.114\"}",
          "description": "代理节点域名的解析策略，格式同 nameserver-policy；仅在 proxy-server-nameserver 非空时生效。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.direct-nameserver",
          "title": "direct-nameserver",
          "kind": "list",
          "hint": "[\"system\"]",
          "description": "用于 direct 出口的域名解析。留空时按 nameserver-policy、nameserver 和 fallback 的配置解析。",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.direct-nameserver-follow-policy",
          "title": "direct-nameserver-follow-policy",
          "kind": "boolean",
          "hint": "false",
          "description": "direct-nameserver 是否遵循 nameserver-policy，默认 false；仅在 direct-nameserver 非空时生效。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback-filter",
          "title": "fallback-filter",
          "kind": "group",
          "hint": "",
          "description": "",
          "required": false,
          "children": [
            {
              "path": "dns.fallback-filter.geoip",
              "title": "geoip",
              "kind": "boolean",
              "hint": "true",
              "description": "是否启用 GEOIP 判断，用 geoip-code 指定的国家筛选 nameserver 结果。",
              "required": false,
              "document": "dns/index.md"
            },
            {
              "path": "dns.fallback-filter.geoip-code",
              "title": "geoip-code",
              "kind": "string",
              "hint": "CN",
              "description": "国家缩写，默认 CN。该国家的解析结果直接采用；其他国家的结果视为污染，改用 fallback 结果。",
              "required": false,
              "document": "dns/index.md",
              "defaultHint": "CN"
            },
            {
              "path": "dns.fallback-filter.ipcidr",
              "title": "ipcidr",
              "kind": "list",
              "hint": "[\"240.0.0.0/4\",\"0.0.0.0/32\",\"127.0.0.1/32\",\"100.64.0.0/10\"]",
              "description": "视为污染的 IP 网段列表，格式为 IP/掩码。nameserver 返回这些地址时改用 fallback 结果。",
              "required": false,
              "elementKind": "string",
              "document": "dns/index.md"
            },
            {
              "path": "dns.fallback-filter.domain",
              "title": "domain",
              "kind": "list",
              "hint": "[\"+.google.com\",\"+.facebook.com\",\"+.youtube.com\"]",
              "description": "只使用 fallback 解析的域名列表，不查询 nameserver。",
              "required": false,
              "elementKind": "string",
              "document": "dns/index.md"
            },
            {
              "path": "dns.fallback-filter.geosite",
              "title": "geosite",
              "kind": "list",
              "hint": "[\"gfw\"]",
              "description": "已弃用，建议使用 nameserver-policy。匹配这些 GEOSITE 集合的域名只使用 fallback 解析。",
              "required": false,
              "elementKind": "string",
              "document": "dns/index.md"
            }
          ]
        },
        {
          "path": "dns.fallback-lazy-query",
          "title": "fallback-lazy-query",
          "kind": "boolean",
          "hint": "false",
          "description": "默认 false；开启后先检查 nameserver 结果是否满足 fallback-filter，再按需发起 fallback 查询。",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.nameserver-policy",
          "title": "nameserver-policy",
          "kind": "map",
          "hint": "{\"+.arpa\":\"10.0.0.1\",\"rule-set:cn\":[\"https://doh.pub/dns-query\",\"https://dns.alidns.com/dns-query\"]}",
          "description": "指定域名使用的 DNS 服务器，优先于 nameserver / fallback。键支持域名通配、geosite 或规则集；值支持单个服务器或列表。",
          "required": false,
          "elementKind": "list",
          "document": "dns/index.md"
        },
        {
          "path": "dns.use-system-hosts",
          "title": "use-system-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否查询系统 hosts，默认 true。",
          "required": false,
          "document": "dns/index.md"
        }
      ]
    },
    {
      "path": "external-controller-pipe",
      "title": "external-controller-pipe",
      "kind": "string",
      "hint": "\\\\.\\pipe\\mihomo",
      "description": "Windows 命名管道 API 的监听地址，仅适用于 Windows。该接口不验证 secret。",
      "required": false,
      "unavailableReason": "仅支持 Windows",
      "document": "general.md"
    },
    {
      "path": "external-controller-routing-mark",
      "title": "external-controller-routing-mark",
      "kind": "integer",
      "hint": "0",
      "description": "为 HTTP / HTTPS API 的监听 socket 设置路由标记，仅支持 Linux。",
      "required": false,
      "unavailableReason": "仅支持 Linux",
      "document": "general.md"
    },
    {
      "path": "unified-delay",
      "title": "unified-delay",
      "kind": "boolean",
      "hint": "true",
      "description": "测速时计算 RTT，减少连接握手等因素造成的不同类型节点延迟差异。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "routing-mark",
      "title": "routing-mark",
      "kind": "integer",
      "hint": "6666",
      "description": "Linux 出站连接使用的默认流量标记，仅适用于 Linux。",
      "required": false,
      "unavailableReason": "仅支持 Linux",
      "document": "general.md"
    },
    {
      "path": "geodata-mode",
      "title": "geodata-mode",
      "kind": "boolean",
      "hint": "true",
      "description": "GEOIP 数据格式：true 使用 geoip.dat；false 使用 MMDB。文档默认值为 false。",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "geodata-loader",
      "title": "geodata-loader",
      "kind": "choice",
      "hint": "memconservative",
      "description": "GEO 数据加载器：standard 标准加载器；memconservative 适合内存受限设备（默认）。",
      "required": false,
      "choices": [
        "memconservative",
        "standard"
      ],
      "defaultHint": "memconservative",
      "document": "general.md"
    },
    {
      "path": "global-ua",
      "title": "global-ua",
      "kind": "string",
      "hint": "clash.meta",
      "description": "下载外部资源时使用的 User-Agent，内核默认值为 clash.meta。",
      "required": false,
      "defaultHint": "clash.meta",
      "document": "general.md"
    },
    {
      "path": "etag-support",
      "title": "etag-support",
      "kind": "boolean",
      "hint": "true",
      "description": "是否支持外部资源下载的 ETag，文档默认值为 true。",
      "required": false,
      "document": "general.md"
    }
  ]
}
"""#

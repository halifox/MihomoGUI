// Generated from Meta-Docs config documentation by scripts/build-schema.rb.
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
          "description": "",
          "required": false
        },
        {
          "path": "bind-address",
          "title": "bind-address",
          "kind": "string",
          "hint": "*",
          "description": "",
          "required": false
        },
        {
          "path": "lan-allowed-ips",
          "title": "lan-allowed-ips",
          "kind": "list",
          "hint": "[\"0.0.0.0/0\",\"::/0\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "lan-disallowed-ips",
          "title": "lan-disallowed-ips",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "authentication",
          "title": "authentication",
          "kind": "list",
          "hint": "[\"user1:pass1\",\"user2:pass2\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "skip-auth-prefixes",
          "title": "skip-auth-prefixes",
          "kind": "list",
          "hint": "[\"127.0.0.1/8\",\"::1/128\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "mode",
          "title": "mode",
          "kind": "choice",
          "hint": "rule",
          "description": "",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ]
        },
        {
          "path": "log-level",
          "title": "log-level",
          "kind": "choice",
          "hint": "info",
          "description": "",
          "required": false,
          "choices": [
            "silent",
            "error",
            "warning",
            "info",
            "debug"
          ]
        },
        {
          "path": "ipv6",
          "title": "ipv6",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许内核接受 IPv6 流量 可选值 true/false,默认为 true",
          "required": false
        },
        {
          "path": "keep-alive-interval",
          "title": "keep-alive-interval",
          "kind": "integer",
          "hint": "15",
          "description": "",
          "required": false
        },
        {
          "path": "keep-alive-idle",
          "title": "keep-alive-idle",
          "kind": "integer",
          "hint": "15",
          "description": "",
          "required": false
        },
        {
          "path": "disable-keep-alive",
          "title": "disable-keep-alive",
          "kind": "boolean",
          "hint": "false",
          "description": "",
          "required": false
        },
        {
          "path": "find-process-mode",
          "title": "find-process-mode",
          "kind": "choice",
          "hint": "strict",
          "description": "",
          "required": false,
          "choices": [
            "always",
            "strict",
            "off"
          ]
        },
        {
          "path": "external-controller",
          "title": "external-controller",
          "kind": "string",
          "hint": "127.0.0.1:9090",
          "description": "",
          "required": false
        },
        {
          "path": "external-controller-cors.allow-origins",
          "title": "external-controller-cors.allow-origins",
          "kind": "list",
          "hint": "[\"*\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "external-controller-cors.allow-private-network",
          "title": "external-controller-cors.allow-private-network",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "external-controller-unix",
          "title": "external-controller-unix",
          "kind": "string",
          "hint": "mihomo.sock",
          "description": "",
          "required": false
        },
        {
          "path": "external-controller-pipe",
          "title": "external-controller-pipe",
          "kind": "string",
          "hint": "\\\\.\\pipe\\mihomo",
          "description": "",
          "required": false,
          "unavailableReason": "仅支持 Windows"
        },
        {
          "path": "external-controller-tls",
          "title": "external-controller-tls",
          "kind": "string",
          "hint": "127.0.0.1:9443",
          "description": "",
          "required": false
        },
        {
          "path": "external-controller-routing-mark",
          "title": "external-controller-routing-mark",
          "kind": "integer",
          "hint": "0",
          "description": "",
          "required": false,
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "external-doh-server",
          "title": "external-doh-server",
          "kind": "string",
          "hint": "/dns-query",
          "description": "",
          "required": false
        },
        {
          "path": "secret",
          "title": "secret",
          "kind": "secret",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "external-ui",
          "title": "external-ui",
          "kind": "string",
          "hint": "/path/to/ui/folder",
          "description": "",
          "required": false
        },
        {
          "path": "external-ui-name",
          "title": "external-ui-name",
          "kind": "string",
          "hint": "xd",
          "description": "",
          "required": false
        },
        {
          "path": "external-ui-url",
          "title": "external-ui-url",
          "kind": "string",
          "hint": "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip",
          "description": "",
          "required": false
        },
        {
          "path": "profile.store-selected",
          "title": "profile.store-selected",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "profile.store-fake-ip",
          "title": "profile.store-fake-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "unified-delay",
          "title": "unified-delay",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "tcp-concurrent",
          "title": "tcp-concurrent",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "en0",
          "description": "",
          "required": false
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "",
          "required": false,
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tls.certificate",
          "title": "tls.certificate",
          "kind": "string",
          "hint": "string",
          "description": "",
          "required": false
        },
        {
          "path": "tls.private-key",
          "title": "tls.private-key",
          "kind": "secret",
          "hint": "string",
          "description": "",
          "required": false
        },
        {
          "path": "tls.ech-key",
          "title": "tls.ech-key",
          "kind": "string",
          "hint": "-----BEGIN ECH KEYS-----\nACATwY30o/RKgD6hgeQxwrSiApLaCgU+HKh7B6SUrAHaDwBD/g0APwAAIAAgHjzK\nmadSJjYQIf9o1N5GXjkW4DEEeb17qMxHdwMdNnwADAABAAEAAQACAAEAAwAIdGVz\ndC5jb20AAA==\n-----END ECH KEYS-----",
          "description": "",
          "required": false
        },
        {
          "path": "geodata-mode",
          "title": "geodata-mode",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "geodata-loader",
          "title": "geodata-loader",
          "kind": "choice",
          "hint": "memconservative",
          "description": "",
          "required": false,
          "choices": [
            "memconservative",
            "standard"
          ]
        },
        {
          "path": "geo-auto-update",
          "title": "geo-auto-update",
          "kind": "boolean",
          "hint": "false",
          "description": "",
          "required": false
        },
        {
          "path": "geo-update-interval",
          "title": "geo-update-interval",
          "kind": "integer",
          "hint": "24",
          "description": "",
          "required": false
        },
        {
          "path": "geox-url.geoip",
          "title": "geox-url.geoip",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat",
          "description": "",
          "required": false
        },
        {
          "path": "geox-url.geosite",
          "title": "geox-url.geosite",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
          "description": "",
          "required": false
        },
        {
          "path": "geox-url.mmdb",
          "title": "geox-url.mmdb",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb",
          "description": "",
          "required": false
        },
        {
          "path": "geox-url.asn",
          "title": "geox-url.asn",
          "kind": "string",
          "hint": "https://github.com/xishang0128/geoip/releases/download/latest/GeoLite2-ASN.mmdb",
          "description": "",
          "required": false
        },
        {
          "path": "global-ua",
          "title": "global-ua",
          "kind": "string",
          "hint": "clash.meta",
          "description": "",
          "required": false,
          "defaultHint": "clash.meta"
        },
        {
          "path": "etag-support",
          "title": "etag-support",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "7890",
          "description": "",
          "required": false
        },
        {
          "path": "socks-port",
          "title": "socks-port",
          "kind": "integer",
          "hint": "7891",
          "description": "",
          "required": false
        },
        {
          "path": "mixed-port",
          "title": "mixed-port",
          "kind": "integer",
          "hint": "7892",
          "description": "",
          "required": false
        },
        {
          "path": "redir-port",
          "title": "redir-port",
          "kind": "integer",
          "hint": "7893",
          "description": "",
          "required": false
        },
        {
          "path": "tproxy-port",
          "title": "tproxy-port",
          "kind": "integer",
          "hint": "7894",
          "description": "",
          "required": false,
          "unavailableReason": "仅支持 Linux / Android"
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
          "description": "是否启用，如为 false，则使用系统 DNS 解析",
          "required": false
        },
        {
          "path": "dns.cache-algorithm",
          "title": "dns.cache-algorithm",
          "kind": "choice",
          "hint": "arc",
          "description": "支持的算法： - lru: Least Recently Used, 默认值 - arc: Adaptive Replacement Cache",
          "required": false,
          "choices": [
            "lru",
            "arc"
          ]
        },
        {
          "path": "dns.prefer-h3",
          "title": "dns.prefer-h3",
          "kind": "boolean",
          "hint": "false",
          "description": "DOH 优先使用 http/3",
          "required": false
        },
        {
          "path": "dns.use-hosts",
          "title": "dns.use-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否回应配置中的 hosts，默认 true",
          "required": false
        },
        {
          "path": "dns.use-system-hosts",
          "title": "dns.use-system-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否查询系统 hosts，默认 true",
          "required": false
        },
        {
          "path": "dns.respect-rules",
          "title": "dns.respect-rules",
          "kind": "boolean",
          "hint": "false",
          "description": "dns 连接遵守路由规则，需配置 proxy-server-nameserver 强烈不建议和 prefer-h3 一起使用",
          "required": false
        },
        {
          "path": "dns.listen",
          "title": "dns.listen",
          "kind": "string",
          "hint": "0.0.0.0:1053",
          "description": "DNS 服务监听，支持 udp, tcp",
          "required": false
        },
        {
          "path": "dns.ipv6",
          "title": "dns.ipv6",
          "kind": "boolean",
          "hint": "false",
          "description": "是否解析 IPV6, 如为 false, 则回应 AAAA 的空解析",
          "required": false
        },
        {
          "path": "dns.default-nameserver",
          "title": "dns.default-nameserver",
          "kind": "list",
          "hint": "[\"223.5.5.5\"]",
          "description": "默认 DNS, 用于解析 DNS 服务器 的域名 必须为 IP, 可为加密 DNS",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.enhanced-mode",
          "title": "dns.enhanced-mode",
          "kind": "choice",
          "hint": "fake-ip",
          "description": "可选值 fake-ip/redir-host，默认redir-host mihomo 的 DNS 处理模式",
          "required": false,
          "choices": [
            "fake-ip",
            "redir-host"
          ]
        },
        {
          "path": "dns.fake-ip-range",
          "title": "dns.fake-ip-range",
          "kind": "string",
          "hint": "198.18.0.1/16",
          "description": "fakeip 下的 IP 段设置，tun 的默认 IPV4 地址 也使用此值作为参考",
          "required": false
        },
        {
          "path": "dns.fake-ip-range6",
          "title": "dns.fake-ip-range6",
          "kind": "string",
          "hint": "fdfe:dcba:9876::1/64",
          "description": "fakeip 下的 IPv6 段设置",
          "required": false
        },
        {
          "path": "dns.fake-ip-filter-mode",
          "title": "dns.fake-ip-filter-mode",
          "kind": "choice",
          "hint": "rule",
          "description": "可选 blacklist/whitelist/rule，默认blacklist，whitelist 即只有匹配成功才返回 fake-ip 当fake-ip-filter-mode设置为rule时，开启规则模式，此时fake-ip-filter的写法发生改变:",
          "required": false,
          "choices": [
            "blacklist",
            "whitelist",
            "rule"
          ]
        },
        {
          "path": "dns.fake-ip-filter",
          "title": "dns.fake-ip-filter",
          "kind": "list",
          "hint": "[\"RULE-SET,reject-domain,fake-ip\",\"RULE-SET,proxy-domain,fake-ip\",\"GEOSITE,gfw,fake-ip\",\"DOMAIN,www.baidu.com,real-ip\",\"DOMAIN-SUFFIX,qq.com,real-ip\",\"DOMAIN-SUFFIX,jd.com,fake-ip\",\"MATCH,fake-ip\"]",
          "description": "fakeip 过滤，以下地址不会下发 fakeip 映射用于连接 值支持域名通配以及引入域名集合",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.fake-ip-ttl",
          "title": "dns.fake-ip-ttl",
          "kind": "integer",
          "hint": "1",
          "description": "配置fakeip查询返回的TTL，非必要情况下请勿修改",
          "required": false
        },
        {
          "path": "dns.nameserver-policy",
          "title": "dns.nameserver-policy",
          "kind": "map",
          "hint": "{\"+.arpa\":\"10.0.0.1\",\"rule-set:cn\":[\"https://doh.pub/dns-query\",\"https://dns.alidns.com/dns-query\"]}",
          "description": "指定域名查询的解析服务器，可使用 geosite, 优先于 nameserver/fallback 查询 键支持域名通配 值支持字符串/数组",
          "required": false,
          "elementKind": "list"
        },
        {
          "path": "dns.nameserver",
          "title": "dns.nameserver",
          "kind": "list",
          "hint": "[\"https://8.8.8.8/dns-query#proxy&ecs=1.1.1.1/24&ecs-override=true\"]",
          "description": "默认的域名解析服务器",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.fallback",
          "title": "dns.fallback",
          "kind": "list",
          "hint": "[\"tls://8.8.4.4\",\"tls://1.1.1.1\"]",
          "description": "后备域名解析服务器，一般情况下使用境外 DNS, 保证结果可信 配置 fallback后默认启用 fallback-filter,geoip-code为 cn",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.proxy-server-nameserver",
          "title": "dns.proxy-server-nameserver",
          "kind": "list",
          "hint": "[\"https://doh.pub/dns-query\"]",
          "description": "代理节点域名解析服务器，仅用于解析代理节点的域名，如果不填则遵循 nameserver-policy、nameserver 和 fallback 的配置",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.proxy-server-nameserver-policy",
          "title": "dns.proxy-server-nameserver-policy",
          "kind": "map",
          "hint": "{\"www.yournode.com\":\"114.114.114.114\"}",
          "description": "格式同nameserver-policy，仅用于节点域名解析，当且仅当proxy-server-nameserver不为空时生效",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.direct-nameserver",
          "title": "dns.direct-nameserver",
          "kind": "list",
          "hint": "[\"system\"]",
          "description": "用于 direct 出口域名解析的 DNS 服务器，如果不填则遵循 nameserver-policy、nameserver 和 fallback 的配置",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.direct-nameserver-follow-policy",
          "title": "dns.direct-nameserver-follow-policy",
          "kind": "boolean",
          "hint": "false",
          "description": "是否遵循 nameserver-policy，默认为不遵守，仅当 direct-nameserver 不为空时生效",
          "required": false
        },
        {
          "path": "dns.fallback-filter.geoip",
          "title": "dns.fallback-filter.geoip",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "dns.fallback-filter.geoip-code",
          "title": "dns.fallback-filter.geoip-code",
          "kind": "string",
          "hint": "CN",
          "description": "",
          "required": false
        },
        {
          "path": "dns.fallback-filter.geosite",
          "title": "dns.fallback-filter.geosite",
          "kind": "list",
          "hint": "[\"gfw\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.fallback-filter.ipcidr",
          "title": "dns.fallback-filter.ipcidr",
          "kind": "list",
          "hint": "[\"240.0.0.0/4\",\"0.0.0.0/32\",\"127.0.0.1/32\",\"100.64.0.0/10\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.fallback-filter.domain",
          "title": "dns.fallback-filter.domain",
          "kind": "list",
          "hint": "[\"+.google.com\",\"+.facebook.com\",\"+.youtube.com\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dns.fallback-lazy-query",
          "title": "dns.fallback-lazy-query",
          "kind": "boolean",
          "hint": "false",
          "description": "默认值为 false ，如果为 true 会先判断来自 nameserver 的结果是否满足 fallback-filter 后再发起查询",
          "required": false
        },
        {
          "path": "proxies",
          "title": "proxies",
          "kind": "list",
          "hint": "[{\"name\":\"proxy\",\"type\":\"ss\"}]",
          "description": "",
          "required": false,
          "elementKind": "object",
          "children": [
            {
              "path": "name",
              "title": "name",
              "kind": "string",
              "hint": "proxy",
              "description": "",
              "required": false
            },
            {
              "path": "type",
              "title": "type",
              "kind": "string",
              "hint": "ss",
              "description": "",
              "required": false
            }
          ]
        },
        {
          "path": "hosts",
          "title": "hosts",
          "kind": "map",
          "hint": "{\"*.clash.dev\":\"127.0.0.1\",\"alpha.clash.dev\":\"::1\",\"test.com\":[\"1.1.1.1\",\"2.2.2.2\"],\"baidu.com\":\"google.com\"}",
          "description": "",
          "required": false,
          "elementKind": "list"
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
          "description": "是否启用 sniffer",
          "required": false
        },
        {
          "path": "sniffer.force-dns-mapping",
          "title": "sniffer.force-dns-mapping",
          "kind": "boolean",
          "hint": "true",
          "description": "对 redir-host 类型识别的流量进行强制嗅探",
          "required": false
        },
        {
          "path": "sniffer.parse-pure-ip",
          "title": "sniffer.parse-pure-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "对所有未获取到域名的流量进行强制嗅探",
          "required": false
        },
        {
          "path": "sniffer.override-destination",
          "title": "sniffer.override-destination",
          "kind": "boolean",
          "hint": "false",
          "description": "是否使用嗅探结果作为实际访问，默认为 true",
          "required": false
        },
        {
          "path": "sniffer.sniff.HTTP.ports",
          "title": "sniffer.sniff.HTTP.ports",
          "kind": "list",
          "hint": "[80,\"8080-8880\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "sniffer.sniff.HTTP.override-destination",
          "title": "sniffer.sniff.HTTP.override-destination",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "sniffer.sniff.TLS.ports",
          "title": "sniffer.sniff.TLS.ports",
          "kind": "list",
          "hint": "[443,8443]",
          "description": "",
          "required": false,
          "elementKind": "integer"
        },
        {
          "path": "sniffer.sniff.QUIC.ports",
          "title": "sniffer.sniff.QUIC.ports",
          "kind": "list",
          "hint": "[443,8443]",
          "description": "",
          "required": false,
          "elementKind": "integer"
        },
        {
          "path": "sniffer.force-domain",
          "title": "sniffer.force-domain",
          "kind": "list",
          "hint": "[\"+.v2ex.com\"]",
          "description": "强制进行嗅探的域名列表，使用域名通配",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "sniffer.skip-domain",
          "title": "sniffer.skip-domain",
          "kind": "list",
          "hint": "[\"Mijia Cloud\"]",
          "description": "跳过嗅探的域名列表，使用域名通配",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "sniffer.skip-src-address",
          "title": "sniffer.skip-src-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的来源 IP 段列表",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "sniffer.skip-dst-address",
          "title": "sniffer.skip-dst-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的目标 IP 段列表",
          "required": false,
          "elementKind": "string"
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
          "description": "启用 tun",
          "required": false
        },
        {
          "path": "tun.stack",
          "title": "tun.stack",
          "kind": "choice",
          "hint": "mips",
          "description": "tun 模式堆栈，如无使用问题，建议使用 mips 栈，默认 mips 可用值： system/gvisor/mixed/mips system 使用系统协议栈，可以提供更稳定/全面的 tun 体验，且占用相对其他堆栈更低 gvisor 通过在用户空间中实现网络协议栈，可以提供更高的安全性和隔离性，同时可以避免操作系统内核和用户空间之间的切换，从而在特定情况下具有更好的网络处理性能 mixed 混合堆栈，tcp 使用 system栈，udp 使用 gvisor栈，使用体验可能相对更好 mips 使用 mihomo ",
          "required": false,
          "choices": [
            "system",
            "gvisor",
            "mixed",
            "mips"
          ]
        },
        {
          "path": "tun.auto-route",
          "title": "tun.auto-route",
          "kind": "boolean",
          "hint": "true",
          "description": "自动设置全局路由，可以自动将全局流量路由进入 tun 网卡。",
          "required": false
        },
        {
          "path": "tun.auto-redirect",
          "title": "tun.auto-redirect",
          "kind": "boolean",
          "hint": "true",
          "description": "仅支持 Linux，自动配置 iptables/nftables 以重定向 TCP 连接，需要auto-route已启用 在 Android 中： 仅转发本地 IPv4 连接。要通过热点或中继共享您的 VPN 连接，请使用 VPNHotspot。 在 Linux 中： 带有 auto-route 的 auto-redirect 现在可以在路由器上按预期工作，无需干预。",
          "required": false,
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.auto-detect-interface",
          "title": "tun.auto-detect-interface",
          "kind": "boolean",
          "hint": "true",
          "description": "自动选择流量出口接口，多出口网卡同时连接的设备建议手动指定出口网卡",
          "required": false
        },
        {
          "path": "tun.dns-hijack",
          "title": "tun.dns-hijack",
          "kind": "list",
          "hint": "[\"any:53\",\"tcp://any:53\"]",
          "description": "dns 劫持，将匹配到的连接导入内部 dns 模块，不书写协议则为 udp:// 在 MacOS/Windows 无法自动劫持发往局域网的 dns 请求 在 Android 如开启 私人dns 则无法自动劫持 dns 请求",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.device",
          "title": "tun.device",
          "kind": "string",
          "hint": "utun0",
          "description": "指定 tun 网卡名称，MacOS 设备只能使用 utun 开头的网卡名",
          "required": false
        },
        {
          "path": "tun.mtu",
          "title": "tun.mtu",
          "kind": "integer",
          "hint": "9000",
          "description": "最大传输单元，会影响极限状态下的速率，一般用户默认即可。",
          "required": false
        },
        {
          "path": "tun.strict-route",
          "title": "tun.strict-route",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 auto-route 时执行严格的路由规则 在 Linux 中: 让不支持的网络无法到达 将所有连接路由到 tun 它可以防止地址泄漏，并使 DNS 劫持在 Android 上工作。 在 Windows 中: 添加防火墙规则以阻止 Windows 的 普通多宿主 DNS 解析行为 造成的 DNS 泄露 它可能会使某些应用程序（如 VirtualBox）在某些情况下无法正常工作。",
          "required": false
        },
        {
          "path": "tun.gso",
          "title": "tun.gso",
          "kind": "boolean",
          "hint": "true",
          "description": "启用通用分段卸载，仅支持 Linux",
          "required": false,
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.gso-max-size",
          "title": "tun.gso-max-size",
          "kind": "integer",
          "hint": "65536",
          "description": "数据块的最大长度",
          "required": false,
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.inet6-address",
          "title": "tun.inet6-address",
          "kind": "list",
          "hint": "[\"fdfe:dcba:9876::1/126\"]",
          "description": "指定tun的ipv6地址 目前会在程序启动时检查系统其他网卡是否有IPV6，如果不存在会禁用该功能，如果需要强制开启tun的v6地址，请手动设置SKIP_SYSTEM_IPV6_CHECK=1系统环境变量 需要同时将顶层配置中的ipv6设置为true才会生效",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.udp-timeout",
          "title": "tun.udp-timeout",
          "kind": "integer",
          "hint": "300",
          "description": "UDP NAT 过期时间，以秒为单位，默认为 300(5 分钟)",
          "required": false,
          "defaultHint": "300"
        },
        {
          "path": "tun.iproute2-table-index",
          "title": "tun.iproute2-table-index",
          "kind": "integer",
          "hint": "2022",
          "description": "auto-route 生成的 iproute2 路由表索引，默认使用 2022",
          "required": false,
          "defaultHint": "2022",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.iproute2-rule-index",
          "title": "tun.iproute2-rule-index",
          "kind": "integer",
          "hint": "9000",
          "description": "auto-route 生成的 iproute2 规则起始索引，默认使用 9000",
          "required": false,
          "defaultHint": "9000",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.endpoint-independent-nat",
          "title": "tun.endpoint-independent-nat",
          "kind": "boolean",
          "hint": "false",
          "description": "启用独立于端点的 NAT，性能可能会略有下降，所以不建议在不需要的时候开启。",
          "required": false
        },
        {
          "path": "tun.route-address-set",
          "title": "tun.route-address-set",
          "kind": "list",
          "hint": "[\"ruleset-1\"]",
          "description": "将指定规则集中的目标 IP CIDR 规则添加到防火墙，不匹配的流量将绕过路由 仅支持 Linux，且需要 nftables 以及auto-route 和 auto-redirect 已启用。 与任意配置中的 routing-mark 冲突",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.route-exclude-address-set",
          "title": "tun.route-exclude-address-set",
          "kind": "list",
          "hint": "[\"ruleset-2\"]",
          "description": "将指定规则集中的目标 IP CIDR 规则添加到防火墙，匹配的流量将绕过路由 仅支持 Linux，且需要 nftables 以及auto-route 和 auto-redirect 已启用。 与任意配置中的 routing-mark 冲突",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.route-address",
          "title": "tun.route-address",
          "kind": "list",
          "hint": "[\"0.0.0.0/1\",\"128.0.0.0/1\",\"::/1\",\"8000::/1\"]",
          "description": "启用 auto-route时路由自定义路由网段而不是默认路由，一般无需配置。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.route-exclude-address",
          "title": "tun.route-exclude-address",
          "kind": "list",
          "hint": "[\"192.168.0.0/16\",\"fc00::/7\"]",
          "description": "启用 auto-route 时排除自定义网段",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.include-interface",
          "title": "tun.include-interface",
          "kind": "list",
          "hint": "[\"eth0\"]",
          "description": "限制被路由的接口，默认不限制，与 exclude-interface 冲突，不可一起配置",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.exclude-interface",
          "title": "tun.exclude-interface",
          "kind": "list",
          "hint": "[\"eth1\"]",
          "description": "排除路由的接口，与 include-interface 冲突，不可一起配置",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.include-uid",
          "title": "tun.include-uid",
          "kind": "list",
          "hint": "[0]",
          "description": "包含的用户，使其被 Tun 路由流量，未被配置的用户不会被 Tun 路由流量，默认不限制 UID 规则仅在 Linux 下被支持,并且需要 auto-route",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.include-uid-range",
          "title": "tun.include-uid-range",
          "kind": "list",
          "hint": "[\"1000:9999\"]",
          "description": "包含的用户范围，使其被 Tun 路由流量，未被配置的用户不会被 Tun 路由流量",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.exclude-uid",
          "title": "tun.exclude-uid",
          "kind": "list",
          "hint": "[1000]",
          "description": "排除用户，使其避免被 Tun 路由流量",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.exclude-uid-range",
          "title": "tun.exclude-uid-range",
          "kind": "list",
          "hint": "[\"1000:9999\"]",
          "description": "排除用户范围，使其避免被 Tun 路由流量",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.include-mac-address",
          "title": "tun.include-mac-address",
          "kind": "list",
          "hint": "[\"00:11:22:33:44:55\"]",
          "description": "按来源 MAC 地址限制被路由的局域网设备。仅支持 Linux，且需要启用 auto-route 和 auto-redirect。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.exclude-mac-address",
          "title": "tun.exclude-mac-address",
          "kind": "list",
          "hint": "[\"00:11:22:33:44:66\"]",
          "description": "按来源 MAC 地址排除局域网设备的流量。仅支持 Linux，且需要启用 auto-route 和 auto-redirect。",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Linux"
        },
        {
          "path": "tun.include-android-user",
          "title": "tun.include-android-user",
          "kind": "list",
          "hint": "[0,10]",
          "description": "包含的 Android 用户，使其被 Tun 路由流量，未被配置的用户不会被 Tun 路由流量 Android 用户和应用规则仅在 Android 下被支持,并且需要 auto-route | 常用用户 | ID | | -------- | --- | | 机主 | 0 | | 手机分身 | 10 | | 应用多开 | 999 |",
          "required": false,
          "elementKind": "integer",
          "unavailableReason": "仅支持 Android"
        },
        {
          "path": "tun.include-package",
          "title": "tun.include-package",
          "kind": "list",
          "hint": "[\"com.android.chrome\"]",
          "description": "包含的 Android 应用包名，使其被 Tun 路由流量，未配置的应用包不会被 Tun 路由流量",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Android"
        },
        {
          "path": "tun.exclude-package",
          "title": "tun.exclude-package",
          "kind": "list",
          "hint": "[\"com.android.captiveportallogin\"]",
          "description": "排除 Android 应用包名，使其避免被 Tun 路由流量",
          "required": false,
          "elementKind": "string",
          "unavailableReason": "仅支持 Android"
        },
        {
          "path": "tun.inet4-route-address",
          "title": "tun.inet4-route-address",
          "kind": "list",
          "hint": "[\"0.0.0.0/1\",\"128.0.0.0/1\"]",
          "description": "启用 auto-route时路由自定义网段而不是默认路由，一般无需配置。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.inet6-route-address",
          "title": "tun.inet6-route-address",
          "kind": "list",
          "hint": "[\"::/1\",\"8000::/1\"]",
          "description": "启用 auto-route时路由自定义网段而不是默认路由，一般无需配置。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.inet4-route-exclude-address",
          "title": "tun.inet4-route-exclude-address",
          "kind": "list",
          "hint": "[\"192.168.0.0/16\"]",
          "description": "启用 auto-route 时排除自定义网段",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.inet6-route-exclude-address",
          "title": "tun.inet6-route-exclude-address",
          "kind": "list",
          "hint": "[\"fc00::/7\"]",
          "description": "启用 auto-route 时排除自定义网段",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "tun.congestion-controller",
          "title": "tun.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法，可选值：cubic、reno、bbr、bbr3，默认为 cubic，仅在使用 mips 协议栈时生效",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "1.2.3.4",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "<your password>",
          "description": "",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 utls 指纹，仅适用于 VMess/VLESS/Trojan/AnyTLS 协议 可选：chrome, firefox, safari, ios, android, edge, 360, qq, random, 若选择 random, 则按 Cloudflare Radar 数据按概率生成一个现代浏览器指纹。",
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
          ]
        },
        {
          "path": "client-metadata",
          "title": "client-metadata",
          "kind": "string",
          "hint": "",
          "description": "可选，发送给服务端的客户端元数据 由于 client-metadata 可能被用于统计客户端信息并区别对待，从 v1.19.30 开始默认不再发送该内容，如果需要请自行填写",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "ECH 配置，如果为空则通过 dns 解析，不为空则通过该值指定，格式为经过 base64 编码的 ech 参数（例如AEn+DQBFKwAgACABWIHUGj4u+PIggYXcR5JF0gYk3dCRioBW8uJq9H4mKAAIAAEAAQABAANAEnB1YmxpYy50bHMtZWNoLmRldgAA） 您可以通过mihomo generate ech-keypair test.com命令为服务器端和客户端生成符合要求的自签名 ech 配置对，请将test.com自行替换为您想要对外展现的 SNI ",
          "required": false
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 ECH（Encrypted Client Hello），如果为 true，则启用 ECH",
          "required": false
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "可选项，不为空时用于指定通过 dns 解析时的域名",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "idle-session-check-interval",
          "title": "idle-session-check-interval",
          "kind": "integer",
          "hint": "30",
          "description": "检查空闲会话的时间间隔。默认值：30 秒。",
          "required": false
        },
        {
          "path": "idle-session-timeout",
          "title": "idle-session-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "在检查中，关闭闲置时间超过此值的会话。默认值：30 秒。",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码",
          "required": false
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名",
          "required": false
        },
        {
          "path": "min-idle-session",
          "title": "min-idle-session",
          "kind": "integer",
          "hint": "0",
          "description": "在检查中，至少前 n 个空闲会话保持打开状态。默认值：n=0",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码",
          "required": false
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "TLS 版本提示，可选值为 tls12 / tls13",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ]
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码",
          "required": false
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "支持 v1 / v2 / v3；留空时默认为 v2。",
          "required": false,
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "1234",
          "description": "节点发起连接时附加的路由标记",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复。",
          "required": true
        },
        {
          "path": "accept-dns",
          "title": "accept-dns",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否接受网络下发的 DNS 配置。",
          "required": false
        },
        {
          "path": "dhcp",
          "title": "dhcp",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否通过 DHCP 获取 overlay IPv4 地址。ipv4 为空时默认开启，否则默认关闭；未获取到时实例将没有 overlay IPv4。",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "可选，通过其他出站代理承载 EasyTier 的网络通信，其中 ss1 为其他代理节点的名称。",
          "required": false
        },
        {
          "path": "disable-kcp-input",
          "title": "disable-kcp-input",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否禁用 KCP 输入，默认值为 false。",
          "required": false
        },
        {
          "path": "disable-p2p",
          "title": "disable-p2p",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否禁用 P2P 连接（仅通过中继通信），默认值为 false。",
          "required": false
        },
        {
          "path": "disable-quic-input",
          "title": "disable-quic-input",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否禁用 QUIC 输入，默认值为 false。",
          "required": false
        },
        {
          "path": "enable-encryption",
          "title": "enable-encryption",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否启用节点间加密，默认值为 true。",
          "required": false
        },
        {
          "path": "enable-exit-node",
          "title": "enable-exit-node",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否作为其他节点使用的 exit node，默认值为 false。",
          "required": false
        },
        {
          "path": "enable-kcp-proxy",
          "title": "enable-kcp-proxy",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否启用 KCP 代理（将 TCP 流量经 KCP 转发），默认值为 false。",
          "required": false
        },
        {
          "path": "enable-quic-proxy",
          "title": "enable-quic-proxy",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否启用 QUIC 代理（将 TCP 流量经 QUIC 转发），默认值为 false。",
          "required": false
        },
        {
          "path": "encryption-algorithm",
          "title": "encryption-algorithm",
          "kind": "string",
          "hint": "aes-gcm",
          "description": "可选，加密算法，默认值为 aes-gcm。",
          "required": false,
          "defaultHint": "aes-gcm"
        },
        {
          "path": "exit-nodes",
          "title": "exit-nodes",
          "kind": "list",
          "hint": "[\"10.144.0.1\"]",
          "description": "可选，要使用的 exit node 列表（填写对端节点的 overlay IPv4 地址），用于将流量转发至指定节点出网。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "hostname",
          "title": "hostname",
          "kind": "string",
          "hint": "mihomo",
          "description": "可选，本节点在 overlay 网络中的主机名，用于 MagicDNS 解析。不填写时由 EasyTier 处理。",
          "required": false
        },
        {
          "path": "instance-name",
          "title": "instance-name",
          "kind": "string",
          "hint": "mihomo-easytier",
          "description": "可选，EasyTier 实例名称，默认值为代理名称。",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "WLAN",
          "description": "可选，指定 EasyTier 使用的网络接口名称。",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4-prefer",
          "description": "可选，指定 IP 协议版本偏好（只影响底层 peer 连接）。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "ipv4",
          "title": "ipv4",
          "kind": "string",
          "hint": "10.144.0.1/24",
          "description": "可选，本节点的 overlay IPv4 地址，CIDR 格式，如 10.144.0.1/24。",
          "required": false
        },
        {
          "path": "latency-first",
          "title": "latency-first",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否启用延迟优先模式（优先选择延迟最低的路径而非跳数最少的路径），默认值为 false。",
          "required": false
        },
        {
          "path": "listeners",
          "title": "listeners",
          "kind": "list",
          "hint": "[\"tcp://0.0.0.0:11010\"]",
          "description": "可选，本节点监听的 URI 列表，用于接受其他节点的连接，如 tcp://0.0.0.0:11010。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "local-private-key",
          "title": "local-private-key",
          "kind": "secret",
          "hint": "base64-x25519-private-key",
          "description": "可选，本机 X25519 私钥（Base64），用于固定本机身份，避免每次启动更换公钥。",
          "required": false
        },
        {
          "path": "local-public-key",
          "title": "local-public-key",
          "kind": "string",
          "hint": "base64-x25519-public-key",
          "description": "可选，本机 X25519 公钥（Base64），通常可由私钥派生；必须与 local-private-key 一同配置。",
          "required": false
        },
        {
          "path": "mapped-listeners",
          "title": "mapped-listeners",
          "kind": "list",
          "hint": "[\"tcp://203.0.113.10:11010\"]",
          "description": "可选，向其他节点公告的对外映射监听地址列表，适用于端口映射等场景，如 tcp://203.0.113.10:11010。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1380",
          "description": "可选，MTU 覆盖值，默认值为 1380。",
          "required": false,
          "defaultHint": "1380"
        },
        {
          "path": "network-name",
          "title": "network-name",
          "kind": "string",
          "hint": "example",
          "description": "必须，EasyTier 网络名称。",
          "required": false
        },
        {
          "path": "network-secret",
          "title": "network-secret",
          "kind": "string",
          "hint": "secret",
          "description": "可选，EasyTier 网络密钥。相同网络名称和密钥的节点属于同一虚拟网络。",
          "required": false
        },
        {
          "path": "no-listener",
          "title": "no-listener",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否禁用监听，默认值为 true（即 listeners 为空）。不能与 listeners 同时启用；显式设置为 false 且 listeners 为空时，使用默认监听地址 tcp://0.0.0.0:11010。",
          "required": false
        },
        {
          "path": "peers",
          "title": "peers",
          "kind": "list",
          "hint": "[\"tcp://192.0.2.10:11010\",\"udp://192.0.2.11:11010\"]",
          "description": "可选，初始连接的入口节点列表，可配置多个，支持 tcp://、udp:// 等协议 URI。 默认不会隐式连接 public.easytier.top；listeners 为空时至少需要配置一个。 在 URI 中追加 peer-public-key 查询参数可锁定共享节点的公钥，防止中间人攻击：",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "private-mode",
          "title": "private-mode",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否启用隐私模式，默认值为 false。",
          "required": false
        },
        {
          "path": "proxy-networks",
          "title": "proxy-networks",
          "kind": "list",
          "hint": "[\"10.0.0.0/24\"]",
          "description": "可选，需要通过 EasyTier 网络代理访问的远端子网（CIDR）列表，如 10.0.0.0/24。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "可选，设置 Linux 路由标记。",
          "required": false
        },
        {
          "path": "secure-mode",
          "title": "secure-mode",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否启用 Noise 端到端加密。配置了 local-private-key、local-public-key 或 peer URI 中的 peer-public-key 时会自动开启。",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "state-dir",
          "title": "state-dir",
          "kind": "string",
          "hint": "./easytier",
          "description": "可选，状态目录，默认值为 easytier/<代理名称>，用于持久化 instance_id。",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "tld-dns-zone",
          "title": "tld-dns-zone",
          "kind": "string",
          "hint": "et.net.",
          "description": "可选，MagicDNS 使用的 TLD DNS 区域，默认值为 et.net.。 在 DNS 配置中可使用 et://<代理名称> 解析 overlay 网络中的 A/PTR 记录，建议配合 nameserver-policy 使用。",
          "required": false,
          "defaultHint": "et.net."
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否启用 UDP，默认值为 false。",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "ECH 配置，如果为空则通过 dns 解析，不为空则通过该值指定，格式为经过 base64 编码的 ech 参数（例如AEn+DQBFKwAgACABWIHUGj4u+PIggYXcR5JF0gYk3dCRioBW8uJq9H4mKAAIAAEAAQABAANAEnB1YmxpYy50bHMtZWNoLmRldgAA） 您可以通过mihomo generate ech-keypair test.com命令为服务器端和客户端生成符合要求的自签名 ech 配置对，请将test.com自行替换为您想要对外展现的 SNI ",
          "required": false
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 ECH（Encrypted Client Hello），如果为 true，则启用 ECH",
          "required": false
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "可选项，不为空时用于指定通过 dns 解析时的域名",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "headers",
          "title": "headers",
          "kind": "map",
          "hint": "{}",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "dual",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码",
          "required": false
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码",
          "required": false
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "TLS 版本提示，可选值为 tls12 / tls13",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ]
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码",
          "required": false
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "支持 v1 / v2 / v3；留空时默认为 v2。",
          "required": false,
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "custom.com",
          "description": "",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 tls，仅适用于使用 tls 的协议，trojan 协议强制启用",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server.com",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "auth-str",
          "title": "auth-str",
          "kind": "secret",
          "hint": "yourpassword",
          "description": "",
          "required": false
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "disable_mtu_discovery",
          "title": "disable_mtu_discovery",
          "kind": "boolean",
          "hint": "false",
          "description": "",
          "required": false
        },
        {
          "path": "down",
          "title": "down",
          "kind": "string",
          "hint": "200 Mbps",
          "description": "",
          "required": false
        },
        {
          "path": "fast-open",
          "title": "fast-open",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "obfs",
          "title": "obfs",
          "kind": "string",
          "hint": "obfs_str",
          "description": "",
          "required": false
        },
        {
          "path": "ports",
          "title": "ports",
          "kind": "string",
          "hint": "1000,2000-3000,4000",
          "description": "",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "protocol",
          "title": "protocol",
          "kind": "string",
          "hint": "udp",
          "description": "",
          "required": false
        },
        {
          "path": "recv-window",
          "title": "recv-window",
          "kind": "integer",
          "hint": "52428800",
          "description": "",
          "required": false
        },
        {
          "path": "recv-window-conn",
          "title": "recv-window-conn",
          "kind": "integer",
          "hint": "12582912",
          "description": "",
          "required": false
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "false",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "server.com",
          "description": "",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "up",
          "title": "up",
          "kind": "string",
          "hint": "30 Mbps",
          "description": "",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server.com",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "yourpassword",
          "description": "认证密码",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ]
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "down",
          "title": "down",
          "kind": "string",
          "hint": "200 Mbps",
          "description": "",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "handshake-timeout",
          "title": "handshake-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "单位为秒；配置后握手时不受外层连接超时影响；默认值为 0，表示仅使用外层连接超时",
          "required": false,
          "defaultHint": "0"
        },
        {
          "path": "hop-interval",
          "title": "hop-interval",
          "kind": "string",
          "hint": "30",
          "description": "端口跳跃的间隔，单位为秒，默认为 30 支持填写\"15-30\"会每次随机选取其中一个值作为切换间隔，仅支持写一个范围（即不允许出现逗号）",
          "required": false,
          "defaultHint": "30"
        },
        {
          "path": "initial-connection-receive-window",
          "title": "initial-connection-receive-window",
          "kind": "integer",
          "hint": "20971520",
          "description": "",
          "required": false
        },
        {
          "path": "initial-stream-receive-window",
          "title": "initial-stream-receive-window",
          "kind": "integer",
          "hint": "8388608",
          "description": "",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "max-connection-receive-window",
          "title": "max-connection-receive-window",
          "kind": "integer",
          "hint": "20971520",
          "description": "",
          "required": false
        },
        {
          "path": "max-stream-receive-window",
          "title": "max-stream-receive-window",
          "kind": "integer",
          "hint": "8388608",
          "description": "",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "obfs",
          "title": "obfs",
          "kind": "choice",
          "hint": "salamander",
          "description": "QUIC 流量混淆器类型，可设为 salamander或gecko，如果为空则禁用",
          "required": false,
          "choices": [
            "salamander",
            "gecko"
          ]
        },
        {
          "path": "obfs-max-packet-size",
          "title": "obfs-max-packet-size",
          "kind": "integer",
          "hint": "1200",
          "description": "最大线上数据包大小（字节）。仅限 gecko。",
          "required": false
        },
        {
          "path": "obfs-min-packet-size",
          "title": "obfs-min-packet-size",
          "kind": "integer",
          "hint": "512",
          "description": "最小线上数据包大小（字节）。仅限 gecko。",
          "required": false
        },
        {
          "path": "obfs-password",
          "title": "obfs-password",
          "kind": "secret",
          "hint": "yourpassword",
          "description": "QUIC 流量混淆器密码",
          "required": false
        },
        {
          "path": "ports",
          "title": "ports",
          "kind": "string",
          "hint": "443-8443",
          "description": "配置则启用端口跳跃，忽略port，格式参考端口范围",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "realm-opts.enable",
          "title": "realm-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "realm-opts.realm-id",
          "title": "realm-opts.realm-id",
          "kind": "string",
          "hint": "my-cabin-1f3a8c2e9b",
          "description": "",
          "required": false
        },
        {
          "path": "realm-opts.server-url",
          "title": "realm-opts.server-url",
          "kind": "string",
          "hint": "https://realm.hy2.io",
          "description": "",
          "required": false
        },
        {
          "path": "realm-opts.stun-servers",
          "title": "realm-opts.stun-servers",
          "kind": "list",
          "hint": "[\"stun.nextcloud.com:3478\",\"stun.sip.us:3478\",\"global.stun.twilio.com:3478\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "realm-opts.token",
          "title": "realm-opts.token",
          "kind": "secret",
          "hint": "public",
          "description": "",
          "required": false
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "false",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "server.com",
          "description": "",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "up",
          "title": "up",
          "kind": "string",
          "hint": "30 Mbps",
          "description": "",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server.com",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ]
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "bbr",
          "description": "修改默认的拥塞控制算法，默认为不启用，可选值包括 bbr",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"1.1.1.1\",\"8.8.8.8\"]",
          "description": "远程 DNS 服务器列表，在启用 remote-dns-resolve 后生效",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "handshake-timeout",
          "title": "handshake-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "握手超时时间，单位为秒。默认值为 0，表示仅使用外层连接超时",
          "required": false,
          "defaultHint": "0"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip",
          "title": "ip",
          "kind": "string",
          "hint": "172.16.0.2/32",
          "description": "本地 IPv4 地址，CIDR 格式（如 172.16.0.2/32）",
          "required": false
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法，可选值：cubic、reno、bbr、bbr3，默认为 cubic 对于 gVisor IP 协议栈，该选项不会生效。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "可选值：auto、gvisor、mips。默认值为 auto。auto 始终使用 mihomo IP 协议栈（MIPS）；gvisor 需使用 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ]
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "ipv6",
          "title": "ipv6",
          "kind": "string",
          "hint": "fd00::2/128",
          "description": "本地 IPv6 地址，CIDR 格式（如 fd00::2/128）",
          "required": false
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1280",
          "description": "TUN 设备的 MTU 大小，默认为 1280",
          "required": false,
          "defaultHint": "1280"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "h2",
          "description": "可选，默认为 quic。masque-h2 需要设置为 h2，h3-l4proxy 模式需要设置为 h3-l4proxy h3-l4proxy 模式目前不支持 UDP。",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "grpc",
            "h2",
            "http"
          ]
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "BASE64_ENCODED_PRIVATE_KEY",
          "description": "必须，base64 编码的 ECDSA 私钥",
          "required": false
        },
        {
          "path": "public-key",
          "title": "public-key",
          "kind": "string",
          "hint": "BASE64_ENCODED_PUBLIC_KEY",
          "description": "必须，base64 编码的 ECDSA 公钥（服务器端公钥） 注意去掉 PEM 格式中的头尾标识符，如 -----BEGIN PUBLIC KEY----- ， -----END PUBLIC KEY----- 和 PEM 格式中的换行符 \\n。",
          "required": false
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用远程 DNS 解析，通过 MASQUE 隧道解析 DNS",
          "required": false
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 tls，仅适用于使用 tls 的协议，trojan 协议强制启用",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 UDP 支持，默认为 false",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "2999",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "",
          "required": true
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "user",
          "description": "",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "handshake-mode",
          "title": "handshake-mode",
          "kind": "string",
          "hint": "HANDSHAKE_STANDARD",
          "description": "握手模式。HANDSHAKE_STANDARD（默认）等待握手完成；HANDSHAKE_NO_WAIT 启用 0-RTT 握手。",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "multiplexing",
          "title": "multiplexing",
          "kind": "string",
          "hint": "MULTIPLEXING_LOW",
          "description": "多路复用，可以使用的值包括 MULTIPLEXING_OFF, MULTIPLEXING_LOW, MULTIPLEXING_MIDDLE, MULTIPLEXING_HIGH。其中 MULTIPLEXING_OFF 会关闭多路复用功能。默认值为 MULTIPLEXING_LOW",
          "required": false,
          "defaultHint": "MULTIPLEXING_LOW"
        },
        {
          "path": "port-range",
          "title": "port-range",
          "kind": "string",
          "hint": "2090-2099",
          "description": "端口范围，不可与 port 同时书写",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "traffic-pattern",
          "title": "traffic-pattern",
          "kind": "string",
          "hint": "",
          "description": "一个 base64 字符串用于微调网络行为，格式请参考mieru 官方文档",
          "required": false
        },
        {
          "path": "transport",
          "title": "transport",
          "kind": "choice",
          "hint": "TCP",
          "description": "协议，目前支持 TCP 和 UDP",
          "required": false,
          "choices": [
            "TCP",
            "UDP"
          ]
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "vpn.example.com",
          "description": "必须，OpenVPN 服务器地址。",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "1194",
          "description": "必须，OpenVPN 服务器端口，默认 1194。",
          "required": true
        },
        {
          "path": "auth",
          "title": "auth",
          "kind": "string",
          "hint": "SHA256",
          "description": "可选，数据验证算法，支持 MD5 /SHA1 / SHA256/ SHA384 / SHA512，默认 SHA256；AEAD cipher 会忽略 auth。",
          "required": false
        },
        {
          "path": "ca",
          "title": "ca",
          "kind": "string",
          "hint": "-----BEGIN CERTIFICATE-----\nMIIB...example\n-----END CERTIFICATE-----\n",
          "description": "必须，CA 证书内容。请从 .ovpn 文件的 <ca> 标签中复制。",
          "required": false
        },
        {
          "path": "cert",
          "title": "cert",
          "kind": "string",
          "hint": "",
          "description": "可选，客户端证书内容。从 .ovpn 文件的 <cert> 标签中复制。使用用户名/密码认证时可省略。",
          "required": false
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "string",
          "hint": "AES-128-GCM",
          "description": "可选，加密方式，支持 AES-128-GCM / AES-256-GCM/ AES-128-CBC / AES-256-CBC /CHACHA20-POLY1305默认 AES-128-GCM， AES-CBC 会按 AES-128-CBC 处理。",
          "required": false
        },
        {
          "path": "comp-lzo",
          "title": "comp-lzo",
          "kind": "string",
          "hint": "no",
          "description": "可选，数据压缩方式。可选值：yes、no、adaptive。",
          "required": false
        },
        {
          "path": "data-ciphers",
          "title": "data-ciphers",
          "kind": "list",
          "hint": "[\"AES-256-GCM\",\"AES-128-GCM\"]",
          "description": "可选，数据通道 cipher 协商列表，发送 IV_CIPHERS 给服务端；服务端 push 的 cipher 列表与本地列表取交集，取第一个匹配项。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "data-ciphers-fallback",
          "title": "data-ciphers-fallback",
          "kind": "string",
          "hint": "AES-128-CBC",
          "description": "可选，协商失败时的回退 cipher（对应 --data-ciphers-fallback）",
          "required": false
        },
        {
          "path": "dev",
          "title": "dev",
          "kind": "string",
          "hint": "tun",
          "description": "可选，虚拟网卡类型，当前仅支持 tun，默认 tun。",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "可选，指定出站代理的标识。若设置，OpenVPN 连接将通过该代理发出。",
          "required": false
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"1.1.1.1\",\"8.8.8.8\"]",
          "description": "可选，仅在 remote-dns-resolve 为 true 时生效，指定远程解析的 DNS 地址列表。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "handshake-timeout",
          "title": "handshake-timeout",
          "kind": "integer",
          "hint": "30",
          "description": "可选，握手超时时间，单位为秒。默认值为 0，表示仅使用外层连接超时。",
          "required": false,
          "defaultHint": "0"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法，可选值：cubic、reno、bbr、bbr3，默认为 cubic 对于 gVisor IP 协议栈，该选项不会生效。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "可选值：auto、gvisor、mips。默认值为 auto。auto 始终使用 mihomo IP 协议栈（MIPS）；gvisor 需使用 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ]
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "key",
          "title": "key",
          "kind": "string",
          "hint": "",
          "description": "可选，客户端私钥内容。从 .ovpn 文件的 <key> 标签中复制。使用用户名/密码认证时可省略。",
          "required": false
        },
        {
          "path": "key-direction",
          "title": "key-direction",
          "kind": "string",
          "hint": "1",
          "description": "可选，使用 tls-auth 时填写，支持 \"1\" 或 \"0\"；如果不填或为空字符串，则默认为双向模式（bidirectional）。",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1500",
          "description": "可选，最大传输单元，默认 1500。",
          "required": false,
          "defaultHint": "1500"
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "pass",
          "description": "",
          "required": false
        },
        {
          "path": "peer-info.IV_HWADDR",
          "title": "peer-info.IV_HWADDR",
          "kind": "string",
          "hint": "52:54:00:ff:72:87",
          "description": "",
          "required": false
        },
        {
          "path": "peer-info.UV_DEVICE_ID",
          "title": "peer-info.UV_DEVICE_ID",
          "kind": "string",
          "hint": "laptop-001",
          "description": "",
          "required": false
        },
        {
          "path": "ping",
          "title": "ping",
          "kind": "integer",
          "hint": "10",
          "description": "可选，默认值为0。",
          "required": false,
          "defaultHint": "0"
        },
        {
          "path": "ping-restart",
          "title": "ping-restart",
          "kind": "integer",
          "hint": "60",
          "description": "可选，默认值为0。",
          "required": false,
          "defaultHint": "0"
        },
        {
          "path": "proto",
          "title": "proto",
          "kind": "string",
          "hint": "udp",
          "description": "可选，协议类型，支持 udp 或 tcp，默认 udp。",
          "required": false
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否强制 DNS 远程解析，默认 false。",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "tls-auth",
          "title": "tls-auth",
          "kind": "string",
          "hint": "",
          "description": "可选，从 .ovpn 文件的 <tls-auth> 标签中复制，与 tls-crypt / tls-crypt-v2 互斥",
          "required": false
        },
        {
          "path": "tls-crypt",
          "title": "tls-crypt",
          "kind": "string",
          "hint": "",
          "description": "可选，TLS 加密密钥。从 .ovpn 文件的 <tls-crypt> 标签中复制，不需要保留标签。与 tls-auth / tls-crypt-v2 互斥。",
          "required": false
        },
        {
          "path": "tls-crypt-v2",
          "title": "tls-crypt-v2",
          "kind": "string",
          "hint": "",
          "description": "可选，从 .ovpn 文件的 <tls-crypt-v2> 标签中复制客户端密钥，不需要保留标签。与 tls-auth / tls-crypt 互斥。",
          "required": false
        },
        {
          "path": "tran-window",
          "title": "tran-window",
          "kind": "integer",
          "hint": "3600",
          "description": "旧 data key 在 rekey 后保留的秒数；默认 3600，显式设为 0 表示立即过期，应与服务端 --tran-window 对齐",
          "required": false,
          "defaultHint": "3600"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否启用 UDP。true 表示使用 UDP，false 表示使用 TCP。",
          "required": false
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "user",
          "description": "",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "target-rematch-name",
          "title": "target-rematch-name",
          "kind": "string",
          "hint": "streaming",
          "description": "覆盖原始 metadata 中的 rematch-name，可使用 REMATCH-NAME 规则匹配",
          "required": false
        },
        {
          "path": "target-sub-rule",
          "title": "target-sub-rule",
          "kind": "string",
          "hint": "ai-rules",
          "description": "如果填写，后续会直接使用指定的 sub-rule 匹配；如果名称不存在或为空，则回退到主 rules",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "www.example.com",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "10443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "必须，用于 ShadowQUIC 的认证密码",
          "required": true
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "必须，用于 ShadowQUIC 的认证用户名",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "可选，应用层协议协商列表，默认使用 h3",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "standard",
          "description": "可选，设置 BBR 算法的激进程度配置，可选值为 standard/conservative/aggressive，仅在拥塞控制算法为 bbr 时有效",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ]
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "可选，设置拥塞控制算法，可选值为 cubic/new_reno/bbr，默认为 cubic",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "cwnd",
          "title": "cwnd",
          "kind": "integer",
          "hint": "32",
          "description": "可选，设置初始拥塞窗口大小（Initial Congestion Window size），默认为 32",
          "required": false,
          "defaultHint": "32"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "disable-mtu-discovery",
          "title": "disable-mtu-discovery",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，设置是否禁用路径 MTU 发现（Path MTU Discovery），若设为 true 则使用固定的 MTU 大小",
          "required": false
        },
        {
          "path": "down",
          "title": "down",
          "kind": "string",
          "hint": "100 Mbps",
          "description": "可选，设置客户端请求的下载速度，受 Listener 的 up 限制。填写后将通过 mihomo 私有扩展协商 Brutal；对端不支持时回退到 congestion-controller",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "keep-alive-interval",
          "title": "keep-alive-interval",
          "kind": "integer",
          "hint": "10000",
          "description": "可选，发送保持连接活动的心跳包的间隔时间，单位为毫秒",
          "required": false
        },
        {
          "path": "max-datagram-frame-size",
          "title": "max-datagram-frame-size",
          "kind": "integer",
          "hint": "1400",
          "description": "可选，设置允许的最大数据报帧大小，单位为字节，默认为 1400",
          "required": false,
          "defaultHint": "1400"
        },
        {
          "path": "max-open-streams",
          "title": "max-open-streams",
          "kind": "integer",
          "hint": "1024",
          "description": "可选，设置最大同时打开的并发流数量，默认为 1024",
          "required": false,
          "defaultHint": "1024"
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "quic-versions",
          "title": "quic-versions",
          "kind": "list",
          "hint": "[\"v1\"]",
          "description": "可选，设置支持的 QUIC 版本，可选值为 v1/v2，默认为 v1",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "recv-window",
          "title": "recv-window",
          "kind": "integer",
          "hint": "0",
          "description": "可选，设置连接级别的接收窗口大小，如果设为 0 则使用内部默认值",
          "required": false
        },
        {
          "path": "recv-window-conn",
          "title": "recv-window-conn",
          "kind": "integer",
          "hint": "0",
          "description": "可选，设置单个流级别的接收窗口大小，如果设为 0 则使用内部默认值",
          "required": false
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，ShadowQUIC TLS 握手使用的 SNI",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "udp-over-stream",
          "title": "udp-over-stream",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，设置是否通过数据流传输 UDP（UDP over stream），默认为 false",
          "required": false
        },
        {
          "path": "up",
          "title": "up",
          "kind": "string",
          "hint": "100 Mbps",
          "description": "可选，设置客户端上传速度。填写后将通过 mihomo 私有扩展协商 Brutal；对端不支持时回退到 congestion-controller",
          "required": false
        },
        {
          "path": "zero-rtt",
          "title": "zero-rtt",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，设置是否开启 0-RTT（零往返时延握手）。 官方 server 的 0-RTT 路径可能在 JLS 认证完成前读取用户状态（已确认影响 v0.3.11）；使用官方 server 如果遇到不通或断联情况，请在服务端关闭 zero-rtt",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "44046",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "psk",
          "title": "psk",
          "kind": "secret",
          "hint": "yourpsk",
          "description": "",
          "required": true
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 utls 指纹，仅适用于 VMess/VLESS/Trojan/AnyTLS 协议 可选：chrome, firefox, safari, ios, android, edge, 360, qq, random, 若选择 random, 则按 Cloudflare Radar 数据按概率生成一个现代浏览器指纹。",
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
          ]
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "obfs-opts.alpn",
          "title": "obfs-opts.alpn",
          "kind": "list",
          "hint": "[\"h2\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "obfs-opts.host",
          "title": "obfs-opts.host",
          "kind": "string",
          "hint": "bing.com",
          "description": "",
          "required": false
        },
        {
          "path": "obfs-opts.mode",
          "title": "obfs-opts.mode",
          "kind": "choice",
          "hint": "jls",
          "description": "",
          "required": false,
          "choices": [
            "http",
            "tls",
            "shadow-tls",
            "restls",
            "jls"
          ]
        },
        {
          "path": "obfs-opts.password",
          "title": "obfs-opts.password",
          "kind": "secret",
          "hint": "jls_password",
          "description": "",
          "required": false
        },
        {
          "path": "obfs-opts.username",
          "title": "obfs-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名，仅使用 jls 时需填写",
          "required": false
        },
        {
          "path": "obfs-opts.version",
          "title": "obfs-opts.version",
          "kind": "integer",
          "hint": "2",
          "description": "",
          "required": false
        },
        {
          "path": "obfs-opts.version-hint",
          "title": "obfs-opts.version-hint",
          "kind": "string",
          "hint": "tls13",
          "description": "Restls TLS 版本提示，可选值为 tls12 / tls13",
          "required": false
        },
        {
          "path": "reuse",
          "title": "reuse",
          "kind": "boolean",
          "hint": "false",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "version",
          "title": "version",
          "kind": "integer",
          "hint": "4",
          "description": "",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "ECH 配置，如果为空则通过 dns 解析，不为空则通过该值指定，格式为经过 base64 编码的 ech 参数（例如AEn+DQBFKwAgACABWIHUGj4u+PIggYXcR5JF0gYk3dCRioBW8uJq9H4mKAAIAAEAAQABAANAEnB1YmxpYy50bHMtZWNoLmRldgAA） 您可以通过mihomo generate ech-keypair test.com命令为服务器端和客户端生成符合要求的自签名 ech 配置对，请将test.com自行替换为您想要对外展现的 SNI ",
          "required": false
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 ECH（Encrypted Client Hello），如果为 true，则启用 ECH",
          "required": false
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "可选项，不为空时用于指定通过 dns 解析时的域名",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv6",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码",
          "required": false
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码",
          "required": false
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "TLS 版本提示，可选值为 tls12 / tls13",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ]
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码",
          "required": false
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "支持 v1 / v2 / v3；留空时默认为 v2。",
          "required": false,
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 tls，仅适用于使用 tls 的协议，trojan 协议强制启用",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "string",
          "hint": "aes-128-gcm",
          "description": "=== \"AES\" | 方法 | | | |----------------------------|----------------------------|----------------------------| | aes-128-ctr | aes-192-ctr | aes-256-ctr | | aes-128-cfb | aes-192-cfb | aes-256-cfb | | aes-128-gcm | aes-192-gcm | aes-256-gcm | | aes-128-ccm | ae",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "Shadowsocks 密码",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "plugin",
          "title": "plugin",
          "kind": "string",
          "hint": "obfs",
          "description": "插件，支持 obfs/v2ray-plugin/gost-plugin/shadow-tls/restls/kcptun/jls",
          "required": false
        },
        {
          "path": "plugin-opts.mode",
          "title": "plugin-opts.mode",
          "kind": "choice",
          "hint": "tls",
          "description": "",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ]
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "udp-over-tcp",
          "title": "udp-over-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 UDP over TCP，默认 false",
          "required": false
        },
        {
          "path": "udp-over-tcp-version",
          "title": "udp-over-tcp-version",
          "kind": "integer",
          "hint": "2",
          "description": "UDP over TCP 的协议版本，默认 1。可选值 1/2。",
          "required": false,
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "127.0.0.1",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "22",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "root",
          "description": "",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "host-key",
          "title": "host-key",
          "kind": "list",
          "hint": "[\"ssh-rsa AAAAB3NzaC1yc2EAA...\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "host-key-algorithms",
          "title": "host-key-algorithms",
          "kind": "list",
          "hint": "[\"rsa\"]",
          "description": "",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "key",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "private-key-passphrase",
          "title": "private-key-passphrase",
          "kind": "secret",
          "hint": "key_password",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "string",
          "hint": "chacha20-ietf",
          "description": "",
          "required": true
        },
        {
          "path": "obfs",
          "title": "obfs",
          "kind": "string",
          "hint": "tls1.2_ticket_auth",
          "description": "",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "",
          "required": true
        },
        {
          "path": "protocol",
          "title": "protocol",
          "kind": "string",
          "hint": "auth_sha1_v4",
          "description": "",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "obfs-param",
          "title": "obfs-param",
          "kind": "string",
          "hint": "domain.tld",
          "description": "",
          "required": false
        },
        {
          "path": "protocol-param",
          "title": "protocol-param",
          "kind": "string",
          "hint": "#",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "1.2.3.4",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "aead-method",
          "title": "aead-method",
          "kind": "string",
          "hint": "chacha20-poly1305",
          "description": "可选值：chacha20-poly1305、aes-128-gcm、none。不建议使用 none，因为它不提供 AEAD 保护。",
          "required": false
        },
        {
          "path": "custom-table",
          "title": "custom-table",
          "kind": "string",
          "hint": "xpxvvpvv",
          "description": "可选，自定义字节布局，必须包含 2 个 x、2 个 p、4 个 v，可随意组合；只对 entropy 方向生效",
          "required": false
        },
        {
          "path": "custom-tables",
          "title": "custom-tables",
          "kind": "list",
          "hint": "[\"xpxvvpvv\",\"vxpvxvvp\"]",
          "description": "可选，自定义字节布局列表（x/v/p），非空时覆盖 custom-table",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "enable-pure-downlink",
          "title": "enable-pure-downlink",
          "kind": "boolean",
          "hint": "false",
          "description": "选择下行模式：false 为带宽优化下行，true 为纯 Sudoku 下行。该配置需要与服务端保持一致。",
          "required": false
        },
        {
          "path": "httpmask.disable",
          "title": "httpmask.disable",
          "kind": "boolean",
          "hint": "false",
          "description": "是否禁用所有 HTTP 伪装/隧道",
          "required": false
        },
        {
          "path": "httpmask.host",
          "title": "httpmask.host",
          "kind": "string",
          "hint": "",
          "description": "可选：覆盖 Host/SNI（支持 example.com 或 example.com:443）；仅在 mode 为 stream/poll/auto/ws 时生效",
          "required": false
        },
        {
          "path": "httpmask.mode",
          "title": "httpmask.mode",
          "kind": "choice",
          "hint": "legacy",
          "description": "可选：legacy（默认）、stream、poll、auto、ws；stream/poll/auto/ws 支持走 CDN/反代",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ]
        },
        {
          "path": "httpmask.multiplex",
          "title": "httpmask.multiplex",
          "kind": "string",
          "hint": "off",
          "description": "兼容旧配置；设置时优先于顶层 multiplex",
          "required": false
        },
        {
          "path": "httpmask.path-root",
          "title": "httpmask.path-root",
          "kind": "string",
          "hint": "",
          "description": "可选：HTTP 隧道端点一级路径前缀（双方需一致），例如 \"aabbcc\" => /aabbcc/session、/aabbcc/stream、/aabbcc/api/v1/upload、/aabbcc/ws",
          "required": false
        },
        {
          "path": "httpmask.tls",
          "title": "httpmask.tls",
          "kind": "boolean",
          "hint": "true",
          "description": "可选：仅在 mode 为 stream/poll/auto/ws 时生效；true 强制 https；false 强制 http（不会根据端口自动推断）",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "key",
          "title": "key",
          "kind": "string",
          "hint": "<client_key>",
          "description": "如果你使用 sudoku 生成的 ED25519 密钥对，请填写密钥对中的私钥，否则填入和服务端相同的 uuid",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "multiplex",
          "title": "multiplex",
          "kind": "string",
          "hint": "off",
          "description": "可选：off（默认）、auto（仅复用 HTTPMask 底层连接）、on（在原始 TCP 或 HTTPMask 上启用 Sudoku 单会话多目标 mux）",
          "required": false
        },
        {
          "path": "padding-max",
          "title": "padding-max",
          "kind": "integer",
          "hint": "7",
          "description": "最大填充率，范围为 0-100，且必须大于或等于 padding-min。",
          "required": false
        },
        {
          "path": "padding-min",
          "title": "padding-min",
          "kind": "integer",
          "hint": "2",
          "description": "最小填充率，范围为 0-100。",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "table-type",
          "title": "table-type",
          "kind": "string",
          "hint": "prefer_ascii",
          "description": "可选值：prefer_ascii、prefer_entropy、up_ascii_down_entropy、up_entropy_down_ascii",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复。",
          "required": true
        },
        {
          "path": "accept-routes",
          "title": "accept-routes",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否接受 Tailnet 中发布的 subnet routes。",
          "required": false
        },
        {
          "path": "auth-key",
          "title": "auth-key",
          "kind": "string",
          "hint": "tskey-auth-xxxx",
          "description": "可选，Tailscale 或 Headscale 的登录密钥。不填写时，首次启动会在日志中输出交互式登录 URL。",
          "required": false
        },
        {
          "path": "control-url",
          "title": "control-url",
          "kind": "string",
          "hint": "https://controlplane.tailscale.com",
          "description": "可选，自定义 Tailscale control server 或 Headscale 地址。",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "可选，一个出站代理的标识。当值不为空时，将使用指定的 proxy 发出 Tailscale 控制面和 DERP/STUN 等连接。",
          "required": false
        },
        {
          "path": "ephemeral",
          "title": "ephemeral",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否作为 ephemeral node 登录，默认值为 false。",
          "required": false
        },
        {
          "path": "exit-node",
          "title": "exit-node",
          "kind": "string",
          "hint": "100.64.0.1",
          "description": "可选，使用指定 exit node。可以填写节点 IP，也可以填写 auto:any。 当目标不在 Tailscale 路由内时，连接会直接报错，不会回退到直连。访问公网需要配置可用的 exit-node，或接受覆盖目标网段的 subnet routes。",
          "required": false
        },
        {
          "path": "exit-node-allow-lan-access",
          "title": "exit-node-allow-lan-access",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，使用 exit node 时是否允许访问本地 LAN。",
          "required": false
        },
        {
          "path": "hostname",
          "title": "hostname",
          "kind": "string",
          "hint": "mihomo",
          "description": "可选，Tailscale 设备名。不填写时由 tsnet 处理。",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "WLAN",
          "description": "可选，指定出站网卡。",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4-prefer",
          "description": "可选，指定出站使用的 IP 版本。 可选值：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "可选，Linux 下配置 fwmark。",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "state-dir",
          "title": "state-dir",
          "kind": "string",
          "hint": "./tailscale",
          "description": "可选，tsnet 状态目录，默认值为 tailscale。",
          "required": false,
          "defaultHint": "tailscale"
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否启用 UDP，默认值为 false。",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "yourpsk",
          "description": "",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "random",
          "description": "客户端 utls 指纹，仅适用于 VMess/VLESS/Trojan/AnyTLS 协议 可选：chrome, firefox, safari, ios, android, edge, 360, qq, random, 若选择 random, 则按 Cloudflare Radar 数据按概率生成一个现代浏览器指纹。",
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
          ]
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "ECH 配置，如果为空则通过 dns 解析，不为空则通过该值指定，格式为经过 base64 编码的 ech 参数（例如AEn+DQBFKwAgACABWIHUGj4u+PIggYXcR5JF0gYk3dCRioBW8uJq9H4mKAAIAAEAAQABAANAEnB1YmxpYy50bHMtZWNoLmRldgAA） 您可以通过mihomo generate ech-keypair test.com命令为服务器端和客户端生成符合要求的自签名 ech 配置对，请将test.com自行替换为您想要对外展现的 SNI ",
          "required": false
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 ECH（Encrypted Client Hello），如果为 true，则启用 ECH",
          "required": false
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "可选项，不为空时用于指定通过 dns 解析时的域名",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "grpc-opts.grpc-service-name",
          "title": "grpc-opts.grpc-service-name",
          "kind": "string",
          "hint": "example",
          "description": "gRPC 服务名称",
          "required": false
        },
        {
          "path": "grpc-opts.grpc-user-agent",
          "title": "grpc-opts.grpc-user-agent",
          "kind": "string",
          "hint": "",
          "description": "gRPC UserAgent",
          "required": false
        },
        {
          "path": "grpc-opts.max-connections",
          "title": "grpc-opts.max-connections",
          "kind": "integer",
          "hint": "1",
          "description": "最大连接数量。默认值为 1 即只使用一条底层链接 与 max-streams 冲突",
          "required": false,
          "defaultHint": "1"
        },
        {
          "path": "grpc-opts.max-streams",
          "title": "grpc-opts.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "grpc-opts.min-streams",
          "title": "grpc-opts.min-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "grpc-opts.ping-interval",
          "title": "grpc-opts.ping-interval",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 心跳包间隔，默认关闭，单位为秒",
          "required": false
        },
        {
          "path": "h2-opts.host",
          "title": "h2-opts.host",
          "kind": "list",
          "hint": "[\"example.com\"]",
          "description": "主机域名列表，如果设置，客户端将随机选择，服务器将验证",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "h2-opts.path",
          "title": "h2-opts.path",
          "kind": "string",
          "hint": "/",
          "description": "http 请求路径",
          "required": false
        },
        {
          "path": "http-opts.headers",
          "title": "http-opts.headers",
          "kind": "map",
          "hint": "{\"Connection\":[\"keep-alive\"]}",
          "description": "http 请求头 Mihomo 的 H2 传输层未实现多路复用功能，如果需要使用多路复用，在 Mihomo 中更建议使用 gRPC 协议，或者 sing-mux",
          "required": false,
          "elementKind": "list"
        },
        {
          "path": "http-opts.method",
          "title": "http-opts.method",
          "kind": "string",
          "hint": "GET",
          "description": "http 请求方法",
          "required": false
        },
        {
          "path": "http-opts.path",
          "title": "http-opts.path",
          "kind": "list",
          "hint": "[\"/\",\"/video\"]",
          "description": "http 请求路径",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码",
          "required": false
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "tcp",
          "description": "",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "grpc",
            "h2",
            "http"
          ]
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "reality-opts.public-key",
          "title": "reality-opts.public-key",
          "kind": "string",
          "hint": "xxxx",
          "description": "reality 服务端私钥对应的公钥",
          "required": false
        },
        {
          "path": "reality-opts.short-id",
          "title": "reality-opts.short-id",
          "kind": "string",
          "hint": "xxxx",
          "description": "服务端 short id 之一",
          "required": false
        },
        {
          "path": "reality-opts.support-x25519mlkem768",
          "title": "reality-opts.support-x25519mlkem768",
          "kind": "boolean",
          "hint": "true",
          "description": "支持 X25519-MLKEM768 密钥交换",
          "required": false
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码",
          "required": false
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "TLS 版本提示，可选值为 tls12 / tls13",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ]
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码",
          "required": false
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "支持 v1 / v2 / v3；留空时默认为 v2。",
          "required": false,
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "ss-opts.enabled",
          "title": "ss-opts.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "",
          "required": false
        },
        {
          "path": "ss-opts.method",
          "title": "ss-opts.method",
          "kind": "string",
          "hint": "aes-128-gcm",
          "description": "",
          "required": false
        },
        {
          "path": "ss-opts.password",
          "title": "ss-opts.password",
          "kind": "secret",
          "hint": "example",
          "description": "",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "ws-opts.early-data-header-name",
          "title": "ws-opts.early-data-header-name",
          "kind": "string",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "ws-opts.headers",
          "title": "ws-opts.headers",
          "kind": "map",
          "hint": "{\"Host\":\"example.com\"}",
          "description": "请求头",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "ws-opts.max-early-data",
          "title": "ws-opts.max-early-data",
          "kind": "string",
          "hint": "",
          "description": "Early Data 首包长度阈值",
          "required": false
        },
        {
          "path": "ws-opts.path",
          "title": "ws-opts.path",
          "kind": "string",
          "hint": "/path",
          "description": "请求路径",
          "required": false
        },
        {
          "path": "ws-opts.v2ray-http-upgrade",
          "title": "ws-opts.v2ray-http-upgrade",
          "kind": "boolean",
          "hint": "false",
          "description": "使用 http upgrade",
          "required": false
        },
        {
          "path": "ws-opts.v2ray-http-upgrade-fast-open",
          "title": "ws-opts.v2ray-http-upgrade-fast-open",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 http upgrade 的 fast open",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "1.2.3.4",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "password",
          "description": "",
          "required": true
        },
        {
          "path": "username",
          "title": "username",
          "kind": "string",
          "hint": "username",
          "description": "",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ]
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 utls 指纹，仅适用于 VMess/VLESS/Trojan/AnyTLS 协议 可选：chrome, firefox, safari, ios, android, edge, 360, qq, random, 若选择 random, 则按 Cloudflare Radar 数据按概率生成一个现代浏览器指纹。",
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
          ]
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "bbr",
          "description": "设置 QUIC 拥塞控制算法。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "ECH 配置，如果为空则通过 dns 解析，不为空则通过该值指定，格式为经过 base64 编码的 ech 参数（例如AEn+DQBFKwAgACABWIHUGj4u+PIggYXcR5JF0gYk3dCRioBW8uJq9H4mKAAIAAEAAQABAANAEnB1YmxpYy50bHMtZWNoLmRldgAA） 您可以通过mihomo generate ech-keypair test.com命令为服务器端和客户端生成符合要求的自签名 ech 配置对，请将test.com自行替换为您想要对外展现的 SNI ",
          "required": false
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 ECH（Encrypted Client Hello），如果为 true，则启用 ECH",
          "required": false
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "可选项，不为空时用于指定通过 dns 解析时的域名",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "health-check",
          "title": "health-check",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码",
          "required": false
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名",
          "required": false
        },
        {
          "path": "max-connections",
          "title": "max-connections",
          "kind": "integer",
          "hint": "8",
          "description": "最大连接数量。 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "max-streams",
          "title": "max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "min-streams",
          "title": "min-streams",
          "kind": "integer",
          "hint": "5",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "quic",
          "title": "quic",
          "kind": "boolean",
          "hint": "true",
          "description": "是否开启 QUIC 协议，默认为 false。",
          "required": false
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码",
          "required": false
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "TLS 版本提示，可选值为 tls12 / tls13",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ]
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码",
          "required": false
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "支持 v1 / v2 / v3；留空时默认为 v2。",
          "required": false,
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "www.example.com",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "10443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h3\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "bbr-profile",
          "title": "bbr-profile",
          "kind": "choice",
          "hint": "",
          "description": "",
          "required": false,
          "choices": [
            "standard",
            "conservative",
            "aggressive"
          ]
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "bbr",
          "description": "设置拥塞控制算法，可选项为 cubic/new_reno/bbr",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "disable-sni",
          "title": "disable-sni",
          "kind": "boolean",
          "hint": "true",
          "description": "设置是否在 TLS 握手中禁用 SNI（服务器名称指示）SNI 用于在同一 IP 地址上承载多个 HTTPS 站点",
          "required": false
        },
        {
          "path": "fast-open",
          "title": "fast-open",
          "kind": "boolean",
          "hint": "true",
          "description": "设置是否启用 Fast Open，这可以减少连接建立时间",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "heartbeat-interval",
          "title": "heartbeat-interval",
          "kind": "integer",
          "hint": "10000",
          "description": "发送保持连接活动的心跳包的间隔时间，单位为毫秒",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip",
          "title": "ip",
          "kind": "string",
          "hint": "127.0.0.1",
          "description": "用于覆盖“server”选项中设置的服务器地址的 DNS 查找结果",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "max-open-streams",
          "title": "max-open-streams",
          "kind": "integer",
          "hint": "20",
          "description": "设置最大打开流的数量过多的打开流可能会影响性能",
          "required": false
        },
        {
          "path": "max-udp-relay-packet-size",
          "title": "max-udp-relay-packet-size",
          "kind": "integer",
          "hint": "1500",
          "description": "设置最大的 UDP 数据包中继大小，单位为字节",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "password",
          "title": "password",
          "kind": "secret",
          "hint": "PASSWORD_1",
          "description": "必须，用于 TUICV5 的用户密码，使用 TUIC V4 时不可书写",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "reduce-rtt",
          "title": "reduce-rtt",
          "kind": "boolean",
          "hint": "true",
          "description": "设置是否在客户端启用 QUIC 的 0-RTT 握手这可以减少连接建立时间，但可能增加重放攻击的风险",
          "required": false
        },
        {
          "path": "request-timeout",
          "title": "request-timeout",
          "kind": "integer",
          "hint": "8000",
          "description": "设置建立到 TUIC 代理服务器的连接的超时时间，单位为毫秒",
          "required": false
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "sni",
          "title": "sni",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "token",
          "title": "token",
          "kind": "secret",
          "hint": "TOKEN",
          "description": "必须，用于 TUIC V4 的用户标识，使用 TUIC V5 时不可书写",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "udp-relay-mode",
          "title": "udp-relay-mode",
          "kind": "choice",
          "hint": "native",
          "description": "设置 UDP 数据包中继模式，可以是 native/quic",
          "required": false,
          "choices": [
            "native",
            "quic"
          ]
        },
        {
          "path": "uuid",
          "title": "uuid",
          "kind": "string",
          "hint": "00000000-0000-0000-0000-000000000001",
          "description": "必须，用于 TUICV5 的用户唯一识别码，使用 TUIC V4 时不可书写",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "uuid",
          "title": "uuid",
          "kind": "string",
          "hint": "uuid",
          "description": "必须，VLESS 用户 ID",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 utls 指纹，仅适用于 VMess/VLESS/Trojan/AnyTLS 协议 可选：chrome, firefox, safari, ios, android, edge, 360, qq, random, 若选择 random, 则按 Cloudflare Radar 数据按概率生成一个现代浏览器指纹。",
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
          ]
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "ECH 配置，如果为空则通过 dns 解析，不为空则通过该值指定，格式为经过 base64 编码的 ech 参数（例如AEn+DQBFKwAgACABWIHUGj4u+PIggYXcR5JF0gYk3dCRioBW8uJq9H4mKAAIAAEAAQABAANAEnB1YmxpYy50bHMtZWNoLmRldgAA） 您可以通过mihomo generate ech-keypair test.com命令为服务器端和客户端生成符合要求的自签名 ech 配置对，请将test.com自行替换为您想要对外展现的 SNI ",
          "required": false
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 ECH（Encrypted Client Hello），如果为 true，则启用 ECH",
          "required": false
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "可选项，不为空时用于指定通过 dns 解析时的域名",
          "required": false
        },
        {
          "path": "encryption",
          "title": "encryption",
          "kind": "string",
          "hint": "",
          "description": "vless encryption 客户端配置： encryption: \"mlkem768x25519plus.native/xorpub/random.1rtt/0rtt.(padding len).(padding gap).(X25519 Password).(ML-KEM-768 Client)...\" （native/xorpub 的 XTLS Vision 可以 Splice。只使用 1-RTT 模式 / 若服务端发的 ticket 中秒数不为零则 0-RTT 复用） / 是只能选一个，后面 base6",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "flow",
          "title": "flow",
          "kind": "string",
          "hint": "xtls-rprx-vision",
          "description": "VLESS 子协议，可用值为 xtls-rprx-vision",
          "required": false
        },
        {
          "path": "grpc-opts.grpc-service-name",
          "title": "grpc-opts.grpc-service-name",
          "kind": "string",
          "hint": "example",
          "description": "gRPC 服务名称",
          "required": false
        },
        {
          "path": "grpc-opts.grpc-user-agent",
          "title": "grpc-opts.grpc-user-agent",
          "kind": "string",
          "hint": "",
          "description": "gRPC UserAgent",
          "required": false
        },
        {
          "path": "grpc-opts.max-connections",
          "title": "grpc-opts.max-connections",
          "kind": "integer",
          "hint": "1",
          "description": "最大连接数量。默认值为 1 即只使用一条底层链接 与 max-streams 冲突",
          "required": false,
          "defaultHint": "1"
        },
        {
          "path": "grpc-opts.max-streams",
          "title": "grpc-opts.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "grpc-opts.min-streams",
          "title": "grpc-opts.min-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "grpc-opts.ping-interval",
          "title": "grpc-opts.ping-interval",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 心跳包间隔，默认关闭，单位为秒",
          "required": false
        },
        {
          "path": "h2-opts.host",
          "title": "h2-opts.host",
          "kind": "list",
          "hint": "[\"example.com\"]",
          "description": "主机域名列表，如果设置，客户端将随机选择，服务器将验证",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "h2-opts.path",
          "title": "h2-opts.path",
          "kind": "string",
          "hint": "/",
          "description": "http 请求路径",
          "required": false
        },
        {
          "path": "http-opts.headers",
          "title": "http-opts.headers",
          "kind": "map",
          "hint": "{\"Connection\":[\"keep-alive\"]}",
          "description": "http 请求头 Mihomo 的 H2 传输层未实现多路复用功能，如果需要使用多路复用，在 Mihomo 中更建议使用 gRPC 协议，或者 sing-mux",
          "required": false,
          "elementKind": "list"
        },
        {
          "path": "http-opts.method",
          "title": "http-opts.method",
          "kind": "string",
          "hint": "GET",
          "description": "http 请求方法",
          "required": false
        },
        {
          "path": "http-opts.path",
          "title": "http-opts.path",
          "kind": "list",
          "hint": "[\"/\",\"/video\"]",
          "description": "http 请求路径",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码",
          "required": false
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "tcp",
          "description": "传输层，支持 ws/http/h2/grpc/xhttp，不配置或配置其他值则为 tcp 参阅 传输层配置",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "grpc",
            "h2",
            "http"
          ]
        },
        {
          "path": "packet-encoding",
          "title": "packet-encoding",
          "kind": "choice",
          "hint": "xudp",
          "description": "UDP 包编码，为空则使用原始编码，可选 packetaddr (由 v2ray 5+ 支持)/ xudp (由 xray 支持)",
          "required": false,
          "choices": [
            "xudp",
            "packetaddr"
          ]
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "reality-opts.public-key",
          "title": "reality-opts.public-key",
          "kind": "string",
          "hint": "xxxx",
          "description": "reality 服务端私钥对应的公钥",
          "required": false
        },
        {
          "path": "reality-opts.short-id",
          "title": "reality-opts.short-id",
          "kind": "string",
          "hint": "xxxx",
          "description": "服务端 short id 之一",
          "required": false
        },
        {
          "path": "reality-opts.support-x25519mlkem768",
          "title": "reality-opts.support-x25519mlkem768",
          "kind": "boolean",
          "hint": "true",
          "description": "支持 X25519-MLKEM768 密钥交换",
          "required": false
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码",
          "required": false
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "TLS 版本提示，可选值为 tls12 / tls13",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ]
        },
        {
          "path": "servername",
          "title": "servername",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码",
          "required": false
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "支持 v1 / v2 / v3；留空时默认为 v2。",
          "required": false,
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 tls，仅适用于使用 tls 的协议，trojan 协议强制启用",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "ws-opts.early-data-header-name",
          "title": "ws-opts.early-data-header-name",
          "kind": "string",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "ws-opts.headers",
          "title": "ws-opts.headers",
          "kind": "map",
          "hint": "{\"Host\":\"example.com\"}",
          "description": "请求头",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "ws-opts.max-early-data",
          "title": "ws-opts.max-early-data",
          "kind": "string",
          "hint": "",
          "description": "Early Data 首包长度阈值",
          "required": false
        },
        {
          "path": "ws-opts.path",
          "title": "ws-opts.path",
          "kind": "string",
          "hint": "/path",
          "description": "请求路径",
          "required": false
        },
        {
          "path": "ws-opts.v2ray-http-upgrade",
          "title": "ws-opts.v2ray-http-upgrade",
          "kind": "boolean",
          "hint": "false",
          "description": "使用 http upgrade",
          "required": false
        },
        {
          "path": "ws-opts.v2ray-http-upgrade-fast-open",
          "title": "ws-opts.v2ray-http-upgrade-fast-open",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 http upgrade 的 fast open",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "server",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": true
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "443",
          "description": "必须项，代理节点端口",
          "required": true
        },
        {
          "path": "uuid",
          "title": "uuid",
          "kind": "string",
          "hint": "uuid",
          "description": "",
          "required": true
        },
        {
          "path": "alpn",
          "title": "alpn",
          "kind": "list",
          "hint": "[\"h2\",\"http/1.1\"]",
          "description": "支持的应用层协议协商列表，按优先顺序排列。 如果两个对等点都支持 ALPN，则选择的协议将是此列表中的一个，如果没有相互支持的协议则连接将失败。 参阅 Application-Layer Protocol Negotiation",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "alterId",
          "title": "alterId",
          "kind": "integer",
          "hint": "0",
          "description": "",
          "required": false
        },
        {
          "path": "authenticated-length",
          "title": "authenticated-length",
          "kind": "boolean",
          "hint": "false",
          "description": "",
          "required": false
        },
        {
          "path": "certificate",
          "title": "certificate",
          "kind": "string",
          "hint": "xxxx",
          "description": "如果填写则开启 mTLS（需要和 private-key 同时填写），内容为证书 PEM 格式，或者 证书的路径",
          "required": false
        },
        {
          "path": "cipher",
          "title": "cipher",
          "kind": "choice",
          "hint": "auto",
          "description": "",
          "required": false,
          "choices": [
            "auto",
            "aes-128-gcm",
            "chacha20-poly1305",
            "none",
            "zero"
          ]
        },
        {
          "path": "client-fingerprint",
          "title": "client-fingerprint",
          "kind": "choice",
          "hint": "chrome",
          "description": "客户端 utls 指纹，仅适用于 VMess/VLESS/Trojan/AnyTLS 协议 可选：chrome, firefox, safari, ios, android, edge, 360, qq, random, 若选择 random, 则按 Cloudflare Radar 数据按概率生成一个现代浏览器指纹。",
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
          ]
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "ech-opts.config",
          "title": "ech-opts.config",
          "kind": "string",
          "hint": "base64_encoded_config",
          "description": "ECH 配置，如果为空则通过 dns 解析，不为空则通过该值指定，格式为经过 base64 编码的 ech 参数（例如AEn+DQBFKwAgACABWIHUGj4u+PIggYXcR5JF0gYk3dCRioBW8uJq9H4mKAAIAAEAAQABAANAEnB1YmxpYy50bHMtZWNoLmRldgAA） 您可以通过mihomo generate ech-keypair test.com命令为服务器端和客户端生成符合要求的自签名 ech 配置对，请将test.com自行替换为您想要对外展现的 SNI ",
          "required": false
        },
        {
          "path": "ech-opts.enable",
          "title": "ech-opts.enable",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 ECH（Encrypted Client Hello），如果为 true，则启用 ECH",
          "required": false
        },
        {
          "path": "ech-opts.query-server-name",
          "title": "ech-opts.query-server-name",
          "kind": "string",
          "hint": "xxx.com",
          "description": "可选项，不为空时用于指定通过 dns 解析时的域名",
          "required": false
        },
        {
          "path": "fingerprint",
          "title": "fingerprint",
          "kind": "string",
          "hint": "xxxx",
          "description": "证书指纹，仅适用于使用 tls 的协议，可使用 获取，也可以通过 Chrome 浏览器的“证书查看器”中“SHA256 指纹”的“证书”项获取 当填入的是叶子证书（即包含 sni 名称的证书）时，只验证服务端发来的证书是否符合该指纹，不会做额外校验 当填入的是其他类型的证书（如中级证书或根证书）的指纹，会验证服务端发来的证书链是否由该证书签发，自 v1.19.20 起还需符合 sni/servername 的要求 此项中的指纹是完整证书的指纹，不是 HPKP 中定义的“证书公钥指纹”，请勿混淆",
          "required": false
        },
        {
          "path": "global-padding",
          "title": "global-padding",
          "kind": "boolean",
          "hint": "false",
          "description": "",
          "required": false
        },
        {
          "path": "grpc-opts.grpc-service-name",
          "title": "grpc-opts.grpc-service-name",
          "kind": "string",
          "hint": "example",
          "description": "gRPC 服务名称",
          "required": false
        },
        {
          "path": "grpc-opts.grpc-user-agent",
          "title": "grpc-opts.grpc-user-agent",
          "kind": "string",
          "hint": "",
          "description": "gRPC UserAgent",
          "required": false
        },
        {
          "path": "grpc-opts.max-connections",
          "title": "grpc-opts.max-connections",
          "kind": "integer",
          "hint": "1",
          "description": "最大连接数量。默认值为 1 即只使用一条底层链接 与 max-streams 冲突",
          "required": false,
          "defaultHint": "1"
        },
        {
          "path": "grpc-opts.max-streams",
          "title": "grpc-opts.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "grpc-opts.min-streams",
          "title": "grpc-opts.min-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "grpc-opts.ping-interval",
          "title": "grpc-opts.ping-interval",
          "kind": "integer",
          "hint": "0",
          "description": "gRPC 心跳包间隔，默认关闭，单位为秒",
          "required": false
        },
        {
          "path": "h2-opts.host",
          "title": "h2-opts.host",
          "kind": "list",
          "hint": "[\"example.com\"]",
          "description": "主机域名列表，如果设置，客户端将随机选择，服务器将验证",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "h2-opts.path",
          "title": "h2-opts.path",
          "kind": "string",
          "hint": "/",
          "description": "http 请求路径",
          "required": false
        },
        {
          "path": "http-opts.headers",
          "title": "http-opts.headers",
          "kind": "map",
          "hint": "{\"Connection\":[\"keep-alive\"]}",
          "description": "http 请求头 Mihomo 的 H2 传输层未实现多路复用功能，如果需要使用多路复用，在 Mihomo 中更建议使用 gRPC 协议，或者 sing-mux",
          "required": false,
          "elementKind": "list"
        },
        {
          "path": "http-opts.method",
          "title": "http-opts.method",
          "kind": "string",
          "hint": "GET",
          "description": "http 请求方法",
          "required": false
        },
        {
          "path": "http-opts.path",
          "title": "http-opts.path",
          "kind": "list",
          "hint": "[\"/\",\"/video\"]",
          "description": "http 请求路径",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "jls-opts.password",
          "title": "jls-opts.password",
          "kind": "secret",
          "hint": "jls-password",
          "description": "JLS 密码",
          "required": false
        },
        {
          "path": "jls-opts.username",
          "title": "jls-opts.username",
          "kind": "string",
          "hint": "jls-user",
          "description": "JLS 用户名",
          "required": false
        },
        {
          "path": "mptcp",
          "title": "mptcp",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Multi Path, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "name-cert-verify",
          "title": "name-cert-verify",
          "kind": "string",
          "hint": "example.com",
          "description": "可选，仅修改证书 DNSName 校验目标，不修改 SNI",
          "required": false
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "tcp",
          "description": "",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "grpc",
            "h2",
            "http"
          ]
        },
        {
          "path": "packet-encoding",
          "title": "packet-encoding",
          "kind": "choice",
          "hint": "packetaddr",
          "description": "",
          "required": false,
          "choices": [
            "xudp",
            "packetaddr"
          ]
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "xxx",
          "description": "如果填写则开启 mTLS（需要和 certificate 同时填写），内容为证书对应的私钥 PEM 格式，或者私钥路径",
          "required": false
        },
        {
          "path": "reality-opts.public-key",
          "title": "reality-opts.public-key",
          "kind": "string",
          "hint": "xxxx",
          "description": "reality 服务端私钥对应的公钥",
          "required": false
        },
        {
          "path": "reality-opts.short-id",
          "title": "reality-opts.short-id",
          "kind": "string",
          "hint": "xxxx",
          "description": "服务端 short id 之一",
          "required": false
        },
        {
          "path": "reality-opts.support-x25519mlkem768",
          "title": "reality-opts.support-x25519mlkem768",
          "kind": "boolean",
          "hint": "true",
          "description": "支持 X25519-MLKEM768 密钥交换",
          "required": false
        },
        {
          "path": "restls-opts.password",
          "title": "restls-opts.password",
          "kind": "secret",
          "hint": "restls-password",
          "description": "Restls 密码",
          "required": false
        },
        {
          "path": "restls-opts.version-hint",
          "title": "restls-opts.version-hint",
          "kind": "choice",
          "hint": "tls13",
          "description": "TLS 版本提示，可选值为 tls12 / tls13",
          "required": false,
          "choices": [
            "tls12",
            "tls13"
          ]
        },
        {
          "path": "servername",
          "title": "servername",
          "kind": "string",
          "hint": "example.com",
          "description": "",
          "required": false
        },
        {
          "path": "shadow-tls-opts.password",
          "title": "shadow-tls-opts.password",
          "kind": "secret",
          "hint": "shadow-tls-password",
          "description": "ShadowTLS 密码",
          "required": false
        },
        {
          "path": "shadow-tls-opts.version",
          "title": "shadow-tls-opts.version",
          "kind": "integer",
          "hint": "3",
          "description": "支持 v1 / v2 / v3；留空时默认为 v2。",
          "required": false,
          "defaultHint": "2"
        },
        {
          "path": "skip-cert-verify",
          "title": "skip-cert-verify",
          "kind": "boolean",
          "hint": "true",
          "description": "跳过证书验证，仅适用于使用 tls 的协议",
          "required": false
        },
        {
          "path": "smux.brutal-opts.down",
          "title": "smux.brutal-opts.down",
          "kind": "integer",
          "hint": "100",
          "description": "",
          "required": false
        },
        {
          "path": "smux.brutal-opts.enabled",
          "title": "smux.brutal-opts.enabled",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 TCP Brutal 拥塞控制算法",
          "required": false
        },
        {
          "path": "smux.brutal-opts.up",
          "title": "smux.brutal-opts.up",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "smux.enabled",
          "title": "smux.enabled",
          "kind": "boolean",
          "hint": "false",
          "description": "是否启用多路复用",
          "required": false
        },
        {
          "path": "smux.max-connections",
          "title": "smux.max-connections",
          "kind": "integer",
          "hint": "4",
          "description": "最大连接数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.max-streams",
          "title": "smux.max-streams",
          "kind": "integer",
          "hint": "0",
          "description": "在打开新连接之前，连接中的最大多路复用流数量 与 max-connections 和 min-streams 冲突",
          "required": false
        },
        {
          "path": "smux.min-streams",
          "title": "smux.min-streams",
          "kind": "integer",
          "hint": "4",
          "description": "在打开新连接之前，连接中的最小多路复用流数量 与 max-streams 冲突",
          "required": false
        },
        {
          "path": "smux.only-tcp",
          "title": "smux.only-tcp",
          "kind": "boolean",
          "hint": "false",
          "description": "仅允许 tcp，如果设置为 true,smux 的设置将不会对 udp 生效，udp 连接会直接走节点默认 udp 协议传输",
          "required": false
        },
        {
          "path": "smux.padding",
          "title": "smux.padding",
          "kind": "boolean",
          "hint": "true",
          "description": "启用填充",
          "required": false
        },
        {
          "path": "smux.protocol",
          "title": "smux.protocol",
          "kind": "choice",
          "hint": "smux",
          "description": "多路复用协议，支持如下协议，默认使用 h2mux | 协议 | 描述 | |---------|--------------------------------------| | smux | <https://github.com/xtaci/smux> | | yamux | <https://github.com/hashicorp/yamux> | | h2mux | <https://golang.org/x/net/http2> |",
          "required": false,
          "choices": [
            "h2mux",
            "smux",
            "yamux"
          ]
        },
        {
          "path": "smux.statistic",
          "title": "smux.statistic",
          "kind": "boolean",
          "hint": "false",
          "description": "控制是否将底层连接显示在面板中，方便打断底层连接",
          "required": false
        },
        {
          "path": "tfo",
          "title": "tfo",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 TCP Fast Open, 仅生效于 TCP 协议",
          "required": false
        },
        {
          "path": "tls",
          "title": "tls",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 tls，仅适用于使用 tls 的协议，trojan 协议强制启用",
          "required": false
        },
        {
          "path": "tlsmirror-opts.primary-key",
          "title": "tlsmirror-opts.primary-key",
          "kind": "string",
          "hint": "xxxx",
          "description": "必填，32 字节主密钥的 base64 编码",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
        },
        {
          "path": "ws-opts.early-data-header-name",
          "title": "ws-opts.early-data-header-name",
          "kind": "string",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "ws-opts.headers",
          "title": "ws-opts.headers",
          "kind": "map",
          "hint": "{\"Host\":\"example.com\"}",
          "description": "请求头",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "ws-opts.max-early-data",
          "title": "ws-opts.max-early-data",
          "kind": "string",
          "hint": "",
          "description": "Early Data 首包长度阈值",
          "required": false
        },
        {
          "path": "ws-opts.path",
          "title": "ws-opts.path",
          "kind": "string",
          "hint": "/path",
          "description": "请求路径",
          "required": false
        },
        {
          "path": "ws-opts.v2ray-http-upgrade",
          "title": "ws-opts.v2ray-http-upgrade",
          "kind": "boolean",
          "hint": "false",
          "description": "使用 http upgrade",
          "required": false
        },
        {
          "path": "ws-opts.v2ray-http-upgrade-fast-open",
          "title": "ws-opts.v2ray-http-upgrade-fast-open",
          "kind": "boolean",
          "hint": "false",
          "description": "启用 http upgrade 的 fast open",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "server",
          "title": "server",
          "kind": "string",
          "hint": "162.159.192.1",
          "description": "必须，代理节点服务器 (域名/ip)",
          "required": false
        },
        {
          "path": "port",
          "title": "port",
          "kind": "integer",
          "hint": "2480",
          "description": "必须项，代理节点端口",
          "required": false
        },
        {
          "path": "allowed-ips",
          "title": "allowed-ips",
          "kind": "list",
          "hint": "[\"0.0.0.0/0\"]",
          "description": "可选字段，限制客户端的哪些 IP 段的流量由服务端进行转发。一般情况下可填['0.0.0.0/0']",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "amnezia-wg-option.content-padding-addition",
          "title": "amnezia-wg-option.content-padding-addition",
          "kind": "string",
          "hint": "0-32",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.disable-cookies",
          "title": "amnezia-wg-option.disable-cookies",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.h1",
          "title": "amnezia-wg-option.h1",
          "kind": "integer",
          "hint": "123456",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.h2",
          "title": "amnezia-wg-option.h2",
          "kind": "integer",
          "hint": "67543",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.h3",
          "title": "amnezia-wg-option.h3",
          "kind": "integer",
          "hint": "123123",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.h4",
          "title": "amnezia-wg-option.h4",
          "kind": "integer",
          "hint": "32345",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.header-protection-key",
          "title": "amnezia-wg-option.header-protection-key",
          "kind": "string",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.i1",
          "title": "amnezia-wg-option.i1",
          "kind": "string",
          "hint": "<b 0xf6ab3267fa><b 0xf6ab><t><r 10>",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.i2",
          "title": "amnezia-wg-option.i2",
          "kind": "string",
          "hint": "<b 0xf6ab3267fa><r 100>",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.i3",
          "title": "amnezia-wg-option.i3",
          "kind": "string",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.i4",
          "title": "amnezia-wg-option.i4",
          "kind": "string",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.i5",
          "title": "amnezia-wg-option.i5",
          "kind": "string",
          "hint": "",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.itime",
          "title": "amnezia-wg-option.itime",
          "kind": "integer",
          "hint": "60",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.j1",
          "title": "amnezia-wg-option.j1",
          "kind": "string",
          "hint": "<b 0xffffffff><c><b 0xf6ab><t><r 10>",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.j2",
          "title": "amnezia-wg-option.j2",
          "kind": "string",
          "hint": "<c><b 0xf6ab><t><wt 1000>",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.j3",
          "title": "amnezia-wg-option.j3",
          "kind": "string",
          "hint": "<t><b 0xf6ab><c><r 10>",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.jc",
          "title": "amnezia-wg-option.jc",
          "kind": "integer",
          "hint": "5",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.jmax",
          "title": "amnezia-wg-option.jmax",
          "kind": "integer",
          "hint": "501",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.jmin",
          "title": "amnezia-wg-option.jmin",
          "kind": "integer",
          "hint": "500",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.keepalive-timeout",
          "title": "amnezia-wg-option.keepalive-timeout",
          "kind": "integer",
          "hint": "10",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.max-handshake-attempts",
          "title": "amnezia-wg-option.max-handshake-attempts",
          "kind": "integer",
          "hint": "18",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.random-trailers",
          "title": "amnezia-wg-option.random-trailers",
          "kind": "boolean",
          "hint": "true",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.reject-after-time",
          "title": "amnezia-wg-option.reject-after-time",
          "kind": "integer",
          "hint": "180",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.rekey-after-time",
          "title": "amnezia-wg-option.rekey-after-time",
          "kind": "integer",
          "hint": "120",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.rekey-timeout",
          "title": "amnezia-wg-option.rekey-timeout",
          "kind": "integer",
          "hint": "5",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.s1",
          "title": "amnezia-wg-option.s1",
          "kind": "integer",
          "hint": "30",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.s2",
          "title": "amnezia-wg-option.s2",
          "kind": "integer",
          "hint": "40",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.s3",
          "title": "amnezia-wg-option.s3",
          "kind": "integer",
          "hint": "50",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.s4",
          "title": "amnezia-wg-option.s4",
          "kind": "integer",
          "hint": "8",
          "description": "",
          "required": false
        },
        {
          "path": "amnezia-wg-option.version",
          "title": "amnezia-wg-option.version",
          "kind": "integer",
          "hint": "2",
          "description": "",
          "required": false
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "指定当前 proxies 通过 dialer-proxy 建立网络连接，值可以为策略组/出站代理的 name，用法可参考dialer-proxy 文档",
          "required": false
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"1.1.1.1\",\"8.8.8.8\"]",
          "description": "可选字段，当remote-dns-resolve为 true 时生效，指定远程解析使用的 dns 服务器",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "eth0",
          "description": "指定节点绑定的接口，从此接口发起连接",
          "required": false
        },
        {
          "path": "ip",
          "title": "ip",
          "kind": "string",
          "hint": "172.16.0.2",
          "description": "本机在 Wireguard 网络中使用的 IPv4 地址",
          "required": false
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法，可选值：cubic、reno、bbr、bbr3，默认为 cubic 对于 gVisor IP 协议栈，该选项不会生效。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "可选值：auto、gvisor、mips。默认值为 auto。auto 始终使用 mihomo IP 协议栈（MIPS）；gvisor 需使用 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ]
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4",
          "description": "代理软件出站使用的 ip 版本，如果不是 direct，则会影响 server 为域名时使用的 ip 地址 可选：dual/ipv4/ipv6/ipv4-prefer/ipv6-prefer ,默认使用 dual ipv4: 仅使用 IPv4 ipv6: 仅使用 IPv6 ipv4-prefer: 优先使用 IPv4，对于 TCP 会进行双栈解析，并发链接但是优先使用 IPv4 链接，UDP 则为双栈解析，获取结果中的第一个 IPv4 ipv6-prefer:优先使用 IPv6，对于 TCP 会进行双栈解析，并发链",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "ipv6",
          "title": "ipv6",
          "kind": "string",
          "hint": "fd01:5ca1:ab1e:80fa:ab85:6eea:213f:f4a5",
          "description": "可选字段，本机在 Wireguard 网络中使用的 IPv6 地址",
          "required": false
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1408",
          "description": "可选字段，设置 MTU 值",
          "required": false
        },
        {
          "path": "peers",
          "title": "peers",
          "kind": "list",
          "hint": "[{\"server\":\"162.159.192.1\",\"port\":2480,\"public-key\":\"Cr8hWlKvtDt7nrvf+f0brNQQzabAqrjfBvas9pmowjo=\",\"allowed-ips\":[\"0.0.0.0/0\"],\"pre-shared-key\":\"31aIhAPwktDGpH4JDhA8GNvjFXEf/a6+UaQRyOAiyfM=\",\"reserved\":[209,98,59]}]",
          "description": "",
          "required": false,
          "elementKind": "object",
          "children": [
            {
              "path": "server",
              "title": "server",
              "kind": "string",
              "hint": "162.159.192.1",
              "description": "必须，代理节点服务器 (域名/ip)",
              "required": false
            },
            {
              "path": "port",
              "title": "port",
              "kind": "integer",
              "hint": "2480",
              "description": "必须项，代理节点端口",
              "required": false
            },
            {
              "path": "public-key",
              "title": "public-key",
              "kind": "string",
              "hint": "Cr8hWlKvtDt7nrvf+f0brNQQzabAqrjfBvas9pmowjo=",
              "description": "base64 编码的 Wireguard 服务端公钥",
              "required": false
            },
            {
              "path": "allowed-ips",
              "title": "allowed-ips",
              "kind": "list",
              "hint": "[\"0.0.0.0/0\"]",
              "description": "可选字段，限制客户端的哪些 IP 段的流量由服务端进行转发。一般情况下可填['0.0.0.0/0']",
              "required": false,
              "elementKind": "string"
            },
            {
              "path": "pre-shared-key",
              "title": "pre-shared-key",
              "kind": "string",
              "hint": "31aIhAPwktDGpH4JDhA8GNvjFXEf/a6+UaQRyOAiyfM=",
              "description": "可选字段，预共享密钥",
              "required": false
            },
            {
              "path": "reserved",
              "title": "reserved",
              "kind": "list",
              "hint": "[209,98,59]",
              "description": "可选字段，Wireguard 协议保留字段的值，部分 WARP 节点需要使用",
              "required": false,
              "elementKind": "integer"
            }
          ]
        },
        {
          "path": "persistent-keepalive",
          "title": "persistent-keepalive",
          "kind": "integer",
          "hint": "0",
          "description": "可选字段，定期发送数据包来维持连接的持久性",
          "required": false
        },
        {
          "path": "pre-shared-key",
          "title": "pre-shared-key",
          "kind": "string",
          "hint": "31aIhAPwktDGpH4JDhA8GNvjFXEf/a6+UaQRyOAiyfM=",
          "description": "可选字段，预共享密钥",
          "required": false
        },
        {
          "path": "private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "eCtXsJZ27+4PbhDkHnB923tkUn2Gj59wZw5wFA75MnU=",
          "description": "base64 编码的 Wireguard 客户端私钥 可以使用wg genkey | tee privatekey | wg pubkey > publickey命令生成一对可用的公私钥文件",
          "required": false
        },
        {
          "path": "public-key",
          "title": "public-key",
          "kind": "string",
          "hint": "Cr8hWlKvtDt7nrvf+f0brNQQzabAqrjfBvas9pmowjo=",
          "description": "base64 编码的 Wireguard 服务端公钥",
          "required": false
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "可选字段，是否强制 dns 远程解析，默认值为 false",
          "required": false
        },
        {
          "path": "reserved",
          "title": "reserved",
          "kind": "list",
          "hint": "[209,98,59]",
          "description": "可选字段，Wireguard 协议保留字段的值，部分 WARP 节点需要使用",
          "required": false,
          "elementKind": "integer"
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否允许 UDP 通过代理，默认为 false 此选项在 TUIC 等基于 UDP 的协议以及 direct 和 dns 类型中默认开启",
          "required": false
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
          "description": "必须，代理名称，不可重复",
          "required": true
        },
        {
          "path": "dialer-proxy",
          "title": "dialer-proxy",
          "kind": "string",
          "hint": "ss1",
          "description": "可选，通过其他出站代理承载 ZeroTier 的网络通信，其中 ss1 为其他代理节点的名称。",
          "required": false
        },
        {
          "path": "dns",
          "title": "dns",
          "kind": "list",
          "hint": "[\"10.147.17.1\"]",
          "description": "可选，用于覆盖控制器提供的 DNS 服务器，可配置一个或多个 DNS 服务器。",
          "required": false,
          "elementKind": "string"
        },
        {
          "path": "encrypted-hello",
          "title": "encrypted-hello",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，默认值为 false。",
          "required": false
        },
        {
          "path": "identity-secret",
          "title": "identity-secret",
          "kind": "string",
          "hint": "0123456789:0:public-key:private-key",
          "description": "可选，完整的 identity.secret 内容；会覆盖 state-dir 中保存的身份，且不会写入 state-dir",
          "required": false
        },
        {
          "path": "interface-name",
          "title": "interface-name",
          "kind": "string",
          "hint": "WLAN",
          "description": "可选，指定 ZeroTier 使用的网络接口名称。",
          "required": false
        },
        {
          "path": "ip-stack.congestion-controller",
          "title": "ip-stack.congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法，可选值：cubic、reno、bbr、bbr3，默认为 cubic 对于 gVisor IP 协议栈，该选项不会生效。",
          "required": false,
          "choices": [
            "cubic",
            "reno",
            "bbr",
            "bbr3"
          ]
        },
        {
          "path": "ip-stack.mode",
          "title": "ip-stack.mode",
          "kind": "choice",
          "hint": "auto",
          "description": "可选值：auto、gvisor、mips。默认值为 auto。auto 始终使用 mihomo IP 协议栈（MIPS）；gvisor 需使用 -tags with_gvisor 编译。",
          "required": false,
          "choices": [
            "rule",
            "global",
            "direct"
          ]
        },
        {
          "path": "ip-version",
          "title": "ip-version",
          "kind": "choice",
          "hint": "ipv4-prefer",
          "description": "可选，指定 IP 协议版本偏好。",
          "required": false,
          "choices": [
            "dual",
            "ipv4",
            "ipv6",
            "ipv4-prefer",
            "ipv6-prefer"
          ]
        },
        {
          "path": "low-bandwidth",
          "title": "low-bandwidth",
          "kind": "boolean",
          "hint": "false",
          "description": "可选，是否启用低带宽模式，默认值为 false。",
          "required": false
        },
        {
          "path": "mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "1400",
          "description": "可选，本地 MTU 覆盖值，该值不能超过 ZeroTier 控制器提供的 MTU",
          "required": false
        },
        {
          "path": "network",
          "title": "network",
          "kind": "choice",
          "hint": "0123456789abcdef",
          "description": "ZeroTier 网络 ID",
          "required": false,
          "choices": [
            "tcp",
            "ws",
            "grpc",
            "h2",
            "http"
          ]
        },
        {
          "path": "orbit",
          "title": "orbit",
          "kind": "list",
          "hint": "[{\"world\":\"0123456789abcdef\",\"seed\":\"0123456789\"}]",
          "description": "可选，配置私有 Moon 根服务器列表",
          "required": false,
          "elementKind": "object",
          "children": [
            {
              "path": "world",
              "title": "world",
              "kind": "string",
              "hint": "0123456789abcdef",
              "description": "",
              "required": false
            },
            {
              "path": "seed",
              "title": "seed",
              "kind": "string",
              "hint": "0123456789",
              "description": "",
              "required": false
            }
          ]
        },
        {
          "path": "physical-mtu",
          "title": "physical-mtu",
          "kind": "integer",
          "hint": "1432",
          "description": "可选，ZeroTier UDP 负载 MTU，有效范围为 510-10324，默认值为 1432。",
          "required": false,
          "defaultHint": "1432"
        },
        {
          "path": "planet",
          "title": "planet",
          "kind": "string",
          "hint": "./planet",
          "description": "可选，私有 Planet 文件路径，用于替换内置的 Earth Planet",
          "required": false
        },
        {
          "path": "primary-port",
          "title": "primary-port",
          "kind": "integer",
          "hint": "0",
          "description": "可选，主 UDP 端口，设置为 0 时自动选择可用端口。",
          "required": false
        },
        {
          "path": "remote-dns-resolve",
          "title": "remote-dns-resolve",
          "kind": "boolean",
          "hint": "true",
          "description": "可选，是否通过 ZeroTier，使用控制器提供的 DNS 服务器解析目标域名。",
          "required": false
        },
        {
          "path": "remote-trace-level",
          "title": "remote-trace-level",
          "kind": "integer",
          "hint": "0",
          "description": "可选，远程诊断跟踪级别，可使用以下值： 0：普通 10：详细 15：规则 20：调试 30：极详",
          "required": false
        },
        {
          "path": "remote-trace-target",
          "title": "remote-trace-target",
          "kind": "string",
          "hint": "0123456789",
          "description": "可选，用于接收全局诊断跟踪信息的 ZeroTier 节点 ID。",
          "required": false
        },
        {
          "path": "routing-mark",
          "title": "routing-mark",
          "kind": "integer",
          "hint": "6666",
          "description": "可选，设置 Linux 路由标记。",
          "required": false
        },
        {
          "path": "secondary-port",
          "title": "secondary-port",
          "kind": "integer",
          "hint": "0",
          "description": "可选，第二 UDP 端口， 0 为自动选择； -1 为禁用",
          "required": false
        },
        {
          "path": "state-dir",
          "title": "state-dir",
          "kind": "string",
          "hint": "./zerotier-node",
          "description": "可选，持久化节点状态与默认身份；默认使用由网络 ID 和出站名称生成的独立目录",
          "required": false
        },
        {
          "path": "tcp-fallback-mode",
          "title": "tcp-fallback-mode",
          "kind": "string",
          "hint": "auto",
          "description": "可选，TCP 回退模式，可使用以下值： auto：UDP 连接失败后使用中继。 force：仅使用中继。 disable：禁用 TCP 中继回退。 默认值为 auto。",
          "required": false,
          "defaultHint": "auto"
        },
        {
          "path": "tcp-fallback-relay",
          "title": "tcp-fallback-relay",
          "kind": "string",
          "hint": "204.80.128.1:443",
          "description": "可选，TCP 回退中继服务器地址",
          "required": false
        },
        {
          "path": "udp",
          "title": "udp",
          "kind": "boolean",
          "hint": "true",
          "description": "是否启用 UDP。默认值为 true。",
          "required": false
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
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "socks-port",
      "title": "socks-port",
      "kind": "integer",
      "hint": "7891",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "redir-port",
      "title": "redir-port",
      "kind": "integer",
      "hint": "7893",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "tproxy-port",
      "title": "tproxy-port",
      "kind": "integer",
      "hint": "7894",
      "description": "",
      "required": false,
      "unavailableReason": "仅支持 Linux / Android",
      "document": "general.md"
    },
    {
      "path": "mixed-port",
      "title": "mixed-port",
      "kind": "integer",
      "hint": "7892",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "allow-lan",
      "title": "allow-lan",
      "kind": "boolean",
      "hint": "true",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "bind-address",
      "title": "bind-address",
      "kind": "string",
      "hint": "*",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "authentication",
      "title": "authentication",
      "kind": "list",
      "hint": "[\"user1:pass1\",\"user2:pass2\"]",
      "description": "",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "skip-auth-prefixes",
      "title": "skip-auth-prefixes",
      "kind": "list",
      "hint": "[\"127.0.0.1/8\",\"::1/128\"]",
      "description": "",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "lan-allowed-ips",
      "title": "lan-allowed-ips",
      "kind": "list",
      "hint": "[\"0.0.0.0/0\",\"::/0\"]",
      "description": "",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "lan-disallowed-ips",
      "title": "lan-disallowed-ips",
      "kind": "list",
      "hint": "[\"192.168.0.3/32\"]",
      "description": "",
      "required": false,
      "elementKind": "string",
      "document": "general.md"
    },
    {
      "path": "find-process-mode",
      "title": "find-process-mode",
      "kind": "choice",
      "hint": "strict",
      "description": "",
      "required": false,
      "choices": [
        "always",
        "strict",
        "off"
      ],
      "document": "general.md"
    },
    {
      "path": "mode",
      "title": "mode",
      "kind": "choice",
      "hint": "rule",
      "description": "",
      "required": false,
      "choices": [
        "rule",
        "global",
        "direct"
      ],
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
          "description": "",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.geosite",
          "title": "geosite",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
          "description": "",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.mmdb",
          "title": "mmdb",
          "kind": "string",
          "hint": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb",
          "description": "",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "geox-url.asn",
          "title": "asn",
          "kind": "string",
          "hint": "https://github.com/xishang0128/geoip/releases/download/latest/GeoLite2-ASN.mmdb",
          "description": "",
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
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "geo-update-interval",
      "title": "geo-update-interval",
      "kind": "integer",
      "hint": "24",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "log-level",
      "title": "log-level",
      "kind": "choice",
      "hint": "info",
      "description": "",
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
      "description": "是否允许内核接受 IPv6 流量 可选值 true/false,默认为 true",
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
          "description": "",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "tls.private-key",
          "title": "private-key",
          "kind": "secret",
          "hint": "string",
          "description": "",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "tls.ech-key",
          "title": "ech-key",
          "kind": "string",
          "hint": "-----BEGIN ECH KEYS-----\nACATwY30o/RKgD6hgeQxwrSiApLaCgU+HKh7B6SUrAHaDwBD/g0APwAAIAAgHjzK\nmadSJjYQIf9o1N5GXjkW4DEEeb17qMxHdwMdNnwADAABAAEAAQACAAEAAwAIdGVz\ndC5jb20AAA==\n-----END ECH KEYS-----",
          "description": "",
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
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-controller-tls",
      "title": "external-controller-tls",
      "kind": "string",
      "hint": "127.0.0.1:9443",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "secret",
      "title": "secret",
      "kind": "secret",
      "hint": "",
      "description": "",
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
          "description": "",
          "required": false,
          "elementKind": "string",
          "document": "general.md"
        },
        {
          "path": "external-controller-cors.allow-private-network",
          "title": "allow-private-network",
          "kind": "boolean",
          "hint": "true",
          "description": "",
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
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "tcp-concurrent",
      "title": "tcp-concurrent",
      "kind": "boolean",
      "hint": "true",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-ui",
      "title": "external-ui",
      "kind": "string",
      "hint": "/path/to/ui/folder",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-ui-name",
      "title": "external-ui-name",
      "kind": "string",
      "hint": "xd",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-ui-url",
      "title": "external-ui-url",
      "kind": "string",
      "hint": "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "external-doh-server",
      "title": "external-doh-server",
      "kind": "string",
      "hint": "/dns-query",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "interface-name",
      "title": "interface-name",
      "kind": "string",
      "hint": "en0",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "disable-keep-alive",
      "title": "disable-keep-alive",
      "kind": "boolean",
      "hint": "false",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "keep-alive-idle",
      "title": "keep-alive-idle",
      "kind": "integer",
      "hint": "15",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "keep-alive-interval",
      "title": "keep-alive-interval",
      "kind": "integer",
      "hint": "15",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "hosts",
      "title": "hosts",
      "kind": "map",
      "hint": "{\"*.clash.dev\":\"127.0.0.1\",\"alpha.clash.dev\":\"::1\",\"test.com\":[\"1.1.1.1\",\"2.2.2.2\"],\"baidu.com\":\"google.com\"}",
      "description": "",
      "required": false,
      "elementKind": "list",
      "document": "dns/index.md"
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
          "description": "",
          "required": false,
          "document": "general.md"
        },
        {
          "path": "profile.store-fake-ip",
          "title": "store-fake-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "",
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
          "description": "启用 tun",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.stack",
          "title": "stack",
          "kind": "choice",
          "hint": "mips",
          "description": "tun 模式堆栈，如无使用问题，建议使用 mips 栈，默认 mips 可用值： system/gvisor/mixed/mips system 使用系统协议栈，可以提供更稳定/全面的 tun 体验，且占用相对其他堆栈更低 gvisor 通过在用户空间中实现网络协议栈，可以提供更高的安全性和隔离性，同时可以避免操作系统内核和用户空间之间的切换，从而在特定情况下具有更好的网络处理性能 mixed 混合堆栈，tcp 使用 system栈，udp 使用 gvisor栈，使用体验可能相对更好 mips 使用 mihomo ",
          "required": false,
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
          "description": "dns 劫持，将匹配到的连接导入内部 dns 模块，不书写协议则为 udp:// 在 MacOS/Windows 无法自动劫持发往局域网的 dns 请求 在 Android 如开启 私人dns 则无法自动劫持 dns 请求",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-detect-interface",
          "title": "auto-detect-interface",
          "kind": "boolean",
          "hint": "true",
          "description": "自动选择流量出口接口，多出口网卡同时连接的设备建议手动指定出口网卡",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-route",
          "title": "auto-route",
          "kind": "boolean",
          "hint": "true",
          "description": "自动设置全局路由，可以自动将全局流量路由进入 tun 网卡。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.mtu",
          "title": "mtu",
          "kind": "integer",
          "hint": "9000",
          "description": "最大传输单元，会影响极限状态下的速率，一般用户默认即可。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.gso",
          "title": "gso",
          "kind": "boolean",
          "hint": "true",
          "description": "启用通用分段卸载，仅支持 Linux",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.gso-max-size",
          "title": "gso-max-size",
          "kind": "integer",
          "hint": "65536",
          "description": "数据块的最大长度",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.strict-route",
          "title": "strict-route",
          "kind": "boolean",
          "hint": "true",
          "description": "启用 auto-route 时执行严格的路由规则 在 Linux 中: 让不支持的网络无法到达 将所有连接路由到 tun 它可以防止地址泄漏，并使 DNS 劫持在 Android 上工作。 在 Windows 中: 添加防火墙规则以阻止 Windows 的 普通多宿主 DNS 解析行为 造成的 DNS 泄露 它可能会使某些应用程序（如 VirtualBox）在某些情况下无法正常工作。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.congestion-controller",
          "title": "congestion-controller",
          "kind": "choice",
          "hint": "cubic",
          "description": "TCP 拥塞控制算法，可选值：cubic、reno、bbr、bbr3，默认为 cubic，仅在使用 mips 协议栈时生效",
          "required": false,
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
          "description": "启用 auto-route时路由自定义路由网段而不是默认路由，一般无需配置。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.endpoint-independent-nat",
          "title": "endpoint-independent-nat",
          "kind": "boolean",
          "hint": "false",
          "description": "启用独立于端点的 NAT，性能可能会略有下降，所以不建议在不需要的时候开启。",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-interface",
          "title": "include-interface",
          "kind": "list",
          "hint": "[\"eth0\"]",
          "description": "限制被路由的接口，默认不限制，与 exclude-interface 冲突，不可一起配置",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.exclude-interface",
          "title": "exclude-interface",
          "kind": "list",
          "hint": "[\"eth1\"]",
          "description": "排除路由的接口，与 include-interface 冲突，不可一起配置",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.auto-redirect",
          "title": "auto-redirect",
          "kind": "boolean",
          "hint": "true",
          "description": "仅支持 Linux，自动配置 iptables/nftables 以重定向 TCP 连接，需要auto-route已启用 在 Android 中： 仅转发本地 IPv4 连接。要通过热点或中继共享您的 VPN 连接，请使用 VPNHotspot。 在 Linux 中： 带有 auto-route 的 auto-redirect 现在可以在路由器上按预期工作，无需干预。",
          "required": false,
          "unavailableReason": "仅支持 Linux",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.device",
          "title": "device",
          "kind": "string",
          "hint": "utun0",
          "description": "指定 tun 网卡名称，MacOS 设备只能使用 utun 开头的网卡名",
          "required": false,
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-address",
          "title": "inet6-address",
          "kind": "list",
          "hint": "[\"fdfe:dcba:9876::1/126\"]",
          "description": "指定tun的ipv6地址 目前会在程序启动时检查系统其他网卡是否有IPV6，如果不存在会禁用该功能，如果需要强制开启tun的v6地址，请手动设置SKIP_SYSTEM_IPV6_CHECK=1系统环境变量 需要同时将顶层配置中的ipv6设置为true才会生效",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.udp-timeout",
          "title": "udp-timeout",
          "kind": "integer",
          "hint": "300",
          "description": "UDP NAT 过期时间，以秒为单位，默认为 300(5 分钟)",
          "required": false,
          "defaultHint": "300",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.iproute2-table-index",
          "title": "iproute2-table-index",
          "kind": "integer",
          "hint": "2022",
          "description": "auto-route 生成的 iproute2 路由表索引，默认使用 2022",
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
          "description": "auto-route 生成的 iproute2 规则起始索引，默认使用 9000",
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
          "description": "将指定规则集中的目标 IP CIDR 规则添加到防火墙，不匹配的流量将绕过路由 仅支持 Linux，且需要 nftables 以及auto-route 和 auto-redirect 已启用。 与任意配置中的 routing-mark 冲突",
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
          "description": "将指定规则集中的目标 IP CIDR 规则添加到防火墙，匹配的流量将绕过路由 仅支持 Linux，且需要 nftables 以及auto-route 和 auto-redirect 已启用。 与任意配置中的 routing-mark 冲突",
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
          "description": "启用 auto-route 时排除自定义网段",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.include-uid",
          "title": "include-uid",
          "kind": "list",
          "hint": "[0]",
          "description": "包含的用户，使其被 Tun 路由流量，未被配置的用户不会被 Tun 路由流量，默认不限制 UID 规则仅在 Linux 下被支持,并且需要 auto-route",
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
          "description": "包含的用户范围，使其被 Tun 路由流量，未被配置的用户不会被 Tun 路由流量",
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
          "description": "排除用户，使其避免被 Tun 路由流量",
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
          "description": "排除用户范围，使其避免被 Tun 路由流量",
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
          "description": "按来源 MAC 地址限制被路由的局域网设备。仅支持 Linux，且需要启用 auto-route 和 auto-redirect。",
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
          "description": "按来源 MAC 地址排除局域网设备的流量。仅支持 Linux，且需要启用 auto-route 和 auto-redirect。",
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
          "description": "包含的 Android 用户，使其被 Tun 路由流量，未被配置的用户不会被 Tun 路由流量 Android 用户和应用规则仅在 Android 下被支持,并且需要 auto-route | 常用用户 | ID | | -------- | --- | | 机主 | 0 | | 手机分身 | 10 | | 应用多开 | 999 |",
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
          "description": "包含的 Android 应用包名，使其被 Tun 路由流量，未配置的应用包不会被 Tun 路由流量",
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
          "description": "排除 Android 应用包名，使其避免被 Tun 路由流量",
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
          "description": "启用 auto-route时路由自定义网段而不是默认路由，一般无需配置。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-route-address",
          "title": "inet6-route-address",
          "kind": "list",
          "hint": "[\"::/1\",\"8000::/1\"]",
          "description": "启用 auto-route时路由自定义网段而不是默认路由，一般无需配置。",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet4-route-exclude-address",
          "title": "inet4-route-exclude-address",
          "kind": "list",
          "hint": "[\"192.168.0.0/16\"]",
          "description": "启用 auto-route 时排除自定义网段",
          "required": false,
          "elementKind": "string",
          "document": "inbound/tun.md"
        },
        {
          "path": "tun.inet6-route-exclude-address",
          "title": "inet6-route-exclude-address",
          "kind": "list",
          "hint": "[\"fc00::/7\"]",
          "description": "启用 auto-route 时排除自定义网段",
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
          "description": "是否启用 sniffer",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.force-dns-mapping",
          "title": "force-dns-mapping",
          "kind": "boolean",
          "hint": "true",
          "description": "对 redir-host 类型识别的流量进行强制嗅探",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.parse-pure-ip",
          "title": "parse-pure-ip",
          "kind": "boolean",
          "hint": "true",
          "description": "对所有未获取到域名的流量进行强制嗅探",
          "required": false,
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.override-destination",
          "title": "override-destination",
          "kind": "boolean",
          "hint": "false",
          "description": "是否使用嗅探结果作为实际访问，默认为 true",
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
                  "description": "",
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
                  "description": "",
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
                  "description": "",
                  "required": false,
                  "elementKind": "string",
                  "document": "sniff/index.md"
                },
                {
                  "path": "sniffer.sniff.HTTP.override-destination",
                  "title": "override-destination",
                  "kind": "boolean",
                  "hint": "true",
                  "description": "",
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
          "description": "强制进行嗅探的域名列表，使用域名通配",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-src-address",
          "title": "skip-src-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的来源 IP 段列表",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-dst-address",
          "title": "skip-dst-address",
          "kind": "list",
          "hint": "[\"192.168.0.3/32\"]",
          "description": "跳过嗅探的目标 IP 段列表",
          "required": false,
          "elementKind": "string",
          "document": "sniff/index.md"
        },
        {
          "path": "sniffer.skip-domain",
          "title": "skip-domain",
          "kind": "list",
          "hint": "[\"Mijia Cloud\"]",
          "description": "跳过嗅探的域名列表，使用域名通配",
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
          "description": "支持的算法： - lru: Least Recently Used, 默认值 - arc: Adaptive Replacement Cache",
          "required": false,
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
          "description": "是否启用，如为 false，则使用系统 DNS 解析",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.prefer-h3",
          "title": "prefer-h3",
          "kind": "boolean",
          "hint": "false",
          "description": "DOH 优先使用 http/3",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.listen",
          "title": "listen",
          "kind": "string",
          "hint": "0.0.0.0:1053",
          "description": "DNS 服务监听，支持 udp, tcp",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.ipv6",
          "title": "ipv6",
          "kind": "boolean",
          "hint": "false",
          "description": "是否解析 IPV6, 如为 false, 则回应 AAAA 的空解析",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.default-nameserver",
          "title": "default-nameserver",
          "kind": "list",
          "hint": "[\"223.5.5.5\"]",
          "description": "默认 DNS, 用于解析 DNS 服务器 的域名 必须为 IP, 可为加密 DNS",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.enhanced-mode",
          "title": "enhanced-mode",
          "kind": "choice",
          "hint": "fake-ip",
          "description": "可选值 fake-ip/redir-host，默认redir-host mihomo 的 DNS 处理模式",
          "required": false,
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
          "description": "fakeip 下的 IP 段设置，tun 的默认 IPV4 地址 也使用此值作为参考",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-range6",
          "title": "fake-ip-range6",
          "kind": "string",
          "hint": "fdfe:dcba:9876::1/64",
          "description": "fakeip 下的 IPv6 段设置",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-filter",
          "title": "fake-ip-filter",
          "kind": "list",
          "hint": "[\"RULE-SET,reject-domain,fake-ip\",\"RULE-SET,proxy-domain,fake-ip\",\"GEOSITE,gfw,fake-ip\",\"DOMAIN,www.baidu.com,real-ip\",\"DOMAIN-SUFFIX,qq.com,real-ip\",\"DOMAIN-SUFFIX,jd.com,fake-ip\",\"MATCH,fake-ip\"]",
          "description": "fakeip 过滤，以下地址不会下发 fakeip 映射用于连接 值支持域名通配以及引入域名集合",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fake-ip-filter-mode",
          "title": "fake-ip-filter-mode",
          "kind": "choice",
          "hint": "rule",
          "description": "可选 blacklist/whitelist/rule，默认blacklist，whitelist 即只有匹配成功才返回 fake-ip 当fake-ip-filter-mode设置为rule时，开启规则模式，此时fake-ip-filter的写法发生改变:",
          "required": false,
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
          "description": "配置fakeip查询返回的TTL，非必要情况下请勿修改",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.use-hosts",
          "title": "use-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否回应配置中的 hosts，默认 true",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.respect-rules",
          "title": "respect-rules",
          "kind": "boolean",
          "hint": "false",
          "description": "dns 连接遵守路由规则，需配置 proxy-server-nameserver 强烈不建议和 prefer-h3 一起使用",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.nameserver",
          "title": "nameserver",
          "kind": "list",
          "hint": "[\"https://8.8.8.8/dns-query#proxy&ecs=1.1.1.1/24&ecs-override=true\"]",
          "description": "默认的域名解析服务器",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.fallback",
          "title": "fallback",
          "kind": "list",
          "hint": "[\"tls://8.8.4.4\",\"tls://1.1.1.1\"]",
          "description": "后备域名解析服务器，一般情况下使用境外 DNS, 保证结果可信 配置 fallback后默认启用 fallback-filter,geoip-code为 cn",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.proxy-server-nameserver",
          "title": "proxy-server-nameserver",
          "kind": "list",
          "hint": "[\"https://doh.pub/dns-query\"]",
          "description": "代理节点域名解析服务器，仅用于解析代理节点的域名，如果不填则遵循 nameserver-policy、nameserver 和 fallback 的配置",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.proxy-server-nameserver-policy",
          "title": "proxy-server-nameserver-policy",
          "kind": "map",
          "hint": "{\"www.yournode.com\":\"114.114.114.114\"}",
          "description": "格式同nameserver-policy，仅用于节点域名解析，当且仅当proxy-server-nameserver不为空时生效",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.direct-nameserver",
          "title": "direct-nameserver",
          "kind": "list",
          "hint": "[\"system\"]",
          "description": "用于 direct 出口域名解析的 DNS 服务器，如果不填则遵循 nameserver-policy、nameserver 和 fallback 的配置",
          "required": false,
          "elementKind": "string",
          "document": "dns/index.md"
        },
        {
          "path": "dns.direct-nameserver-follow-policy",
          "title": "direct-nameserver-follow-policy",
          "kind": "boolean",
          "hint": "false",
          "description": "是否遵循 nameserver-policy，默认为不遵守，仅当 direct-nameserver 不为空时生效",
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
              "description": "",
              "required": false,
              "document": "dns/index.md"
            },
            {
              "path": "dns.fallback-filter.geoip-code",
              "title": "geoip-code",
              "kind": "string",
              "hint": "CN",
              "description": "",
              "required": false,
              "document": "dns/index.md"
            },
            {
              "path": "dns.fallback-filter.ipcidr",
              "title": "ipcidr",
              "kind": "list",
              "hint": "[\"240.0.0.0/4\",\"0.0.0.0/32\",\"127.0.0.1/32\",\"100.64.0.0/10\"]",
              "description": "",
              "required": false,
              "elementKind": "string",
              "document": "dns/index.md"
            },
            {
              "path": "dns.fallback-filter.domain",
              "title": "domain",
              "kind": "list",
              "hint": "[\"+.google.com\",\"+.facebook.com\",\"+.youtube.com\"]",
              "description": "",
              "required": false,
              "elementKind": "string",
              "document": "dns/index.md"
            },
            {
              "path": "dns.fallback-filter.geosite",
              "title": "geosite",
              "kind": "list",
              "hint": "[\"gfw\"]",
              "description": "",
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
          "description": "默认值为 false ，如果为 true 会先判断来自 nameserver 的结果是否满足 fallback-filter 后再发起查询",
          "required": false,
          "document": "dns/index.md"
        },
        {
          "path": "dns.nameserver-policy",
          "title": "nameserver-policy",
          "kind": "map",
          "hint": "{\"+.arpa\":\"10.0.0.1\",\"rule-set:cn\":[\"https://doh.pub/dns-query\",\"https://dns.alidns.com/dns-query\"]}",
          "description": "指定域名查询的解析服务器，可使用 geosite, 优先于 nameserver/fallback 查询 键支持域名通配 值支持字符串/数组",
          "required": false,
          "elementKind": "list",
          "document": "dns/index.md"
        },
        {
          "path": "dns.use-system-hosts",
          "title": "use-system-hosts",
          "kind": "boolean",
          "hint": "true",
          "description": "是否查询系统 hosts，默认 true",
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
      "description": "",
      "required": false,
      "unavailableReason": "仅支持 Windows",
      "document": "general.md"
    },
    {
      "path": "external-controller-routing-mark",
      "title": "external-controller-routing-mark",
      "kind": "integer",
      "hint": "0",
      "description": "",
      "required": false,
      "unavailableReason": "仅支持 Linux",
      "document": "general.md"
    },
    {
      "path": "unified-delay",
      "title": "unified-delay",
      "kind": "boolean",
      "hint": "true",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "routing-mark",
      "title": "routing-mark",
      "kind": "integer",
      "hint": "6666",
      "description": "",
      "required": false,
      "unavailableReason": "仅支持 Linux",
      "document": "general.md"
    },
    {
      "path": "geodata-mode",
      "title": "geodata-mode",
      "kind": "boolean",
      "hint": "true",
      "description": "",
      "required": false,
      "document": "general.md"
    },
    {
      "path": "geodata-loader",
      "title": "geodata-loader",
      "kind": "choice",
      "hint": "memconservative",
      "description": "",
      "required": false,
      "choices": [
        "memconservative",
        "standard"
      ],
      "document": "general.md"
    },
    {
      "path": "global-ua",
      "title": "global-ua",
      "kind": "string",
      "hint": "clash.meta",
      "description": "",
      "required": false,
      "defaultHint": "clash.meta",
      "document": "general.md"
    },
    {
      "path": "etag-support",
      "title": "etag-support",
      "kind": "boolean",
      "hint": "true",
      "description": "",
      "required": false,
      "document": "general.md"
    }
  ]
}
"""#

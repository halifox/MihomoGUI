# 配置字段与内核版本

当前字段兼容版本的单一声明是 `Sources/MihomoGUICore/DocSchemas.swift` 中的 `configurationCoreVersion`，现为 `1.19.34`。构建会检查固定资源标签和内核 `-v` 输出；安装前再次检查暂存内核版本；热重载先读取 `/version`，不匹配时拒绝写入，草稿仍可保留。错误消息不回显任意版本响应内容。

2026-11-15 核对官方 mihomo `v1.19.32`（`88dcbf7f1614a67c3b36b848ee3592dfa92ada36`）至 `v1.19.34`（`0455d0d28c4526937380505153e65a843d8612e8`）的 28 个提交、82 个文件差异：

- `config/config.go` 中现有默认配置未改动；新增 TUN `dns-mode`。本编辑器不承诺列出内核全部新增字段，可沿用额外字段输入，最终由匹配版本的内核校验。
- `adapter/outboundgroup/parser.go` 与 `adapter/provider/healthcheck.go` 在此区间未改动，现有健康检查默认值继续适用。
- `config/config.go` 的 GlobalUA 使用 `"clash.meta/" + C.Version`，两处过期的类型化默认值已改为 v1.19.34。
- `adapter/outbound/snell.go` 和 `docs/config.yaml` 新增 Snell v6。已校正版本/UDP/复用说明及 v6 PSK、混淆限制；HTTP、SSH、WireGuard 等更改主要涉及运行行为，仍以真实内核校验和对应回归为准，不声称完整协议互通测试。

固定来源：[v1.19.34 源码](https://github.com/MetaCubeX/mihomo/tree/0455d0d28c4526937380505153e65a843d8612e8)、[版本差异](https://github.com/MetaCubeX/mihomo/compare/88dcbf7f1614a67c3b36b848ee3592dfa92ada36...0455d0d28c4526937380505153e65a843d8612e8)。

更新资源 PR 必须先审查版本差异、默认值与字段语义，修订定义和说明，更新兼容声明，再执行完整构建、交互回归和相应协议验证。不能仅改版本常量来绕过失败门禁。新内核上游版本不自动视为兼容，旧服务应在更新应用后明确停止并重新启动。

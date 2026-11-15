# 字段文档来源

字段结构、默认值与说明分别维护在 `DocSchemas.swift`、`Groups.swift`、`HelpDocs.swift`；不在运行时读取外部文档。2026-11-15 的来源快照和文件摘要见 [field-sources.json](field-sources.json)，覆盖上述定义引用的全部 42 份中文文档。

文档来源为 [MetaCubeX/Meta-Docs 固定提交 0ec4dad4496d905b42db3794c49b2ce690a13a5b](https://github.com/MetaCubeX/Meta-Docs/tree/0ec4dad4496d905b42db3794c49b2ce690a13a5b/docs/config)。每份文件保留官方 Git blob SHA-1 与原始字节 SHA-256，避免以可移动的 main 分支作为唯一依据。

最初使用的本地 Meta-Docs 是无 Git 元数据的目录，无法追溯其原始下载提交。本次通过官方固定提交的完整 Git tree 比对：39 份文件逐字节一致；TUN、Snell、load-balance 三份不同，已下载固定提交原文并核对差异，清单同时保留这三份本地旧文件摘要。该比对不声称找回了原始目录的历史提交。

文档可能领先内核：此次差异包含 TUN dns-mode、Snell v6/userkey 和负载均衡 hash-key。应用现有字段按固定内核源码核对；没有因为文档出现新选项就自动加入 UI 或写入默认配置。尤其文档里的 Snell userkey 不应被当作 v1.19.34 已核对支持的字段。内核固定源码、版本范围与审核结论见 [core-compatibility.md](core-compatibility.md)，二者冲突时以该版本源码和实际校验结果为准。

执行 `python3 scripts/check-field-sources.py` 可检查引用覆盖、快照格式及审核产物摘要。它验证来源记录与代码是否同步，不能证明字段语义正确。维护者修改字段或说明后，须阅读相关正文、公共字段、示例及目标版本源码，记录新的固定来源和日期，再更新审核产物摘要。禁止只刷新摘要而跳过语义审核。

本项目保留文档摘要与链接，不打包 Meta-Docs 原文；引入新的第三方内容时仍需核对其许可证和归属要求。

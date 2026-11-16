# v1.0.0 历史附件验证

本次为已有公开版本补充校验和、重建的构建元数据及历史来源验证记录。原始应用 ZIP 与标签保持不变；该 ZIP 的源码提交为 `7853f1d5a3ddd0140080af0ab36804f2df86a1e5`，不包含后续源码修复。

已核对原始成功运行 https://github.com/halifox/MihomoGUI/actions/runs/43689272459 的检出日志、工具链及 CI 归档：

- 原始应用 ZIP 的 SHA-256：`9246cd83009f610c7a0860550f93cc020fa1dbcd8171928af7652b0105743c71`。
- CI 归档（资产 ID `14151089074`）的 SHA-256：`c62c24d6776738e5bab696b1bcaeba5a940204e53ab843ac1a84765e133109d8`。归档仅包含上述应用 ZIP，其内部文件与公开 ZIP 摘要一致。
- 检出日志记录同一源码提交；工具链为 Xcode 26.5（17F42）、Swift 6.3.2，二进制声明最低 macOS 13.0、SDK 26.5，签名为 ad-hoc。

`BUILD-METADATA.json` 来自原始日志与二进制静态检查；未记录的原始工作树状态等字段保留为 `null`。`LEGACY-PROVENANCE.json` 是后补的验证记录，附带原始 CI 归档供独立核对；它不是原始构建签发的 Sigstore 证明。原始工作流没有签发步骤，现有摘要的证明查询返回404，因此没有补造 `provenance.sigstore.json`。新版本仍须通过正常的来源证明发布门禁。

从同一 Release 下载以下文件到同一目录：应用 ZIP、`MihomoGUI-v1.0.0-ci-artifact.zip`、`BUILD-METADATA.json`、`LEGACY-PROVENANCE.json`、本文件及 `SHA256SUMS`。先执行：

```bash
shasum -a 256 -c SHA256SUMS
```

再核对 CI 归档中的应用 ZIP：

```python
import hashlib
import zipfile
name = "MihomoGUI-v1.0.0-macos-arm64.zip"
with zipfile.ZipFile("MihomoGUI-v1.0.0-ci-artifact.zip") as archive:
    digest = hashlib.sha256()
    with archive.open(name) as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
assert digest.hexdigest() == "9246cd83009f610c7a0860550f93cc020fa1dbcd8171928af7652b0105743c71"
```

本记录验证历史来源关联与文件完整性，不代表 Developer ID、公证、Gatekeeper 或所有系统与网络场景的实机验收。

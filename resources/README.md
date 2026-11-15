# 内置资源

## 自动下载与更新

CI 使用 `manifest.json` 固定 mihomo arm64 内核和四份 GEO 数据的上游资产 ID、来源与 SHA-256。已安装 GitHub CLI 并设置 `GH_TOKEN` 后，可执行：

```sh
python3 scripts/resources.py download
bash scripts/build.sh
```

内核与数据下载到下述现有目录，不提交 Git。下载成功后在忽略目录 `.build/resource-receipts.json` 保存每个固定资产及解压后文件的摘要；构建会核对收据、当前清单、源文件及复制后的文件。缺少收据或任一文件被替换时默认失败。更新清单使用 `python3 scripts/resources.py update`，定时工作流也会执行此命令并创建 PR。清单摘要针对上游原始文件（内核为 gzip 文件），下载校验后才解压。

上游使用可变的 `latest` 发布时，资产 ID 可以防止下载被替换的文件，但不能保证上游永久保留旧资产。旧资产被删除时构建会失败，需要更新清单；不会自动回退到未经确认的新资源。清单中的 URL 用于追溯来源，实际通过 GitHub API 按资产 ID 下载。

发布前须核对所选内核和数据的许可证及归属要求；自动下载不会改变这些要求。现有许可文本与归属说明位于 [licenses/](licenses/)，构建脚本会复制许可说明，并按实际打包文件生成随包资源清单。项目源代码许可证见 [LICENSE](../LICENSE)，自动资源更新流程见 [发布维护文档](../docs/releasing.md)。

`AppIcon.png` 是应用图标的 1024 × 1024 PNG 源图，也用于 README 展示；
`AppIcon.icns` 包含 macOS 所需的多尺寸图标，由构建脚本复制到应用资源目录。

将下载并解压后的文件放在以下位置，名称及大小写必须一致：

```text
resources/
  core/
    arm64/mihomo     # macOS Apple Silicon 内核
    x86_64/mihomo    # macOS Intel 内核
  geodata/
    Country.mmdb
    geoip.dat
    geosite.dat
    ASN.mmdb
```

内核使用 mihomo 官方发行的 macOS 二进制文件，解压后重命名为 `mihomo`，不要放入 `.gz` 压缩包、Linux 或 Windows 版本。只需准备当前构建机器对应架构的内核；为两个架构分发时，分别在对应架构环境构建。

GEO 数据用途：

| 文件 | 用途 |
| --- | --- |
| `Country.mmdb` | 默认 MMDB 模式下的 GEOIP 国家规则 |
| `geoip.dat` | 启用 `geodata-mode` 时的 GEOIP 国家规则 |
| `geosite.dat` | GEOSITE 域名分类规则 |
| `ASN.mmdb` | IP-ASN / SRC-IP-ASN 规则 |

可从 MetaCubeX/meta-rules-dat 的 release 数据中获取前三项；其 `country.mmdb` 下载后重命名为 `Country.mmdb`。ASN 数据可使用 xishang0128/geoip 的 `GeoLite2-ASN.mmdb`，重命名为 `ASN.mmdb`。请随分发保留所使用内核及数据要求的许可和归属说明。

在项目根目录执行：

```sh
bash scripts/build.sh
```

脚本检查四份数据和当前架构内核，并核对下载收据，缺少、为空或摘要不一致时立即报错，不会自动下载。文件复制到 `dist/MihomoGUI.app` 后再签名；最终交付整个 `.app`，无需另外交付 resources 文件夹。

手动准备的资源（包括当前清单尚未固定的 Intel 内核）需显式执行 `ALLOW_UNVERIFIED_RESOURCES=1 bash scripts/build.sh`。此模式不会把本地文件冒认为固定上游资产，随包清单标为 `local-unverified`，记录实际输入及打包文件摘要，不附加未经验证的上游资产身份；分发者仍须核对来源和许可。

随包 `resources-manifest.json` 由实际构建生成：固定资产模式为 `pinned-source-sha256`，包含原资产身份、输入文件摘要及最终打包摘要。内核签名会改变文件内容，因此清单分别记录签名前后的 SHA-256 及 `codesign` 转换；GEO 数据应保持逐字节一致。可运行 `python3 scripts/check-resources.py` 验证离线身份与复制边界。

应用固定使用内置内核，无需选择内核路径。GEO 数据按需复制到可写缓存，已有有效缓存会保留；自定义 GEO 下载地址优先于内置数据。

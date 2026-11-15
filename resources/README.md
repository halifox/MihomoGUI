# 内置资源

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

脚本检查四份数据和当前架构内核，缺少或为空时立即报错，不会自动下载。文件复制到 `dist/mihomo.app` 后再签名；最终交付整个 `.app`，无需另外交付 resources 文件夹。

应用固定使用内置内核，无需选择内核路径。GEO 数据按需复制到可写缓存，已有有效缓存会保留；自定义 GEO 下载地址优先于内置数据。

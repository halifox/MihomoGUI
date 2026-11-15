# 卸载

MihomoGUI 的界面、内核服务、特权辅助服务和用户数据分别存放。仅将应用移到废纸篓不会停止或删除已安装的系统服务。

系统服务只属于一位安装用户。切换到另一位用户前，应由原用户停止服务并完成系统卸载，或由管理员执行以下步骤；各用户自己的草稿目录可分别保留。归属记录缺失而仍有系统文件时，应用会拒绝自动接管，需先完整清理。

以下步骤按当前代码中的服务标签和安装路径编写；命令需要在终端中手动执行。它们未经过本次文档整理的实际卸载验证。删除前备份需要保留的配置，后两步的删除操作不可恢复。

## 1. 停止内核并退出应用

在仪表盘点击“停止 mihomo 内核”，确认服务停止，再使用 Cmd-Q 退出 GUI。关闭窗口也会退出当前应用，但退出本身不会停止内核。

应用无法打开时，可使用系统命令停止并禁止内核服务自动启动：

```bash
sudo launchctl disable system/local.MihomoGUI.core
sudo launchctl bootout system/local.MihomoGUI.core
```

若服务已经卸载，`bootout` 可能报告找不到服务。继续前用以下命令检查；仍能输出服务详情时，不应直接删除运行文件：

```bash
sudo launchctl print system/local.MihomoGUI.core
```

`print` 报告找不到服务，表示该标签当前未加载。其他权限或系统错误需先排查。

## 2. 卸载特权辅助服务

GUI 退出后，在终端执行：

```bash
sudo launchctl bootout system/local.MihomoGUI.helper
sudo launchctl print system/local.MihomoGUI.helper
```

同样确认 `print` 报告找不到服务。若仍显示已加载，先处理停止失败，再继续。

## 3. 删除系统文件和应用

确认两个服务均未加载、且没有正在进行的安装或管理员授权操作后，删除当前版本安装的文件：

```bash
sudo rm -f /Library/LaunchDaemons/local.MihomoGUI.core.plist
sudo rm -f /Library/LaunchDaemons/local.MihomoGUI.helper.plist
sudo rm -f /Library/PrivilegedHelperTools/local.MihomoGUI.helper
sudo rm -rf /Library/PrivilegedHelperTools/MihomoGUI
sudo rm -rf "/Library/Application Support/MihomoGUI"
```

然后将安装位置的 `MihomoGUI.app` 移到废纸篓。这些步骤不删除当前用户的草稿、订阅和节点缓存。

## 4. 可选：删除用户数据

如需保留设置以便重新安装，跳过此步。完整清除当前用户配置、节点、订阅与 GEO 缓存时执行：

```bash
rm -rf "$HOME/Library/Application Support/MihomoGUI"
```

这里的 `~/Library/` 是用户目录，区别于前一步的系统目录 `/Library/`。多用户机器上，每个用户的数据需要分别处理。

重新安装时，应用会在启动内核过程中重新安装和启用所需服务，并按系统要求请求管理员授权。

## 安装锁异常

安装与升级用目录锁协调多个用户，正常完成或失败会释放。若安装进程被强制杀死，锁可能残留。先确认所有用户均没有正在安装，且上次安装进程已经退出，再检查并删除空锁目录：

```bash
sudo ls -ld /Library/PrivilegedHelperTools/local.MihomoGUI.helper.install-lock
sudo rmdir /Library/PrivilegedHelperTools/local.MihomoGUI.helper.install-lock
```

不要在安装进行中移除锁；目录不存在时无需执行删除。锁的清理不会改变安装用户归属。

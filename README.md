# taoSync Magisk

基于 [taoSync](https://github.com/dr34m/taosync) 源码编译的 Magisk 模块，在 Android 设备上开机自启动 taoSync 同步服务。

taoSync 是一个文件同步管理工具，支持多存储之间的文件同步、备份、迁移等操作。

## 功能特性

- **开机自启** — 刷入后重启自动运行，无需任何操作
- **进程守护** — 每 30 秒检测进程状态，崩溃自动重启
- **Magisk 开关控制** — 关闭模块 30 秒内自动停服，无需重启；重新开启后重启恢复
- **默认密码** — 首次启动密码为 `admin`
- **兼容 Magisk v20.4+**

## 安装

1. 从 [Releases](https://github.com/ojbkxc/taosync-Magisk/releases) 下载最新版本的 zip 文件
2. Magisk App → 模块 → 从本地安装
3. 重启设备

## 使用

### 访问管理面板

同一局域网浏览器访问 `http://手机IP:8023`，默认密码 `admin`。

### Magisk 开关控制

- **关闭**：Magisk 中关闭模块 → 守护进程 30 秒内检测到 `disable` 文件 → 自动停止服务，**无需重启**
- **开启**：Magisk 中重新开启 → 重启设备 → 服务自动恢复

### 环境变量

启动时通过以下环境变量配置（参照 [taoSync Dockerfile](https://github.com/dr34m/taosync/blob/main/Dockerfile)）：

| 变量 | 值 | 说明 |
|------|-----|------|
| `TAO_PASSWORD` | `admin` | 管理员密码 |
| `TAO_PORT` | `8023` | Web 服务端口 |
| `TAO_EXPIRES` | `2` | 登录过期时间（小时） |
| `TAO_LOG_LEVEL` | `1` | 日志级别 |
| `TAO_CONSOLE_LEVEL` | `2` | 控制台日志级别 |
| `TAO_LOG_SAVE` | `7` | 日志保留天数 |
| `TAO_TASK_SAVE` | `0` | 任务记录保留天数 |
| `TAO_TASK_TIMEOUT` | `72` | 任务超时时间（小时） |

## 目录

| 路径 | 说明 |
|------|------|
| `/data/adb/taosync/data/` | 数据目录（config.ini、secret.key、taoSync.db） |
| `/data/adb/taosync/taosync.log` | 运行日志 |

## 构建

GitHub Actions 自动从 taoSync 源码编译 arm64 二进制（PyInstaller + StaticX）并打包为 Magisk 模块。

- 推送 `v*` 标签自动触发发版
- 或手动触发 "Build & Release" 工作流

## 常见问题

**Q: 如何查看 taoSync 是否正常运行？**

```bash
ps -ef | grep taoSync
```

**Q: 如何查看日志？**

```bash
cat /data/adb/taosync/taosync.log
```

**Q: 如何手动重启？**

```bash
pkill -f taoSync_bin
# 守护进程会在 30 秒内自动重启
```

**Q: 忘记管理员密码？**

```bash
# 删除数据目录重新初始化（丢失所有配置）
rm -rf /data/adb/taosync/data
# 重启后密码恢复为 admin
```

## License

MIT
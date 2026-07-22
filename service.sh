#!/system/bin/sh
export PATH=/sbin:/system/sbin:/system/bin:/system/xbin

# 等待系统完全启动
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 10
done

MODDIR=${0%/*}
CONF_DIR=/data/adb/taosync
LOG_FILE="$CONF_DIR/taosync.log"
DATA_DIR="$CONF_DIR/data"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

mkdir -p "$CONF_DIR"
mkdir -p "$DATA_DIR"

log "=== service.sh 启动 ==="

# 查找 taoSync 二进制
TAOSYNC_BIN="$MODDIR/taosync_bin"
if [ ! -f "$TAOSYNC_BIN" ]; then
  log "错误: 未找到 taoSync 二进制文件"
  exit 1
fi

log "二进制: $TAOSYNC_BIN"
log "数据目录: $DATA_DIR"

# 启动函数
start_taosync() {
  mkdir -p "$DATA_DIR"
  cd "$CONF_DIR"
  TAO_PASSWORD=admin \
  TAO_PORT=8023 \
  TAO_EXPIRES=2 \
  TAO_LOG_LEVEL=1 \
  TAO_CONSOLE_LEVEL=2 \
  TAO_LOG_SAVE=7 \
  TAO_TASK_SAVE=0 \
  TAO_TASK_TIMEOUT=72 \
  "$TAOSYNC_BIN" >> "$LOG_FILE" 2>&1 &
  log "taoSync 已启动, PID=$!"
}

# 首次启动
start_taosync

# 守护循环：每30秒检测一次，崩溃自动重启，检测到 disable 文件则退出
while true; do
  sleep 30

  # 检测 Magisk 模块是否被禁用
  if [ -f "$MODDIR/disable" ]; then
    pkill -f "$TAOSYNC_BIN" 2>/dev/null
    log "检测到模块已禁用，taoSync 已停止"
    exit 0
  fi

  if ! pgrep -f "$TAOSYNC_BIN" > /dev/null 2>&1; then
    log "taoSync 进程已退出，正在重启..."
    start_taosync
  fi
done
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
TMP_DIR="$CONF_DIR/tmp"

PYTHON_BIN="/system/bin/python3.11-android"
TAOSYNC_DIR="/system/lib/taosync"
TAOSYNC_MAIN="$TAOSYNC_DIR/main.py"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

mkdir -p "$CONF_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$TMP_DIR"
chmod 1777 "$TMP_DIR"
export TMPDIR="$TMP_DIR"

log "=== service.sh 启动 ==="

# 查找 Python 和 taosync
if [ ! -f "$PYTHON_BIN" ]; then
  log "错误: 未找到 Python 二进制文件: $PYTHON_BIN"
  exit 1
fi

if [ ! -f "$TAOSYNC_MAIN" ]; then
  log "错误: 未找到 taosync 主文件: $TAOSYNC_MAIN"
  exit 1
fi

chmod 755 "$PYTHON_BIN" 2>/dev/null
log "Python: $PYTHON_BIN"
log "taosync: $TAOSYNC_MAIN"
log "数据目录: $DATA_DIR"

# 启动函数
start_taosync() {
  mkdir -p "$DATA_DIR"
  mkdir -p "$TMP_DIR"
  chmod 1777 "$TMP_DIR"

  # 设置环境变量
  export PYTHONPATH="$TAOSYNC_DIR"
  export TAO_PASSWORD=admin
  export TAO_PORT=8023
  export TAO_EXPIRES=2
  export TAO_LOG_LEVEL=1
  export TAO_CONSOLE_LEVEL=2
  export TAO_LOG_SAVE=7
  export TAO_TASK_SAVE=0
  export TAO_TASK_TIMEOUT=72

  # 切换到数据目录并启动
  cd "$CONF_DIR"
  "$PYTHON_BIN" "$TAOSYNC_MAIN" >> "$LOG_FILE" 2>&1 &
  log "taoSync 已启动, PID=$!"
}

# 首次启动
start_taosync

# 守护循环：每30秒检测一次，崩溃自动重启，检测到 disable 文件则退出
while true; do
  sleep 30

  # 检测 Magisk 模块是否被禁用
  if [ -f "$MODDIR/disable" ]; then
    pkill -f "$TAOSYNC_MAIN" 2>/dev/null
    log "检测到模块已禁用，taoSync 已停止"
    exit 0
  fi

  if ! pgrep -f "$TAOSYNC_MAIN" > /dev/null 2>&1; then
    log "taoSync 进程已退出，正在重启..."
    start_taosync
  fi
done
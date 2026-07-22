SKIPMOUNT=true
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true

# 设置执行权限
if [ -f "$MODPATH/system/bin/python3.11-android" ]; then
  set_perm $MODPATH/system/bin/python3.11-android 0 0 0755
  ui_print "- Python 二进制文件就绪"
else
  ui_print "! 警告：未找到 Python 二进制文件"
fi

# 设置 taosync 目录权限
if [ -d "$MODPATH/system/lib/taosync" ]; then
  set_perm_recursive $MODPATH/system/lib/taosync 0 0 0755 0644
  ui_print "- taoSync 源码目录就绪"
else
  ui_print "! 警告：未找到 taosync 源码目录"
fi

ui_print "----------------------------------"
ui_print "  taoSync 同步服务 安装成功"
ui_print "----------------------------------"
ui_print "作者：ojbkxc"
ui_print "管理面板：http://手机IP:8023"
ui_print "默认账户：admin / admin"
ui_print "配置目录：/data/adb/taosync/data/"
ui_print "日志文件：/data/adb/taosync/taosync.log"
ui_print "----------------------------------"
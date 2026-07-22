SKIPMOUNT=true
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true

# 复制二进制到模块根目录（参照 cloudflare-Magisk / lucky_Magisk）
if [ -f "$MODPATH/system/bin/taosync" ]; then
  cp "$MODPATH/system/bin/taosync" "$MODPATH/taosync_bin"
fi

# 设置执行权限
if [ -f "$MODPATH/taosync_bin" ]; then
  set_perm $MODPATH/taosync_bin 0 0 0755
  ui_print "- taoSync 二进制文件就绪"
else
  ui_print "! 警告：未找到 taoSync 二进制文件，模块可能无法正常工作"
fi

ui_print "----------------------------------"
ui_print "  taoSync 同步服务 安装成功"
ui_print "----------------------------------"
ui_print "管理面板：http://手机IP:8023"
ui_print "默认密码：admin"
ui_print "配置目录：/data/adb/taosync/data/"
ui_print "日志文件：/data/adb/taosync/taosync.log"
ui_print "----------------------------------"
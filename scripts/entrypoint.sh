#!/bin/sh

# 检查配置文件
if ! /smbox/sing-box/sing-box check -c /smbox/sing-box/config.json; then
    echo "❌ Singbox 配置检查失败"
    exit 1
fi
echo "✅ Singbox 配置检查通过"
exec /usr/bin/supervisord -c /etc/supervisord.conf

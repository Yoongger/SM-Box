#!/bin/bash

# 检查配置文件
check_config() {
    if ! /app/singbox/sing-box check -c /app/singbox/config.json; then
        echo "❌ Singbox 配置检查失败"
        exit 1
    fi
    echo "✅ Singbox 配置检查通过"
}

check_config
exec /usr/bin/supervisord -c /etc/supervisord.conf

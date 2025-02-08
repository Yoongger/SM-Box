package handlers

import (
    "net/http"
    "sync"

    "github.com/gin-gonic/gin"
)

var (
    proxyMutex sync.RWMutex
    currentMode = "auto" // 默认代理模式
)

// 代理模式配置结构
type ProxyConfig struct {
    Mode       string   `json:"mode"`
    PACUrl     string   `json:"pac_url,omitempty"`
    DirectList []string `json:"direct_list,omitempty"`
    ProxyList  []string `json:"proxy_list,omitempty"`
}

// SetProxyMode 设置代理模式
func SetProxyMode(c *gin.Context) {
    var config struct {
        Mode string `json:"mode" binding:"required,oneof=direct proxy auto rule"`
    }

    if err := c.ShouldBindJSON(&config); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    proxyMutex.Lock()
    currentMode = config.Mode
    proxyMutex.Unlock()

    // 这里可以添加实际切换代理模式的逻辑
    // 例如调用系统命令或更新路由规则

    c.JSON(http.StatusOK, gin.H{
        "message": "代理模式已更新",
        "mode":    config.Mode,
    })
}

// GetProxyStatus 获取当前代理状态
func GetProxyStatus() ProxyConfig {
    proxyMutex.RLock()
    defer proxyMutex.RUnlock()

    return ProxyConfig{
        Mode:       currentMode,
        PACUrl:     "http://localhost:8080/proxy.pac",
        DirectList: []string{"localhost", "192.168.0.0/16"},
        ProxyList:  []string{"example.com"},
    }
}

// ServePACFile 提供PAC文件服务
func ServePACFile(c *gin.Context) {
    pacContent := `function FindProxyForURL(url, host) {
        // 自动模式规则
        if (shExpMatch(host, "*.internal.com")) return "DIRECT";
        return "PROXY proxy.example.com:8080; DIRECT";
    }`

    c.Header("Content-Type", "application/x-ns-proxy-autoconfig")
    c.String(200, pacContent)
}
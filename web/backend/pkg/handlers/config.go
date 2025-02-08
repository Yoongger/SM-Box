package handlers

import (
    "encoding/json"
    "os"
    "sync"
    "net/http"
    "github.com/gin-gonic/gin"
)

var (
    configMutex sync.Mutex
    configFile  = "config.json"
)

type FilterList struct {
    Name    string `json:"name"`
    URL     string `json:"url"`
    Enabled bool   `json:"enabled"`
}

type Config struct {
    AdBlockEnabled  bool         `json:"adBlockEnabled"`
    ProxyMode       string       `json:"proxyMode"`
    UpdateInterval  int          `json:"updateInterval"`
    FilterLists     []FilterList `json:"filterLists"`
    CustomFilters   string       `json:"customFilters"`
}

func loadConfig() (Config, error) {
    configMutex.Lock()
    defer configMutex.Unlock()

    file, err := os.ReadFile(configFile)
    if err != nil {
        return Config{}, err
    }

    var config Config
    err = json.Unmarshal(file, &config)
    return config, err
}

func saveConfig(config Config) error {
    configMutex.Lock()
    defer configMutex.Unlock()

    data, err := json.MarshalIndent(config, "", "  ")
    if err != nil {
        return err
    }

    return os.WriteFile(configFile, data, 0644)
}

func GetConfig(c *gin.Context) {
    config, err := loadConfig()
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "无法读取配置"})
        return
    }
    c.JSON(http.StatusOK, config)
}

func UpdateConfig(c *gin.Context) {
    var newConfig Config
    if err := c.ShouldBindJSON(&newConfig); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    if err := saveConfig(newConfig); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "保存配置失败"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "配置更新成功"})
}
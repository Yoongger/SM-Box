package main

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "web/pkg/handlers"
    "web/pkg/middleware"
)

func main() {
    r := gin.Default()
    r.Use(middleware.CORS())

    api := r.Group("/api")
    {
        api.POST("/subscribe/convert", handlers.ConvertSubscription)
        api.GET("/config", handlers.GetConfig)
        api.PUT("/config", handlers.UpdateConfig)
        api.POST("/update/subscriptions", handlers.UpdateSubscriptions)
        api.POST("/update/rules", handlers.UpdateRules)
        api.PUT("/proxy/mode", handlers.SetProxyMode)
        api.GET("/proxy/status", func(c *gin.Context) {
            c.JSON(200, handlers.GetProxyStatus())
        })
        api.GET("/visual/nodes", handlers.GetVisualNodes)
        api.POST("/visual/nodes", handlers.SaveVisualNodes)
    }

    r.GET("/proxy.pac", handlers.ServePACFile)
    r.StaticFS("/ui", http.Dir("../frontend/build"))

    r.Run(":8080")
}
package handlers

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

type VisualNodes struct {
    Nodes []Node `json:"nodes"`
}

type Node struct {
    ID       string    `json:"id"`
    Position Position  `json:"position"`
    Data     NodeData  `json:"data"`
}

type Position struct {
    X float64 `json:"x"`
    Y float64 `json:"y"`
}

type NodeData struct {
    Label string `json:"label"`
}

func GetVisualNodes(c *gin.Context) {
    // 示例数据，实际应从数据库获取
    nodes := []Node{
        {
            ID:       "1",
            Position: Position{X: 0, Y: 0},
            Data:     NodeData{Label: "起始节点"},
        },
    }
    c.JSON(http.StatusOK, nodes)
}

func SaveVisualNodes(c *gin.Context) {
    var input VisualNodes
    if err := c.ShouldBindJSON(&input); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // 这里添加实际保存逻辑（如存入数据库）

    c.JSON(http.StatusOK, gin.H{
        "message": "节点保存成功",
        "count":   len(input.Nodes),
    })
}
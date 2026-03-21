package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"yuchat/hello/db"   // ← change to your module name!
)

func main() {
	// Connect to PostgreSQL when server starts
	db.ConnectDatabase()

	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":   "Hello from Gin + GORM + PostgreSQL!",
			"db_status": "connected", // just to prove it works
		})
	})

	// Simple /ping → check DB is alive
	r.GET("/ping", func(c *gin.Context) {
		sqlDB, err := db.DB.DB()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "DB not initialized"})
			return
		}

		if err := sqlDB.Ping(); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "DB ping failed"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"status":  "pong",
			"db":      "alive and reachable",
			"gorm":    "works",
		})
	})

	r.Run(":8080") // ← or r.Run() for default :8080
}
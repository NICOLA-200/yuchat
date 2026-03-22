package main

import (
	"net/http"
    "log"
	"github.com/gin-gonic/gin"
	"yuchat/backend/db"
	"yuchat/backend/models"
	"yuchat/backend/handlers" // ← change to your module name!
)

func main() {
	// Connect to PostgreSQL when server starts
	db.ConnectDatabase()

	err := db.DB.AutoMigrate(
		&models.User{},
		// &models.OtherModel{},  ← add more later
	)
	if err != nil {
		log.Fatalf("AutoMigrate failed: %v", err)
	}
	log.Println("Database migrated successfully")

	r := gin.Default()

	api := r.Group("/api")


	auth := api.Group("/auth")
	{
		auth.POST("/signup", handlers.SignupHandler)
		r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":   "Hello from Gin + GORM + PostgreSQL!",
			"db_status": "connected", // just to prove it works
		})
	})

	}



	r.Run(":8080") // ← or r.Run() for default :8080
}
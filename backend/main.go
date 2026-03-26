package main

import (
	"net/http"
	"github.com/joho/godotenv"
    "log"
	"github.com/gin-gonic/gin"
	"yuchat/backend/db"
	_ "yuchat/backend/docs"
	ginSwagger "github.com/swaggo/gin-swagger"
    "github.com/swaggo/files"
	"yuchat/backend/models"
	"yuchat/backend/handlers" // ← change to your module name!
)




// main.go (or docs.go)

// @title           YuChat API
// @version         1.0
// @description     Simple chat backend with user authentication
// @termsOfService  http://example.com/terms/

// @contact.name    API Support
// @contact.url     http://example.com/support
// @contact.email   support@yuchat.example.com

// @license.name    MIT
// @license.url     https://opensource.org/licenses/MIT

// @host      localhost:8080
// @BasePath  /api
// @schemes   http
func main() {
	_ = godotenv.Load()   // load .env file

    config.InitCloudinary()
    
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
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":   "Hello from Gin + GORM + PostgreSQL!",
			"db_status": "connected", // just to prove it works
		})
	})
    r.GET("/swagger/*any", func(c *gin.Context) {
    log.Println("Swagger handler hit for path:", c.Request.URL.Path)
    ginSwagger.WrapHandler(swaggerFiles.Handler)(c)
})

	auth := api.Group("/auth")
	{
		auth.POST("/signup", handlers.SignupHandler)
		auth.POST("/login",  handlers.LoginHandler)
		

	}



	r.Run(":8080") // ← or r.Run() for default :8080
}
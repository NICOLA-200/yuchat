package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// gin.Default() includes Logger + Recovery middleware — good default for beginners
	r := gin.Default()

	// Simple route
	r.GET("/", func(c *gin.Context) {
		// Three common ways — pick whichever you like:

		// Option 1: Plain text
		c.String(http.StatusOK, "Hello World from Gin! 🚀")

		// Option 2: JSON (most common for APIs)
		// c.JSON(http.StatusOK, gin.H{
		// 	"message": "Hello World from Gin!",
		// 	"status":  "ok",
		// })

		// Option 3: HTML snippet (just for fun)
		// c.Data(http.StatusOK, "text/html; charset=utf-8", []byte("<h1>Hello Gin 🌍</h1>"))
	})

	// Start server on port 8080 (default if you call r.Run() with no argument)
	r.Run(":8080")
	// You can also write: r.Run()  ← same as :8080
}
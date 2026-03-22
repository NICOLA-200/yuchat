package db

import (
	"fmt"
	"log"
	

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	// ────────────────────────────────────────────────
	// Change these values to match YOUR local PostgreSQL
	// ────────────────────────────────────────────────
	host     := "localhost"
	port     := 5432
	user     := "postgres"          // ← your postgres username
	password := "12345"     // ← your password
	dbname   := "yuchat"            // ← create this database first!

	// Recommended connection string format
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%d sslmode=disable TimeZone=UTC",
		host, user, password, dbname, port)

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		// Good defaults for development
		PrepareStmt:            true,   // prepared statements = safer + faster
		SkipDefaultTransaction: false,  // usually keep transactions on
	})

	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	fmt.Println("Database connection successful! 🚀")

	// Optional: print actual used driver version (pgx)
	sqlDB, _ := database.DB()
	log.Printf("PostgreSQL driver (pgx) stats: %v open connections", sqlDB.Stats().OpenConnections)

	DB = database

	// Optional: AutoMigrate your models later (uncomment when you have models)
	// DB.AutoMigrate(&User{}, &Product{}, ...)
	
}

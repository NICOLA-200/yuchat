package db

import (
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "12345")
	dbname := getEnv("DB_NAME", "yuchat")

	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=UTC",
		host, user, password, dbname, port,
	)

	var database *gorm.DB
	var err error

	// Retry logic (because Postgres takes its sweet time)
	for i := 0; i < 10; i++ {
		database, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			PrepareStmt:            true,
			SkipDefaultTransaction: false,
		})

		if err == nil {
			break
		}

		log.Println("Database not ready yet... retrying in 2s")
		time.Sleep(2 * time.Second)
	}

	if err != nil {
		log.Fatalf("Failed to connect to database after retries: %v", err)
	}

	fmt.Println("Database connection successful 🚀")

	sqlDB, _ := database.DB()
	log.Printf("Open connections: %d", sqlDB.Stats().OpenConnections)

	DB = database
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
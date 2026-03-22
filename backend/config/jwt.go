package config

import (
	"os"
	"time"
)

var (
	JWTSecret     = []byte(getEnvOrDefault("JWT_SECRET", "super-secret-key-change-me-in-production-2026"))
	AccessTokenDuration  = 15 * time.Minute   // short-lived access token
	// RefreshTokenDuration = 7 * 24 * time.Hour  // optional later
)

func getEnvOrDefault(key, defaultVal string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultVal
}
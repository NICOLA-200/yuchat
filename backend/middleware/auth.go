package middleware

import (
    "net/http"
    "strings"

    "github.com/gin-gonic/gin"
    "os"
    "github.com/golang-jwt/jwt/v5"
)

func AuthRequired() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Get Authorization header
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "missing or invalid token"})
            return
        }

        tokenStr := strings.TrimPrefix(authHeader, "Bearer ")

        // Parse and validate token
        token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
            return []byte(os.Getenv("JWT_SECRET")), nil
        })

        if err != nil || !token.Valid {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired token"})
            return
        }

        // Extract user_id from claims
        claims, ok := token.Claims.(jwt.MapClaims)
        if !ok {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token claims"})
            return
        }

        userID := uint(claims["user_id"].(float64)) // JWT numbers are float64 by default
        c.Set("user_id", userID)

        c.Next()
    }
}
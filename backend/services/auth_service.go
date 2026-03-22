package services

import (


    "time"

	"github.com/golang-jwt/jwt/v5"
	"yuchat/backend/config"

	"errors"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"yuchat/backend/db"      // adjust to your module name
	"yuchat/backend/models"   // adjust
)

type AuthService struct{}

var Auth AuthService // singleton style (or use dependency injection later)

func (s *AuthService) Signup(username, password string) error {
	// 1. Check if username already exists
	var existing models.User
	if err := db.DB.Where("username = ?", username).First(&existing).Error; err == nil {
		return errors.New("username already taken")
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return err // real db error
	}

	// 2. Hash password
	hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	// 3. Create user
	user := models.User{
		Username: username,
		Password: string(hashed),
	}

	if err := db.DB.Create(&user).Error; err != nil {
		return err
	}

	return nil
}




func (s *AuthService) Login(username, password string) (string, error) {
	var user models.User
	if err := db.DB.Where("username = ?", username).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return "", errors.New("invalid username or password")
		}
		return "", err
	}

	if !user.CheckPassword(password) {
		return "", errors.New("invalid username or password")
	}

	// Generate JWT
	claims := jwt.MapClaims{
		"sub": user.ID,
		"username": user.Username,
		"iat": time.Now().Unix(),
		"exp": time.Now().Add(config.AccessTokenDuration).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(config.JWTSecret)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}
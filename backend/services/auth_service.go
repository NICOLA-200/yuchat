package services

import (


    "time"

	"github.com/golang-jwt/jwt/v5"
	"yuchat/backend/config"

	"errors"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"yuchat/backend/dto"
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



// GetProfile returns user profile by ID (for logged-in user)
func (s *AuthService) GetProfile(userID uint) (*models.User, error) {
	var user models.User
	if err := db.DB.First(&user, userID).Error; err != nil {
		return nil, err
	}
	return &user, nil
}




func (s *AuthService) UpdateProfile(userID uint, input dto.UpdateProfileInput) error {
    updates := map[string]interface{}{}

    // Check username availability if provided
    if input.Username != "" {
        var existing models.User
        result := db.DB.Where("username = ? AND id != ?", input.Username, userID).First(&existing)
        if result.Error == nil {
            // found a user with that username who isn't the current user
            return errors.New("username already taken")
        }
        updates["username"] = input.Username
    }

    if input.Slogan != "" {
        updates["slogan"] = input.Slogan
    }

    if input.ProfilePicture != "" {
        updates["profile_picture"] = input.ProfilePicture
    }

    if len(updates) == 0 {
        return nil // nothing to update, no-op
    }

    return db.DB.Model(&models.User{}).Where("id = ?", userID).Updates(updates).Error
}


// GetAllUsers returns basic public profile of all users (excluding password)
func (s *AuthService) GetAllUsers() ([]models.User, error) {
	var users []models.User

	// Select only needed fields for security and performance
	err := db.DB.Select("id, username, slogan, profile_picture, created_at").
		Order("created_at DESC").
		Find(&users).Error

	return users, err
}
package models

import (
"time"
"gorm.io/gorm"
"golang.org/x/crypto/bcrypt"
)
type User struct {
	gorm.Model
	Username       string `gorm:"size:50;unique;not null;index"`
	Password       string `gorm:"size:255;not null"`
	Slogan         string `gorm:"size:150"`
	ProfilePicture string `gorm:"size:500"`   // Cloudinary secure URL
	LastLogin      time.Time `gorm:"index"`
}

func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}
package models

import (

"gorm.io/gorm"
"golang.org/x/crypto/bcrypt"
)
type User struct {
	gorm.Model
	Username     string    `gorm:"size:50;unique;not null;index"`
	Password     string    `gorm:"size:255;not null"` // hashed password
	Slogan       string    `gorm:"size:150"`           // short bio / slogan
	ProfilePicture string  `gorm:"size:500"`           // URL or path to profile image
	LastLogin    time.Time `gorm:"index"`

	// You can add more fields later (email, full name, etc.)
}

func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}
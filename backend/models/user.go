package models

import (

"gorm.io/gorm"
"golang.org/x/crypto/bcrypt"
)
type User struct {
	gorm.Model          // adds ID, CreatedAt, UpdatedAt, DeletedAt
	Username string `gorm:"size:50;unique;not null;index"`
	Password string `gorm:"size:255;not null"` // will store bcrypt hash
}

func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}
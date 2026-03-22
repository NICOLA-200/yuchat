package models

import "gorm.io/gorm"

type User struct {
	gorm.Model          // adds ID, CreatedAt, UpdatedAt, DeletedAt
	Username string `gorm:"size:50;unique;not null;index"`
	Password string `gorm:"size:255;not null"` // will store bcrypt hash
}
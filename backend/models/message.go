package models

import "gorm.io/gorm"

type Message struct {
	gorm.Model
	RoomID     string `json:"room_id"    gorm:"index"`
	SenderID   uint   `json:"sender_id"`
	SenderName string `json:"sender_name"`
	Content    string `json:"content"`
}
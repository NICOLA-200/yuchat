package models

import "time"

type Message struct {
	SenderID   uint      `json:"sender_id"`
	SenderName string    `json:"sender_name"`
	RoomID     string    `json:"room_id"`
	Content    string    `json:"content"`
	CreatedAt  time.Time `json:"created_at"`
}
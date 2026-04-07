package models

import "time"

type ConversationPreview struct {
	RoomID           string    `json:"room_id"`
	OtherUserID      int       `json:"other_user_id"`
	OtherUserName    string    `json:"other_user_name"`
	OtherUserPicture string    `json:"other_user_picture"`
	LastMessage      string    `json:"last_message"`
	LastMessageAt    time.Time `json:"last_message_at"`
	SenderID         uint      `json:"sender_id"`
	SenderName       string    `json:"sender_name"`
	IsMe             bool      `json:"is_me"`
}
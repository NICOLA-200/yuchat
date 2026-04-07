package services

import (
	"log"
	"yuchat/backend/db"
	"yuchat/backend/models"
)

type MessageService struct{}

var Message MessageService

func (s *MessageService) Save(msg *models.Message) {
	if err := db.DB.Create(msg).Error; err != nil {
		log.Println("[message] failed to save message:", err)
	}
}

func (s *MessageService) GetByRoom(roomID string, limit int) ([]models.Message, error) {
	var messages []models.Message
	err := db.DB.
		Where("room_id = ?", roomID).
		Order("created_at ASC").
		Limit(limit).
		Find(&messages).Error
	return messages, err
}
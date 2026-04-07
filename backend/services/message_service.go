package services

import (
	"log"
	"yuchat/backend/db"
	"yuchat/backend/models"
	"fmt"
	"time"
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


func (s *MessageService) GetRecentConversations(userID uint, limit int) ([]map[string]interface{}, error) {
	rows, err := db.DB.Raw(`
		SELECT DISTINCT ON (room_id)
			room_id,
			sender_id,
			sender_name,
			content,
			created_at
		FROM messages
		WHERE (room_id LIKE ? OR room_id LIKE ?)
		  AND deleted_at IS NULL
		ORDER BY room_id, created_at DESC
		LIMIT ?
	`,
		fmt.Sprintf("%d_%%", userID),
		fmt.Sprintf("%%_%d", userID),
		limit,
	).Rows()

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []map[string]interface{}
	for rows.Next() {
		var roomID, senderName, content string
		var senderID uint
		var createdAt time.Time

		if err := rows.Scan(&roomID, &senderID, &senderName, &content, &createdAt); err != nil {
			log.Println("[message] scan error:", err)
			continue
		}

		results = append(results, map[string]interface{}{
			"room_id":      roomID,
			"sender_id":    senderID,
			"sender_name":  senderName,
			"content":      content,
			"created_at":   createdAt,
			"is_me":        senderID == userID,
		})
	}

	return results, nil
}
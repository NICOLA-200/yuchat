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



func (s *MessageService) GetRecentConversations(userID uint, limit int) ([]models.ConversationPreview, error) {
	// Get the most recent message per room where this user participated
	rows, err := db.DB.Raw(`
		SELECT DISTINCT ON (m.room_id)
			m.room_id,
			m.sender_id,
			m.sender_name,
			m.content    AS last_message,
			m.created_at AS last_message_at,
			u.id         AS other_user_id,
			u.username   AS other_user_name,
			u.profile_picture AS other_user_picture
		FROM messages m
		JOIN users u ON (
			CASE
				WHEN m.sender_id = ? THEN
					u.id = CAST(
						CASE
							WHEN split_part(m.room_id, '_', 1) = CAST(? AS TEXT)
							THEN split_part(m.room_id, '_', 2)
							ELSE split_part(m.room_id, '_', 1)
						END
					AS INTEGER)
				ELSE u.id = m.sender_id
			END
		)
		WHERE m.room_id LIKE ? OR m.room_id LIKE ?
		  AND m.deleted_at IS NULL
		ORDER BY m.room_id, m.created_at DESC
		LIMIT ?
	`,
		userID, userID,
		fmt.Sprintf("%d_%%", userID),
		fmt.Sprintf("%%_%d", userID),
		limit,
	).Rows()

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var previews []models.ConversationPreview
	for rows.Next() {
		var p models.ConversationPreview
		if err := rows.Scan(
			&p.RoomID,
			&p.SenderID,
			&p.SenderName,
			&p.LastMessage,
			&p.LastMessageAt,
			&p.OtherUserID,
			&p.OtherUserName,
			&p.OtherUserPicture,
		); err != nil {
			log.Println("[message] scan error:", err)
			continue
		}
		p.IsMe = p.SenderID == userID
		previews = append(previews, p)
	}

	return previews, nil
}
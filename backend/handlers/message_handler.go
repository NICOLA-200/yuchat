package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"yuchat/backend/services"
	
)

// GetMessages godoc
// @Summary      Get chat history
// @Description  Returns last N messages for a room
// @Tags         messages
// @Security     BearerAuth
// @Param        roomID  path      string  true  "Room ID"
// @Param        limit   query     int     false "Number of messages (default 50)"
// @Success      200     {array}   models.Message
// @Failure      500     {object}  map[string]string
// @Router       /messages/{roomID} [get]
func GetMessages(c *gin.Context) {
	roomID := c.Param("roomID")

	limit := 50
	if l := c.Query("limit"); l != "" {
		if parsed, err := strconv.Atoi(l); err == nil {
			limit = parsed
		}
	}

	messages, err := services.Message.GetByRoom(roomID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch messages"})
		return
	}

	c.JSON(http.StatusOK, messages)
}


// GetConversations godoc
// @Summary      Get recent conversations
// @Description  Returns last 20 people the logged-in user chatted with + last message
// @Tags         messages
// @Security     BearerAuth
// @Success      200  {array}   models.ConversationPreview
// @Failure      500  {object}  map[string]string
// @Router       /conversations [get]
func GetConversations(c *gin.Context) {
	userID := c.GetUint("user_id")

	previews, err := services.Message.GetRecentConversations(userID, 20)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch conversations"})
		return
	}

	if previews == nil {
		previews = []map[string]interface{}{}
	}

	c.JSON(http.StatusOK, previews)
}
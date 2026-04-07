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
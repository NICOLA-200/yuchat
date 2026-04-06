package handlers

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"yuchat/backend/hub"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	// Allow all origins for now — tighten in production
	CheckOrigin: func(r *http.Request) bool { return true },
}

// ChatHandler godoc
// @Summary      WebSocket chat endpoint
// @Description  Connect to a chat room via WebSocket
// @Tags         chat
// @Security     BearerAuth
// @Param        roomID  path  string  true  "Room ID"
// @Router       /ws/{roomID} [get]
func ChatHandler(c *gin.Context) {
	roomID := c.Param("roomID")
	userID := c.GetUint("user_id")

	// Safe username extraction — won't panic if missing
	username := "unknown"
	if u, exists := c.Get("username"); exists {
		if name, ok := u.(string); ok {
			username = name
		}
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("[ws] upgrade error:", err)
		return
	}

	client := &hub.Client{
		ID:     userID,
		Name:   username,
		RoomID: roomID,
		Conn:   conn,
		Send:   make(chan []byte, 256),
		Hub:    hub.H,
	}

	hub.H.Register <- client

	go client.WritePump()
	go client.ReadPump()
}
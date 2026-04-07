package hub

import (
	"encoding/json"
	"log"
	"sync"
    "time"
	"github.com/gorilla/websocket"
	"yuchat/backend/models"
	"yuchat/backend/services"
)

// Client represents a single connected WebSocket user
type Client struct {
	ID     uint
	Name   string
	RoomID string
	Conn   *websocket.Conn
	Send   chan []byte
	Hub    *Hub
}

// Hub manages all active clients and rooms
type Hub struct {
	mu      sync.RWMutex
	rooms   map[string]map[*Client]bool // roomID → set of clients
	Register   chan *Client
	Unregister chan *Client
	Broadcast  chan *models.Message
}

// Global hub instance
var H = NewHub()

func NewHub() *Hub {
	return &Hub{
		rooms:      make(map[string]map[*Client]bool),
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
		Broadcast:  make(chan *models.Message),
	}
}

// Run starts the hub event loop — call this once in main.go
func (h *Hub) Run() {
	for {
		select {

		case client := <-h.Register:
			h.mu.Lock()
			if h.rooms[client.RoomID] == nil {
				h.rooms[client.RoomID] = make(map[*Client]bool)
			}
			h.rooms[client.RoomID][client] = true
			h.mu.Unlock()
			log.Printf("[hub] client %d joined room %s", client.ID, client.RoomID)

		case client := <-h.Unregister:
			h.mu.Lock()
			if clients, ok := h.rooms[client.RoomID]; ok {
				if _, exists := clients[client]; exists {
					delete(clients, client)
					close(client.Send)
					if len(clients) == 0 {
						delete(h.rooms, client.RoomID)
					}
				}
			}
			h.mu.Unlock()
			log.Printf("[hub] client %d left room %s", client.ID, client.RoomID)

		case msg := <-h.Broadcast:
			h.mu.RLock()
			clients := h.rooms[msg.RoomID]
			h.mu.RUnlock()

			data, err := json.Marshal(msg)
			if err != nil {
				log.Println("[hub] failed to marshal message:", err)
				continue
			}

			for client := range clients {
				select {
				case client.Send <- data:
				default:
					// Client send buffer full — disconnect them
					h.mu.Lock()
					delete(h.rooms[msg.RoomID], client)
					close(client.Send)
					h.mu.Unlock()
				}
			}
			go services.Message.Save(msg)
		}
	}
}

// WritePump sends queued messages to the WebSocket connection
func (c *Client) WritePump() {
	defer c.Conn.Close()
	for {
		msg, ok := <-c.Send
		if !ok {
			c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
			return
		}
		if err := c.Conn.WriteMessage(websocket.TextMessage, msg); err != nil {
			log.Println("[hub] write error:", err)
			return
		}
	}
}

// ReadPump reads messages from the WebSocket and sends to hub
func (c *Client) ReadPump() {
	defer func() {
		c.Hub.Unregister <- c
		c.Conn.Close()
	}()

	for {
		_, raw, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err,
				websocket.CloseGoingAway,
				websocket.CloseAbnormalClosure,
			) {
				log.Println("[hub] read error:", err)
			}
			break
		}

		// Parse incoming message
		var incoming struct {
			Content string `json:"content"`
		}
		if err := json.Unmarshal(raw, &incoming); err != nil || incoming.Content == "" {
			log.Println("[hub] invalid message format")
			continue
		}

		msg := &models.Message{
			SenderID:   c.ID,
			SenderName: c.Name,
			RoomID:     c.RoomID,
			Content:    incoming.Content,
			
		}

		c.Hub.Broadcast <- msg
	}
}

func timeNow() time.Time {
	return time.Now()
}
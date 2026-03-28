package dto


type UpdateProfileInput struct {
	Slogan         string `form:"slogan" binding:"max=150"`
	ProfilePicture string `json:"-"` // we set this manually from upload
}

// Response when getting profile
type UserProfileResponse struct {
	ID             uint   `json:"id"`
	Username       string `json:"username"`
	Slogan         string `json:"slogan,omitempty"`
	ProfilePicture string `json:"profile_picture,omitempty"`
	CreatedAt      string `json:"created_at"`
}
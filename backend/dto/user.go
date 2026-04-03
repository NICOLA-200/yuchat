package dto


type UpdateProfileInput struct {
    Username       string `form:"username" binding:"omitempty,min=3,max=30"`
    Slogan         string `form:"slogan" binding:"omitempty,max=150"`
    ProfilePicture string `json:"-"` // set manually from upload
}
// Response when getting profile
type UserProfileResponse struct {
	ID             uint   `json:"id"`
	Username       string `json:"username"`
	Slogan         string `json:"slogan,omitempty"`
	ProfilePicture string `json:"profile_picture,omitempty"`
	CreatedAt      string `json:"created_at"`
}



// GetAllUsersResponse represents public user profile (safe to expose)
type GetAllUsersResponse struct {
	ID             uint   `json:"id"`
	Username       string `json:"username"`
	Slogan         string `json:"slogan,omitempty"`
	ProfilePicture string `json:"profile_picture,omitempty"`
	CreatedAt      string `json:"created_at"`
}
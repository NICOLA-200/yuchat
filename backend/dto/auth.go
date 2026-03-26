package dto

type SignupInput struct {
	Username string `json:"username" binding:"required,min=3,max=50,alphanum"` // letters + numbers only
	Password string `json:"password" binding:"required,min=8,max=72"`         // bcrypt limit ~72 chars
}



type LoginInput struct {
	Username string `json:"username" binding:"required,min=3,max=50,alphanum"`
	Password string `json:"password" binding:"required,min=8,max=72"`
}

type AuthResponse struct {
	AccessToken string `json:"access_token"`
	// RefreshToken string `json:"refresh_token,omitempty"` // optional later
	Username    string `json:"username"`
	ExpiresIn   int    `json:"expires_in"` // in seconds
}


package dto

// For updating profile
type UpdateProfileInput struct {
	Slogan         string `json:"slogan" binding:"max=150"`
	ProfilePicture string `json:"profile_picture" binding:"omitempty,url"` // optional URL validation
}

// Response when getting profile
type UserProfileResponse struct {
	ID             uint   `json:"id"`
	Username       string `json:"username"`
	Slogan         string `json:"slogan,omitempty"`
	ProfilePicture string `json:"profile_picture,omitempty"`
	CreatedAt      string `json:"created_at"`
}
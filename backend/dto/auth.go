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






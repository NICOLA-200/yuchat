package dto

type SignupInput struct {
	Username string `json:"username" binding:"required,min=3,max=50,alphanum"` // letters + numbers only
	Password string `json:"password" binding:"required,min=8,max=72"`         // bcrypt limit ~72 chars
}
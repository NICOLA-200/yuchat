type UpdateProfileInput struct {
	Slogan         string `form:"slogan" binding:"max=150"`
	ProfilePicture string `json:"-"` // we set this manually from upload
}
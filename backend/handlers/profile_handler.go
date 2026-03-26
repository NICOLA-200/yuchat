import (
	"net/http"

	"github.com/gin-gonic/gin"
	"yuchat/backend/dto"
	"yuchat/backend/services"
)

func UpdateMyProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	// Parse multipart form (max 5MB for now)
	if err := c.Request.ParseMultipartForm(5 << 20); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "failed to parse form"})
		return
	}

	var input dto.UpdateProfileInput
	input.Slogan = c.PostForm("slogan")

	// Handle profile picture upload
	var profilePicURL string
	fileHeader, err := c.FormFile("profile_picture")
	if err == nil && fileHeader != nil {
		url, err := services.Upload.UploadProfilePicture(fileHeader, userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to upload image to Cloudinary"})
			return
		}
		profilePicURL = url
		input.ProfilePicture = profilePicURL
	} else if err != nil && err != http.ErrMissingFile {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid file"})
		return
	}

	err = services.Auth.UpdateProfile(userID, input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":          "profile updated successfully",
		"profile_picture":  profilePicURL,
	})
}
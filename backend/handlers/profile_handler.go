package handlers

import (
	"net/http"
    "time"
	"github.com/gin-gonic/gin"
	"yuchat/backend/dto"
	"yuchat/backend/services"
)

// GetProfileByID godoc
// @Summary      Get a user's profile by ID
// @Description  Returns profile of the user with the given ID
// @Tags         profile
// @Produce      json
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  dto.UserProfileResponse
// @Failure      400  {object}  map[string]string
// @Failure      404  {object}  map[string]string
// @Router       /profile/{id} [get]
func GetProfileByID(c *gin.Context) {
	targetID, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}

	user, err := services.Auth.GetProfile(uint(targetID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	response := dto.UserProfileResponse{
		ID:             user.ID,
		Username:       user.Username,
		Slogan:         user.Slogan,
		ProfilePicture: user.ProfilePicture,
		CreatedAt:      user.CreatedAt.Format(time.RFC3339),
	}

	c.JSON(http.StatusOK, response)
}

// UpdateMyProfile godoc
// @Summary      Update current user's profile
// @Description  Update slogan and/or profile picture of logged-in user
// @Tags         profile
// @Security     BearerAuth
// @Accept       json
// @Produce      json
// @Param        body  body  dto.UpdateProfileInput  true  "Profile update data"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Router       /profile [put]
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




// GetAllUsers godoc
// @Summary      Get all users
// @Description  Returns list of all users with their public profile (username, slogan, profile picture)
// @Tags         users
// @Produce      json
// @Success      200  {array}   dto.GetAllUsersResponse
// @Failure      500  {object}  map[string]string
// @Router       /users [get]
func GetAllUsers(c *gin.Context) {
	users, err := services.Auth.GetAllUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch users"})
		return
	}

	// Convert to response DTO
	response := make([]dto.GetAllUsersResponse, len(users))
	for i, user := range users {
		response[i] = dto.GetAllUsersResponse{
			ID:             user.ID,
			Username:       user.Username,
			Slogan:         user.Slogan,
			ProfilePicture: user.ProfilePicture,
			CreatedAt:      user.CreatedAt.Format(time.RFC3339),
		}
	}

	c.JSON(http.StatusOK, response)
}
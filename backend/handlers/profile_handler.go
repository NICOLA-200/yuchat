package handlers

import (
	"net/http"
    "time"
	"strconv"
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
// @Description  Updates the logged-in user's profile. The :id param is for routing only.
// @Tags         profile
// @Security     BearerAuth
// @Accept       multipart/form-data
// @Produce      json
// @Param        id    path      int     true  "User ID (unused, JWT is authoritative)"
// @Param        body  body      dto.UpdateProfileInput  true  "Profile update data"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Router       /profile/{id} [put]
func UpdateMyProfile(c *gin.Context) {
    jwtUserID := c.GetUint("user_id")

    if err := c.Request.ParseMultipartForm(5 << 20); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "failed to parse form"})
        return
    }

    var input dto.UpdateProfileInput
    if err := c.ShouldBind(&input); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Handle optional profile picture
    fileHeader, err := c.FormFile("profile_picture")
    if err == nil && fileHeader != nil {
        url, uploadErr := services.Upload.UploadProfilePicture(fileHeader, jwtUserID)
        if uploadErr != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to upload image to Cloudinary"})
            return
        }
        input.ProfilePicture = url
    } else if err != nil && err != http.ErrMissingFile {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid file"})
        return
    }

    updatedUser, err := services.Auth.UpdateProfile(jwtUserID, input)
    if err != nil {
        if err.Error() == "username already taken" {
            c.JSON(http.StatusConflict, gin.H{"error": "username already taken"})
            return
        }
        c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update profile"})
        return
    }

    // Return the full updated profile
    c.JSON(http.StatusOK, dto.UserProfileResponse{
        ID:             updatedUser.ID,
        Username:       updatedUser.Username,
        Slogan:         updatedUser.Slogan,
        ProfilePicture: updatedUser.ProfilePicture,
        CreatedAt:      updatedUser.CreatedAt.Format(time.RFC3339),
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
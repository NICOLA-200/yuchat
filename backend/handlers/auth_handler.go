package handlers

import (
	"net/http"
    "fmt"
	"yuchat/backend/config"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"yuchat/backend/dto"      // adjust module name
	"yuchat/backend/services" // adjust
)






// Signup godoc
// @Summary      Register a new user
// @Description  Create a new user account with username and password
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body  body  dto.SignupInput  true  "User registration data"
// @Success      201   {object}  map[string]interface{}  "User created"
// @Failure      400   {object}  map[string]string  "Validation error"
// @Failure      409   {object}  map[string]string  "Username taken"
// @Failure      500   {object}  map[string]string  "Server error"
// @Router       /auth/signup [post]
func SignupHandler(c *gin.Context) {
	var input dto.SignupInput

	// Bind JSON + validate automatically via binding tags
	if err := c.ShouldBindJSON(&input); err != nil {
    // Handle validation errors nicely
    if validationErrs, ok := err.(validator.ValidationErrors); ok {
        var errors []string
        for _, e := range validationErrs {
            switch e.Tag() {
            case "required":
                errors = append(errors, fmt.Sprintf("%s is required", e.Field()))
            case "min":
                if e.Field() == "Password" {
                    errors = append(errors, "Password must be at least 8 characters long")
                } else if e.Field() == "Username" {
                    errors = append(errors, fmt.Sprintf("Username must be at least %s characters", e.Param()))
                } else {
                    errors = append(errors, fmt.Sprintf("%s must be at least %s characters", e.Field(), e.Param()))
                }
            case "max":
                errors = append(errors, fmt.Sprintf("%s must be at most %s characters", e.Field(), e.Param()))
            case "alphanum":
                errors = append(errors, "Username can only contain letters and numbers")
            default:
                errors = append(errors, fmt.Sprintf("%s failed validation (%s)", e.Field(), e.Tag()))
            }
        }

        c.JSON(http.StatusBadRequest, gin.H{
            "error":   "validation failed",
            "details": errors,  // now it's an array of clear messages
        })
        return
    }

    // Fallback for other bind errors
    c.JSON(http.StatusBadRequest, gin.H{
        "error":   "invalid request body",
        "details": err.Error(),
    })
    return
}

	// Call service
	err := services.Auth.Signup(input.Username, input.Password)
	if err != nil {
		if err.Error() == "username already taken" {
			c.JSON(http.StatusConflict, gin.H{"error": "username already taken"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create user"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":  "user created successfully",
		"username": input.Username,
	})
}








// Login godoc
// @Summary      Authenticate user and get JWT
// @Description  Login with username and password, returns JWT access token
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body  body  dto.LoginInput  true  "Login credentials"
// @Success      200   {object}  dto.AuthResponse
// @Failure      400   {object}  map[string]string  "Invalid input"
// @Failure      401   {object}  map[string]string  "Invalid credentials"
// @Failure      500   {object}  map[string]string  "Server error"
// @Router       /auth/login [post]
func LoginHandler(c *gin.Context) {
	var input dto.LoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		// Reuse your improved validation error handling from before
		// or keep simple for now:
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid input", "details": err.Error()})
		return
	}

	token, err := services.Auth.Login(input.Username, input.Password)
	if err != nil {
		if err.Error() == "invalid username or password" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":   "invalid credentials",
				"details": []string{"invalid username or password"},
			})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "server error",
			"details": []string{"failed to generate token"},
		})
		return
	}

	c.JSON(http.StatusOK, dto.AuthResponse{
		AccessToken: token,
		Username:    input.Username,
		ExpiresIn:   int(config.AccessTokenDuration.Seconds()),
	})
}
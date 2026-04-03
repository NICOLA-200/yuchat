package services

import (
	"context"
	"mime/multipart"
	
	"time"

	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
	"yuchat/backend/config"
)

type UploadService struct{}

var Upload UploadService

// UploadProfilePicture uploads image to Cloudinary and returns secure URL
func (s *UploadService) UploadProfilePicture(fileHeader *multipart.FileHeader, userID uint) (string, error) {
	file, err := fileHeader.Open()
	if err != nil {
		return "", err
	}
	defer file.Close()

	// Optional: Give unique public ID
	publicID := "profile_pics/" + "user_" + string(rune(userID)) + "_" + time.Now().Format("20060102150405")

	ctx := context.Background()
	uploadParams := uploader.UploadParams{
		PublicID:     publicID,
		Folder:       "yuchat/profiles",   // organizes images in Cloudinary dashboard
		ResourceType: "image",
	}

	result, err := config.Cld.Upload.Upload(ctx, file, uploadParams)
	if err != nil {
		return "", err
	}

	return result.SecureURL, nil   // This is the URL you save in DB
}



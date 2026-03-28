package config

import (
	"context"
	"log"
	"os"

	"github.com/cloudinary/cloudinary-go/v2"
)

var Cld *cloudinary.Cloudinary

func InitCloudinary() {
	cloudName := os.Getenv("CLOUDINARY_CLOUD_NAME")
	apiKey := os.Getenv("CLOUDINARY_API_KEY")
	apiSecret := os.Getenv("CLOUDINARY_API_SECRET")

	if cloudName == "" || apiKey == "" || apiSecret == "" {
		log.Fatal("Cloudinary credentials are missing in environment variables")
	}

	var err error
	Cld, err = cloudinary.NewFromParams(cloudName, apiKey, apiSecret)
	if err != nil {
		log.Fatalf("Failed to initialize Cloudinary: %v", err)
	}

	log.Println("Cloudinary initialized successfully ✅")
}
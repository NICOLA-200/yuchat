# Use official Go image
FROM golang:1.25-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git

# Copy go mod first (cache optimization)
COPY go.mod go.sum ./
RUN go mod download

# Copy project
COPY . .

# Build app
RUN go build -o main .

# Expose port
EXPOSE 8080

# Run app
CMD ["./main"]
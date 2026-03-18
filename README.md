# YuChat

A simple and fast chat application built with Flutter (frontend) and Go (backend), using Redis for data storage.

## Features

- Real-time messaging
- Simple user interface
- Fast performance with Redis backend

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Go
- **Database**: Redis

## Prerequisites

- Flutter SDK (latest stable version)
- Go (1.19 or later)
- Redis server

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd yuchat
```

### 2. Set up Redis

Make sure Redis is running on your system. You can install and start Redis using:

```bash
# On macOS with Homebrew
brew install redis
brew services start redis

# Or run directly
redis-server
```

### 3. Set up the Backend (Go)

Navigate to the backend directory (assuming it's in a subfolder, e.g., `backend/`):

```bash
cd backend
go mod tidy
go run main.go
```

The backend will start on port 8080 by default.

### 4. Set up the Frontend (Flutter)

In the root directory:

```bash
flutter pub get
flutter run
```

This will launch the Flutter app on your connected device or emulator.

## Project Structure

- `lib/`: Flutter frontend code
- `backend/`: Go backend code (create this directory if not present)
- `android/`, `ios/`, etc.: Platform-specific code


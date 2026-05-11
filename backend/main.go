package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

// App holds our external dependencies so all our routes can access them
type App struct {
	DB               *sql.DB
	StandardS3Client *s3.Client
	PresignClient    *s3.PresignClient
	BucketName       string
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: Error loading .env file (ignoring if variables are set in environment): " + err.Error())
	}

	// 1. Initialize Database
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASS")
	dbName := os.Getenv("DB_NAME")
	dbHost := os.Getenv("DB_HOST")
	if dbHost == "" {
		dbHost = "localhost"
	}

	connStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=prefer", dbHost, dbUser, dbPass, dbName)
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Failed to open database connection: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Printf("Warning: Database ping failed: %v", err)
	} else {
		log.Println("Successfully connected to PostgreSQL!")
		var v string
		db.QueryRow("SELECT version()").Scan(&v)
		log.Println(v)
	}

	// 2. Initialize AWS S3
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load AWS SDK config: %v", err)
	}

	// 3. Create the Application Instance
	app := &App{
		DB:               db,
		StandardS3Client: s3.NewFromConfig(cfg),
		PresignClient:    s3.NewPresignClient(s3.NewFromConfig(cfg)),
		BucketName:       os.Getenv("S3_BUCKET_NAME"),
	}

	// 4. Setup Routes
	mux := http.NewServeMux()

	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("API is healthy and running!"))
	})

	// Auth Routes
	mux.HandleFunc("POST /api/register", app.registerUser)
	mux.HandleFunc("POST /api/login", app.loginUser)
	mux.HandleFunc("POST /api/logout", app.logoutUser)
	mux.HandleFunc("GET /api/me", app.getCurrentUser)

	// To-Do Routes (Protected by Auth Middleware)
	mux.HandleFunc("GET /api/todos", app.requireAuth(app.getTodos))
	mux.HandleFunc("POST /api/todos", app.requireAuth(app.createTodo))
	mux.HandleFunc("DELETE /api/todos/{id}", app.requireAuth(app.deleteTodo))
	mux.HandleFunc("GET /api/todos/s3-presign", app.requireAuth(app.presignS3))

	// 5. Start Server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s...\n", port)
	log.Fatal(http.ListenAndServe(":"+port, corsMiddleware(mux)))
}

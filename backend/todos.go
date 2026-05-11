package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type Todo struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	ImageURL    string `json:"image_url"`
	IsCompleted bool   `json:"is_completed"`
}

func (app *App) getTodos(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(userIDKey).(int)
	rows, err := app.DB.Query("SELECT id, title, description, image_url, is_completed FROM todos WHERE user_id=$1", userID)

	if err != nil {
		http.Error(w, "Failed to query database | "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var todos []Todo
	for rows.Next() {
		var t Todo
		var desc, imageURL sql.NullString
		if err := rows.Scan(&t.ID, &t.Title, &desc, &imageURL, &t.IsCompleted); err != nil {
			http.Error(w, "Failed to parse data | "+err.Error(), http.StatusInternalServerError)
			return
		}
		if desc.Valid {
			t.Description = desc.String
		}
		if imageURL.Valid {
			t.ImageURL = imageURL.String
		}

		if imageURL.Valid && imageURL.String != "" {
			parts := strings.Split(imageURL.String, "/")
			objectKey := parts[len(parts)-1]

			req, err := app.PresignClient.PresignGetObject(r.Context(), &s3.GetObjectInput{
				Bucket: &app.BucketName,
				Key:    &objectKey,
			}, s3.WithPresignExpires(time.Hour*1))

			if err == nil {
				t.ImageURL = req.URL
			} else {
				log.Printf("Failed to presign GET for %s: %v", objectKey, err)
				t.ImageURL = imageURL.String
			}
		}
		todos = append(todos, t)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(todos)
}

func (app *App) presignS3(w http.ResponseWriter, r *http.Request) {
	filename := r.URL.Query().Get("filename")
	if filename == "" {
		http.Error(w, "Filename is required", http.StatusBadRequest)
		return
	}

	uniqueFilename := fmt.Sprintf("%d_%s", time.Now().Unix(), filename)

	req, err := app.PresignClient.PresignPutObject(r.Context(), &s3.PutObjectInput{
		Bucket: &app.BucketName,
		Key:    &uniqueFilename,
	}, s3.WithPresignExpires(time.Minute*5))

	if err != nil {
		http.Error(w, "Failed to sign put request | "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"upload_url": req.URL,
		"image_url":  fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s", app.BucketName, os.Getenv("AWS_REGION"), uniqueFilename),
	})
}

func (app *App) createTodo(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(userIDKey).(int)

	var t Todo
	if err := json.NewDecoder(r.Body).Decode(&t); err != nil {
		http.Error(w, "Invalid request payload | "+err.Error(), http.StatusBadRequest)
		return
	}

	err := app.DB.QueryRow(
		"INSERT INTO todos (user_id, title, description, image_url) VALUES ($1, $2, $3, $4) RETURNING id",
		userID, t.Title, t.Description, t.ImageURL,
	).Scan(&t.ID)

	if err != nil {
		http.Error(w, "Failed to create To-Do | "+err.Error(), http.StatusInternalServerError)
		return
	}

	if t.ImageURL != "" {
		parts := strings.Split(t.ImageURL, "/")
		objectKey := parts[len(parts)-1]

		req, err := app.PresignClient.PresignGetObject(r.Context(), &s3.GetObjectInput{
			Bucket: &app.BucketName,
			Key:    &objectKey,
		}, s3.WithPresignExpires(time.Hour*1))

		if err == nil {
			t.ImageURL = req.URL
		} else {
			log.Printf("Warning: Failed to presign POST response: %v", err)
		}
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(t)
}

func (app *App) deleteTodo(w http.ResponseWriter, r *http.Request) {
	userID := r.Context().Value(userIDKey).(int)
	todoID := r.PathValue("id")
	if todoID == "" {
		http.Error(w, "Missing To-Do ID", http.StatusBadRequest)
		return
	}

	var imgUrl sql.NullString
	err := app.DB.QueryRow("SELECT image_url FROM todos WHERE id = $1 AND user_id = $2", todoID, userID).Scan(&imgUrl)
	if err != nil {
		http.Error(w, "To-Do not found or unauthorized | "+err.Error(), http.StatusNotFound)
		return
	}

	var todoTitle string
	err = app.DB.QueryRow("SELECT title FROM todos WHERE id = $1", todoID).Scan(&todoTitle)
	if err != nil {
		todoTitle = "Unknown | " + err.Error()
	}

	result, err := app.DB.Exec("DELETE FROM todos WHERE id = $1 AND user_id = $2", todoID, userID)
	if err != nil {
		http.Error(w, "Failed to delete To-Do | "+err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil || rowsAffected == 0 {
		http.Error(w, "To-Do not found or unauthorized", http.StatusNotFound)
		return
	}

	if imgUrl.Valid && imgUrl.String != "" {
		parts := strings.Split(imgUrl.String, "/")
		objectKey := parts[len(parts)-1]

		_, s3Err := app.StandardS3Client.DeleteObject(r.Context(), &s3.DeleteObjectInput{
			Bucket: &app.BucketName,
			Key:    &objectKey,
		})

		if s3Err != nil {
			http.Error(w, "Warning: Failed to delete image from S3 | "+s3Err.Error(), http.StatusInternalServerError)
			return // Return early since we are sending an HTTP error
		}
	}

	w.Write([]byte(`{"message": "Task '` + todoTitle + `' deleted successfully"}`))
}

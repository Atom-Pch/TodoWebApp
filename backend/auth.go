package main

import (
	"encoding/json"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type Credentials struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (app *App) registerUser(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	json.NewDecoder(r.Body).Decode(&creds)

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(creds.Password), 14)
	if err != nil {
		http.Error(w, "Server error | "+err.Error(), http.StatusInternalServerError)
		return
	}

	_, err = app.DB.Exec("INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)",
		creds.Username, creds.Email, string(hashedPassword))

	if err != nil {
		http.Error(w, "Failed to create user | "+err.Error(), http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusCreated)
	w.Write([]byte(`{"message": "User registered successfully"}`))
}

func (app *App) loginUser(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	json.NewDecoder(r.Body).Decode(&creds)

	var storedHash string
	var userID int
	err := app.DB.QueryRow("SELECT id, password_hash FROM users WHERE username=$1", creds.Username).Scan(&userID, &storedHash)
	if err != nil {
		http.Error(w, "Invalid credentials | "+err.Error(), http.StatusUnauthorized)
		return
	}

	if err = bcrypt.CompareHashAndPassword([]byte(storedHash), []byte(creds.Password)); err != nil {
		http.Error(w, "Invalid credentials | "+err.Error(), http.StatusUnauthorized)
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})

	jwtSecret := os.Getenv("JWT_SECRET")
	tokenString, _ := token.SignedString([]byte(jwtSecret))

	http.SetCookie(w, &http.Cookie{
		Name:     "session_token",
		Value:    tokenString,
		Expires:  time.Now().Add(time.Hour * 24),
		HttpOnly: true,
		Secure:   false,
		Path:     "/",
		SameSite: http.SameSiteLaxMode,
	})

	w.Write([]byte(`{"message": "Logged in successfully"}`))
}

func (app *App) logoutUser(w http.ResponseWriter, r *http.Request) {
	http.SetCookie(w, &http.Cookie{
		Name:     "session_token",
		Value:    "",
		Expires:  time.Now().Add(-1 * time.Hour),
		HttpOnly: true,
		Path:     "/",
	})
	w.Write([]byte(`{"message": "Logged out"}`))
}

func (app *App) getCurrentUser(w http.ResponseWriter, r *http.Request) {
	cookie, err := r.Cookie("session_token")
	if err != nil {
		http.Error(w, "Not logged in", http.StatusUnauthorized)
		return
	}

	jwtSecret := []byte(os.Getenv("JWT_SECRET"))
	token, err := jwt.Parse(cookie.Value, func(token *jwt.Token) (any, error) {
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		http.Error(w, "Invalid session", http.StatusUnauthorized)
		return
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		http.Error(w, "Invalid token claims", http.StatusUnauthorized)
		return
	}

	userID := int(claims["user_id"].(float64))

	var username string
	err = app.DB.QueryRow("SELECT username FROM users WHERE id=$1", userID).Scan(&username)
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"username": username,
	})
}

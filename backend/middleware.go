package main

import (
	"context"
	"github.com/golang-jwt/jwt/v5"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"net/http"
	"os"
	"regexp"
	"slices"
	"strconv"
	"time"
)

type contextKey string

const userIDKey = contextKey("user_id")

var pattern = `^http://todo-app-alb-\d+\.us-east-2\.elb\.amazonaws\.com$`
var alb_origin = regexp.MustCompile(pattern)

var localhost_origin = []string{
	"http://localhost:5173",
	"http://localhost:3000",
	"https://onlytodo.xyz",
}

// Define the Prometheus Metrics
var (
	// Records how long requests take (Histogram)
	httpDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "http_request_duration_seconds",
		Help:    "Duration of HTTP requests.",
		Buckets: prometheus.DefBuckets,
	}, []string{"method", "path"})

	// Records the total number of requests (Counter)
	httpRequestsTotal = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "http_requests_total",
		Help: "Total number of HTTP requests.",
	}, []string{"method", "path", "status"})
)

// Create a custom ResponseWriter to capture the status code
// Standard http.ResponseWriter doesn't let us read the status code after it's written!
type statusWriter struct {
	http.ResponseWriter
	status int
}

func (w *statusWriter) WriteHeader(status int) {
	w.status = status
	w.ResponseWriter.WriteHeader(status)
}

// Global Middleware for CORS
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if slices.Contains(localhost_origin, origin) || alb_origin.MatchString(origin) {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		}

		w.Header().Set("Access-Control-Allow-Credentials", "true")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// App Method Middleware for Authentication
func (app *App) requireAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		cookie, err := r.Cookie("session_token")
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		tokenString := cookie.Value
		jwtSecret := []byte(os.Getenv("BACKEND_JWT_STRING"))

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return jwtSecret, nil
		})

		if err != nil || !token.Valid {
			http.Error(w, "Unauthorized | "+err.Error(), http.StatusUnauthorized)
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			http.Error(w, "Invalid token claims", http.StatusUnauthorized)
			return
		}

		userID := int(claims["user_id"].(float64))

		// Check if user exists in DB
		var exists bool
		err = app.DB.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE id=$1)", userID).Scan(&exists)
		if err != nil || !exists {
			http.Error(w, "Unauthorized: User no longer exists", http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), userIDKey, userID)
		reqWithContext := r.WithContext(ctx)

		next.ServeHTTP(w, reqWithContext)
	}
}

// 3. The Metrics Middleware
func metricsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// Wrap the response writer and default to 200 OK
		sw := &statusWriter{ResponseWriter: w, status: http.StatusOK}

		// Pass the request to the next handler (the actual API logic)
		next.ServeHTTP(sw, r)

		// Calculate how long the request took
		duration := time.Since(start).Seconds()

		// Extract the path (e.g., "/api/todos")
		path := r.URL.Path

		// DevOps Note: If you have URLs with IDs like /api/todos/5, it's best practice
		// to strip the ID and log it as "/api/todos/{id}" to avoid high cardinality in Prometheus.
		// For this simple app, logging the raw path is fine to start.

		// Record the metrics!
		httpDuration.WithLabelValues(r.Method, path).Observe(duration)
		httpRequestsTotal.WithLabelValues(r.Method, path, strconv.Itoa(sw.status)).Inc()
	})
}

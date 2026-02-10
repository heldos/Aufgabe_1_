package main

import (
	"context"
	"encoding/json"
	"log"
	"net"
	"net/http"
	"os"
	"path/filepath"

	"google.golang.org/grpc"

	pb "grpc-celsius-kelvin/temperature"
)

type server struct {
	pb.UnimplementedTemperatureServiceServer
}

func (s *server) CelsiusToKelvin(ctx context.Context, req *pb.CelsiusRequest) (*pb.KelvinResponse, error) {
	return &pb.KelvinResponse{Kelvin: req.Celsius + 273.15}, nil
}

type convertReq struct {
	Celsius float64 `json:"celsius"`
}
type convertResp struct {
	Kelvin float64 `json:"kelvin"`
}

func main() {
	// Cloud Run expects PORT env var
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// --- start gRPC server internally (not exposed publicly) ---
	go func() {
		lis, err := net.Listen("tcp", ":50051")
		if err != nil {
			log.Fatal(err)
		}
		grpcServer := grpc.NewServer()
		pb.RegisterTemperatureServiceServer(grpcServer, &server{})
		log.Println("gRPC listening on :50051")
		log.Fatal(grpcServer.Serve(lis))
	}()

	// --- HTTP server (public) ---
	mux := http.NewServeMux()

	// API endpoint: POST /api/celsius-to-kelvin
	mux.HandleFunc("/api/celsius-to-kelvin", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		var req convertReq
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "bad json", http.StatusBadRequest)
			return
		}
		kelvin := req.Celsius + 273.15
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(convertResp{Kelvin: kelvin})
	})

	// Serve frontend static files
	publicDir := "/app/public"
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// SPA fallback: serve index.html for unknown routes
		path := filepath.Join(publicDir, filepath.Clean(r.URL.Path))
		if info, err := os.Stat(path); err == nil && !info.IsDir() {
			http.ServeFile(w, r, path)
			return
		}
		http.ServeFile(w, r, filepath.Join(publicDir, "index.html"))
	})

	log.Println("HTTP listening on :" + port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}

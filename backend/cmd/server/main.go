package main

import (
	"fmt"
	"log"
	"net"
	"os"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	tempconvv1 "tempconv/backend/gen/tempconv/v1"
	"tempconv/backend/internal/service"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "50051"
	}
	addr := fmt.Sprintf("0.0.0.0:%s", port)

	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("failed to listen on %s: %v", addr, err)
	}

	grpcServer := grpc.NewServer()
	tempconvv1.RegisterTempConvServiceServer(grpcServer, service.New())
	reflection.Register(grpcServer)

	log.Printf("tempconv backend listening on %s", addr)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("grpc server stopped: %v", err)
	}
}


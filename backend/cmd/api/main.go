package main

import (
	"log"

	"backend/internal/config"
)

func main() {
	server, err := config.BuildServer()
	if err != nil {
		log.Fatalf("cannot bootstrap server: %v", err)
	}

	if err := server.Run(); err != nil {
		log.Fatalf("server stopped: %v", err)
	}
}

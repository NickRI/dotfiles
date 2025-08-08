package main

import (
	"context"
	"errors"
	"flag"
	"log"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
)

var listenAddress = flag.String("listen", "127.0.0.1:1223", "Listen address")

func main() {
	flag.Parse()

	ctx, cancel := context.WithCancel(context.Background())

	hlog := slog.With("listen-address", *listenAddress)

	log.Default().SetFlags(0)

	mux := http.NewServeMux()

	mux.HandleFunc("/", MainHandler)
	mux.HandleFunc("/time-zone", TimeZoneHandler)

	server := &http.Server{Addr: *listenAddress, Handler: mux}

	go func() {
		hlog.Info("Server started")

		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			hlog.Error("Server error", "err", err)
		}
	}()

	signalChan := make(chan os.Signal, 1)

	signal.Notify(signalChan, os.Interrupt, os.Kill)

	select {
	case sig := <-signalChan:
		hlog.Warn("App stopped by signal", "signal", sig)
		cancel()
	case <-ctx.Done():
	}

	if err := server.Shutdown(ctx); err != nil && !errors.Is(err, context.Canceled) {
		hlog.Error("Server shutdown error", "err", err)
	}

	hlog.Info("Go geo service is stopped...")
}

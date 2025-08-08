package main

import (
	"context"
	"crypto/tls"
	_ "embed"
	"errors"
	"flag"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"time"
)

//go:embed googleapis-hack/www.googleapis.com.crt
var googleapisCert []byte

//go:embed googleapis-hack/www.googleapis.com.key
var googleapisKey []byte

var cachePath = flag.String("cache-path", "/var/cache/wifi-geo/bssid_cache.db", "Listen address")
var cacheTTL = flag.Duration("cache-ttl", 6*time.Hour, "Lookup cache TTL")
var listenAddress = flag.String("listen", "127.0.0.1:1223", "Listen address")
var ipAddress = flag.String("ip-address", "", "Use selected ip address instead of auto-detection")

func main() {
	flag.Parse()

	ctx, cancel := context.WithCancel(context.Background())

	hlog := slog.With("listen-address", *listenAddress, "cache-path", *cachePath, "cache-ttl", *cacheTTL)

	lookupCache, err := NewWifiLookupCache(*cachePath, *cacheTTL)
	if err != nil {
		hlog.Error("can't create lookup cache", "err", err)
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/geolocation/v1/geolocate", GoogleLocationHandler(lookupCache))
	mux.HandleFunc("/time-zone", TimeZoneHandler)

	cert, err := tls.X509KeyPair(googleapisCert, googleapisKey)
	if err != nil {
		hlog.Error("Certificate error", "err", err)
		return
	}

	server := &http.Server{Addr: *listenAddress, Handler: mux, TLSConfig: &tls.Config{
		Certificates: []tls.Certificate{cert},
	}}

	go func() {
		hlog.Info("Server started")

		if err := server.ListenAndServeTLS("", ""); err != nil && !errors.Is(err, http.ErrServerClosed) {
			hlog.Error("Server error", "err", err)
			cancel()
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

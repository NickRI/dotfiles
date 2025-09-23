package main

import (
	"context"
	"errors"
	"flag"
	bolt "go.etcd.io/bbolt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"time"
)

var (
	cachePath      = flag.String("cache-path", "/var/cache/wifi-geo/wifi_geo_cache.db", "geotarging ")
	wifiCacheTTL   = flag.Duration("wifi-cache-ttl", 5*time.Minute, "Wifi get cache TTL")
	lookupCacheTTL = flag.Duration("lookup-cache-ttl", 6*time.Hour, "Lookup cache TTL")
	listenAddress  = flag.String("listen", "127.0.0.1:1223", "Listen address")
	ipAddress      = flag.String("ip-address", "", "Use selected ip address instead of auto-detection")
)

func main() {
	flag.Parse()

	ctx, cancel := context.WithCancel(context.Background())

	hlog := slog.With(
		"listen-address",
		*listenAddress,
		"cache-path",
		*cachePath,
		"lookup-cache-ttl",
		*lookupCacheTTL,
		"wifi-cache-ttl",
		*wifiCacheTTL,
	)

	db, err := bolt.Open(*cachePath, 0600, nil)
	if err != nil {
		hlog.Error("failed to open bolt database", "err", err)
		return
	}

	lookupCache, err := NewCache[*LookupResult](db, "bssid_cache", *lookupCacheTTL)
	if err != nil {
		hlog.Error("can't create lookup cache", "err", err)
		return
	}

	wifiCache, err := NewCache[[]AccessPoint](db, "wifi_get_cache", *wifiCacheTTL)
	if err != nil {
		hlog.Error("can't create wifi cache", "err", err)
		return
	}

	mux := http.NewServeMux()

	wifiLocator := NewWifiLocator(lookupCache, wifiCache, hlog.WithGroup("wifi_location"))

	mux.HandleFunc("/geolocate", GoogleLocationHandler(wifiLocator))
	mux.HandleFunc("/time-zone", TimeZoneHandler(wifiLocator))

	server := http.Server{Addr: *listenAddress, Handler: mux}

	go func() {
		hlog.Info("Server started")

		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
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

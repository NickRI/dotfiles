package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"sort"
	"strings"
	"time"
)

type WifiRequest struct {
	WifiAccessPoints []AccessPoint `json:"wifiAccessPoints"`
}

type AccessPoint struct {
	MacAddress     string `json:"macAddress"`
	SignalStrength int    `json:"signalStrength"`
	Age            int    `json:"age"`
}

type WifiResponse struct {
	Location struct {
		Lat float64 `json:"lat"`
		Lng float64 `json:"lng"`
	} `json:"location"`
	Accuracy float64 `json:"accuracy"`
}
type ErrorResponse struct {
	Error struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func NewErrorResponse(code int, message string) *ErrorResponse {
	return &ErrorResponse{
		Error: struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		}{
			Code:    code,
			Message: message,
		},
	}
}

func internalServerError(w http.ResponseWriter, err error) {
	w.WriteHeader(http.StatusInternalServerError)
	_ = json.NewEncoder(w).Encode(NewErrorResponse(http.StatusInternalServerError, err.Error()))
}

func sendLocation(w http.ResponseWriter, lookup *LookupResult) {
	w.WriteHeader(http.StatusOK)

	_ = json.NewEncoder(w).Encode(&WifiResponse{
		Location: struct {
			Lat float64 `json:"lat"`
			Lng float64 `json:"lng"`
		}{
			Lat: lookup.Latitude,
			Lng: lookup.Longitude,
		},
		Accuracy: 10,
	})
}

func GoogleLocationHandler(cache *WifiLookupCache) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		timestamp := time.Now().UnixMilli()

		hlog := slog.With(
			slog.String("url", r.URL.String()),
			slog.Int64("timestamp-id", timestamp),
		)

		var buf bytes.Buffer

		_, _ = io.Copy(&buf, r.Body)
		defer r.Body.Close()

		hlog.Info("Incomming request", slog.String("method", r.Method))

		var wreq WifiRequest

		if err := json.NewDecoder(&buf).Decode(&wreq); err != nil {
			slog.Error("failed to decode request", slog.String("err", err.Error()))
			internalServerError(w, fmt.Errorf("failed to decode request: %w", err))
			return
		}

		if len(wreq.WifiAccessPoints) == 0 {
			hlog.Error("no wifi access points was received")
			w.WriteHeader(http.StatusNotFound)
			NewErrorResponse(http.StatusNotFound, "not found")
			return
		}

		sort.Slice(wreq.WifiAccessPoints, func(i, j int) bool {
			return wreq.WifiAccessPoints[i].SignalStrength > wreq.WifiAccessPoints[j].SignalStrength
		})

		hlog.Info("processing access points", slog.Any("wifi-access-points", wreq.WifiAccessPoints))

		for _, ap := range wreq.WifiAccessPoints {
			macAddress := strings.ReplaceAll(ap.MacAddress, "-", ":")

			cLookup, exists, err := cache.Get(macAddress)
			if err != nil {
				hlog.Error("failed to get cache", "bssid", macAddress, "err", err)
				internalServerError(w, fmt.Errorf("failed to get cache bssid: %w", err))
				return
			}

			if exists {
				hlog.Info("found cached wifi access point", slog.Any("lookup", cLookup))
				sendLocation(w, cLookup)
				return
			}

			lookups, err := LookupBSSID(macAddress)
			if err != nil {
				hlog.Error("failed to lookup bssid", "err", err)
				internalServerError(w, fmt.Errorf("failed to lookup bssid: %w", err))
				return
			}

			for _, lookup := range lookups {
				if lookup.Correct() {
					hlog.Info("found wifi access point", slog.Any("lookup", lookup))

					if err := cache.Set(macAddress, &lookup); err != nil {
						hlog.Error("failed to set lookup to cache", "lookup", lookup, "err", err)
						internalServerError(w, fmt.Errorf("failed to set lookup to cache: %w", err))
						return
					}

					sendLocation(w, &lookup)
					return
				} else {
					hlog.Warn("wifi access point is incorrect", slog.Any("ap", lookup))
				}
			}
		}
	}
}

func TimeZoneHandler(w http.ResponseWriter, r *http.Request) {
	timestamp := time.Now().UnixMilli()

	hlog := slog.With(
		slog.String("url", r.URL.String()),
		slog.Int64("timestamp-id", timestamp),
	)

	zone, err := GetTimeZone(r.Context(), *ipAddress)
	if err != nil {
		hlog.Error("failed to get timezone", "err", err)
		internalServerError(w, err)
		return
	}

	hlog.Info("time zone", slog.String("zone", zone))

	w.WriteHeader(http.StatusOK)
	_, _ = fmt.Fprint(w, zone)
}

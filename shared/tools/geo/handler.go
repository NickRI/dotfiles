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
	Name           string `json:"name"`
	MacAddress     string `json:"macAddress"`
	InUse          bool   `json:"inUse"`
	SignalStrength int    `json:"signalStrength"`
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

func internalServerError(hlog *slog.Logger, w http.ResponseWriter, err error) {
	hlog.Error(err.Error())
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusInternalServerError)
	_ = json.NewEncoder(w).Encode(NewErrorResponse(http.StatusInternalServerError, err.Error()))
}

func sendLocation(w http.ResponseWriter, lookup *LookupResult) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	_ = json.NewEncoder(w).Encode(&WifiResponse{
		Location: struct {
			Lat float64 `json:"lat"`
			Lng float64 `json:"lng"`
		}{
			Lat: lookup.Latitude,
			Lng: lookup.Longitude,
		},
		Accuracy: 30,
	})
}

func GoogleLocationHandler(lcache *Cache[*LookupResult], wcache *Cache[[]AccessPoint]) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		timestamp := time.Now().UnixMilli()

		hlog := slog.With(
			slog.String("url", r.URL.String()),
			slog.Int64("timestamp-id", timestamp),
			slog.String("method", r.Method),
		)

		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		w.Header().Set("Access-Control-Allow-Private-Network", "true")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		var buf bytes.Buffer

		_, err := io.Copy(&buf, r.Body)
		if err != nil {
			internalServerError(hlog, w, fmt.Errorf("error reading body: %w", err))
			return
		}

		defer r.Body.Close()

		hlog.Info("Incoming request", slog.String("url", r.URL.String()), slog.String("body", buf.String()))

		var wreq WifiRequest

		err = json.NewDecoder(&buf).Decode(&wreq)
		if err != nil {
			internalServerError(hlog, w, fmt.Errorf("failed to decode request: %w", err))
			return
		}

		if len(wreq.WifiAccessPoints) == 0 {
			hlog.Warn("no wifi access points was received")

			scanPoints, exists, err := wcache.Get("wifi-scan")
			if err != nil {
				internalServerError(hlog, w, fmt.Errorf("failed to find wifi scan cache: %w", err))
				return
			}

			if exists {
				hlog.Info("found cached access points", "count", len(scanPoints))
				wreq.WifiAccessPoints = scanPoints
			} else {
				wreq.WifiAccessPoints, err = GetWifiInfo(r.Context())
				if err != nil {
					internalServerError(hlog, w, fmt.Errorf("failed to get WifiInfo: %w", err))
					return
				}

				if err := wcache.Set("wifi-scan", wreq.WifiAccessPoints); err != nil {
					internalServerError(hlog, w, fmt.Errorf("failed to cache WifiInfo: %w", err))
					return
				}
			}
		}

		sort.Slice(wreq.WifiAccessPoints, func(i, j int) bool {
			return wreq.WifiAccessPoints[i].InUse ||
				wreq.WifiAccessPoints[i].SignalStrength > wreq.WifiAccessPoints[j].SignalStrength
		})

		hlog.Info("processing access points", slog.Any("wifi-access-points", wreq.WifiAccessPoints))

		for _, ap := range wreq.WifiAccessPoints {
			macAddress := strings.ReplaceAll(ap.MacAddress, "-", ":")

			cLookup, exists, err := lcache.Get(macAddress)
			if err != nil {
				internalServerError(hlog, w, fmt.Errorf("failed to get cache bssid: %w", err))
				return
			}

			if exists {
				hlog.Info("found cached wifi access point", slog.Any("lookup", cLookup))
				sendLocation(w, cLookup)
				return
			}

			lookups, err := LookupBSSID(macAddress)
			if err != nil {
				internalServerError(hlog, w, fmt.Errorf("failed to lookup bssid: %w", err))
				return
			}

			for _, lookup := range lookups {
				if lookup.Correct() {
					hlog.Info("found wifi access point", slog.Any("lookup", lookup))

					if err := lcache.Set(macAddress, &lookup); err != nil {
						internalServerError(hlog, w, fmt.Errorf("failed to set lookup to cache: %w", err))
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
		internalServerError(hlog, w, err)
		return
	}

	hlog.Info("time zone", slog.String("zone", zone))

	w.WriteHeader(http.StatusOK)
	_, _ = fmt.Fprint(w, zone)
}

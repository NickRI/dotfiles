package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
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

func GoogleLocationHandler(wfl *WifiLocator) func(w http.ResponseWriter, r *http.Request) {
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
			hlog.Info("Options request", slog.String("url", r.URL.String()))

			w.WriteHeader(http.StatusNoContent)
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

		if buf.Len() > 0 {
			err = json.NewDecoder(&buf).Decode(&wreq)
			if err != nil {
				internalServerError(hlog, w, fmt.Errorf("failed to decode request: %w", err))
				return
			}
		}

		ap, err := wfl.TryProcessWifiAPS(r.Context(), wreq.WifiAccessPoints)
		if err != nil {
			internalServerError(hlog, w, fmt.Errorf("failed to lookup bssid: %w", err))
			return
		}

		sendLocation(w, ap)
		return
	}
}

func TimeZoneHandler(wfl *WifiLocator) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		timestamp := time.Now().UnixMilli()

		hlog := slog.With(
			slog.String("url", r.URL.String()),
			slog.Int64("timestamp-id", timestamp),
		)

		aps, err := wfl.TryProcessWifiAPS(r.Context(), nil)
		if err != nil {
			internalServerError(hlog, w, err)
			return
		}

		zone := GetTimeZoneByLatLng(aps.Latitude, aps.Longitude)

		hlog.Info("time zone", slog.String("zone", zone))

		w.WriteHeader(http.StatusOK)
		_, _ = fmt.Fprint(w, zone)
	}
}

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/bradfitz/latlong"
	"log/slog"
	"net/http"
)

type TimeZoneRunner interface {
	ExtractTimeZone(ctx context.Context, ip string) (string, error)
}

type JsonRunner[T any] struct {
	UrlFormat string
	Extract   func(T) string
}

func (j *JsonRunner[T]) ExtractTimeZone(ctx context.Context, ip string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, fmt.Sprintf(j.UrlFormat, ip), nil)
	if err != nil {
		return "", fmt.Errorf("[%s] failed to create request: %w", j.UrlFormat, err)
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("[%s] timezone runner error: %w", j.UrlFormat, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("[%s] timezone runner error: %s", j.UrlFormat, resp.Status)
	}

	var body T

	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return "", fmt.Errorf("[%s] timezone json decode error: %w", j.UrlFormat, err)
	}

	return j.Extract(body), nil
}

var runners = []TimeZoneRunner{
	&JsonRunner[struct {
		Location struct {
			TimeZone string `json:"time_zone"`
		} `json:"location"`
	}]{
		UrlFormat: "https://geoip.chrisdown.name/%s",
		Extract: func(body struct {
			Location struct {
				TimeZone string `json:"time_zone"`
			} `json:"location"`
		}) string {
			return body.Location.TimeZone
		},
	},

	&JsonRunner[struct {
		TimeZone string `json:"time_zone"`
	}]{
		UrlFormat: "https://api.ipbase.com/v1/json/%s",
		Extract: func(s struct {
			TimeZone string `json:"time_zone"`
		}) string {
			return s.TimeZone
		},
	},

	&JsonRunner[struct {
		TimeZone string `json:"timezone"`
	}]{
		UrlFormat: "https://ipapi.co/%s/json/",
		Extract: func(s struct {
			TimeZone string `json:"timezone"`
		}) string {
			return s.TimeZone
		},
	},

	&JsonRunner[struct {
		TimeZone string `json:"timezone"`
	}]{
		UrlFormat: "https://worldtimeapi.org/api/ip/%s",
		Extract: func(s struct {
			TimeZone string `json:"timezone"`
		}) string {
			return s.TimeZone
		},
	},

	&JsonRunner[struct {
		TimeZone string `json:"time_zone"`
	}]{
		UrlFormat: "https://reallyfreegeoip.org/json/%s",
		Extract: func(s struct {
			TimeZone string `json:"time_zone"`
		}) string {
			return s.TimeZone
		},
	},

	&JsonRunner[struct {
		TimeZone struct {
			ID string `json:"id"`
		} `json:"timezone"`
	}]{
		UrlFormat: "https://ipwho.is/%s",
		Extract: func(s struct {
			TimeZone struct {
				ID string `json:"id"`
			} `json:"timezone"`
		}) string {
			return s.TimeZone.ID
		},
	},

	&JsonRunner[struct {
		TimeZone string `json:"timezone"`
	}]{
		UrlFormat: "https://ipinfo.io/%s/json",
		Extract: func(s struct {
			TimeZone string `json:"timezone"`
		}) string {
			return s.TimeZone
		},
	},
}

func GetTimeZone(ctx context.Context, ip string) (string, error) {
	for _, runner := range runners {
		timeZone, err := runner.ExtractTimeZone(ctx, ip)
		if err != nil {
			slog.WarnContext(ctx, "timezone runner error, skipped", slog.Any("runner", runner), slog.Any("err", err))
			continue
		}

		return timeZone, nil
	}

	return "", fmt.Errorf("[%s] all timezone runners finalized without results", ip)
}

func GetTimeZoneByLatLng(lat, lng float64) string {
	return latlong.LookupZoneName(lat, lng)
}

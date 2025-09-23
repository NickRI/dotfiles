package main

import (
	"context"
	"errors"
	"fmt"
	"github.com/mdlayher/wifi"
	"log/slog"
	"sort"
	"strings"
)

type WifiLocator struct {
	lcache *Cache[*LookupResult]
	wcache *Cache[[]AccessPoint]
	hlog   *slog.Logger
}

func NewWifiLocator(lcache *Cache[*LookupResult], wcache *Cache[[]AccessPoint], hlog *slog.Logger) *WifiLocator {
	return &WifiLocator{lcache: lcache, wcache: wcache, hlog: hlog}
}

func (l *WifiLocator) TryProcessWifiAPS(ctx context.Context, accessPoints []AccessPoint) (*LookupResult, error) {
	if len(accessPoints) == 0 {
		l.hlog.Warn("no wifi access points was received")

		scanPoints, exists, err := l.wcache.Get("wifi-scan")
		if err != nil {
			return nil, fmt.Errorf("failed to retrieve wifi scan: %w", err)
		}

		if exists {
			l.hlog.Info("found cached access points", "count", len(scanPoints))
			accessPoints = scanPoints
		} else {
			accessPoints, err = GetWifiInfo(ctx)
			if err != nil {
				return nil, fmt.Errorf("failed to fetch wifi access points: %w", err)
			}

			if err := l.wcache.Set("wifi-scan", accessPoints); err != nil {
				return nil, fmt.Errorf("failed to cache wifi access points: %w", err)
			}
		}
	}

	sort.Slice(accessPoints, func(i, j int) bool {
		return accessPoints[i].InUse ||
			accessPoints[i].SignalStrength > accessPoints[j].SignalStrength
	})

	l.hlog.Info("processing access points", slog.Any("wifi-access-points", accessPoints))

	for _, ap := range accessPoints {
		macAddress := strings.ReplaceAll(ap.MacAddress, "-", ":")

		cLookup, exists, err := l.lcache.Get(macAddress)
		if err != nil {
			return nil, fmt.Errorf("failed to get cache bssid: %w", err)
		}

		if exists {
			l.hlog.Info("found cached wifi access point", slog.Any("lookup", cLookup))
			return cLookup, nil
		}

		lookups, err := LookupBSSID(macAddress)
		if err != nil {
			return nil, fmt.Errorf("failed to lookup bssid: %w", err)
		}

		for _, lookup := range lookups {
			if lookup.Correct() {
				l.hlog.Info("found wifi access point", slog.Any("lookup", lookup))

				if err := l.lcache.Set(macAddress, &lookup); err != nil {
					return nil, fmt.Errorf("failed to set lookup to cache: %w", err)
				}

				return &lookup, nil
			} else {
				l.hlog.Warn("wifi access point is incorrect", slog.Any("ap", lookup))
			}
		}
	}

	return nil, fmt.Errorf("failed to find wifi access points")
}

func GetWifiInfo(ctx context.Context) ([]AccessPoint, error) {
	c, err := wifi.New()
	if err != nil {
		return nil, fmt.Errorf("failed to create wifi: %v", err)
	}

	defer c.Close()

	ifs, err := c.Interfaces()
	for _, iface := range ifs {
		if len(iface.Name) == 0 {
			continue
		}

		hlog := slog.With("iface", iface.Name)
		if err := c.Scan(ctx, iface); err != nil {
			hlog.Warn(
				"Skip on scanning due error",
				slog.String("err", err.Error()),
			)
			continue
		}

		infos, err := c.AccessPoints(iface)
		if err != nil {
			hlog.Warn(
				"Error on getting stations info for",
				slog.String("err", err.Error()),
			)
			continue
		}

		res := make([]AccessPoint, 0, len(infos))

		for _, info := range infos {
			res = append(res, AccessPoint{
				Name:       info.SSID,
				MacAddress: info.BSSID.String(),
				InUse:      info.Status == wifi.BSSStatusAssociated,
			})
		}

		return res, nil
	}

	return nil, errors.New("no interfaces found")
}

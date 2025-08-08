package main

import (
	"context"
	"errors"
	"fmt"
	"github.com/mdlayher/wifi"
	"log/slog"
)

type AccessPoint struct {
	MacAddress     string `json:"macAddress"`
	SignalStrength int    `json:"signalStrength"`
	Age            int    `json:"age"`
}

func getWifiInfo(ctx context.Context) ([]AccessPoint, error) {
	c, err := wifi.New()
	if err != nil {
		return nil, fmt.Errorf("failed to create wifi: %v", err)
	}

	defer c.Close()

	ifs, err := c.Interfaces()
	for _, iface := range ifs {
		hlog := slog.With("iface", iface.Name)
		if err := c.Scan(ctx, iface); err != nil {
			hlog.Warn(
				"Skip on scanning due error",
				slog.String("err", err.Error()),
			)
			continue
		}

		infos, err := c.StationInfo(iface)
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
				MacAddress:     info.HardwareAddr.String(),
				SignalStrength: info.SignalAverage,
			})
		}

		return res, nil
	}

	return nil, errors.New("no interfaces found")
}

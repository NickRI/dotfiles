package main

import (
	"bytes"
	"compress/gzip"
	"errors"
	"fmt"
	"io"
	"net/http"

	"geo/bssidapple"
	"google.golang.org/protobuf/proto"
)

type LookupResult struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	BSSID     string  `json:"bssid"`
}

func (ar LookupResult) Correct() bool {
	return ar.Latitude != -180 && ar.Longitude != -180
}

type LookupResults []LookupResult

func LookupBSSID(bssid string) (LookupResults, error) {
	reqBody := buildRequest(bssid)

	req, err := http.NewRequest("POST", "https://gs-loc.apple.com/clls/wloc", bytes.NewReader(reqBody))
	if err != nil {
		return nil, fmt.Errorf("failed to build request: %w", err)
	}

	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Accept-Charset", "utf-8")
	req.Header.Set("Accept-Encoding", "gzip, deflate")
	req.Header.Set("Accept-Language", "en-us")
	req.Header.Set("User-Agent", "locationd/1753.17 CFNetwork/711.1.12 Darwin/14.0.0")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to make request: %w", err)
	}
	defer resp.Body.Close()

	var body []byte
	if resp.Header.Get("Content-Encoding") == "gzip" {
		body, err = decompressGzip(resp.Body)
	} else {
		body, err = io.ReadAll(resp.Body)
	}
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	if len(body) <= 10 {
		return nil, errors.New("response too short")
	}

	body = body[10:] // Skip Apple binary header

	var response bssidapple.BSSIDResp
	if err := proto.Unmarshal(body, &response); err != nil {
		return nil, fmt.Errorf("failed to decode protobuf: %w", err)
	}

	var result = make([]LookupResult, 0, len(response.GetWifi()))

	for _, wifi := range response.GetWifi() {
		result = append(result, LookupResult{
			Latitude:  float64(wifi.Location.GetLat()) / 1e8,
			Longitude: float64(wifi.Location.GetLon()) / 1e8,
			BSSID:     wifi.GetBssid(),
		})
	}

	return result, nil
}

func buildRequest(bssid string) []byte {
	bssidBytes := fmt.Sprintf("\x12\x13\n\x11%s\x18\x00\x20\x01", bssid)
	payload := []byte("\x00\x01\x00\x05en_US\x00\x13com.apple.locationd\x00\x0a8.1.12B411\x00\x00\x00\x01\x00\x00\x00")
	lengthByte := []byte{byte(len(bssidBytes))}

	return append(payload, append(lengthByte, []byte(bssidBytes)...)...)
}

func decompressGzip(data io.Reader) ([]byte, error) {
	reader, err := gzip.NewReader(data)
	if err != nil {
		return nil, err
	}
	defer reader.Close()
	return io.ReadAll(reader)
}

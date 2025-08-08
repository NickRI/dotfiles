package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
)

type TimeZoneResponse struct {
	TimeZone string `json:"timeZone"`
}

func getTimeZone(lat, lon float64) (string, error) {
	endpoint := "https://timeapi.io/api/TimeZone/coordinate"

	// Собираем параметры запроса
	params := url.Values{}
	params.Set("latitude", fmt.Sprintf("%f", lat))
	params.Set("longitude", fmt.Sprintf("%f", lon))

	// Строим URL
	fullURL := fmt.Sprintf("%s?%s", endpoint, params.Encode())

	// Отправляем запрос
	resp, err := http.Get(fullURL)
	if err != nil {
		return "", fmt.Errorf("запрос не удался: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("ошибка ответа: %s", resp.Status)
	}

	// Распаковываем ответ
	var tzResp TimeZoneResponse
	if err := json.NewDecoder(resp.Body).Decode(&tzResp); err != nil {
		return "", fmt.Errorf("ошибка декодирования: %w", err)
	}

	return tzResp.TimeZone, nil
}

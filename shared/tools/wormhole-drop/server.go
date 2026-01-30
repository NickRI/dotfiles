package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func runServer(listen string, files []string) error {
	ctx, cancel := context.WithCancel(context.Background())

	password := generatePassword()
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, password, files)
	})

	mux.HandleFunc("/submit", func(w http.ResponseWriter, r *http.Request) {
		// Структура запроса: { texts: [ {text: base64, iv: base64, salt: base64}, ... ] }
		var payload struct {
			Texts []EncryptedText `json:"texts"`
		}

		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			http.Error(w, "Неверный JSON", http.StatusBadRequest)
			return
		}

		if len(payload.Texts) != len(files) {
			http.Error(w, "Количество текстов не совпадает с количеством файлов", http.StatusBadRequest)
			return
		}

		for _, t := range payload.Texts {
			ct, err := base64.StdEncoding.DecodeString(t.Ciphertext)
			if err != nil {
				log.Printf("Неверный base64 ciphertext: %v", err)
				http.Error(w, "Неверный base64 ciphertext", http.StatusBadRequest)
				return
			}

			iv, err := base64.StdEncoding.DecodeString(t.IV)
			if err != nil {
				log.Printf("Неверный base64 iv: %v", err)
				http.Error(w, "Неверный base64 iv", http.StatusBadRequest)
				return
			}

			salt, err := base64.StdEncoding.DecodeString(t.Salt)
			if err != nil {
				log.Printf("Неверный base64 salt: %v", err)
				http.Error(w, "Неверный base64 salt", http.StatusBadRequest)
				return
			}

			key := deriveKey([]byte(password), salt)

			plaintext, err := decrypt(ct, key, iv)
			if err != nil {
				log.Printf("Ошибка дешифровки файла %s: %v", t.File, err)
				http.Error(w, fmt.Sprintf("Ошибка дешифровки файла %s: %v", t.File, err), http.StatusBadRequest)
				return
			}

			if err := os.WriteFile(t.File, plaintext, 0644); err != nil {
				log.Printf("Ошибка записи файла %s: %v", t.File, err)
				http.Error(w, fmt.Sprintf("Ошибка записи файла %s: %v", t.File, err), http.StatusInternalServerError)
				return
			}
		}

		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Файлы успешно сохранены"))
		cancel()
	})

	server := &http.Server{Addr: listen, Handler: mux}

	go func() {
		log.Printf("Сервер запущен: %v", listen)

		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatal("Ошибка сервера:", err)
		}
	}()

	signalChan := make(chan os.Signal, 1)

	signal.Notify(signalChan, os.Interrupt, syscall.SIGTERM)

	select {
	case sig := <-signalChan:
		log.Printf("Приложение остановелно по сигналу: %v\n", sig)
		cancel()
	case <-ctx.Done():
		log.Println("Файлы успешно сохранены")
	}

	// Используем новый контекст с таймаутом для graceful shutdown
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer shutdownCancel()

	if err := server.Shutdown(shutdownCtx); err != nil && !errors.Is(err, context.Canceled) {
		log.Fatal("Ошибка закрытия сервера:", err)
	}

	log.Println("Сервер остановлен")

	return nil
}

type EncryptedText struct {
	File       string `json:"file"`
	Ciphertext string `json:"text"`
	IV         string `json:"iv"`
	Salt       string `json:"salt"`
}

package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"time"

	bolt "go.etcd.io/bbolt"
)

type cacheEntry struct {
	Lookup    *LookupResult `json:"lookups"`
	ExpiresAt time.Time     `json:"expires_at"` // в миллисекундах
}

type WifiLookupCache struct {
	db  *bolt.DB
	ttl time.Duration
}

func NewWifiLookupCache(dbPath string, ttl time.Duration) (*WifiLookupCache, error) {
	db, err := bolt.Open(dbPath, 0600, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to open BoltDB: %w", err)
	}

	err = db.Update(func(tx *bolt.Tx) error {
		_, err := tx.CreateBucketIfNotExists([]byte("bssid_cache"))
		return err
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create bucket: %w", err)
	}

	return &WifiLookupCache{db: db, ttl: ttl}, nil
}

func (c *WifiLookupCache) Set(mac string, lookups *LookupResult) error {
	entry := cacheEntry{
		Lookup:    lookups,
		ExpiresAt: time.Now().Add(c.ttl),
	}

	data, err := json.Marshal(entry)
	if err != nil {
		return fmt.Errorf("failed to marshal entry: %w", err)
	}

	return c.db.Update(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("bssid_cache"))
		return b.Put([]byte(mac), data)
	})
}

func (c *WifiLookupCache) Get(mac string) (*LookupResult, bool, error) {
	var entry cacheEntry

	err := c.db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte("bssid_cache"))
		data := b.Get([]byte(mac))
		if data == nil {
			return errors.New("bssid not found")
		}
		return json.Unmarshal(data, &entry)
	})

	if err != nil {
		return nil, false, nil // just skip
	}

	// check ttl
	if time.Now().After(entry.ExpiresAt) {
		return nil, false, nil
	}

	return entry.Lookup, true, nil
}

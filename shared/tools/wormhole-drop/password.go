package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"math/big"

	"golang.org/x/crypto/pbkdf2"
)

var animals = []string{
	"cat", "dog", "lion", "wolf", "fox",
	"bear", "tiger", "mouse", "eagle", "shark",
	"owl", "horse", "zebra", "rabbit", "cobra",
	"panther", "leopard", "falcon", "bull", "rhino",
	"otter", "badger", "moose", "beaver", "lynx",
	"puma", "jackal", "bison", "mongoose", "seal",
	"viper", "buffalo", "jaguar", "sparrow", "hawk",
	"mole", "ferret", "dolphin", "crane", "pelican",
	"weasel", "ibex", "gazelle", "heron", "cougar",
	"antelope", "badger", "bat", "beetle", "bison",
	"butterfly", "camel", "capybara", "caribou", "cheetah",
	"chimpanzee", "chipmunk", "coyote", "crab", "crocodile",
	"crow", "deer", "dingo", "dove", "dragonfly",
	"duck", "elephant", "elk", "falcon", "flamingo",
	"fox", "frog", "gazelle", "gerbil", "giraffe",
	"gnu", "goat", "gorilla", "grasshopper", "hare",
	"hedgehog", "hippopotamus", "hornet", "hyena", "ibis",
	"jackal", "jellyfish", "kangaroo", "kingfisher", "koala",
	"lemur", "leopard", "lizard", "llama", "lobster",
	"macaw", "magpie", "mallard", "meerkat", "mink",
	"mole", "mongoose", "monkey", "moose", "narwhal",
}

func generatePassword() string {
	pick := func() string {
		n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(animals))))
		return animals[n.Int64()]
	}
	return fmt.Sprintf("%s-%s-%s", pick(), pick(), pick())
}

const iterations = 100_000

func deriveKey(password, salt []byte) []byte {
	return pbkdf2.Key(password, salt, iterations, 16, sha256.New)
}

func decrypt(ciphertext, key, iv []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	plaintext, err := gcm.Open(nil, iv, ciphertext, nil)
	if err != nil {
		return nil, err
	}
	return plaintext, nil
}

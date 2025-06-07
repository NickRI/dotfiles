package main

import (
	"flag"
	"fmt"
	"log"
	"strings"
)

const fileCount = 10

func main() {
	var files []string

	listen := flag.String("listen", ":8080", "Set http server listen address")

	for i := 1; i <= fileCount; i++ {
		strID := fmt.Sprintf("%d", i)
		flag.String("file"+strID, "", "Path to file "+strID)
	}

	flag.Parse()

	flag.Visit(func(f *flag.Flag) {
		if strings.Contains(f.Name, "file") {
			files = append(files, f.Value.String())
		}
	})

	if len(files) == 0 {
		log.Fatal("Необходимо указать хотя бы один файл -file1=path")
	}

	if err := runServer(*listen, files); err != nil {
		log.Fatal(err)
	}
}

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

func maybe(err error) {
	if err != nil {
		fmt.Printf("Error: %s\n", err.Error())
		os.Exit(1)
	}
}

func walk(path string) map[string]interface{} {
	data := map[string]interface{}{}
	files, err := ioutil.ReadDir(path)
	maybe(err)
	for _, file := range files {
		if file.IsDir() {
			data[file.Name()] = walk(filepath.Join(path, file.Name()))
			continue
		}
		raw, err := ioutil.ReadFile(filepath.Join(path, file.Name()))
		maybe(err)
		data[file.Name()] = map[string]string{
			"perm":    fmt.Sprintf("%#o", file.Mode()),
			"content": string(raw),
		}
	}
	return data
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("specify path")
		os.Exit(1)
	}
	_, err := os.Stat("./config")
	if err == nil {
		json.NewEncoder(os.Stdout).Encode(walk(os.Args[1]))
	}
}

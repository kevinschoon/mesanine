package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

const ConfigPath = "/var/mesanine/envs.json"

func LoadEnvs() {
	raw, err := ioutil.ReadFile(ConfigPath)
	if err != nil {
		os.Exit(0)
	}
	envs := map[string]string{}
	err = json.Unmarshal(raw, &envs)
	if err != nil {
		os.Exit(0)
	}
}

func main() {
	fmt.Println("vim-go")
}

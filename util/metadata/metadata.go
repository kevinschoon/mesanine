package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"os/user"
)

func maybe(err error) {
	if err != nil {
		fmt.Println("Error: %s", err.Error())
		os.Exit(1)
	}
}

func getPubKey() []byte {
	usr, err := user.Current()
	maybe(err)
	raw, err := ioutil.ReadFile(fmt.Sprintf("%s/.ssh/id_rsa.pub", usr.HomeDir))
	maybe(err)
	return raw
}

func main() {
	template := map[string]interface{}{
		"ssh": map[string]map[string]string{
			"authorized_keys": map[string]string{
				"perm":    "0644",
				"content": string(getPubKey()),
			},
		},
	}
	maybe(json.NewEncoder(os.Stdout).Encode(template))
}

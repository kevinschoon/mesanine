package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/coreos/ignition/config/v2_1/types"
	"io/ioutil"
	"os"
	"path/filepath"
)

const configPath = ""

func maybe(err error) {
	if err != nil {
		fmt.Printf("Error: %s\n", err.Error())
		os.Exit(1)
	}
}

func walk(path string, walkFn func(*os.File) error) error {
	infos, err := ioutil.ReadDir(path)
	if err != nil {
		return err
	}
	for _, info := range infos {
		if info.IsDir() {
			err = walk(filepath.Join(path, info.Name()), walkFn)
			if err != nil {
				return err
			}
		}
		fd, err := os.Open(filepath.Join(path, info.Name()))
		if err != nil {
			return err
		}
		defer fd.Close()
		err = walkFn(fd)
		if err != nil {
			return err
		}
	}
	return nil
}

func newWalkFn(storage *types.Storage) func(*os.File) error {
	return func(fd *os.File) error {
		info, err := fd.Stat()
		if err != nil {
			return err
		}
		switch {
		case info.Mode().IsDir():
			dir := types.Directory{
				Node: types.Node{
					Filesystem: "root",
					Path:       fmt.Sprintf("%s/%s", configPath, fd.Name()),
				},
				DirectoryEmbedded1: types.DirectoryEmbedded1{Mode: 0755},
			}
			storage.Directories = append(storage.Directories, dir)
		case info.Mode().IsRegular():
			raw, err := ioutil.ReadAll(fd)
			if err != nil {
				return err
			}
			content := base64.StdEncoding.EncodeToString(raw)
			file := types.File{
				Node: types.Node{
					Filesystem: "root",
					Path:       fmt.Sprintf("%s/%s", configPath, fd.Name()),
				},
				FileEmbedded1: types.FileEmbedded1{
					Mode: int(info.Mode()),
					Contents: types.FileContents{
						Source: fmt.Sprintf("data:text/plain;charset=utf-8;base64,%s", content),
					},
				},
			}
			storage.Files = append(storage.Files, file)
		}
		return nil
	}
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("usage: metadata.go PATH")
		os.Exit(1)
	}
	configPath := os.Args[1]
	storage := &types.Storage{
		Files:       []types.File{},
		Links:       []types.Link{},
		Directories: []types.Directory{},
	}
	maybe(os.Chdir(configPath))
	maybe(walk(".", newWalkFn(storage)))
	config := &types.Config{
		Ignition: types.Ignition{Version: "2.1.0"},
		Storage:  *storage,
	}
	maybe(json.NewEncoder(os.Stdout).Encode(config))
}

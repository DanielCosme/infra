package main

import (
	"fmt"
	"os"

	"git.danicos.dev/daniel/infra/pkg/gitea"
	"sigs.k8s.io/yaml"
	// net "k8s.io/api/networking/v1"
	// batch "k8s.io/api/batch/v1"
)

func main() {
	os.RemoveAll("kubernetes")
	os.Mkdir("kubernetes", os.ModePerm)
	giteaManifests := map[string]any{
		"namespace":  gitea.Namespace,
		"srv":        gitea.SRV,
		"deployment": gitea.StatefulSet(),
		"ingress":    gitea.Ingress(),
	}
	err := MarshalManifests(gitea.Namespace.Name, giteaManifests)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
}

func MarshalManifests(folder string, manifests map[string]any) error {
	dir := fmt.Sprintf("kubernetes/%s", folder)
	err := os.RemoveAll(dir)
	if err != nil {
		return err
	}
	err = os.Mkdir(dir, os.ModePerm)
	if err != nil {
		return err
	}
	for name, manifest := range manifests {
		b, err := yaml.Marshal(manifest)
		if err != nil {
			return err
		}
		manifest := fmt.Sprintf("%s/%s.yaml", dir, name)
		fmt.Println("Creating: ", manifest)
		err = os.WriteFile(manifest, b, 0644)
		if err != nil {
			return err
		}
	}
	return nil
}

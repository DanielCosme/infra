package kube

import (
	corev1 "k8s.io/api/core/v1"
	"os"
)

func ConfigFromFile(key, path string, m Metadata) corev1.ConfigMap {
	config := ReadFile(path)
	meta := m.Meta()
	meta.Name += "-configmap"
	return corev1.ConfigMap{
		TypeMeta:   ConfigMapMeta,
		ObjectMeta: meta,
		Data: map[string]string{
			key: string(config),
		},
	}
}

func SecretFromFile(key, path string, m Metadata) corev1.Secret {
	secret := ReadFileBytes(path)
	meta := m.Meta()
	return corev1.Secret{
		TypeMeta:   SecretMeta,
		ObjectMeta: meta,
		Data: map[string][]byte{
			key: secret,
		},
	}
}

func ReadFile(path string) string {
	return string(ReadFileBytes(path))
}

func ReadFileBytes(path string) []byte {
	f, err := os.ReadFile(path)
	if err != nil {
		panic(err)
	}
	return f
}

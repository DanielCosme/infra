package kube

import (
	"sort"

	corev1 "k8s.io/api/core/v1"
)

type EnvVar struct {
	secretName    string
	secretMapping map[string]string
	envMapping    map[string]string
}

func NewEnvVar(envMapping map[string]string) []corev1.EnvVar {
	return NewEnvVarWithSecret(envMapping, nil, "")
}

func NewEnvVarWithSecret(envMapping, secretMapping map[string]string, secretName string) []corev1.EnvVar {
	env := EnvVar{
		secretName:    secretName,
		secretMapping: secretMapping,
		envMapping:    envMapping,
	}
	return env.Env()
}

func (e EnvVar) Env() (env []corev1.EnvVar) {
	keys := make([]string, 0, len(e.envMapping))
	for k := range e.envMapping {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	for _, key := range keys {
		value := e.envMapping[key]
		e := corev1.EnvVar{
			Name:  key,
			Value: value,
		}
		env = append(env, e)
	}

	if len(e.secretMapping) > 0 && e.secretName == "" {
		panic("secret name cannot be empty")
	}
	secretKeys := make([]string, 0, len(e.secretMapping))
	for k := range e.secretMapping {
		secretKeys = append(secretKeys, k)
	}
	sort.Strings(secretKeys)
	for _, varName := range secretKeys {
		keyInSecret := e.secretMapping[varName]
		e := corev1.EnvVar{
			Name: varName, // value
			ValueFrom: &corev1.EnvVarSource{
				SecretKeyRef: &corev1.SecretKeySelector{
					LocalObjectReference: corev1.LocalObjectReference{Name: e.secretName}, // reference to secret
					Key:                  keyInSecret,                                     // key
				},
			},
		}
		env = append(env, e)
	}
	return env
}

package kube

import (
	corev1 "k8s.io/api/core/v1"
)

type VolumeSource int

const (
	VolumeSourcePVC VolumeSource = iota + 1
	VolumeSourceSecret
	VolumeSourceConfigMap
)

func NewVolumeFrom(sourceType VolumeSource, name, sourceName string) (v corev1.Volume) {
	v.Name = name
	switch sourceType {
	case VolumeSourcePVC:
		v.VolumeSource.PersistentVolumeClaim = &corev1.PersistentVolumeClaimVolumeSource{
			ClaimName: sourceName,
		}
	case VolumeSourceConfigMap:
		v.VolumeSource.ConfigMap = &corev1.ConfigMapVolumeSource{
			LocalObjectReference: corev1.LocalObjectReference{
				Name: sourceName,
			},
		}
	case VolumeSourceSecret:
		v.VolumeSource.Secret = &corev1.SecretVolumeSource{
			SecretName: sourceName,
		}
	default:
		panic("unrecognized source type")
	}
	return
}

package kube

import (
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Infra
const (
	IngressClassNameTraefik = "traefik"
	// NOTE: this will change depending on the IngressClass cluster resource.
	// for k3s the default is traefik, but this varies depending on the cluster.
	ingress_class_name = IngressClassNameTraefik
)

const (
	// https://kubernetes.io/docs/concepts/configuration/secret/#secret-types
	SecretOpaque = "Opaque" // arbitrary user-defined data
)

var (
	NamespaceMeta = v1.TypeMeta{
		Kind:       "Namespace",
		APIVersion: "v1",
	}
	PodMeta = v1.TypeMeta{
		Kind:       "Pod",
		APIVersion: "v1",
	}
	DeploymentMeta = v1.TypeMeta{
		Kind:       "Deployment",
		APIVersion: "apps/v1",
	}
	StatefulSetMeta = v1.TypeMeta{
		Kind:       "StatefulSet",
		APIVersion: "apps/v1",
	}
	ServiceMeta = v1.TypeMeta{
		Kind:       "Service",
		APIVersion: "v1",
	}
	ConfigMapMeta = v1.TypeMeta{
		Kind:       "ConfigMap",
		APIVersion: "v1",
	}
	SecretMeta = v1.TypeMeta{
		Kind:       "Secret",
		APIVersion: "v1",
	}
	JobMeta = v1.TypeMeta{
		Kind:       "Job",
		APIVersion: "batch/v1",
	}
	PersistentVolumeMeta = v1.TypeMeta{
		Kind:       "PersistentVolume",
		APIVersion: "v1",
	}
	PersistentVolumeClaimMeta = v1.TypeMeta{
		Kind:       "PersistentVolumeClaim",
		APIVersion: "v1",
	}
	IngressMeta = v1.TypeMeta{
		Kind:       "Ingress",
		APIVersion: "networking.k8s.io/v1",
	}
)

func Namespace(name string) corev1.Namespace {
	return corev1.Namespace{
		TypeMeta: NamespaceMeta,
		ObjectMeta: v1.ObjectMeta{
			Name: name,
		},
	}
}

func ObjectMetaAppLabel(name, namespace string) v1.ObjectMeta {
	obj := ObjectName(name, namespace)
	obj.Labels = map[string]string{"app": name}
	return obj
}

func ObjectName(name, namespace string) v1.ObjectMeta {
	return v1.ObjectMeta{
		Name:      name,
		Namespace: namespace,
	}
}

var StorageRequests1Gi = StorageRequest(resource.MustParse("1Gi"))
var StorageRequests5Gi = StorageRequest(resource.MustParse("5Gi"))
var StorageRequests10Gi = StorageRequest(resource.MustParse("10Gi"))
var StorageRequests20Gi = StorageRequest(resource.MustParse("20Gi"))
var CPURequest100m = CPURequest(resource.MustParse("100m"))

func StorageRequest(q resource.Quantity) map[corev1.ResourceName]resource.Quantity {
	return map[corev1.ResourceName]resource.Quantity{
		corev1.ResourceStorage: q,
	}
}

func CPURequest(q resource.Quantity) map[corev1.ResourceName]resource.Quantity {
	return map[corev1.ResourceName]resource.Quantity{
		corev1.ResourceCPU: q,
	}
}

package kube

import (
	"k8s.io/apimachinery/pkg/api/resource"

	corev1 "k8s.io/api/core/v1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type Metadata struct {
	name      string
	namespace string
}

func NewMetadata(name, namespace string) Metadata {
	return Metadata{
		name:      name,
		namespace: namespace,
	}
}

func (m Metadata) Meta() v1.ObjectMeta {
	return v1.ObjectMeta{
		Name:      m.name,
		Namespace: m.namespace,
	}
}

func (m Metadata) WithAppLabel() v1.ObjectMeta {
	return v1.ObjectMeta{
		Name:      m.name,
		Namespace: m.namespace,
		Labels:    m.AppLabel(),
	}
}

func (m Metadata) OnlyAppLabel() v1.ObjectMeta {
	return v1.ObjectMeta{
		Labels: m.AppLabel(),
	}
}

func (m Metadata) LabelSelector() *v1.LabelSelector {
	return &v1.LabelSelector{
		MatchLabels: m.AppLabel(),
	}
}

func (m Metadata) PVCFrom(r map[corev1.ResourceName]resource.Quantity) corev1.PersistentVolumeClaim {
	meta := m.Meta()
	meta.Name += "-pvc"
	return corev1.PersistentVolumeClaim{
		TypeMeta:   PersistentVolumeClaimMeta,
		ObjectMeta: meta,
		Spec: corev1.PersistentVolumeClaimSpec{
			AccessModes: []corev1.PersistentVolumeAccessMode{corev1.ReadWriteOnce},
			Resources: corev1.VolumeResourceRequirements{
				Requests: r,
			},
		},
	}
}

func (m Metadata) PVC() corev1.PersistentVolumeClaim {
	return m.PVCFrom(StorageRequests1Gi)
}

func (m Metadata) ServiceFrom(ports ...ServicePort) corev1.Service {
	srv := corev1.Service{
		TypeMeta:   ServiceMeta,
		ObjectMeta: m.WithAppLabel(),
		Spec: corev1.ServiceSpec{
			Selector: m.AppLabel(),
		},
	}
	for _, p := range ports {
		srv.Spec.Ports = append(srv.Spec.Ports, corev1.ServicePort{
			Name: p.Name,
			Port: p.Port,
		})
	}
	return srv
}

func (m Metadata) Service(port int32) corev1.Service {
	return m.ServiceFrom(ServicePort{Port: port})
}

func (m Metadata) AppLabel() map[string]string {
	return map[string]string{
		"app": m.name,
	}
}

type ServicePort struct {
	Name string
	Port int32
}

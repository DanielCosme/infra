package kube

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

func NewDeployment(metadata Metadata, podSpec corev1.PodSpec) appsv1.Deployment {
	return appsv1.Deployment{
		TypeMeta:   DeploymentMeta,
		ObjectMeta: metadata.WithAppLabel(),
		Spec: appsv1.DeploymentSpec{
			Selector: metadata.LabelSelector(),
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metadata.OnlyAppLabel(),
				Spec:       podSpec,
			},
		},
	}
}

func NewStatefulSet(metadata Metadata, spec corev1.PodSpec, pvcs []corev1.PersistentVolumeClaim, replicas *int32) appsv1.StatefulSet {
	return appsv1.StatefulSet{
		TypeMeta:   StatefulSetMeta,
		ObjectMeta: metadata.WithAppLabel(),
		Spec: appsv1.StatefulSetSpec{
			Replicas:    replicas,
			ServiceName: metadata.Meta().Name,
			Selector:    metadata.LabelSelector(),
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metadata.OnlyAppLabel(),
				Spec:       spec,
			},
			VolumeClaimTemplates: pvcs,
		},
	}
}

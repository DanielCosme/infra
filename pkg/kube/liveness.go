package kube

import (
	core "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
)

func LivenessProbe(path, port string) *core.Probe {
	return &core.Probe{
		ProbeHandler: core.ProbeHandler{
			HTTPGet: &core.HTTPGetAction{
				Path: path,
				Port: intstr.FromString(port),
			},
		},
		InitialDelaySeconds: 200,
		TimeoutSeconds:      5,
		PeriodSeconds:       10,
		SuccessThreshold:    1,
		FailureThreshold:    10,
	}
}

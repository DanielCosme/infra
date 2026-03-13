package kube

import (
	batch "k8s.io/api/batch/v1"
	core "k8s.io/api/core/v1"
)

func NewJob(m Metadata, spec core.PodSpec) batch.Job {
	j := batch.Job{
		TypeMeta:   JobMeta,
		ObjectMeta: m.Meta(),
		Spec: batch.JobSpec{
			Template: core.PodTemplateSpec{
				Spec: spec,
			},
		},
	}
	return j
}

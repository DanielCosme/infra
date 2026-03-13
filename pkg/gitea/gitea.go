package gitea

import (
	"git.danicos.dev/daniel/infra/pkg/kube"
	"git.danicos.dev/daniel/infra/pkg/services"
	apps "k8s.io/api/apps/v1"
	core "k8s.io/api/core/v1"
	net "k8s.io/api/networking/v1"
)

var meta kube.Metadata

var Namespace = kube.Namespace(services.Gitea)
var PVC core.PersistentVolumeClaim
var SRV core.Service

func init() {
	meta = kube.NewMetadata(services.Gitea, Namespace.Name)
	PVC = meta.PVC()
	SRV = meta.ServiceFrom([]kube.ServicePort{
		{
			Name: "http",
			Port: services.GiteaPort,
		},
		{
			Name: "ssh",
			Port: 22,
		},
	}...)
}

func StatefulSet() apps.StatefulSet {
	/*
		TODO(daniel): Make sure the container has access to the local timezone .
		/etc/localtime:/etc/localtime:ro
	*/
	podSpec := core.PodSpec{
		Containers: []core.Container{{
			Name:          services.Gitea,
			Image:         services.GiteaImage,
			LivenessProbe: kube.LivenessProbe("/api/healthz", "http"),
			Ports: []core.ContainerPort{
				{
					Name:          "http",
					ContainerPort: services.GiteaPort,
				},
				{
					Name:          "ssh",
					ContainerPort: 22,
				},
			},
			VolumeMounts: []core.VolumeMount{{
				Name:      PVC.Name,
				MountPath: "/data",
			}},
		}},
	}
	var replicas int32
	replicas = services.GiteaReplicas
	pvcs := []core.PersistentVolumeClaim{PVC}
	s := kube.NewStatefulSet(meta, podSpec, pvcs, &replicas)
	return s
}

func Ingress() net.Ingress {
	rules := []kube.IngressRule{
		{
			Host:        services.GiteaURL,
			ServiceName: SRV.Name,
			PortNumber:  services.GiteaPort,
		},
	}
	return kube.Ingress(Namespace.Name, rules, true)
}

/*
	Backup Gitea folders
	- app.ini -> /data/gitea/conf/app.ini
	- data/* 	-> /data/gitea
	- repos/* -> /data/git/repositories/

		chown -R git:git /data
	# Regenerate Git Hooks
	/usr/local/bin/gitea -c '/data/gitea/conf/app.ini' admin regenerate hooks
*/

package kube

import (
	networkingv1 "k8s.io/api/networking/v1"
)

type IngressRule struct {
	Host        string
	ServiceName string
	PortNumber  int32
}

func Ingress(namespace string, rules []IngressRule, withTLS bool) networkingv1.Ingress {
	ingressClassName := ingress_class_name // NOTE: this is platform dependent. In k3s this works out of the box
	pathTypePrefix := networkingv1.PathTypePrefix
	ingressRules := []networkingv1.IngressRule{}
	for _, rule := range rules {
		r := networkingv1.IngressRule{
			Host: rule.Host,
			IngressRuleValue: networkingv1.IngressRuleValue{
				HTTP: &networkingv1.HTTPIngressRuleValue{
					Paths: []networkingv1.HTTPIngressPath{
						{
							Path:     "/",
							PathType: &pathTypePrefix,
							Backend: networkingv1.IngressBackend{
								Service: &networkingv1.IngressServiceBackend{
									Name: rule.ServiceName,
									Port: networkingv1.ServiceBackendPort{
										Number: rule.PortNumber,
									},
								},
							},
						},
					},
				},
			},
		}
		ingressRules = append(ingressRules, r)
	}
	meta := ObjectName(namespace+"-ingress", namespace)
	i := networkingv1.Ingress{
		TypeMeta:   IngressMeta,
		ObjectMeta: meta,
		Spec: networkingv1.IngressSpec{
			IngressClassName: &ingressClassName,
			Rules:            ingressRules,
		},
	}
	i.Annotations = map[string]string{}

	if withTLS {
		// NOTE: Only works with Traefik.
		i.Annotations["kubernetes.io/ingress.class"] = IngressClassNameTraefik
		i.Annotations["traefik.ingress.kubernetes.io/router.entrypoints"] = "websecure"
		i.Annotations["traefik.ingress.kubernetes.io/router.tls.certresolver"] = "default"
		tls := networkingv1.IngressTLS{}
		for _, c := range rules {
			tls.Hosts = append(tls.Hosts, c.Host)
		}
		i.Spec.TLS = []networkingv1.IngressTLS{tls}
	}
	return i
}

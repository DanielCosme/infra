#! /usr/bin/env sh
 rsync  -avz --rsync-path="sudo rsync" ./config/k3s/registries.yaml fedora@charlie:/etc/rancher/k3s/registries.yaml

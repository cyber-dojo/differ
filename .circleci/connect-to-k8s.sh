#!/bin/bash -Eeu

readonly K8S_URL=https://raw.githubusercontent.com/cyber-dojo/k8s-install/master
source <(curl "${K8S_URL}/sh/deployment_functions.sh")

gcloud_init
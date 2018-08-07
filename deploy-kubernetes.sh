#!/bin/bash
bosh deploy -d cfcr kubo-deployment/manifests/cfcr.yml \
    -o kubo-deployment/manifests/ops-files/misc/single-master.yml \
    -o kubo-deployment/manifests/ops-files/addons-spec.yml \
    -o kubo-deployment/manifests/ops-files/iaas/aws/lb.yml \
    -o kubo-deployment/manifests/ops-files/iaas/aws/cloud-provider.yml \
    -o ops-files/kubernetes-kubo-0.19.0.yml \
    -o ops-files/kubernetes-worker.yml \
    -o ops-files/kubernetes-uaa.yml \
    -o ops-files/kubernetes-uaa-external-url.yml \
    -o ops-files/kubernetes-master-lb.yml \
    -o ops-files/kubernetes-spot-instance.yml \
    -o ops-files/kubernetes-standard-disk.yml \
    -o ops-files/kubernetes-persistent-disk-type.yml \
    -o ops-files/kubernetes-ingress-lb.yml \
    --var-file addons-spec=<(for f in `ls specs/*.yml`;do cat $f;echo;echo "---";done) \
    -v kubernetes_cluster_tag=${kubernetes_cluster_tag} \
    -v kubernetes_master_host=${master_lb_ip_address} \
    -v uaa_external_url=https://uaa.bosh.tokyo \
    -v kubernetes_uaa_host=uaa.bosh.tokyo \
    -o <(cat <<EOF
- type: replace
  path: /instance_groups/name=master/jobs/name=kube-apiserver/properties/oidc/ca
  value: ((oidc_ca))
EOF) \
    --var-file oidc_ca=acm.ca \
    --no-redact

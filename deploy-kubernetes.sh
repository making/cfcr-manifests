#!/bin/bash

# openssl s_client -connect uaa.bosh.tokyo:443 -showcerts

bosh deploy -d cfcr kubo-deployment/manifests/cfcr.yml \
    -o kubo-deployment/manifests/ops-files/misc/single-master.yml \
    -o kubo-deployment/manifests/ops-files/addons-spec.yml \
    -o kubo-deployment/manifests/ops-files/iaas/aws/lb.yml \
    -o kubo-deployment/manifests/ops-files/iaas/aws/cloud-provider.yml \
    -o kubo-deployment/manifests/ops-files/enable-bbr.yml \
    -o ops-files/kubernetes-worker.yml \
    -o ops-files/kubernetes-instance-profile.yml \
    -o ops-files/kubernetes-uaa.yml \
    -o ops-files/kubernetes-uaa-external-url.yml \
    -o ops-files/kubernetes-uaa-ldap.yml \
    -o ops-files/kubernetes-master-lb.yml \
    -o ops-files/kubernetes-spot-instance.yml \
    -o ops-files/kubernetes-standard-disk.yml \
    -o ops-files/kubernetes-persistent-disk-type.yml \
    -o ops-files/kubernetes-worker-lb.yml \
    -o ops-files/kubernetes-log-level.yml \
    -o ops-files/kubernetes-uaa-moneygr-client.yml \
    -o ops-files/kubernetes-uaa-simple-ldap-ui-client.yml \
    -o ops-files/kubernetes-uaa-concourse-client.yml \
    -o ops-files/kubernetes-node-exporter.yml \
    -o ops-files/kubernetes-postgres-blog-db.yml \
    -o ops-files/kubernetes-service-catalog.yml \
    -o ops-files/kubernetes-remove-z3.yml \
    -o ops-files/kubernetes-ulimits.yml \
    -o ops-files/kubernetes-zipkin.yml \
    --var-file vault_config=vault/config.hcl \
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
    -o <(cat <<EOF
- type: replace
  path: /releases/-
  value:
$(bosh int prometheus-boshrelease/manifests/prometheus.yml --path /releases/name=prometheus | sed 's/^/    /g')
EOF) \
    -o ops-files/kubernetes-prometheus.yml \
    -v metrics_environment=bosh-aws \
    -v bosh_url=https://${BOSH_ENVIRONMENT}:25555 \
    -v uaa_bosh_exporter_client_secret=$(bosh int bosh-aws-creds.yml --path /uaa_bosh_exporter_client_secret) \
    --var-file bosh_ca_cert=<(cat <<EOF
${BOSH_CA_CERT}
EOF) \
    --var-file oidc_ca=acm.ca \
    -v ldap_olc_suffix="dc=ik,dc=am" \
    -v ldap_olc_root_dn="cn=admin,dc=ik,dc=am" \
    --var-file add_ldap_config_ldif=<(echo "") \
    --var-file add_ldap_user_ldif=ldif/init.ldif \
    --var-file modify_ldap_config_ldif=<(echo "") \
    --var-file modify_ldap_user_ldif=<(echo "") \
    -v wavefront-api-url=https://surf.wavefront.com/api/ \
    -v wavefront-alert-targets='tmaki@pivotal.io' \
    --no-redact \
    $@

#    -o ops-files/kubernetes-wavefront-proxy.yml \


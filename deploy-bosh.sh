#!/bin/bash
bosh create-env bosh-deployment/bosh.yml \
    -o bosh-deployment/aws/cpi.yml \
    -o bosh-deployment/uaa.yml \
    -o bosh-deployment/credhub.yml \
    -o bosh-deployment/jumpbox-user.yml \
    -o bosh-deployment/local-dns.yml \
    -o ops-files/director-size-aws.yml \
    -o ops-files/director-spot-instance.yml \
    -o ops-files/director-disk-size.yml \
    -o ops-files/director-node-exporter.yml \
    -o ops-files/old-kubo/dns-addresses.yml \
    -o ops-files/old-kubo/bosh-admin-client.yml \
    -o ops-files/old-kubo/tags.yml \
    -o prometheus-boshrelease/manifests/operators/bosh/add-bosh-exporter-uaa-clients.yml \
    -o prometheus-boshrelease/manifests/operators/bosh/add-credhub-exporter-uaa-clients.yml \
    -v director_name=bosh-aws \
    -v internal_cidr=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $1}') \
    -v internal_gw=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $1}' | sed 's|0/24|1|') \
    -v internal_ip=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $1}' | sed 's|0/24|252|') \
    -v access_key_id=${AWS_ACCESS_KEY_ID} \
    -v secret_access_key=${AWS_SECRET_ACCESS_KEY} \
    -v region=${region} \
    -v az=$(echo ${availability_zones} | awk -F ',' '{print $1}') \
    -v default_key_name=${default_key_name} \
    -v default_security_groups=[${default_security_groups}] \
    --var-file private_key=${HOME}/deployer.pem \
    -v subnet_id=$(echo ${private_subnet_ids} | awk -F ',' '{print $1}') \
    --vars-store=bosh-aws-creds.yml \
    --state bosh-aws-state.json \
    $@
#    -o prometheus-boshrelease/manifests/operators/bosh/add-bosh-exporter-uaa-clients.yml \

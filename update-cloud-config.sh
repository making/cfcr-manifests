#!/bin/bash
bosh update-cloud-config kubo-deployment/configurations/aws/cloud-config.yml \
    -o ops-files/cloud-config-rename-vm-types.yml \
    -o ops-files/cloud-config-small-vm-types.yml \
    -o ops-files/cloud-config-master-lb.yml \
    -o ops-files/cloud-config-multi-az.yml \
    -o ops-files/cloud-config-spot-instance.yml \
    -o ops-files/cloud-config-standard-disk.yml \
    -o ops-files/cloud-config-disk-types.yml \
    -o ops-files/cloud-config-ephemeral-disk.yml \
    -o ops-files/cloud-config-ingress-lb.yml \
    -v master_iam_instance_profile=${prefix}-cfcr-master \
    -v worker_iam_instance_profile=${prefix}-cfcr-worker \
    -v az1_name=$(echo ${availability_zones} | awk -F ',' '{print $1}') \
    -v az1_range=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $1}') \
    -v az1_gateway=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $1}' | sed 's|0/24|1|') \
    -v az1_subnet=$(echo ${private_subnet_ids} | awk -F ',' '{print $1}') \
    -v az2_name=$(echo ${availability_zones} | awk -F ',' '{print $2}') \
    -v az2_range=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $2}') \
    -v az2_gateway=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $2}' | sed 's|0/24|1|') \
    -v az2_subnet=$(echo ${private_subnet_ids} | awk -F ',' '{print $2}') \
    -v az3_name=$(echo ${availability_zones} | awk -F ',' '{print $3}') \
    -v az3_range=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $3}') \
    -v az3_gateway=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $3}' | sed 's|0/24|1|') \
    -v az3_subnet=$(echo ${private_subnet_ids} | awk -F ',' '{print $3}') \
    -v dns_recursor_ip=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $1}' | awk -F '.' '{print $1"."$2".0.2"}') \
    -v access_key_id=${AWS_ACCESS_KEY_ID} \
    -v secret_access_key=${AWS_SECRET_ACCESS_KEY} \
    -v region=${region} \
    -v master_target_pool=${prefix}-cfcr-api \
    -v ingress_https_target_group=${prefix}-cfcr-ingress-https \
    -v uaa_target_group=${prefix}-cfcr-uaa \

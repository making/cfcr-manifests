#!/bin/bash
credhub login \
        -s ${BOSH_ENVIRONMENT}:8844 \
        --client-name=credhub-admin \
        --client-secret=$(bosh int ./bosh-aws-creds.yml --path /credhub_admin_client_secret) \
        --ca-cert <(bosh int ./bosh-aws-creds.yml --path /uaa_ssl/ca) \
        --ca-cert <(bosh int ./bosh-aws-creds.yml --path /credhub_ca/ca)

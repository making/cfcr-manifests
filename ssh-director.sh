#!/bin/bash
target=bosh-aws
ip=${BOSH_ENVIRONMENT}

bosh int ${target}-creds.yml --path /jumpbox_ssh/private_key > ${target}.pem
chmod 600 ${target}.pem

ssh jumpbox@${ip} -o StrictHostKeyChecking=no -i ${target}.pem

rm -f ${target}.pem

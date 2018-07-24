export BOSH_CLIENT=admin  
export BOSH_CLIENT_SECRET=$(bosh int ./bosh-aws-creds.yml --path /admin_password)
export BOSH_CA_CERT=$(bosh int ./bosh-aws-creds.yml --path /director_ssl/ca)
export BOSH_ENVIRONMENT=$(echo ${private_subnet_cidr_blocks} | awk -F ',' '{print $1}' | sed 's|0/24|252|')

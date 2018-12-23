#!/bin/bash
set -e
PASSWORD=$(credhub get -n /bosh-aws/cfcr/ldap_config_database_pw | bosh int - --path /value)
export LDAPTLS_REQCERT=never
ldapsearch -H ldaps://10.0.8.4:636 \
  -D "cn=config" \
  -b "cn=config" \
  -w $PASSWORD\
  $@

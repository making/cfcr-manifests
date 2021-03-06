#!/bin/bash
set -e
PASSWORD=$(credhub get -n /bosh-aws/cfcr/ldap_olc_root_pw | bosh int - --path /value)
export LDAPTLS_REQCERT=never
ldapsearch -H ldaps://10.0.8.4:636 \
  -D "cn=admin,dc=ik,dc=am" \
  -b "dc=ik,dc=am" \
  -w $PASSWORD\
  $@

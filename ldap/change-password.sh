#!/bin/bash
set -e
export LDAPTLS_REQCERT=never
ldappasswd -H ldaps://10.0.8.4:636 \
  -D "$1" \
  -W "$1" \
  -x -S

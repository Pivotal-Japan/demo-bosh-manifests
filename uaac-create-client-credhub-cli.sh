#!/bin/bash

# use ${BOSH_CLIENT_SECRET} for convenience

uaac client add credhub-cli \
  --scope uaa.none \
  --authorized_grant_types client_credentials \
  --authorities "credhub.write,credhub.read" \
  -s ${BOSH_CLIENT_SECRET}


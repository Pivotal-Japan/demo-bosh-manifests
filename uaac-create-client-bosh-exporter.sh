#!/bin/bash

# use ${BOSH_CLIENT_SECRET} for convenience

uaac client add bosh_exporter \
  --scope uaa.none \
  --authorized_grant_types client_credentials,refresh_token \
  --authorities bosh.read \
  -s ${BOSH_CLIENT_SECRET}


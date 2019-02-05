#!/bin/bash

# use ${BOSH_CLIENT_SECRET} for convenience

uaac client add firehose_exporter \
  --scope uaa.none \
  --authorized_grant_types client_credentials,refresh_token \
  --authorities doppler.firehose \
  -s ${BOSH_CLIENT_SECRET}


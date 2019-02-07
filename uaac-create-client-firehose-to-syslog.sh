#!/bin/bash

# use ${BOSH_CLIENT_SECRET} for convenience

uaac client add firehose-to-syslog \
  --scope uaa.none \
  --authorized_grant_types client_credentials,refresh_token \
  --authorities doppler.firehose,cloud_controller.global_auditor \
  -s ${BOSH_CLIENT_SECRET}


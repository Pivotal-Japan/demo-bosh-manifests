#!/bin/bash

# use ${BOSH_CLIENT_SECRET} for convenience

uaac client add cf_exporter \
  --scope uaa.none \
  --authorized_grant_types client_credentials,refresh_token \
  --authorities cloud_controller.admin_read_only \
  -s ${BOSH_CLIENT_SECRET}


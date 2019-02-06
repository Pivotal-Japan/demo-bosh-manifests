#!/bin/bash

# use ${BOSH_CLIENT_SECRET} for convenience

uaac client add concourse_sky \
  --redirect_uri https://concourse.sys.pas.ik.am/sky/issuer/callback \
  --scope openid,cloud_controller.read \
  --authorized_grant_types authorization_code,refresh_token \
  --authorities uaa.none \
  --access_token_validity 3600 \
  --refresh_token_validity 3600 \
  -s ${BOSH_CLIENT_SECRET}


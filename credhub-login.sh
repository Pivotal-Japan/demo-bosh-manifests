#!/bin/bash

credhub login \
  -s ${BOSH_ENVIRONMENT}:8844 \
  --client-name=credhub-cli \
  --client-secret=${BOSH_CLIENT_SECRET} \
  --ca-cert ${BOSH_CA_CERT}

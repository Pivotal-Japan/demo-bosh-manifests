#!/bin/bash

uaac target ${BOSH_ENVIRONMENT}:8443 --ca-cert ${BOSH_CA_CERT}
uaac token client get ${BOSH_CLIENT} -s ${BOSH_CLIENT_SECRET}

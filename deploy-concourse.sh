#!/bin/bash

bosh deploy -d concourse concourse-bosh-deployment/cluster/concourse.yml \
  -l concourse-bosh-deployment/versions.yml \
  -o concourse-bosh-deployment/cluster/operations/web-network-extension.yml \
  -o concourse-bosh-deployment/cluster/operations/basic-auth.yml \
  -o concourse-bosh-deployment/cluster/operations/worker-ephemeral-disk.yml \
  -o concourse-bosh-deployment/cluster/operations/tls-port.yml \
  -o concourse-bosh-deployment/cluster/operations/prometheus.yml \
  -v local_user.username=admin \
  -v local_user.password="((concourse_admin_password))" \
  -v external_url=https://concourse.sys.pas.ik.am \
  -v network_name=bosh \
  -v web_network_name=bosh \
  -v web_vm_type=t2.micro \
  -v db_vm_type=t2.micro \
  -v db_persistent_disk_type="2048" \
  -v worker_vm_type=m4.large \
  -v deployment_name=concourse \
  -v worker_ephemeral_disk=100GB_ephemeral_disk \
  -v atc_tls.bind_port=443 \
  -v external_host=concourse.sys.pas.ik.am \
  -v web_network_vm_extension=concourse-alb \
  -v prometheus_port=9391 \
  -o <(cat <<EOF
# custom ops-files
- type: replace
  path: /instance_groups/name=web/azs/0
  value: ap-northeast-1a

- type: replace
  path: /instance_groups/name=worker/azs/0
  value: ap-northeast-1a

- type: replace
  path: /instance_groups/name=db/azs/0
  value: ap-northeast-1a

- type: replace
  path: /instance_groups/name=web/jobs/name=atc/properties/tls_cert?
  value: ((atc_ssh.certificate))

- type: replace
  path: /instance_groups/name=web/jobs/name=atc/properties/tls_key?
  value: ((atc_ssh.private_key))

- type: replace
  path: /variables/-
  value:
    name: concourse_admin_password
    type: password

- type: replace
  path: /variables/-
  value:
    name: atc_ca
    type: certificate
    options:
      is_ca: true
      common_name: atcCA

- type: replace
  path: /variables/-
  value:
    name: atc_ssh
    type: certificate
    options:
      ca: atc_ca
      common_name: ((external_host))
EOF) \
  --no-redact $@

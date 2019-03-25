#!/bin/bash

read -p "opsman username: " opsman_username
read -s -p "opsman password: " opsman_password
echo

access_token=$(curl -k -s -u opsman: https://localhost:443/uaa/oauth/token \
  -d username=${opsman_username} \
  -d password=${opsman_password} \
  -d grant_type=password | jq -r .access_token)

product_guid=$(curl -H "Authorization: Bearer $access_token" -s -k https://localhost:443/api/v0/deployed/products | jq -r '.[] | select(.type == "cf").guid')
client_secret=$(curl -H "Authorization: Bearer $access_token" -s -k https://localhost:443/api/v0/deployed/products/${product_guid}/credentials/.uaa.admin_client_credentials | jq -r .credential.value.password)
system_domain=$(curl -H "Authorization: Bearer $access_token" -s -k https://localhost:443/api/v0/staged/products/${product_guid}/properties | jq -r '.properties.".cloud_controller.system_domain".value')


bosh deploy -d prometheus prometheus-boshrelease/manifests/prometheus.yml  \
  -o prometheus-boshrelease/manifests/operators/use-sqlite3.yml \
  -o prometheus-boshrelease/manifests/operators/monitor-bosh.yml \
  -o prometheus-boshrelease/manifests/operators/enable-bosh-uaa.yml \
  -o prometheus-boshrelease/manifests/operators/monitor-node.yml \
  -o prometheus-boshrelease/manifests/operators/monitor-cf.yml \
  -o prometheus-boshrelease/manifests/operators/monitor-concourse.yml \
  -o prometheus-boshrelease/manifests/operators/nginx-vm-extension.yml \
  -o ops-files/prometheus-colocate-firehose_exporter.yml \
  -v metrics_environment=p-bosh \
  -v bosh_url=${BOSH_ENVIRONMENT} \
  --var-file bosh_ca_cert=${BOSH_CA_CERT} \
  -v uaa_bosh_exporter_client_secret=${BOSH_CLIENT_SECRET} \
  -v metron_deployment_name=$(bosh deployments | grep -e '^cf' | awk '{print $1}') \
  -v system_domain=${system_domain} \
  -v uaa_clients_cf_exporter_secret=${BOSH_CLIENT_SECRET} \
  -v uaa_clients_firehose_exporter_secret=${BOSH_CLIENT_SECRET} \
  -v traffic_controller_external_port=4443 \
  -v skip_ssl_verify=true \
  -v nginx_vm_extension=prometheus-alb \
  -o <(cat <<EOF
# az
- type: replace
  path: /instance_groups/name=prometheus2/azs/0
  value: ap-northeast-1a

- type: replace
  path: /instance_groups/name=grafana/azs/0
  value: ap-northeast-1a

- type: replace
  path: /instance_groups/name=alertmanager/azs/0
  value: ap-northeast-1a

- type: replace
  path: /instance_groups/name=nginx/azs/0
  value: ap-northeast-1a

# networks
- type: replace
  path: /instance_groups/name=prometheus2/networks/0/name
  value: bosh

- type: replace
  path: /instance_groups/name=grafana/networks/0/name
  value: bosh

- type: replace
  path: /instance_groups/name=alertmanager/networks/0/name
  value: bosh

- type: replace
  path: /instance_groups/name=nginx/networks/0/name
  value: bosh

# vm types
- type: replace
  path: /instance_groups/name=prometheus2/vm_type
  value: t2.small

- type: replace
  path: /instance_groups/name=grafana/vm_type
  value: t2.micro

- type: replace
  path: /instance_groups/name=alertmanager/vm_type
  value: t2.micro

- type: replace
  path: /instance_groups/name=nginx/vm_type
  value: t2.micro
EOF) \
  --no-redact

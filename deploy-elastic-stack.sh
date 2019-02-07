#!/bin/bash

bosh -d elastic-stack deploy ./elastic-stack-bosh-deployment/elastic-stack.yml \
     -l ./elastic-stack-bosh-deployment/versions.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/vm_types.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/disk_types.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/instances.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/networks.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/azs.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/elasticsearch-https-and-basic-auth.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/elasticsearch-add-lb.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/logstash-readiness-probe.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/logstash-tls.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/logstash-elasticsearch-https.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/logstash-elasticsearch-basic-auth.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/kibana-https-and-basic-auth.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/kibana-elasticsearch-https.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/kibana-elasticsearch-basic-auth.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/kibana-add-lb.yml \
     -o ./elastic-stack-bosh-deployment/ops-files/elasticsearch-share-link.yml \
     --var-file logstash.conf=logstash.conf \
     -v elasticsearch_master_instances=1 \
     -v elasticsearch_master_vm_type=m4.large \
     -v elasticsearch_master_disk_type=10240 \
     -v elasticsearch_master_network=bosh \
     -v elasticsearch_master_azs="[ap-northeast-1a, ap-northeast-1c, ap-northeast-1d]" \
     -v elasticsearch_username=admin \
     -v logstash_instances=1 \
     -v logstash_vm_type=t2.medium \
     -v logstash_disk_type=5120 \
     -v logstash_network=bosh \
     -v logstash_azs="[ap-northeast-1a, ap-northeast-1c, ap-northeast-1d]" \
     -v logstash_readiness_probe_http_port=0 \
     -v logstash_readiness_probe_tcp_port=5514 \
     -v kibana_instances=1 \
     -v kibana_vm_type=t2.micro \
     -v kibana_network=bosh \
     -v kibana_azs="[ap-northeast-1a, ap-northeast-1c, ap-northeast-1d]" \
     -v kibana_username=admin \
     -v kibana_elasticsearch_ssl_verification_mode=none \
     -v logstash_ip=10.0.8.235 \
     -o <(cat <<EOF
# custom ops-files
- type: replace
  path: /instance_groups/name=logstash/networks/0/static_ips?
  value:
  - ((logstash_ip))
- type: replace
  path: /variables/name=logstash_tls/options/alternative_names
  value:
  - ((logstash_ip))
  - logstash.service.cf.internal
EOF) \
     --no-redact \
     $@ \

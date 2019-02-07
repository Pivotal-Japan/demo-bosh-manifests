#!/bin/bash

bosh -d zipkin deploy zipkin-boshrelease/manifest/zipkin.yml \
  -l zipkin-boshrelease/manifest/versions.yml \
  -o zipkin-boshrelease/manifest/ops-files/consume-elasticsearch-from-different-deployment.yml \
  -o zipkin-boshrelease/manifest/ops-files/zipkin-lens.yml \
  -o zipkin-boshrelease/manifest/ops-files/zipkin-add-lb.yml \
  -o zipkin-boshrelease/manifest/ops-files/aggregate-dependencies-elasticsearch.yml \
  -v elasticsearch-from=elasticsearch-master \
  -v elasticsearch-deployment=elastic-stack \
  -o <(cat <<EOF
- type: replace
  path: /instance_groups/name=zipkin/azs
  value: 
  - ap-northeast-1a
- type: replace
  path: /instance_groups/name=zipkin/networks/name=default
  value: 
    name: bosh
- type: replace
  path: /instance_groups/name=zipkin/vm_type
  value: t2.micro

- type: replace
  path: /releases/-
  value:
    name: cron
    version: ((cron_version))
    url: https://bosh.io/d/github.com/cloudfoundry-community/cron-boshrelease?v=((cron_version))
    sha1: ((cron_sha1))

- type: replace
  path: /instance_groups/name=zipkin/jobs/-
  value: 
    name: cron
    release: cron
    properties:
      cron:
        entries:
        - command: /var/vcap/jobs/aggregate-dependencies/bin/run >> /var/vcap/sys/log/cron/aggregate-dependencies.log
          minute: '*/2'
          hour: '*'
          day: '*'
          month: '*'
          wday: '*'
          user: vcap
EOF) \
  --no-redact \
  $@

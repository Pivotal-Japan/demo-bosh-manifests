```
git clone --recursive https://github.com/Pivotal-Japan/demo-bosh-manifests.git
cd demo-bosh-manifests
```


## Provision an ALB

```
terraform init terraform/aws/
terraform plan -out plan terraform/aws/
terraform apply plan
```

## Define a network for bosh deployments (non tiles)

```
./update-cloud-config.sh
```

For the convenience, this manifest uses the second half of `pas-services-network` for any bosh deployments (non tiles).
For a production environment, I'd highly recommend to have a dedicated network for non-tile deployments.

## Deploy Concourse

```
./uaac-token-client-get-p-bosh.sh
./uaac-create-client-concourse-sky.sh
```


```
./deploy-concourse.sh
```


Get the concourse admin password


```
./credhub-login.sh

credhub get -n /p-bosh/concourse/concourse_admin_password
```

## Deploy Prometheus

Create bosh exporter UAA client

```
./uaac-token-client-get-p-bosh.sh
./uaac-create-client-bosh-exporter.sh
```

Create cf exporter and firehose exporter UAA clients

```
./uaac-token-client-get-pas.sh
./uaac-create-client-cf-exporter.sh
./uaac-create-client-firehose-exporter.sh
```


then 

```
./deploy-prometheus.sh
```

```
./credhub-login.sh

credhub get -n /p-bosh/prometheus/grafana_password
credhub get -n /p-bosh/prometheus/prometheus_password
credhub get -n /p-bosh/prometheus/alertmanager_password
```

## Deploy Elastic Stack


```
./deploy-elastic-stack.sh
```


```
./credhub-login.sh

credhub get -n /p-bosh/elastic-stack/kibana_password
credhub get -n /p-bosh/elastic-stack/elasticsearch_password

# TLS CA Certificate for Logstash
credhub get -n /p-bosh/elastic-stack/logstash_tls | bosh int - --path /value/ca
```

## Deploy Firehose to Syslog

```
./uaac-token-client-get-pas.sh 
./uaac-create-client-firehose-to-syslog.sh 
```

```
cf target -o system
cf create-space firehose-to-syslog
cf target -s firehose-to-syslog
```

```
mkdir firehose-to-syslog
wget https://github.com/cloudfoundry-community/firehose-to-syslog/releases/download/5.1.0/firehose-to-syslog_linux_amd64 -P firehose-to-syslog
chmod +x ./firehose-to-syslog/firehose-to-syslog_linux_amd64 

cp <logstash_ca.pem (see above)> firehose-to-syslog/logstash_ca.pem

cd firehose-to-syslog
cf push \
  --var system_domain=..... \
  --var logstash_ip=..... \
  --var client_secret=.... \
  --var doppler_port=4443
cd ..
```

## Deploy Zipkin


```
./deploy-zipkin.sh
```

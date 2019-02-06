```
git clone --recursive https://github.com/Pivotal-Japan/demo-bosh-manifests.git
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

## Create an UAA client for credhub cli

`p-bosh` does not have an uaa client for credhub cli by default. 
To retrieve credentials from credhub, you need to create a client by manual.

See also [doc](https://community.pivotal.io/s/article/How-to-Access-CredHub-with-the-CredHub-CLI).

```
./uaac-token-client-get-p-bosh.sh
./uaac-create-client-credhub-cli.sh
```

Login to Credhub on `p-bosh`


```
./credhub-login.sh
```

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

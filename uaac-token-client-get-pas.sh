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

uaac target uaa.${system_domain}:443 --skip-ssl-validation
uaac token client get admin -s ${client_secret}

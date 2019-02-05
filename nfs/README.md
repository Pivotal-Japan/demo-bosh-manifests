```
./deploy-nfs-server.sh
```

```
cf enable-service-access nfs


git clone https://github.com/cloudfoundry/persi-acceptance-tests.git
cd persi-acceptance-tests/assets/pora
cf push pora --no-start
cf create-service nfs Existing demo-nfs -c '{"share":"10.0.8.230/export/vol1"}'
cf bind-service pora demo-nfs -c '{"uid":"1000","gid":"1000"}'
cf restage pora
```

```
filename=$(curl -k -s https://pora.<apps domain>/create)
curl -k https://pora.<apps domain>/read/${filename}
```

```
docker build --build-arg K8S_VERSION=v1.3.6 .

docker cp CONTAINER_ID:/opt/app-root/src/kubernetes-master-v1.3.6-1.noarch.rpm .
docker cp CONTAINER_ID:/opt/app-root/src/kubernetes-node-v1.3.6-1.noarch.rpm .
```
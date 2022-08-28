# scylla-benchmark
To benchmark scylla db

## Prerequisites
- helm
- kubectl
- gcloud
- docker

## Steps

### To build docker image with YCSB client to be able to use it in benchmarking in k8s cluster.

```bash
export $DOCKER_USER_NAME=<docker user name>
export $DOCKER_USER_EMAIL=<docker email>
export $DOCKER_IMAGE_NAME=<docker image name>
export $DOCKER_IMAGE_TAG=<docker image tag>

docker login --username=$DOCKER_USER_NAME --email=$DOCKER_USER_EMAIL
docker build -t $DOCKER_USER_NAME/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG .
docker push $DOCKER_USER_NAME/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG
```

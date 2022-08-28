# scylla-benchmark
To benchmark scylla db in GKE private cluster.

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


### To init session scoped env variables

```bash
GCP_USER=$( gcloud config list account --format "value(core.account)" )
GCP_PROJECT=$( gcloud config list project --format "value(core.project)" )
GCP_REGION=europe-west1
GCP_ZONE=europe-west1-b
CLUSTER_NAME=scylla-demo
CLUSTER_VERSION=$( gcloud container get-server-config --zone ${GCP_ZONE} --format "value(validMasterVersions[0])" )
```

### To setup GKE cluster

```bash
gcloud container \
clusters create "${CLUSTER_NAME}" \
--create-subnetwork name=my-subnet-0 \
--enable-master-authorized-networks \
--master-authorized-networks 99.80.243.80/32 \
--enable-ip-alias \
--enable-private-nodes \
--master-ipv4-cidr 172.16.0.0/28 \
--zone europe-west1-b \
--cluster-version "${CLUSTER_VERSION}" \
--node-version "${CLUSTER_VERSION}" \
--machine-type "n1-standard-4" \
--num-nodes "2" \
--disk-type "pd-ssd" \
--disk-size "20" \
--image-type "UBUNTU_CONTAINERD" \
--system-config-from-file=systemconfig.yaml \
--enable-stackdriver-kubernetes \
--no-enable-autoupgrade \
--no-enable-autorepair
```

### To setup node pool in GKE cluster
```bash
gcloud beta container \
node-pools create "scylla-pool" \
--cluster "${CLUSTER_NAME}" \
--node-version "${CLUSTER_VERSION}" \
--machine-type "n2-highmem-4" \
--num-nodes "3" \
--zone europe-west1-b \
--disk-type "pd-ssd" \
--disk-size "20" \
--ephemeral-storage local-ssd-count="8" \
--node-taints role=scylla-clusters:NoSchedule \
--image-type "UBUNTU_CONTAINERD" \
--no-enable-autoupgrade \
--no-enable-autorepair
```

### Setup GKE RBAC
```bash
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user "${GCP_USER}"
```

### Install xfs-formatter Daemonset
```bash
kubectl apply -f ./scylla/gke/xfs-formatter-daemonset.yaml
kubectl rollout status --timeout=5m daemonset.apps/xfs-formatter
```

### Install local volume provisioner
```bash
helm install local-provisioner ./scylla/common/provisioner
```

### Starting the cert manger
```bash
kubectl apply -f ./scylla/common/cert-manager.yaml
kubectl wait --for condition=established --timeout=60s crd/certificates.cert-manager.io crd/issuers.cert-manager.io
kubectl -n cert-manager rollout status --timeout=5m deployment.apps/cert-manager-webhook
```

### Starting the scylla operator
```bash
kubectl apply -f ./scylla/common/operator.yaml
kubectl wait --for condition=established crd/scyllaclusters.scylla.scylladb.com
kubectl -n scylla-operator rollout status --timeout=5m deployment.apps/scylla-operator
```

### Add firewall rule for allowing ports 9443 and 5000
```bash
export TARGET_TAG=$(gcloud compute firewall-rules list \
    --filter 'name~^gke-scylla-demo' \
    --format 'value(
        targetTags.list()
    )' | head -n 1 | sed 's/-node//g')

gcloud compute firewall-rules create ${TARGET_TAG}-master-manuall \
    --action ALLOW \
    --direction INGRESS \
    --source-ranges 172.16.0.0/28 \
    --rules tcp:9443,tcp:5000 \
    --target-tags ${TARGET_TAG}-node
```

### Run scylla cluster
```bash
sed "s/<gcp_region>/${GCP_REGION}/g;s/<gcp_zone>/${GCP_ZONE}/g" cluster.yaml | kubectl apply -f -
```


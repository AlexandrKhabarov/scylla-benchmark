GCP_USER=$( gcloud config list account --format "value(core.account)" )
GCP_PROJECT=$( gcloud config list project --format "value(core.project)" )
GCP_REGION=europe-west1
GCP_ZONE=europe-west1-b
CLUSTER_NAME=scylla-demo
CLUSTER_VERSION=$( gcloud container get-server-config --zone ${GCP_ZONE} --format "value(validMasterVersions[0])" )

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


gcloud container \
node-pools create "cassandra-stress-pool" \
--cluster "${CLUSTER_NAME}" \
--node-version "${CLUSTER_VERSION}" \
--machine-type "n1-standard-32" \
--num-nodes "2" \
--zone europe-west1-b \
--disk-type "pd-ssd" \
--disk-size "20" \
--node-taints role=cassandra-stress:NoSchedule \
--image-type "UBUNTU_CONTAINERD" \
--no-enable-autoupgrade \
--no-enable-autorepair


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


gcloud compute firewall-rules create gke-scylla-demo-0b68cc2b-master-manuall \
    --action ALLOW \
    --direction INGRESS \
    --source-ranges 172.16.0.0/28 \
    --rules tcp:9443,tcp:5000 \
    --target-tags gke-scylla-demo-0b68cc2b-node

gcloud compute firewall-rules create gke-scylla-demo-6f8458e1-master-manuall \
    --action ALLOW \
    --direction INGRESS \
    --source-ranges 172.16.0.0/28 \
    --rules tcp:9443,tcp:5000 \
    --target-tags gke-scylla-demo-6f8458e1-node
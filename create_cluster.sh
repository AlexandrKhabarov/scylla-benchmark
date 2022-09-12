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
--system-config-from-file=./scylla/gke/systemconfig.yaml \
--enable-stackdriver-kubernetes \
--no-enable-autoupgrade \
--no-enable-autorepair
GCP_USER=$( gcloud config list account --format "value(core.account)" )
GCP_PROJECT=$( gcloud config list project --format "value(core.project)" )
GCP_REGION=europe-west1
GCP_ZONE=europe-west1-b
CLUSTER_NAME=scylla-demo
CLUSTER_VERSION=$( gcloud container get-server-config --zone ${GCP_ZONE} --format "value(validMasterVersions[0])" )

gcloud container \
node-pools create "ycsb-benchmark-pool" \
--cluster "${CLUSTER_NAME}" \
--node-version "${CLUSTER_VERSION}" \
--machine-type "n1-standard-32" \
--num-nodes "3" \
--zone europe-west1-b \
--disk-type "pd-ssd" \
--disk-size "20" \
--node-taints role=ycsb-benchmark:NoSchedule \
--image-type "UBUNTU_CONTAINERD" \
--no-enable-autoupgrade \
--no-enable-autorepair

sed "" ./scylla/benchmark/clients.yaml | kubectl apply -f -

kubectl wait --for=condition=ready --timeout=60s -n default pods --all

kubectl exec -it ycsb-benchmark-0 -- bash -c "apt update && apt install -y maven && apt install -y git && apt install -y python2.7 && git clone https://github.com/brianfrankcooper/YCSB.git && ln -s /usr/bin/python2.7 /usr/bin/python"
kubectl exec -it ycsb-benchmark-1 -- bash -c "apt update && apt install -y maven && apt install -y git && apt install -y python2.7 && git clone https://github.com/brianfrankcooper/YCSB.git && ln -s /usr/bin/python2.7 /usr/bin/python"
kubectl exec -it ycsb-benchmark-2 -- bash -c "apt update && apt install -y maven && apt install -y git && apt install -y python2.7 && git clone https://github.com/brianfrankcooper/YCSB.git && ln -s /usr/bin/python2.7 /usr/bin/python"




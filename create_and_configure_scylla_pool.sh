GCP_USER=$( gcloud config list account --format "value(core.account)" )
GCP_PROJECT=$( gcloud config list project --format "value(core.project)" )
GCP_REGION=europe-west1
GCP_ZONE=europe-west1-b
CLUSTER_NAME=scylla-demo
CLUSTER_VERSION=$( gcloud container get-server-config --zone ${GCP_ZONE} --format "value(validMasterVersions[0])" )

gcloud beta container \
node-pools create "scylla-pool" \
--cluster "${CLUSTER_NAME}" \
--node-version "${CLUSTER_VERSION}" \
--machine-type "n2-highmem-16" \
--num-nodes "3" \
--zone europe-west1-b \
--disk-type "pd-ssd" \
--disk-size "40" \
--ephemeral-storage local-ssd-count="8" \
--node-taints role=scylla-clusters:NoSchedule \
--image-type "UBUNTU_CONTAINERD" \
--no-enable-autoupgrade \
--no-enable-autorepair


kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user "${GCP_USER}"
kubectl apply -f ./scylla/gke/xfs-formatter-daemonset.yaml
kubectl rollout status --timeout=5m daemonset.apps/xfs-formatter

helm install local-provisioner ./scylla/common/provisioner

kubectl apply -f ./scylla/common/cert-manager.yaml
kubectl wait --for condition=established --timeout=60s crd/certificates.cert-manager.io crd/issuers.cert-manager.io
kubectl -n cert-manager rollout status --timeout=5m deployment.apps/cert-manager-webhook

kubectl apply -f ./scylla/common/operator.yaml
kubectl wait --for condition=established crd/scyllaclusters.scylla.scylladb.com
kubectl -n scylla-operator rollout status --timeout=5m deployment.apps/scylla-operator
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


sed "s/<gcp_region>/${GCP_REGION}/g;s/<gcp_zone>/${GCP_ZONE}/g" ./scylla/gke/cluster.yaml | kubectl apply -f -

kubectl wait --for=condition=ready --timeout=60s -n scylla pods --all

echo "create keyspace ycsb WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor': 3 };
                                                                                         USE ycsb;
                                                                                         create table usertable (
                                                                                             y_id varchar primary key,
                                                                                             field0 varchar,
                                                                                             field1 varchar,
                                                                                             field2 varchar,
                                                                                             field3 varchar,
                                                                                             field4 varchar,
                                                                                             field5 varchar,
                                                                                             field6 varchar,
                                                                                             field7 varchar,
                                                                                             field8 varchar,
                                                                                             field9 varchar) ;exit;" | kubectl exec -n scylla -it scylla-cluster-europe-west1-europe-west1-b-1 -- cqlsh


kubectl exec -it ycsb-benchmark-0 -- bash -c /YCSB/bin/ycsb load scylla -s -P workloads/workloada \
    -threads 300 -p recordcount=18000000 \
    -p readproportion=0 -p updateproportion=0 \
    -p fieldcount=250 -p fieldlength=150 \
    -p insertstart=0 -p insertcount=6000000\
    -p cassandra.username=cassandra -p cassandra.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc

kubectl exec -it ycsb-benchmark-1 -- bash -c /YCSB/bin/ycsb load scylla -s -P workloads/workloada \
    -threads 300 -p recordcount=18000000 \
    -p readproportion=0 -p updateproportion=0 \
    -p fieldcount=250 -p fieldlength=150 \
    -p insertstart=6000000 -p insertcount=6000000 \
    -p cassandra.username=cassandra -p cassandra.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc

kubectl exec -it ycsb-benchmark-2 -- bash -c /YCSB/bin/ycsb load scylla -s -P workloads/workloada \
    -threads 300 -p recordcount=18000000 \
    -p readproportion=0 -p updateproportion=0 \
    -p fieldcount=250 -p fieldlength=150 \
    -p insertstart=12000000 -p insertcount=6000000 \
    -p cassandra.username=cassandra -p cassandra.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc
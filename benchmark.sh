bin/ycsb load scylla -s -P workloads/workloada \
    -threads 300 -p recordcount=600000000 \
    -p readproportion=0 -p updateproportion=0 \
    -p fieldcount=10 -p fieldlength=100 \
    -p insertstart=0 -p insertcount=600000000 \
    -p cassandra.username=cassandra -p cassandra.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc



bin/ycsb load scylla -s -P workloads/workloada \
    -threads 300 -p recordcount=200000000 \
    -p readproportion=0 -p updateproportion=0 \
    -p fieldcount=10 -p fieldlength=100 \
    -p insertstart=0 -p insertcount=600000000 \
    -p cassandra.username=cassandra -p cassandra.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc

bin/ycsb run scylla -s -P workloads/workloada \
    -target 3000 -threads 300 -p recordcount=120000000 \
    -p fieldcount=10 -p fieldlength=100 \
    -p operationcount=50000000 \
    -p scylla.username=cassandra -p scylla.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc

bin/ycsb load scylla -s -P workloads/workloada \
    -threads 300 -p recordcount=1000000000 \
    -p readproportion=0 -p updateproportion=0 \
    -p fieldcount=250 -p fieldlength=100 \
    -p insertstart=0 -p insertcount=1000000000 \
    -p cassandra.username=cassandra -p cassandra.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc


bin/ycsb run scylla -s -P workloads/workloada \
    -target 1000 -threads 100 -p recordcount=120000000 \
    -p fieldcount=10 -p fieldlength=100 \
    -p operationcount=5000000 \
    -p readallfields=true \
    -p writeallfields=false \
    -p requestdistribution=zipfian \
    -p fieldlengthdistribution=constant \
    -p readproportion=0.95 \
    -p updateproportion=0.05 \
    -p insertproportion=0 \
    -p scylla.username=cassandra -p scylla.password=cassandra \
    -p scylla.hosts=scylla-cluster-client.scylla.svc
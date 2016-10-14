#!/bin/bash

if [ '$1' == '' ] ; then
        echo Please specify the deployment name / type
        echo e.g. baremetal, lxd, kvm
        exit
fi

etype=$1

# Set spark execution mode to use the yarn client slaves

juju set spark spark_execution_mode=yarn-client

# Define the jdo alias for easier action submission

jdo() { juju action fetch --wait 0 $(juju action do $1 $2 | awk '{print $5}'); }

# Resourcemanager (yarn / hdfs) tests
echo Running resourcemanager tests...
jdo resourcemanager/0 mrbench > ~/mrbench_results-${etype}.txt
jdo resourcemanager/0 nnbench > ~/nnbench_results-${etype}.txt
jdo resourcemanager/0 terasort > ~/terasort_results-${etype}.txt
jdo resourcemanager/0 testdfsio > ~/testdfsiio_results-${etype}.txt

# Spark tests
echo Running spark tests...
jdo spark/0 sparkpi ~/sparkpi_results-${type}.txt
jdo spark/0 sql ~/sql_results-${type}.txt
jdo spark/0 streaming ~/streaming_results-${type}.txt
jdo spark/0 logisticregression ~/logisticregression_results-${type}.txt
jdo spark/0 matrixfactorization ~/matrixfactorization_results-${type}.txt
jdo spark/0 pagerank ~/pagerank_results-${type}.txt
jdo spark/0 svdplusplus ~/svdplusplus_results-${type}.txt
jdo spark/0 svm ~/svm_results-${type}.txt
jdo spark/0 trianglecount ~/trianglecount_results-${type}.txt

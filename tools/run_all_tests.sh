#!/bin/bash

if [ "$1" == "" ] ; then
        echo Please specify the deployment name / type
        echo e.g. baremetal, lxd, kvm
        exit
fi

etype=$1

# Set spark execution mode to use the yarn client slaves
juju set spark spark_execution_mode=yarn-client

# Define the jdo alias for easier action submission
mkdir ../results/${etype}/
base_output_dir="../results/${etype}"

jdo() { juju action fetch --wait 0 $(juju action do $1 $2 | awk '{print $5}'); }

for run_number in {1..10} ; do

        # for now, all we realy need is terasort and anomaly detection
        # Resourcemanager (yarn / hdfs) tests
        echo Running resourcemanager tests, run ${run_number} of 10...
        echo terasort, run ${run_number}
        jdo resourcemanager/0 terasort maps=100 reduces=50 > ${base_output_dir}/terasort_results-${run_number}.txt

        # Spark tests
        echo Running spark tests..., run ${run_number}

        # prepare anomaly detection
        echo Preparing anomaly detection job, run ${run_number}
        ./prepare_anomaly_detection.sh

        # run anomyaly detection
        echo Anomaly detection, run ${run_number}
        echo Check ../results/ for new files after this detection job finishes...
        ./run_anomaly_detection.sh ${etype} ${run_number}
done

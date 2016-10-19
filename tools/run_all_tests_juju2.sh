#!/bin/bash

if [ "$1" == "" ] ; then
        echo Please specify the deployment name / type
        echo e.g. baremetal, lxd, kvm
        exit
fi

etype=$1

# Set spark execution mode to use the yarn client slaves

juju config spark spark_execution_mode=yarn-client

# Define the jdo alias for easier action submission

mkdir ../results/${etype}/
base_output_dir="../results/${etype}"

jdo() { juju show-action-output --wait 0 $(juju run-action $1 $2 | awk '{print $5}'); }

for run_number in {1..10} ; do

       
        # for now, all we realy need is terasort and anomaly detection
        # Resourcemanager (yarn / hdfs) tests
        echo Running resourcemanager tests, run ${run_number} of 10...
#        echo mapreduce benchmark, run ${run_number}
#        jdo resourcemanager/0 mrbench maps=100 reduces=50 > ${base_output_dir}/mrbench_results-${run_number}.txt
#        echo namenode benchmark, run ${run_number}
#        jdo resourcemanager/0 nnbench maps=100 reduces=50 > ${base_output_dir}/nnbench_results-${run_number}.txt
#        juju scp resourcemanager/0:/tmp/NNBench_results.log ${base_output_dir}/nnbench_results_log-${run_number}.txt
        echo terasort, run ${run_number}
        jdo resourcemanager/0 terasort maps=100 reduces=50 > ${base_output_dir}/terasort_results-${run_number}.txt
#        echo dfsio write benchmark, run ${run_number}
#        jdo resourcemanager/0 testdfsio mode='write' > ${base_output_dir}/testdfsio_write_results-${run_number}.txt
#        juju scp resourcemanager/0:/tmp/TestDFSIO_results.log ${base_output_dir}/testdfsio_write_results_detailed-${run_number}.txt
#        echo dfsio read benchmark, run ${run_number}
#        jdo resourcemanager/0 testdfsio mode='read'  > ${base_output_dir}/testdfsio_read_results-${run_number}.txt
#        juju scp resourcemanager/0:/tmp/TestDFSIO_results.log ${base_output_dir}/testdfsio_read_results_detailed-${run_number}.txt

        # Spark tests
        echo Running spark tests..., run ${run_number}
#        echo spark pi, run ${run_number}
#        jdo spark/0 sparkpi > ${base_output_dir}/sparkpi_results-${run_number}.txt
#        echo spark sql, run ${run_number}
#        jdo spark/0 sql > ${base_output_dir}/sql_results-${run_number}.txt
#        echo streaming, run ${run_number}
#        jdo spark/0 streaming > ${base_output_dir}/streaming_results-${run_number}.txt
#        echo logisticregression, run ${run_number}
#        jdo spark/0 logisticregression > ${base_output_dir}/logisticregression_results-${run_number}.txt
#        echo matrix factorization, run ${run_number}
#        jdo spark/0 matrixfactorization > ${base_output_dir}/matrixfactorization_results-${run_number}.txt
#        echo pagerank, run ${run_number}
#        jdo spark/0 pagerank > ${base_output_dir}/pagerank_results-${run_number}.txt
#        echo svdplusplus, run ${run_number}
#        jdo spark/0 svdplusplus > ${base_output_dir}/svdplusplus_results-${run_number}.txt
#        echo svm, run ${run_number}
#        jdo spark/0 svm > ${base_output_dir}/svm_results-${run_number}.txt
#        echo trianglecount, run ${run_number}
#        jdo spark/0 trianglecount > ${base_output_dir}/trianglecount_results-${run_number}.txt
#        
        
        # prepare anomaly detection
        echo Preparing anomaly detection job, run ${run_number} 
        ./prepare_anomaly_detection.sh
        
        # run anomyaly detection
        echo Anomaly detection, run ${run_number}
        echo Check ../results/ for new files after this detection job finishes...
        ./run_anomaly_detection.sh ${etype} ${run_number}

done

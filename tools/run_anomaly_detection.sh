#!/bin/bash
stackname=$1
echo scp anomaly detection jar to spark/0:/tmp/anomaly-detection_2.10-1.0.jar
juju scp ./bin/anomaly-detection_2.10-1.0.jar spark/0:/tmp
echo Submit job
juju run --unit spark/0 "rm /tmp/spark_job_results.txt"
juju run --timeout=120m30s --unit spark/0 "su hdfs -c 'date > /tmp/spark_job_results ; time /usr/bin/spark-submit --class MainRun /tmp/anomaly-detection_2.10-1.0.jar --master yarn >> /tmp/spark_job_results.txt ; date >> /tmp/spark_job_results.txt'"
echo get results
juju scp spark/0:/tmp/spark_job_results.txt ../results/spark_job_results-${stackname}-$(date +%H.%M-%d%m%y)

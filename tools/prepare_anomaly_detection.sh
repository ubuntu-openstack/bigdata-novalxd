#!/bin/bash
echo Get training data and cross_val to /tmp...
juju run --unit slave/0 "wget https://raw.githubusercontent.com/mvogiatzis/spark-anomaly-detection/master/src/test/resources/training.csv -O /tmp/training.csv"
juju run --unit slave/0 "wget https://raw.githubusercontent.com/mvogiatzis/spark-anomaly-detection/master/src/test/resources/cross_val.csv -O /tmp/cross_val.csv"
echo move training data to hdfs://spark-test/resources/
juju run --unit slave/0 "su hdfs -c 'hadoop fs -mkdir -p /spark-test/resources/'"
juju run --unit slave/0 "for a in {1..100} ; do cat /tmp/training.csv > /tmp/training-large.csv ; done"
juju run --unit slave/0 "for a in {1..100} ; do cat /tmp/cross_val.csv > /tmp/cross_val-large.csv ; done"
juju run --unit slave/0 "su hdfs -c 'hdfs dfs -put /tmp/training.csv /spark-test/resources'"
juju run --unit slave/0 "su hdfs -c 'hdfs dfs -put /tmp/training-large.csv /spark-test/resources'"
juju run --unit slave/0 "su hdfs -c 'hdfs dfs -put /tmp/cross_val.csv /spark-test/resources'"
juju run --unit slave/0 "su hdfs -c 'hdfs dfs -put /tmp/cross_val-large.csv /spark-test/resources'"
echo Ready to run anomaly detection job

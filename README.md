# Big Data and Machine Learning on OpenStack backed by Nova-LXD

## Overview
Hadoop was built with bare metal in mind:  get your commodity hardware, stick hadoop on it and let YARN do all the hard work managing resources. However, Big Data software deployments on other substrates such as AWS (ec2 and EMR), AZURE, GCE are gaining popularity. 

We look at the challenges and a relevant solution related to deploying big data software in an OpenStack cloud.  Perhaps most interestingly, we discuss and demonstrate what it looks like to run a machine learning job with Nova-LXD in that cloud to address data locality issues in virtualized environments, and to demonstrate that hypervisor overhead does not necessarily hinder Big/Fast Data processing.

A set of benchmark jobs and routines are executed against each of three different deployment substrates using the same set of identical hardware for each scenario.

We cover:

* How to quickly and easily deploy a big data stack in an OpenStack cloud.

* How we can use Big Data tools to run a machine learning job on OpenStack logs and detect anomalies such as unusual user login location - and scaling to handle increased traffic.

* How Nova-LXD mitigates technical concerns about data-locality and hypervisor overhead in a virtualized environment.

* Spark anomoly detection.


#### Benchmarks and Jobs

1. Terasort Benchmark
2. Spark Benchmarks
3. YARN and HDFS Benchmarks
4. Anomoly Detection and Machine Learning Job

#### Deployment Toplogies

1. [Spark Hadoop Processing][1] on MAAS bare metal
2. [Spark Hadoop Processing][1] on [Ubuntu OpenStack with Nova-LXD][2] hypervisors
3. [Spark Hadoop Processing][1] on [Ubuntu OpenStack with Nova KVM][3] hypervisors


#### Software Specs

* MAAS 1.9 on on Ubuntu 14.04 Trusty
* Juju 1.25.6 on Ubuntu 16.04 Xenial
* All Big Data and OpenStack applications and services are deployed onto Ubuntu 16.04 Xenial.
* As of this writing, MAAS 2.0 was stable and released.  However, the corresponding Juju 2.0 product was in development.  Because MAAS 2.0 does not support the stable Juju 1.25.6, stable MAAS 1.9 was selected for these exercises.
* When Juju 2.0 releases, the same routines should be compatible with a MAAS 2.x and Juju 2.x combination on 16.04.


#### Hardware Specs

(12) Dell PowerEdge R610 Machines
* (1) 2.40GHz Intel Xeon CPU E5620
* 48GB 1333MHz PC3-10600 CL9 ECC DDR3 SDRAM
* (2) Seagate ST9500620NS 500GB 7200 RPM 64MB SATA 6.0Gb/s Near-line Disks
* (4) Broadcom NetXtreme II Gigabit Ethernet

One machine is dedicated to MAAS, though that could be a much lesser machine
or running within a container managed by LXD or a traditional KVM virtual
machine.  The remainder of the machines are allocated to the deployed
workloads, such that there are the same number of Apache Hadoop Slaves
present in all three scenarios.

[1]: https://github.com/ubuntu-openstack/bopenstack/blob/master/juju-bundles/spark-hadoop-processing.yaml
[2]: https://github.com/ubuntu-openstack/bopenstack/blob/master/juju-bundles/openstack-nova-lxd.yaml
[3]: https://github.com/ubuntu-openstack/bopenstack/blob/master/juju-bundles/openstack-nova-kvm.yaml

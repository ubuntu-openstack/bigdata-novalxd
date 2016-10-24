# Big Data and Machine Learning on OpenStack backed by Nova-LXD

_Andrew McLeod [irc: admcleod] and Ryan Beisner [irc: beisner] 
for OpenStack Summit Barcelona 2016_

---

![alt text][slide-sample-600]

## Overview
Hadoop was built with bare metal in mind:  get your commodity hardware, 
stick hadoop on it and let YARN do all the hard work managing resources. 
However, Big Data software deployments on other substrates such as AWS 
(ec2 and EMR), AZURE, GCE are gaining popularity. 

We look at the challenges and a relevant solution related to deploying 
big data software in an OpenStack cloud.  Perhaps most interestingly, 
we discuss and demonstrate what it looks like to run a machine learning 
job with Nova-LXD in that cloud to address data locality issues in 
virtualized environments, and to demonstrate that hypervisor overhead 
does not necessarily hinder Big/Fast Data processing.

A set of benchmark jobs and routines are executed against each of three 
different deployment substrates using the same set of identical hardware 
for each scenario.

We cover:

* How to quickly and easily deploy a big data stack in an OpenStack cloud.

* How we can use Big Data tools to run a machine learning job on OpenStack 
  logs and detect anomalies such as unusual user login location - and
  scaling to handle increased traffic.

* How Nova-LXD mitigates technical concerns about data-locality and 
  hypervisor overhead in a virtualized environment.

* Spark anomoly detection.


#### Benchmarks and Jobs

1. Terasort Benchmark: <TODO description of job>
2. Spark Benchmarks: <TODO description of job>
3. YARN and HDFS Benchmarks: <TODO description of job>
4. Anomoly Detection and Machine Learning Job: <TODO description of job>


#### Deployment Toplogies

1. [Spark Hadoop Processing][1] on [MAAS][4] bare metal
2. [Spark Hadoop Processing][1] on [Ubuntu OpenStack with Nova-LXD][2] hypervisors
3. [Spark Hadoop Processing][1] on [Ubuntu OpenStack with Nova-KVM][3] hypervisors


#### Hardware Specs

(12) Identical Dell PowerEdge R610 Machines
* (1) 2.40GHz Intel Xeon CPU E5620
* 48GB 1333MHz PC3-10600 CL9 ECC DDR3 SDRAM
* (2) Seagate ST9500620NS 500GB 7200 RPM 64MB SATA 6.0Gb/s Near-line Disks
* (4) Broadcom NetXtreme II Gigabit Ethernet

One machine is dedicated to MAAS, though that could be a much lesser machine
or run within a container managed by LXD or a traditional KVM virtual 
machine.  The remainder of the machines are allocated to the deployed
workloads, such that there are the same number of Apache Hadoop Slaves
present in all three scenarios.


#### Software Specs

* OpenStack Mitaka on Ubuntu 16.04 Xenial
* Juju 1.25.6 on Ubuntu 16.04 Xenial
* MAAS 1.9 on on Ubuntu 14.04 Trusty
* Apache Bigtop Hadoop (HDFS and YARN) 2.7.1
* Apache Bigtop Spark version 1.5.1
* TODO Any other Big Data version info
* All Big Data and OpenStack applications and services are deployed onto 
  Ubuntu 16.04 Xenial.
* OpenStack Newton was pre-RC at the time of this research and writing,
  so OpenStack Mitaka was selected.
* Also, as of this research and writing, MAAS 2.0 was released.  However,
  the corresponding Juju 2.0 product was in beta development.  Because
  MAAS 2.0 does not support the stable Juju 1.25.x, MAAS 1.9 was selected
  for these research exercises.
* When OpenStack Newton and Juju 2.0 release, the same routines should be
  compatible with a MAAS 2.x and Juju 2.x combination on 16.04, and these
  procedures can be re-visited and updated accordingly.


## Scenarios

### Pre-requisites

The following is necesary and applicable to all scenaios.

1. (11) machines are commissioned, enlisted, tagged as 'demo' and ready
   to deploy in MAAS.
2. Juju 1.25.x is installed and configured to use MAAS 1.9.x.
3. The bigdata-novalxd repo is locally cloned and is the current directory.
 - Run:

    ```sh
    git clone https://github.com/ubuntu-openstack/bigdata-novalxd
    cd bigdata-novalxd
    ```

### Spark Hadoop Processing on MAAS Bare Metal

1. Deploy Spark Hadoop Processing to bare metal with Juju, the Big Data
   Charms, and MAAS
 - Juju bundle:  [spark-hadoop-processing.yaml][1]
 - Deployment script:  [deploy-spark-on-metal.sh][10]
 - Run:

    ```sh
    tools/deploy-spark-on-metal.sh
    ```

 - Spark Processing will deploy and announce the IP info for the YARN unit.

3. Post-Deployment Routine
 - TODO: script and link to script for benchmarks and jobs


### Spark Hadoop Processing on Ubuntu OpenStack with Nova-LXD

1. Deploy Ubuntu OpenStack to bare metal with Juju, the OpenStack Charms, 
   and MAAS.
 - Juju bundle:  [openstack-nova-lxd.yaml][2]
 - Deployment script:  [deploy-openstack-nova-lxd.sh][8]
 - Run:

    ```sh
    tools/deploy-openstack-nova-lxd.sh
    ```

 - OpenStack will deploy, configure and run basic checks.

2. Deploy Spark Hadoop Processing to OpenStack with Juju and the Big
   Data Charms.
 - Juju bundle:  [spark-hadoop-processing.yaml][1]
 - Deployment script:  [deploy-spark-on-openstack.sh][11]
 - Run:

    ```sh
    tools/deploy-spark-on-openstack.sh
    ```

 - Spark Processing will deploy and announce the IP info for the YARN unit.

3. Post-Deployment Routine
 - TODO: script and link to script for benchmarks and jobs


### Spark Hadoop Processing on Ubuntu OpenStack with Nova-KVM

1. Deploy Ubuntu OpenStack to bare metal with Juju, the OpenStack Charms, 
   and MAAS.
 - Juju bundle:  [openstack-nova-kvm.yaml][3]
 - Deployment script:  [deploy-openstack-nova-kvm.sh][9]
 - Run:

    ```sh
    tools/deploy-openstack-nova-kvm.sh
    ```

 - OpenStack will deploy, configure and run a basic check.

2. Deploy Spark Hadoop Processing to OpenStack with Juju and the Big 
   Data Charms.
 - Juju bundle:  [spark-hadoop-processing.yaml][1]
 - Deployment script:  [deploy-spark-on-openstack.sh][11]
 - Run:

    ```sh
    tools/deploy-spark-on-openstack.sh
    ```

 - Spark Processing will deploy and announce the IP info for the YARN unit.

3. Post-Deployment Routine
 - TODO: script and link to script for benchmarks and jobs


## Additional Resources

The authors and developers can be found on the #openstack-charms and #juju
Freenode IRC channels.

* [Juju][5]
* [MAAS: Metal as a Service][4]
* [OpenStack Charm Development Guide][7]
* [Ubuntu Server][6]
* [Presentation/Slides from ODS Barcelona, October 2016][12]


[1]: juju-bundles/spark-hadoop-processing.yaml
[2]: juju-bundles/openstack-nova-lxd.yaml
[3]: juju-bundles/openstack-nova-kvm.yaml
[4]: http://maas.io
[5]: http://www.ubuntu.com/cloud/juju
[6]: http://www.ubuntu.com/server
[7]: http://docs.openstack.org/developer/charm-guide
[8]: tools/deploy-openstack-nova-lxd.sh
[9]: tools/deploy-openstack-nova-kvm.sh
[10]: tools/deploy-spark-on-metal.sh
[11]: tools/deploy-spark-on-openstack.sh
[12]: http://prezi.com/cvhcdlqwnsfn
[slide-sample-600]: presentation/images/slides-multi-sample-600.png "Big Data and Machine Learning on OpenStack backed by Nova-LXD - Andrew McLeod [irc: admcleod] and Ryan Beisner [irc: beisner]"

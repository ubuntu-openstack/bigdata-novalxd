#!/bin/bash -e
# Run very small terasort job
juju action do resourcemanager/0 terasort size=10000

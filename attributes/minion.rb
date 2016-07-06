#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

# Your kubernetes master fqdn OR cluster proxy
# This defaults to chef server search capabilities in kubelet.rb unless run in chef solo mode
# If you override this, set this to your master fqdn or an array containing the names of your masters:
# default['kubernetes_cluster']['master']['fqdn'] = "myclustermaster.example.com"
# ONLY statically set the master fqdn as a single master fqdn if you are not doing an HA setup"
default['kubernetes_cluster']['master']['fqdn'] = nil

default['kubernetes_cluster']['minion']['labels'] = []

# Set the ssl cert/key for ETCD client (minion to master) communication when ['kubernetes_cluster']['secure']['enabled']
default['kubernetes_cluster']['etcd']['client']['ca'] = nil
default['kubernetes_cluster']['etcd']['client']['cert'] = nil
default['kubernetes_cluster']['etcd']['client']['key'] = nil

default['kubernetes_cluster']['haproxy']['enabled'] = true
default['kubernetes_cluster']['kube-proxy']['enabled'] = true
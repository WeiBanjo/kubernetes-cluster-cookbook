#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

# Enable security
# This will tell the cookbook to make your cluster more secure
# This enables SSL certificates, enables authn/authz, and disables insecure ports
# this will make the cookbook run far more complicated- and will require a lot of
# pre-work such as manually generating SSL certificates and figuring your own way
default['kubernetes_cluster']['secure'].tap do |secure|
  secure['enabled'] = false
  secure['directory'] = '/etc/kubernetes/secrets'

  secure['admin_token_path'] = nil

  # Set the ssl ca/cert/key for ETCD peer (master to master) communication when ['kubernetes_cluster']['secure']['enabled']
  secure['data_bag_name'] = 'kubernetes'
  secure['data_bag_item'] = 'kubernetes'

  secure['peer']['item_name'] = 'peer'
  secure['peer']['ca'] = 'ca'
  secure['peer']['cert'] = 'cert'
  secure['peer']['key'] = 'key'

  # Set the ssl ca/cert/key for ETCD client (minion to master) communication when ['kubernetes_cluster']['secure']['enabled']
  secure['client']['item_name'] = 'client'
  secure['client']['ca'] = 'ca'
  secure['client']['cert'] = 'cert'
  secure['client']['key'] = 'key'

  # Port to host/access Kubernetes secure API
  secure['apiport'] = '8443'
  secure['apihost'] = '127.0.0.1'
end

# Port to host/access Kubernetes insecure API
default['kubernetes_cluster']['insecure']['apiport'] = '8080'
default['kubernetes_cluster']['insecure']['apihost'] = '127.0.0.1'

default['kubernetes_cluster']['allow_privileged'] = false
default['kubernetes_cluster']['cluster_domain'] = 'cluster.local'
default['kubernetes_cluster']['cluster_dns'] = nil

default['kubernetes_cluster']['kubelet'].tap do |kubelet|
  # Set port for Kubelet communication
  kubelet['port'] = '10250'

  # Tell kubelet to register node
  kubelet['register']['node'] = true

  # Tell kubelet to schedule pods on this node
  kubelet['register']['schedulable'] = true

  # Set pause container source in case of network connectivity issues (eg you are behind a firewall)
  kubelet['pause-source'] = nil

  # Set resources reserved for non-kubernetes components. 0 will disable system-reserved flag
  kubelet['system-reserved']['memory'] = 0
  kubelet['system-reserved']['cpu'] = 0
  kubelet['eviction'] = nil
  kubelet['feature-gates'] = nil

  kubelet['extra_args'] = []
  # Set hostname for kubelet
  kubelet['hostname'] = node['fqdn']
end

default['kubernetes_cluster']['docker']['environment'].tap do |environment|
  # Add custom docker registry- optionally insecure
  environment['docker-registry'] = nil
  environment['registry-insecure'] = nil

  # Set docker base directory for local storage- make sure this has plenty of space, optimally its own volume
  # This directory will be created if it does not exist
  environment['docker-options'] = []

  # Set docker daemon proxy settings
  environment['proxy'] = nil
  environment['no-proxy'] = nil
end

# Set optional docker registry credentials
default['kubernetes_cluster']['docker']['secure']['registry'] = nil
default['kubernetes_cluster']['docker']['secure']['secret'] = nil
default['kubernetes_cluster']['docker']['secure']['email'] = nil

# Set kubelet log level- 0 is lowest
default['kubernetes_cluster']['log']['level'] = '5'

# Package versions
default['kubernetes_cluster']['package'].tap do |package|
  package['flannel']['version'] = '>= 0.2.0'
  package['docker']['name'] = 'docker'
  package['docker']['version'] = '= 1.8.2'
  package['kubernetes_master']['version'] = '= 1.0.3'
  package['kubernetes_node']['version'] = '= 1.0.3'
  package['hyperkube']['version'] = 'v1.3.0'
  package['etcd']['version'] = '>= 2.0.0'
  package['cockpit']['enabled'] = true
  package['cockpit']['version'] = '>= 0.71'
  package['docker_registry']['version'] = '>= 0.9.1'
  package['bridge_utils']['version'] = '>= 1.5'
  package['haproxy']['version'] = '>= 1.5.4'
end

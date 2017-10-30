#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

template '/etc/kubernetes/config' do
  mode '0640'
  source 'kube-config.erb'
  variables(
    kubernetes_log_level: node['kubernetes_cluster']['log']['level'],
    kubernetes_master: node['fqdn'],
    kubernetes_api_host: node['kubernetes_cluster']['insecure']['apihost'],
    kubernetes_api_port: node['kubernetes_cluster']['insecure']['apiport'],
    kubernetes_secure_api_host: node['kubernetes_cluster']['secure']['apihost'],
    kubernetes_secure_api_port: node['kubernetes_cluster']['secure']['apiport'],
    etcd_cert_dir: node['kubernetes_cluster']['secure']['directory'],
    allow_privileged: node['kubernetes_cluster']['allow_privileged']
  )
end

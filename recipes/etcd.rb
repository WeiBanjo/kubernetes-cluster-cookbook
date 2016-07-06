#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

unless Chef::Config[:solo]
  etcdservers = []
  search(:node, 'tags:"kubernetes.master"') do |s|
    etcdservers << s[:fqdn]
  end
  node.override['kubernetes_cluster']['etcd']['members'] = etcdservers
end

service 'etcd' do
  action :enable
end

directory node['kubernetes_cluster']['etcd']['basedir'] do
  owner 'etcd'
  group 'etcd'
  recursive true
end

template '/etc/etcd/etcd.conf' do
  mode '0640'
  source 'etcd-etcd.erb'
  variables(
    etcd_client_name: node['kubernetes_cluster']['etcd']['clientname'],
    etcd_cluster_state: node['kubernetes_cluster']['etcd']['clusterstate'],
    etcd_base_dir: node['kubernetes_cluster']['etcd']['basedir'],
    etcd_client_token: node['kubernetes_cluster']['etcd']['token'],
    etcd_client_port: node['kubernetes_cluster']['etcd']['clientport'],
    etcd_peer_port: node['kubernetes_cluster']['etcd']['peerport'],
    etcd_members: node['kubernetes_cluster']['etcd']['members'],
    etcd_cert_dir: node['kubernetes_cluster']['secure']['directory'],
    etcd_bind_address: node['kubernetes_cluster']['etcd']['bind_address'],
    etcd_heartbeat_interval: node['kubernetes_cluster']['etcd']['heartbeat_interval'],
    etcd_election_timeout: node['kubernetes_cluster']['etcd']['election_timeout']
  )
  notifies :restart, 'service[etcd]', :immediately
end

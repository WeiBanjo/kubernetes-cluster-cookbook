#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

node.tag('kubernetes.minion')
node.default['kubernetes_cluster']['kubelet']['register']['node'] = true
node.default['kubernetes_cluster']['kubelet']['register']['schedulable'] = true

include_recipe 'kubernetes-cluster::default'
include_recipe 'kubernetes-cluster::proxy' if node['kubernetes_cluster']['haproxy']['enabled']

group 'kube-services' do
  members ['kube']
  action :modify
  only_if { node['kubernetes_cluster']['secure']['enabled'] }
end

if node['kubernetes_cluster']['secure']['enabled']
  data_bag = Chef::EncryptedDataBagItem.load(node['kubernetes_cluster']['secure']['data_bag_name'], node['kubernetes_cluster']['secure']['data_bag_item'])
  client_certs = data_bag[node['kubernetes_cluster']['secure']['client']['item_name']]
  client_ca = client_certs[node['kubernetes_cluster']['secure']['client']['ca']]
  client_cert = client_certs[node['kubernetes_cluster']['secure']['client']['cert']]
  client_key = client_certs[node['kubernetes_cluster']['secure']['client']['key']]

  {
    "#{node['kubernetes_cluster']['secure']['directory']}/client.ca.crt" => client_ca,
    "#{node['kubernetes_cluster']['secure']['directory']}/client.srv.crt" => client_cert,
    "#{node['kubernetes_cluster']['secure']['directory']}/client.srv.bundle.crt" => "#{client_cert}\n#{client_ca}",
    "#{node['kubernetes_cluster']['secure']['directory']}/client.srv.key" => client_key
  }.each do |filepath, contents|
    file filepath do
      content contents
      owner 'root'
      group 'kube-services'
      mode '0770'
      sensitive true
    end
  end
end

include_recipe 'kubernetes-cluster::kubernetes'
include_recipe 'kubernetes-cluster::kube-proxy' if node['kubernetes_cluster']['kube-proxy']['enabled']
include_recipe 'kubernetes-cluster::docker'
include_recipe 'kubernetes-cluster::flanneld'
include_recipe 'kubernetes-cluster::kubelet'

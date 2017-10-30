#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

# Add kube-apiserver service
template '/etc/systemd/system/kube-apiserver.service' do
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
  notifies :run, 'execute[kube-apiserver-reload]', :delayed
  notifies :restart, 'service[kube-apiserver]', :delayed
end

service 'kube-apiserver' do
  action :enable
end

execute 'kube-apiserver-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

node.default['kubernetes_cluster']['master']['fqdn'] = node['fqdn']

scheme = if node['kubernetes_cluster']['secure']['enabled']
           'https'
         else
           'http'
         end

port = node['kubernetes_cluster']['etcd']['clientport']
etcd_endpoints = node['kubernetes_cluster']['etcd']['clienthosts'].collect { |host| "#{scheme}://#{host}:#{port}" }.sort

template '/etc/kubernetes/etcd.client.conf' do
  mode '0644'
  source 'kube-apiserver-etcd.erb'
  variables(
    etcd_cert_dir: node['kubernetes_cluster']['secure']['directory'],
    kubernetes_master: node['kubernetes_cluster']['master']['fqdn'],
    etcd_endpoints: '"' + etcd_endpoints.join('", "') + '"'
  )
  only_if { node['kubernetes_cluster']['secure']['enabled'] }
end

kubernetes_api_args = node['kubernetes_cluster']['api']['args'].collect { |key, value| "#{key}=#{value}" }

template '/etc/kubernetes/apiserver' do
  mode '0640'
  source 'kube-apiserver.erb'
  variables(
    etcd_endpoints: etcd_endpoints.join(','),
    kubernetes_api_port: node['kubernetes_cluster']['insecure']['apiport'],
    kubernetes_secure_api_port: node['kubernetes_cluster']['secure']['apiport'],
    kubernetes_master: node['kubernetes_cluster']['master']['fqdn'],
    kubernetes_network: node['kubernetes_cluster']['master']['service-network'],
    kubelet_port: node['kubernetes_cluster']['kubelet']['port'],
    etcd_cert_dir: node['kubernetes_cluster']['secure']['directory'],
    kubernetes_api_args: kubernetes_api_args.join(' ')
  )
  notifies :restart, 'service[kube-apiserver]', :delayed
end

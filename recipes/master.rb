#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

node.tag('kubernetes.master')

include_recipe 'kubernetes-cluster::default'

case node['platform']
  when 'redhat', 'centos', 'fedora'
    yum_package "cockpit #{node['kubernetes_cluster']['package']['cockpit']['version']}" do
      only_if { node['kubernetes_cluster']['package']['cockpit']['enabled'] }
    end
    yum_package "etcd #{node['kubernetes_cluster']['package']['etcd']['version']}"
    yum_package "kubernetes-master #{node['kubernetes_cluster']['package']['kubernetes_master']['version']}"
end

group 'kube-services' do
  members %w(etcd kube)
  action :modify
end

directory '/etc/kubernetes/inactive-manifests' do
  owner 'root'
  group 'kube-services'
  mode '0770'
end

directory '/etc/kubernetes/manifests' do
  owner 'root'
  group 'kube-services'
  mode '0770'
end

if node['kubernetes_cluster']['secure']['enabled']
  data_bag = Chef::EncryptedDataBagItem.load(node['kubernetes_cluster']['secure']['data_bag_name'], node['kubernetes_cluster']['secure']['data_bag_item'])
  client_certs = data_bag[node['kubernetes_cluster']['secure']['client']['item_name']]
  client_ca = client_certs[node['kubernetes_cluster']['secure']['client']['ca']]
  client_cert = client_certs[node['kubernetes_cluster']['secure']['client']['cert']]
  client_key = client_certs[node['kubernetes_cluster']['secure']['client']['key']]

  peer_certs = data_bag[node['kubernetes_cluster']['secure']['peer']['item_name']]
  peer_ca = peer_certs[node['kubernetes_cluster']['secure']['peer']['ca']]
  peer_cert = peer_certs[node['kubernetes_cluster']['secure']['peer']['cert']]
  peer_key = peer_certs[node['kubernetes_cluster']['secure']['peer']['key']]

  file 'kubernetes::master[client.ca.crt]' do
    path "#{node['kubernetes_cluster']['secure']['directory']}/client.ca.crt"
    content client_ca
    owner 'root'
    group 'kube-services'
    mode '0770'
    sensitive true
  end
  file "#{node['kubernetes_cluster']['secure']['directory']}/client.srv.crt" do
    content client_cert
    owner 'root'
    group 'kube-services'
    mode '0770'
    sensitive true
  end
  file "#{node['kubernetes_cluster']['secure']['directory']}/client.srv.key" do
    content client_key
    owner 'root'
    group 'kube-services'
    mode '0770'
    sensitive true
  end

  file "#{node['kubernetes_cluster']['secure']['directory']}/client.srv.bundle.crt" do
    content "#{client_cert}\n#{client_ca}"
    owner 'root'
    group 'kube-services'
    mode '0770'
    sensitive true
  end

  file "#{node['kubernetes_cluster']['secure']['directory']}/peer.ca.crt" do
    content peer_ca
    owner 'root'
    group 'kube-services'
    mode '0770'
    sensitive true
  end
  file "#{node['kubernetes_cluster']['secure']['directory']}/peer.srv.crt" do
    content peer_cert
    owner 'root'
    group 'kube-services'
    mode '0770'
    sensitive true
  end
  file "#{node['kubernetes_cluster']['secure']['directory']}/peer.srv.key" do
    content peer_key
    owner 'root'
    group 'kube-services'
    mode '0770'
    sensitive true
  end
end

node['kubernetes_cluster']['master']['enabled_recipes'].each do |recipe|
  include_recipe "kubernetes-cluster::#{recipe}"
end

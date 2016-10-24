#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

# Add kubelet.service
template '/etc/systemd/system/kubelet.service' do
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
  notifies :run, 'execute[kubelet-reload]', :delayed
  notifies :restart, 'service[kubelet]', :delayed
end

execute 'kubelet-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service 'kubelet' do
  action :enable
end

kubernetes_api_host = if node['kubernetes_cluster']['secure']['enabled']
                        node['kubernetes_cluster']['secure']['apihost']
                      else
                        node['kubernetes_cluster']['insecure']['apihost']
                      end

kubernetes_api_port = if node['kubernetes_cluster']['secure']['enabled']
                        node['kubernetes_cluster']['secure']['apiport']
                      else
                        node['kubernetes_cluster']['insecure']['apiport']
                      end

kubernetes_admin_token = nil
admin_token_path = node['kubernetes_cluster']['secure']['admin_token_path']
if admin_token_path && File.exist?(admin_token_path)
  kubernetes_admin_token = File.read(admin_token_path)
end

template "#{node['kubernetes_cluster']['secure']['directory']}/kube.config" do
  mode '770'
  group 'kube-services'
  source 'kube-kubelet-kube-config.erb'
  variables(
    kubernetes_admin_token: kubernetes_admin_token,
    kubernetes_api_host: kubernetes_api_host,
    kubernetes_api_port: kubernetes_api_port,
    etcd_cert_dir: node['kubernetes_cluster']['secure']['directory']
  )
  only_if { node['kubernetes_cluster']['secure']['enabled'] }
end

kubelet_args = [
  '--config=/etc/kubernetes/manifests',
  "--register-node=#{node['kubernetes_cluster']['kubelet']['register']['node']}",
  "--register-schedulable=#{node['kubernetes_cluster']['kubelet']['register']['schedulable']}",
]

if node['kubernetes_cluster']['secure']['enabled']
  kubelet_args << "--kubeconfig=#{node['kubernetes_cluster']['secure']['directory']}/kube.config"
  kubelet_args << "--tls-cert-file=#{node['kubernetes_cluster']['secure']['directory']}/client.srv.bundle.crt"
  kubelet_args << "--tls-private-key-file=#{node['kubernetes_cluster']['secure']['directory']}/client.srv.key"
end

if node['kubernetes_cluster']['kubelet']['system-reserved']['memory'] > 0 && node['kubernetes_cluster']['kubelet']['system-reserved']['cpu'] > 0
  reserved_cpu_units = node['cpu']['total'].to_i * 1000 * node['kubernetes_cluster']['kubelet']['system-reserved']['cpu']
  reserved_memory_units = node['memory']['total'].to_i * node['kubernetes_cluster']['kubelet']['system-reserved']['memory'] / 1024
  kubelet_args << "--system-reserved=cpu=#{reserved_cpu_units.to_i}m,memory=#{reserved_memory_units.to_i}M"
end

if node['kubernetes_cluster']['kubelet']['eviction']
  if node['kubernetes_cluster']['kubelet']['eviction']['hard']
    kubelet_args << "--eviction-hard #{node['kubernetes_cluster']['kubelet']['eviction']['hard']}"
  end
  if node['kubernetes_cluster']['kubelet']['eviction']['soft']
    kubelet_args << "--eviction-hard #{node['kubernetes_cluster']['kubelet']['eviction']['hard']}"
  end
  if node['kubernetes_cluster']['kubelet']['eviction']['minimum-reclaim']
    kubelet_args << "--eviction-minimum-reclaim #{node['kubernetes_cluster']['kubelet']['eviction']['minimum-reclaim']}"
  end
end

if node['kubernetes_cluster']['kubelet']['feature-gates']
  kubelet_args << "--feature-gates #{node['kubernetes_cluster']['kubelet']['feature-gates'].join(',')}"
end

kubelet_args << "--pod-infra-container-image=#{node['kubernetes_cluster']['kubelet']['pause-source']}" if node['kubernetes_cluster']['kubelet']['pause-source']
kubelet_args << "--cluster-dns=#{node['kubernetes_cluster']['cluster_dns']} --cluster-domain=#{node['kubernetes_cluster']['cluster_domain']}" if node['kubernetes_cluster']['cluster_dns']
kubelet_args << "--node-labels=#{node['kubernetes_cluster']['minion']['labels'].join(' ')}" if node['kubernetes_cluster']['minion']['labels'] and not node['kubernetes_cluster']['minion']['labels'].empty?
kubelet_args << node['kubernetes_cluster']['kubelet']['extra_args'].join(' ') if node['kubernetes_cluster']['kubelet']['extra_args'] and not node['kubernetes_cluster']['kubelet']['extra_args'].empty?

template '/etc/kubernetes/kubelet' do
  mode '0640'
  source 'kube-kubelet.erb'
  variables(
    kubelet_hostname: node['kubernetes_cluster']['kubelet']['hostname'],
    kubernetes_api_port: node['kubernetes_cluster']['insecure']['apiport'],
    kubernetes_api_host: node['kubernetes_cluster']['insecure']['apihost'],
    kubernetes_secure_api_port: node['kubernetes_cluster']['secure']['apiport'],
    kubernetes_secure_api_host: node['kubernetes_cluster']['secure']['apihost'],
    kubelet_args: kubelet_args.join(' ')
  )
  notifies :restart, 'service[kubelet]', :delayed
end
